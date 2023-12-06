import Foundation
import GRDB

class MasternodeListState: Record {
    private static let primaryKey = "primaryKey"

    let baseBlockHash: Data

    private let primaryKey: String = MasternodeListState.primaryKey

    override class var databaseTableName: String {
        "masternodeListState"
    }

    enum Columns: String, ColumnExpression {
        case primaryKey
        case baseBlockHash
    }

    required init(row: Row) throws {
        baseBlockHash = row[Columns.baseBlockHash]

        try super.init(row: row)
    }

    override func encode(to container: inout PersistenceContainer) throws {
        container[Columns.primaryKey] = primaryKey
        container[Columns.baseBlockHash] = baseBlockHash
    }

    init(baseBlockHash: Data) {
        self.baseBlockHash = baseBlockHash

        super.init()
    }
}
