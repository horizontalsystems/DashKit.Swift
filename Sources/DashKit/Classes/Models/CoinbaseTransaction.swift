import BitcoinCore
import Foundation
import HsExtensions

struct CoinbaseTransaction {
    private let coinbasePayloadSize = 70 // additional size of coinbase v2 parameters
    let transaction: FullTransaction
    let coinbaseTransactionSize: Data
    let version: UInt16
    let height: UInt32
    let merkleRootMNList: Data
    let merkleRootQuorums: Data?
    var bestCLHeightDiff: Data? = nil
    var bestCLSignature: Data? = nil
    var creditPoolBalance: Data? = nil

    init(transaction: FullTransaction, coinbaseTransactionSize: Data, version: UInt16, height: UInt32, merkleRootMNList: Data, merkleRootQuorums: Data? = nil, bestCLHeightDiff: Data?, bestCLSignature: Data?, creditPoolBalance: Data?) {
        self.transaction = transaction
        self.coinbaseTransactionSize = coinbaseTransactionSize
        self.version = version
        self.height = height
        self.merkleRootMNList = merkleRootMNList
        self.merkleRootQuorums = merkleRootQuorums
        self.bestCLHeightDiff = bestCLHeightDiff
        self.bestCLSignature = bestCLSignature
        self.creditPoolBalance = creditPoolBalance
    }

    init(byteStream: ByteStream) {
        transaction = TransactionSerializer.deserialize(byteStream: byteStream)
        let size = byteStream.read(VarInt.self)
        coinbaseTransactionSize = size.data
        version = byteStream.read(UInt16.self)
        height = byteStream.read(UInt32.self)
        merkleRootMNList = byteStream.read(Data.self, count: 32)
        merkleRootQuorums = version >= 2 ? byteStream.read(Data.self, count: 32) : nil

        if (version >= 3) {
            let bestCLHeightDiffSize = byteStream.read(VarInt.self)
            bestCLHeightDiff = bestCLHeightDiffSize.data

            bestCLSignature = byteStream.read(Data.self, count: 96)
            creditPoolBalance = byteStream.read(Data.self, count: 8)
        }

//        let needToRead = Int(size.underlyingValue) - coinbasePayloadSize
//        if needToRead > 0 {
//            _ = byteStream.read(Data.self, count: needToRead)
//        }
    }
}
