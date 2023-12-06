import BitcoinCore
import Foundation
import HsCryptoKit

class SingleHasher: IDashHasher {
    func hash(data: Data) -> Data {
        Crypto.sha256(data)
    }
}
