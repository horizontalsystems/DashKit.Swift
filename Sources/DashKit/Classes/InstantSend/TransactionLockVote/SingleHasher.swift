import Foundation
import HsCryptoKit
import BitcoinCore

class SingleHasher: IDashHasher {

    func hash(data: Data) -> Data {
        Crypto.sha256(data)
    }

}
