import BitcoinCore
import Foundation

class CoinbaseTransactionSerializer: ICoinbaseTransactionSerializer {
    func serialize(coinbaseTransaction: CoinbaseTransaction) -> Data {
        var data = Data()

        data += TransactionSerializer.serialize(transaction: coinbaseTransaction.transaction)
        data += coinbaseTransaction.coinbaseTransactionSize
        data += Data(from: coinbaseTransaction.version)
        data += Data(from: coinbaseTransaction.height)
        data += coinbaseTransaction.merkleRootMNList

        if let merkleRootQuorums = coinbaseTransaction.merkleRootQuorums {
            data += merkleRootQuorums
        }

        if let bestCLHeightDiff = coinbaseTransaction.bestCLHeightDiff {
            data += bestCLHeightDiff
        }
        if let bestCLSignature = coinbaseTransaction.bestCLSignature {
            data += bestCLSignature
        }
        if let creditPoolBalance = coinbaseTransaction.creditPoolBalance {
            data += creditPoolBalance
        }

        return data
    }
}
