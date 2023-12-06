import BitcoinCore
import Foundation
import HsExtensions

struct TransactionLockMessage: IMessage {
    let transaction: FullTransaction

    var description: String {
        "\(transaction.header.dataHash.hs.reversedHex)"
    }
}
