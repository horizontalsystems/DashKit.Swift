import Foundation
import GRDB

class InstantTransactionHash: Record {
    let txHash: Data

    override class var databaseTableName: String {
        "instantTransactionHashes"
    }

    enum Columns: String, ColumnExpression {
        case txHash
    }

    required init(row: Row) throws {
        txHash = row[Columns.txHash]

        try super.init(row: row)
    }

    override func encode(to container: inout PersistenceContainer) throws {
        container[Columns.txHash] = txHash
    }

    init(txHash: Data) {
        self.txHash = txHash

        super.init()
    }
}
