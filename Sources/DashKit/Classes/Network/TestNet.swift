import BitcoinCore

class TestNet: INetwork {
    let protocolVersion: Int32 = 70214

    let bundleName = "Dash"

    let maxBlockSize: UInt32 = 1_000_000_000
    let pubKeyHash: UInt8 = 0x8C
    let privateKey: UInt8 = 0x80
    let scriptHash: UInt8 = 0x13
    let bech32PrefixPattern: String = "bc"
    let xPubKey: UInt32 = 0x0488_B21E
    let xPrivKey: UInt32 = 0x0488_ADE4
    let magic: UInt32 = 0xCEE2_CAFF
    let port = 19999
    let coinType: UInt32 = 1
    let sigHash: SigHashType = .bitcoinAll
    var syncableFromApi: Bool = true
    var blockchairChainId: String = ""

    let dnsSeeds = [
        "testnet-seed.dashdot.io",
        "test.dnsseed.masternode.io",
    ]

    let dustRelayTxFee = 1000 // https://github.com/dashpay/dash/blob/master/src/policy/policy.h#L36
}
