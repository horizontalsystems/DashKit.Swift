import BitcoinCore
import Foundation

struct ISLockMessage: IMessage {
    let command: String = "islock"

    let inputs: [Outpoint]
    let txHash: Data
    let sign: Data
    let hash: Data

    let requestID: Data

    var description: String {
        "\(txHash) - \(inputs.count) inputs locked"
    }
}

extension ISLockMessage: Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(hash)
    }

    public static func == (lhs: ISLockMessage, rhs: ISLockMessage) -> Bool {
        lhs.hash == rhs.hash && lhs.sign == rhs.sign
    }
}
