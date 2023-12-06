import BitcoinCore
import Foundation

class PeerTaskFactory: IPeerTaskFactory {
    func createRequestMasternodeListDiffTask(baseBlockHash: Data, blockHash: Data) -> PeerTask {
        RequestMasternodeListDiffTask(baseBlockHash: baseBlockHash, blockHash: blockHash)
    }
}
