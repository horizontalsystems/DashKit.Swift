import Foundation
import HSCryptoKit
import GRDB

public enum TransactionStatus: Int, DatabaseValueConvertible { case new, relayed, invalid }

public class Transaction: Record {
    public var dataHashReversedHex: String
    public var dataHash: Data
    public var version: Int
    public var lockTime: Int
    public var timestamp: Int
    public var order: Int
    public var blockHashReversedHex: String? = nil
    public var isMine: Bool = false
    public var isOutgoing: Bool = false
    public var status: TransactionStatus = .relayed
    public var segWit: Bool = false

    init(version: Int = 0, lockTime: Int = 0, timestamp: Int? = nil) {
        self.version = version
        self.lockTime = lockTime
        self.timestamp = timestamp ?? Int(Date().timeIntervalSince1970)
        self.order = 0
        self.dataHash = Data()
        self.dataHashReversedHex = dataHash.reversedHex

        super.init()
    }


    override open class var databaseTableName: String {
        return "transactions"
    }

    enum Columns: String, ColumnExpression, CaseIterable {
        case dataHashReversedHex
        case dataHash
        case version
        case lockTime
        case timestamp
        case order
        case blockHashReversedHex
        case isMine
        case isOutgoing
        case status
        case segWit
    }

    required init(row: Row) {
        dataHashReversedHex = row[Columns.dataHashReversedHex]
        dataHash = row[Columns.dataHash]
        version = row[Columns.version]
        lockTime = row[Columns.lockTime]
        timestamp = row[Columns.timestamp]
        order = row[Columns.order]
        blockHashReversedHex = row[Columns.blockHashReversedHex]
        isMine = row[Columns.isMine]
        isOutgoing = row[Columns.isOutgoing]
        status = row[Columns.status]
        segWit = row[Columns.segWit]

        super.init(row: row)
    }

    override open func encode(to container: inout PersistenceContainer) {
        container[Columns.dataHashReversedHex] = dataHashReversedHex
        container[Columns.dataHash] = dataHash
        container[Columns.version] = version
        container[Columns.lockTime] = lockTime
        container[Columns.timestamp] = timestamp
        container[Columns.order] = order
        container[Columns.blockHashReversedHex] = blockHashReversedHex
        container[Columns.isMine] = isMine
        container[Columns.isOutgoing] = isOutgoing
        container[Columns.status] = status
        container[Columns.segWit] = segWit
    }

}
