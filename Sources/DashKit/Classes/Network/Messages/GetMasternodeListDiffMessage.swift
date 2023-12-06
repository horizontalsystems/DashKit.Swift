import BitcoinCore
import Foundation

struct GetMasternodeListDiffMessage: IMessage { // "getmnlistd"
    let baseBlockHash: Data
    let blockHash: Data

    var description: String {
        "\(baseBlockHash) \(blockHash)"
    }
}
