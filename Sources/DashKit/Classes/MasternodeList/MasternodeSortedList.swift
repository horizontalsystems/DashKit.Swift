import Foundation

class MasternodeSortedList: IMasternodeSortedList {
    private var masternodeSet = Set<Masternode>()

    var masternodes: [Masternode] { masternodeSet.sorted()
    }

    func add(masternodes: [Masternode]) {
        masternodeSet = Set(masternodes).union(masternodeSet)
    }

    func remove(masternodes: [Masternode]) {
        masternodeSet.subtract(Set(masternodes))
    }

    func remove(by proRegTxHashes: [Data]) {
        for hash in proRegTxHashes {
            if let index = masternodeSet.firstIndex(where: { $0.proRegTxHash == hash }) {
                masternodeSet.remove(at: index)
            }
        }
    }

    func removeAll() {
        masternodeSet.removeAll()
    }
}
