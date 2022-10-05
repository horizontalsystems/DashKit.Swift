import Foundation
import BitcoinCore
import HsExtensions

struct TransactionLockMessage: IMessage {

    let transaction: FullTransaction

    var description: String {
        return "\(transaction.header.dataHash.hs.reversedHex)"
    }

}
