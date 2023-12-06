@testable import BitcoinCore
@testable import DashKit
import XCTest

extension XCTestCase {
    func waitForMainQueue(queue: DispatchQueue = DispatchQueue.main) {
        let e = expectation(description: "Wait for Main Queue")
        queue.async { e.fulfill() }
        waitForExpectations(timeout: 2)
    }
}

extension MasternodeListDiffMessage: Equatable {
    public static func == (lhs: MasternodeListDiffMessage, rhs: MasternodeListDiffMessage) -> Bool {
        lhs.blockHash == rhs.blockHash &&
            lhs.baseBlockHash == rhs.baseBlockHash
    }
}

extension CoinbaseTransaction: Equatable {
    public static func == (lhs: CoinbaseTransaction, rhs: CoinbaseTransaction) -> Bool {
        lhs.merkleRootMNList == rhs.merkleRootMNList
    }
}

extension MasternodeListState: Equatable {
    public static func == (lhs: MasternodeListState, rhs: MasternodeListState) -> Bool {
        lhs.baseBlockHash == rhs.baseBlockHash
    }
}

extension InstantTransactionInput: Equatable {
    public static func == (lhs: InstantTransactionInput, rhs: InstantTransactionInput) -> Bool {
        lhs.txHash == rhs.txHash &&
            lhs.inputTxHash == rhs.inputTxHash
    }
}

extension UnspentOutput: Equatable {
    public static func == (lhs: UnspentOutput, rhs: UnspentOutput) -> Bool {
        lhs.output.value == rhs.output.value
    }
}

extension FullTransaction: Equatable {
    public static func == (lhs: FullTransaction, rhs: FullTransaction) -> Bool {
        TransactionSerializer.serialize(transaction: lhs) == TransactionSerializer.serialize(transaction: rhs)
    }
}
