import BitcoinCore
import Foundation

class QuorumListMerkleRootCalculator: IQuorumListMerkleRootCalculator {
    private let merkleRootCreator: IMerkleRootCreator

    init(merkleRootCreator: IMerkleRootCreator, quorumHasher _: IDashHasher) {
        self.merkleRootCreator = merkleRootCreator
    }

    func calculateMerkleRoot(sortedQuorums: [Quorum]) -> Data? {
        merkleRootCreator.create(hashes: sortedQuorums.map(\.dataHash))
    }
}
