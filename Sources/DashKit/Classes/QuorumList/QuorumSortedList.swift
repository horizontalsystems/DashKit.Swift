import Foundation

class QuorumSortedList: IQuorumSortedList {
    private var quorumSet = Set<Quorum>()

    var quorums: [Quorum] { quorumSet.sorted()
    }

    func add(quorums: [Quorum]) {
        quorumSet = Set(quorums).union(quorumSet)
    }

    func remove(quorums: [Quorum]) {
        quorumSet.subtract(Set(quorums))
    }

    func remove(by pairs: [(type: UInt8, quorumHash: Data)]) {
        for (type, quorumHash) in pairs {
            if let index = quorumSet.firstIndex(where: { $0.type == type && $0.quorumHash == quorumHash }) {
                quorumSet.remove(at: index)
            }
        }
    }

    func removeAll() {
        quorumSet.removeAll()
    }
}
