import Foundation
import Combine
import DashKit
import BitcoinCore
import HsToolKit
import HdWalletKit

class DashAdapter: BaseAdapter {
    override var feeRate: Int { return 1 }
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

    public func transactionsUpdated(inserted: [DashTransactionInfo], updated: [DashTransactionInfo]) {
        transactionsSubject.send()
    }

    func transactionsDeleted(hashes: [String]) {
        transactionsSubject.send()
    }

    func balanceUpdated(balance: BalanceInfo) {
        balanceSubject.send()
    }

    func lastBlockInfoUpdated(lastBlockInfo: BlockInfo) {
        lastBlockSubject.send()
    }

    public func kitStateUpdated(state: BitcoinCore.KitState) {
        syncStateSubject.send()
    }

}
