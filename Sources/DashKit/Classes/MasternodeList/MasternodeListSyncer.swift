import Foundation
import Combine
import BitcoinCore

class MasternodeListSyncer: IMasternodeListSyncer {
    private var cancellables = Set<AnyCancellable>()
    private weak var bitcoinCore: BitcoinCore?
    private let initialBlockDownload: IInitialBlockDownload
    private let peerTaskFactory: IPeerTaskFactory
    private let masternodeListManager: IMasternodeListManager

    private var workingPeer: IPeer? = nil
    private let queue: DispatchQueue

    init(bitcoinCore: BitcoinCore, initialBlockDownload: IInitialBlockDownload, peerTaskFactory: IPeerTaskFactory, masternodeListManager: IMasternodeListManager,
         queue: DispatchQueue = DispatchQueue(label: "io.horizontalsystems.dash-kit.masternode-list-syncer", qos: .background)) {
        self.bitcoinCore = bitcoinCore
        self.initialBlockDownload = initialBlockDownload
        self.peerTaskFactory = peerTaskFactory
        self.masternodeListManager = masternodeListManager
        self.queue = queue
    }

    private func assignNextSyncPeer() {
        queue.async {
            guard self.workingPeer == nil,
                  let lastBlockInfo = self.bitcoinCore?.lastBlockInfo,
                  let syncedPeer = self.initialBlockDownload.syncedPeers.first,
                  let blockHash = lastBlockInfo.headerHash.reversedData else {
                return
            }

            let baseBlockHash = self.masternodeListManager.baseBlockHash

            if (blockHash != baseBlockHash) {
                let task = self.peerTaskFactory.createRequestMasternodeListDiffTask(baseBlockHash: baseBlockHash, blockHash: blockHash)
                syncedPeer.add(task: task)

                self.workingPeer = syncedPeer
            }
        }
    }

    func subscribeTo(publisher: AnyPublisher<PeerGroupEvent, Never>) {
        publisher
                .sink { [weak self] event in
                    switch event {
                    case .onPeerDisconnect(let peer, let error): self?.onPeerDisconnect(peer: peer, error: error)
                    default: ()
                    }
                }
                .store(in: &cancellables)
    }

    func subscribeTo(publisher: AnyPublisher<InitialBlockDownloadEvent, Never>) {
        publisher
                .sink { [weak self] event in
                    switch event {
                    case .onPeerSynced(let peer): self?.onPeerSynced(peer: peer)
                    default: ()
                    }
                }
                .store(in: &cancellables)
    }
}

extension MasternodeListSyncer {

    private func onPeerSynced(peer: IPeer) {
        assignNextSyncPeer()
    }

}

extension MasternodeListSyncer {

    private func onPeerDisconnect(peer: IPeer, error: Error?) {
        if peer.equalTo(workingPeer) {
            workingPeer = nil

            assignNextSyncPeer()
        }
    }

}

extension MasternodeListSyncer: IPeerTaskHandler {

    func handleCompletedTask(peer: IPeer, task: PeerTask) -> Bool {
        switch task {
        case let listDiffTask as RequestMasternodeListDiffTask:
            if let message = listDiffTask.masternodeListDiffMessage {
                do {
                    try masternodeListManager.updateList(masternodeListDiffMessage: message)
                    workingPeer = nil
                } catch {
                    peer.disconnect(error: error)
                }
            }
            return true
        default: return false
        }
    }

}
