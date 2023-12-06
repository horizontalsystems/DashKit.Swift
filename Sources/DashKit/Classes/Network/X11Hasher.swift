import BitcoinCore
import Foundation
import X11Kit

class X11Hasher: IDashHasher, IHasher {
    func hash(data: Data) -> Data {
        X11Kit.x11(data)
    }
}
