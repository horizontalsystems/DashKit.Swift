# DashKit.Swift

`DashKit.Swift` is a package that extends [BitcoinCore.Swift](https://github.com/horizontalsystems/BitcoinCore.Swift) and makes it usable with `Dash` Mainnet and Testnet networks.

## Features

- [x] Instant send
- [x] LLMQ lock, Masternodes validation

## Usage

Because Dash uses a fork of Bitcoin's source code, the usage of this package does not differ much from `BitcoinKit.Swift`. So here, we only describe some differences between these packages. For more usage documentation, please see [BitcoinKit.Swift](https://github.com/horizontalsystems/BitcoinKit.Swift)


### Initialization

```swift
import HdWalletKit
import DashKit
        
let seed = Mnemonic.seed(mnemonic: [""], passphrase: "")!

let dashKit = try DashKit.Kit(
    seed: seed,
    walletId: "unique_wallet_id",
    syncMode: BitcoinCore.SyncMode.full,
    networkType: DashKit.Kit.NetworkType.mainNet,
    confirmationsThreshold: 3,
    logger: nil
)
```

### DashTransactionInfo

Dash has some transactions marked `instant`. So, instead of `TransactionInfo` object *DashKit.Kit* works with `DashTransactionInfo`, that has that field and a respective `DashKitDelegate` delegate class.


## Prerequisites

* Xcode 10.0+
* Swift 5+
* iOS 13+

## Installation

### Swift Package Manager

```swift
dependencies: [
    .package(url: "https://github.com/horizontalsystems/DashKit.Swift.git", .upToNextMajor(from: "1.0.0"))
]
```

## Example Project

All features of the library are used in example project. It can be referred as a starting point for usage of the library.

## License

The `DashKit` toolkit is open source and available under the terms of the [MIT License](https://github.com/horizontalsystems/DashKit.Swift/blob/master/LICENSE).

