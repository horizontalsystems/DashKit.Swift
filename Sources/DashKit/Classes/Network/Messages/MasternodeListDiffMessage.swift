import BitcoinCore
import Foundation

struct MasternodeListDiffMessage: IMessage {
    let baseBlockHash: Data
    let blockHash: Data
    let totalTransactions: UInt32
    let merkleHashesCount: UInt32
    let merkleHashes: [Data]
    let merkleFlagsCount: UInt32
    let merkleFlags: Data
    let cbTx: CoinbaseTransaction
    let nVersion: UInt16
    let deletedMNsCount: UInt32
    let deletedMNs: [Data]
    let mnListCount: UInt32
    let mnList: [Masternode]
    let deletedQuorums: [(type: UInt8, quorumHash: Data)]
    let quorumList: [Quorum]

    var description: String {
        "\(baseBlockHash) \(blockHash)"
    }
}
