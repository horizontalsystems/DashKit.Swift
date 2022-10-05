import Foundation
import X11Kit
import BitcoinCore

class X11Hasher: IDashHasher, IHasher {

    func hash(data: Data) -> Data {
        X11Kit.x11(data)
    }

}
