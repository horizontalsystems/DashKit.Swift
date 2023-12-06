import BitcoinCore
import Combine
import DashKit
import Foundation
import HdWalletKit
import HsToolKit

class DashAdapter: BaseAdapter {
    override var feeRate: Int { 1 }
    private let dashKit: Kit

    init(words: [String], testMode: Bool, syncMode: BitcoinCore.SyncMode, logger: Logger) {
        let networkType: Kit.NetworkType = testMode ? .testNet : .mainNet
        let seed = Mnemonic.seed(mnemonic: words)
        dashKit = try! Kit(seed: seed ?? Data(), walletId: "walletId", syncMode: syncMode, networkType: networkType, logger: logger.scoped(with: "DashKit"))

        super.init(name: "Dash", coinCode: "DASH", abstractKit: dashKit)
        dashKit.delegate = self
    }

    override func transactions(fromUid: String?, type: TransactionFilterType? = nil, limit: Int) -> [TransactionRecord] {
        dashKit.transactions(fromUid: fromUid, type: type, limit: limit)
            .compactMap {
                transactionRecord(fromTransaction: $0)
            }
    }

    private func transactionRecord(fromTransaction transaction: DashTransactionInfo) -> TransactionRecord {
        var record = transactionRecord(fromTransaction: transaction as TransactionInfo)
        if transaction.instantTx {
            record.transactionExtraType = "Instant"
        }

        return record
    }

    class func clear() {
        try? Kit.clear()
    }
}

extension DashAdapter: DashKitDelegate {
    public func transactionsUpdated(inserted _: [DashTransactionInfo], updated _: [DashTransactionInfo]) {
        transactionsSubject.send()
    }

    func transactionsDeleted(hashes _: [String]) {
        transactionsSubject.send()
    }

    func balanceUpdated(balance _: BalanceInfo) {
        balanceSubject.send()
    }

    func lastBlockInfoUpdated(lastBlockInfo _: BlockInfo) {
        lastBlockSubject.send()
    }

    public func kitStateUpdated(state _: BitcoinCore.KitState) {
        syncStateSubject.send()
    }
}
