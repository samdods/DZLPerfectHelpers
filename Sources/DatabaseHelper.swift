//
//  DatabaseHelper.swift
//  PerfectTemplate
//
//  Created by Sam Dods on 17/08/2016.
//
//

import PerfectLib
import SQLite

private let databasePath = PerfectServer.homeDir + ".database"

public struct Database {
    
    public static func createTablesIfNecessary(tables: [Table.Type]) {
        do {
            let sqlite = self.sqlite()
            for table in tables {
                try sqlite?.execute(statement: table.createStatement())
            }
        } catch let error {
            print(error)
            print("Failure creating database at " + databasePath)
        }
    }
    
    static func sqlite() -> SQLite? {
        return try? SQLite(databasePath)
    }
    
}

public class Table {
    public typealias ColumnInfo = (type: String, constraints: String?)
    public class func name() -> String { fatalError() } // must override
    public class func columns() -> [String: ColumnInfo] { fatalError() } // must override
    
    private init() {} // cannot instantiate
    
    // MARK: - creating
    
    static func createStatement() -> String {
        var statement = "CREATE TABLE IF NOT EXISTS " + name() + " ("
        for (index, column) in columns().enumerated() {
            if index > 0 {
                statement += ", "
            }
            let name = column.key
            let info = column.value
            statement += name + " " + info.type
            if let constraints = info.constraints {
                statement += " " + constraints
            }
        }
        statement.append(")")
        return statement
    }
    
    // MARK: - inserting
    
    public static func insert(withBindings: (SQLiteStmt) throws -> ()) throws {
        let sqlite = Database.sqlite()
        defer {
            sqlite?.close()
        }
        try sqlite?.execute(statement: insertStatement(), doBindings: withBindings)
    }
    
    private static func insertStatement() -> String {
        var statement = "INSERT INTO " + name()
        var columnNames = ""
        var binders = ""
        for (index, column) in columns().enumerated() {
            if index > 0 {
                columnNames += ", "
                binders += ", "
            }
            columnNames += column.key
            binders += "?"
        }
        statement.append(" (" + columnNames + ") VALUES (" + binders + ")")
        return statement
    }
    
    // MARK: - selecting all
    
    public static func select(withBindings: (SQLiteStmt, Int) -> ()) throws {
        let sqlite = Database.sqlite()
        defer {
            sqlite?.close()
        }
        try sqlite?.forEachRow(statement: selectAllStatement(), handleRow: withBindings)
    }
    
    private static func selectAllStatement() -> String {
        return "SELECT * FROM " + name()
    }
}

