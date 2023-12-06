import BitcoinCore
import Foundation

class GetMasternodeListDiffMessageSerializer: IMessageSerializer {
    var id: String { "getmnlistd" }

    func serialize(message: IMessage) -> Data? {
        guard let message = message as? GetMasternodeListDiffMessage else {
            return nil
        }

        return message.baseBlockHash + message.blockHash
    }
}
