import Foundation

class MasternodeSerializer: IMasternodeSerializer {
    func serialize(masternode: Masternode) -> Data {
        var data = Data()
//        data += Data(from: masternode.nVersion)   // version must be ignore when validating hash
        data += masternode.proRegTxHash
        data += masternode.confirmedHash
        data += masternode.ipAddress
        data += Data(from: masternode.port)

        data += masternode.pubKeyOperator
        data += masternode.keyIDVoting
        data += Data([masternode.isValid ? 0x01 : 0x00])

        if let type = masternode.type {
            data += Data(from: type)
        }
        if let platformHTTPPort = masternode.platformHTTPPort {
            data += Data(from: platformHTTPPort)
        }
        if let platformNodeID = masternode.platformNodeID {
            data += platformNodeID
        }

        return data
    }
}
