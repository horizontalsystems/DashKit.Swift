import RxSwift

class TransactionProcessor {
    private let storage: IStorage
    private let outputExtractor: ITransactionExtractor
    private let inputExtractor: ITransactionExtractor
    private let outputAddressExtractor: ITransactionOutputAddressExtractor
    private let outputsCache: IOutputsCache
    private let publicKeyManager: IPublicKeyManager
    private let irregularOutputFinder: IIrregularOutputFinder
    private let transactionInfoConverter: ITransactionInfoConverter
    private let transactionMediator: ITransactionMediator

    weak var listener: IBlockchainDataListener?
    weak var transactionListener: ITransactionListener?

    private let dateGenerator: () -> Date
    private let queue: DispatchQueue

    init(storage: IStorage, outputExtractor: ITransactionExtractor, inputExtractor: ITransactionExtractor, outputsCache: IOutputsCache,
         outputAddressExtractor: ITransactionOutputAddressExtractor, addressManager: IPublicKeyManager, irregularOutputFinder: IIrregularOutputFinder,
         transactionInfoConverter: ITransactionInfoConverter, transactionMediator: ITransactionMediator,
         listener: IBlockchainDataListener? = nil, dateGenerator: @escaping () -> Date = Date.init, queue: DispatchQueue = DispatchQueue(label: "io.horizontalsystems.bitcoin-core.transaction-processor", qos: .background
    )) {
        self.storage = storage
        self.outputExtractor = outputExtractor
        self.inputExtractor = inputExtractor
        self.outputAddressExtractor = outputAddressExtractor
        self.outputsCache = outputsCache
        self.publicKeyManager = addressManager
        self.irregularOutputFinder = irregularOutputFinder
        self.transactionInfoConverter = transactionInfoConverter
        self.transactionMediator = transactionMediator
        self.listener = listener
        self.dateGenerator = dateGenerator
        self.queue = queue
    }

    private func process(transaction: FullTransaction) {
        outputExtractor.extract(transaction: transaction)
        if outputsCache.hasOutputs(forInputs: transaction.inputs) {
            transaction.header.isMine = true
            transaction.header.isOutgoing = true
        }

        guard transaction.header.isMine else {
            return
        }
        outputsCache.add(fromOutputs: transaction.outputs)
        outputAddressExtractor.extractOutputAddresses(transaction: transaction)
        inputExtractor.extract(transaction: transaction)
    }

    private func relay(transaction: Transaction, withOrder order: Int, inBlock block: Block?) {
        transaction.blockHash = block?.headerHash
        transaction.status = .relayed
        transaction.timestamp = block?.timestamp ?? Int(dateGenerator().timeIntervalSince1970)
        transaction.order = order

        if let block = block, !block.hasTransactions {
            block.hasTransactions = true
            storage.update(block: block)
        }
    }

}

extension TransactionProcessor: ITransactionProcessor {

    func processReceived(transactions: [FullTransaction], inBlock block: Block?, skipCheckBloomFilter: Bool) throws {
        var needToUpdateBloomFilter = false

        var updated = [Transaction]()
        var inserted = [Transaction]()

        try queue.sync {
            for (index, transaction) in transactions.inTopologicalOrder().enumerated() {
                if let existingTransaction = self.storage.transaction(byHash: transaction.header.dataHash) {
                    if existingTransaction.blockHash != nil && block == nil {
                        continue
                    }
                    self.relay(transaction: existingTransaction, withOrder: index, inBlock: block)

                    if block != nil {
                        existingTransaction.conflictingTxHash = nil
                    }
                    try self.storage.update(transaction: existingTransaction)
                    updated.append(existingTransaction)

                    continue
                }

                self.process(transaction: transaction)
                self.transactionListener?.onReceive(transaction: transaction)

                if transaction.header.isMine {
                    self.relay(transaction: transaction.header, withOrder: index, inBlock: block)

                    let conflictingTransactions = storage.conflictingTransactions(for: transaction)

                    let resolution = transactionMediator.resolve(receivedTransaction: transaction, conflictingTransactions: conflictingTransactions)
                    switch resolution {
                    case .ignore:
                        try conflictingTransactions.forEach {
                            try storage.update(transaction: $0)
                        }
                        updated.append(contentsOf: conflictingTransactions)

                    case .accept:
                        conflictingTransactions.forEach {
                            processInvalid(transactionHash: $0.dataHash)
                        }

                        try self.storage.add(transaction: transaction)
                        inserted.append(transaction.header)
                    }

                    if !skipCheckBloomFilter {
                        needToUpdateBloomFilter = needToUpdateBloomFilter || self.publicKeyManager.gapShifts() || self.irregularOutputFinder.hasIrregularOutput(outputs: transaction.outputs)
                    }
                }
            }
        }

        if !updated.isEmpty || !inserted.isEmpty {
            listener?.onUpdate(updated: updated, inserted: inserted, inBlock: block)
        }

        if needToUpdateBloomFilter {
            throw BloomFilterManager.BloomFilterExpired()
        }
    }

    func processCreated(transaction: FullTransaction) throws {
        guard storage.transaction(byHash: transaction.header.dataHash) == nil else {
            throw TransactionCreator.CreationError.transactionAlreadyExists
        }

        process(transaction: transaction)
        try storage.add(transaction: transaction)
        listener?.onUpdate(updated: [], inserted: [transaction.header], inBlock: nil)

        if irregularOutputFinder.hasIrregularOutput(outputs: transaction.outputs) {
            throw BloomFilterManager.BloomFilterExpired()
        }
    }

    public func processInvalid(transactionHash: Data) {
        let invalidTransactionsFullInfo = descendantTransactionsFullInfo(of: transactionHash)

        guard !invalidTransactionsFullInfo.isEmpty else {
            return
        }

        invalidTransactionsFullInfo.forEach { $0.transactionWithBlock.transaction.status = .invalid }

        let invalidTransactions: [InvalidTransaction] = invalidTransactionsFullInfo.map { transactionFullInfo in
            let transactionInfo = transactionInfoConverter.transactionInfo(fromTransaction: transactionFullInfo)
            var transactionInfoJson = Data()
            if let jsonData = try? JSONEncoder.init().encode(transactionInfo) {
                transactionInfoJson = jsonData
            }

            let transaction = transactionFullInfo.transactionWithBlock.transaction

            return InvalidTransaction(
                    uid: transaction.uid, dataHash: transaction.dataHash, version: transaction.version, lockTime: transaction.lockTime, timestamp: transaction.timestamp,
                    order: transaction.order, blockHash: transaction.blockHash, isMine: transaction.isMine, isOutgoing: transaction.isOutgoing,
                    status: transaction.status, segWit: transaction.segWit, conflictingTxHash: transaction.conflictingTxHash, transactionInfoJson: transactionInfoJson
            )
        }


        try? storage.moveTransactionsTo(invalidTransactions: invalidTransactions)
        listener?.onUpdate(updated: invalidTransactions, inserted: [], inBlock: nil)
    }

    private func descendantTransactionsFullInfo(of transactionHash: Data) -> [FullTransactionForInfo] {
        guard let fullTransactionInfo = storage.transactionFullInfo(byHash: transactionHash) else {
            return []
        }

        return storage
                .inputsUsingOutputs(withTransactionHash: transactionHash)
                .reduce(into: [fullTransactionInfo]) { list, input in
                    list.append(contentsOf: descendantTransactionsFullInfo(of: input.transactionHash))
                }
    }

}