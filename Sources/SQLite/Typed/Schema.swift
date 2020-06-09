//
// SQLite.swift
// https://github.com/stephencelis/SQLite.swift
// Copyright © 2014-2015 Stephen Celis.
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.
//

extension SchemaType {
    
    // MARK: - DROP TABLE / VIEW / VIRTUAL TABLE
    
    public func drop(ifExists: Bool = false) -> String {
        return drop("TABLE", tableName(), ifExists)
    }
    
}

extension Table {
    
    // MARK: - CREATE TABLE
    
    public func create(temporary: Bool = false, ifNotExists: Bool = false, withoutRowid: Bool = false, @TableFunctionalBuilder block: () -> Expressible) -> String {
        
        let clauses: [Expressible?] = [
            create(Table.identifier, tableName(), temporary ? .temporary : nil, ifNotExists),
            "".wrap(block()) as Expression<Void>,
            withoutRowid ? Expression<Void>(literal: "WITHOUT ROWID") : nil
        ]
        
        return " ".join(clauses.compactMap { $0 }).asSQL()
    }
    
    public func create(temporary: Bool = false, ifNotExists: Bool = false, withoutRowid: Bool = false, @TableFunctionalBuilder block: () -> [Expressible]) -> String {
        
        let clauses: [Expressible?] = [
            create(Table.identifier, tableName(), temporary ? .temporary : nil, ifNotExists),
            "".wrap(block()) as Expression<Void>,
            withoutRowid ? Expression<Void>(literal: "WITHOUT ROWID") : nil
        ]
        
        return " ".join(clauses.compactMap { $0 }).asSQL()
    }
    
    public func create(_ query: QueryType, temporary: Bool = false, ifNotExists: Bool = false) -> String {
        let clauses: [Expressible?] = [
            create(Table.identifier, tableName(), temporary ? .temporary : nil, ifNotExists),
            Expression<Void>(literal: "AS"),
            query
        ]
        
        return " ".join(clauses.compactMap { $0 }).asSQL()
    }
    
    // MARK: - ALTER TABLE … ADD COLUMN
    
    public func addColumn<V : Value>(_ name: Expression<V>, check: Expression<Bool>? = nil, defaultValue: V) -> String {
        return addColumn(definition(name, V.declaredDatatype, nil, false, false, check, defaultValue, nil, nil))
    }
    
    public func addColumn<V : Value>(_ name: Expression<V>, check: Expression<Bool?>, defaultValue: V) -> String {
        return addColumn(definition(name, V.declaredDatatype, nil, false, false, check, defaultValue, nil, nil))
    }
    
    public func addColumn<V : Value>(_ name: Expression<V?>, check: Expression<Bool>? = nil, defaultValue: V? = nil) -> String {
        return addColumn(definition(name, V.declaredDatatype, nil, true, false, check, defaultValue, nil, nil))
    }
    
    public func addColumn<V : Value>(_ name: Expression<V?>, check: Expression<Bool?>, defaultValue: V? = nil) -> String {
        return addColumn(definition(name, V.declaredDatatype, nil, true, false, check, defaultValue, nil, nil))
    }
    
    public func addColumn<V : Value>(_ name: Expression<V>, unique: Bool = false, check: Expression<Bool>? = nil, references table: QueryType, _ other: Expression<V>) -> String where V.Datatype == Int64 {
        return addColumn(definition(name, V.declaredDatatype, nil, false, unique, check, nil, (table, other), nil))
    }
    
    public func addColumn<V : Value>(_ name: Expression<V>, unique: Bool = false, check: Expression<Bool?>, references table: QueryType, _ other: Expression<V>) -> String where V.Datatype == Int64 {
        return addColumn(definition(name, V.declaredDatatype, nil, false, unique, check, nil, (table, other), nil))
    }
    
    public func addColumn<V : Value>(_ name: Expression<V?>, unique: Bool = false, check: Expression<Bool>? = nil, references table: QueryType, _ other: Expression<V>) -> String where V.Datatype == Int64 {
        return addColumn(definition(name, V.declaredDatatype, nil, true, unique, check, nil, (table, other), nil))
    }
    
    public func addColumn<V : Value>(_ name: Expression<V?>, unique: Bool = false, check: Expression<Bool?>, references table: QueryType, _ other: Expression<V>) -> String where V.Datatype == Int64 {
        return addColumn(definition(name, V.declaredDatatype, nil, true, unique, check, nil, (table, other), nil))
    }
    
    public func addColumn<V : Value>(_ name: Expression<V>, check: Expression<Bool>? = nil, defaultValue: V, collate: Collation) -> String where V.Datatype == String {
        return addColumn(definition(name, V.declaredDatatype, nil, false, false, check, defaultValue, nil, collate))
    }
    
    public func addColumn<V : Value>(_ name: Expression<V>, check: Expression<Bool?>, defaultValue: V, collate: Collation) -> String where V.Datatype == String {
        return addColumn(definition(name, V.declaredDatatype, nil, false, false, check, defaultValue, nil, collate))
    }
    
    public func addColumn<V : Value>(_ name: Expression<V?>, check: Expression<Bool>? = nil, defaultValue: V? = nil, collate: Collation) -> String where V.Datatype == String {
        return addColumn(definition(name, V.declaredDatatype, nil, true, false, check, defaultValue, nil, collate))
    }
    
    public func addColumn<V : Value>(_ name: Expression<V?>, check: Expression<Bool?>, defaultValue: V? = nil, collate: Collation) -> String where V.Datatype == String {
        return addColumn(definition(name, V.declaredDatatype, nil, true, false, check, defaultValue, nil, collate))
    }
    
    fileprivate func addColumn(_ expression: Expressible) -> String {
        return " ".join([
            Expression<Void>(literal: "ALTER TABLE"),
            tableName(),
            Expression<Void>(literal: "ADD COLUMN"),
            expression
        ]).asSQL()
    }
    
    // MARK: - ALTER TABLE … RENAME TO
    
    public func rename(_ to: Table) -> String {
        return rename(to: to)
    }
    
    // MARK: - CREATE INDEX
    
    public func createIndex(_ columns: Expressible..., unique: Bool = false, ifNotExists: Bool = false) -> String {
        let clauses: [Expressible?] = [
            create("INDEX", indexName(columns), unique ? .unique : nil, ifNotExists),
            Expression<Void>(literal: "ON"),
            tableName(qualified: false),
            "".wrap(columns) as Expression<Void>
        ]
        
        return " ".join(clauses.compactMap { $0 }).asSQL()
    }
    
    // MARK: - DROP INDEX
    
    
    public func dropIndex(_ columns: Expressible..., ifExists: Bool = false) -> String {
        return drop("INDEX", indexName(columns), ifExists)
    }
    
    fileprivate func indexName(_ columns: [Expressible]) -> Expressible {
        let string = (["index", clauses.from.name, "on"] + columns.map { $0.expression.template }).joined(separator: " ").lowercased()
        
        let index = string.reduce("") { underscored, character in
            guard character != "\"" else {
                return underscored
            }
            guard "a"..."z" ~= character || "0"..."9" ~= character else {
                return underscored + "_"
            }
            return underscored + String(character)
        }
        
        return database(namespace: index)
    }
    
}

extension View {
    
    // MARK: - CREATE VIEW
    
    public func create(_ query: QueryType, temporary: Bool = false, ifNotExists: Bool = false) -> String {
        let clauses: [Expressible?] = [
            create(View.identifier, tableName(), temporary ? .temporary : nil, ifNotExists),
            Expression<Void>(literal: "AS"),
            query
        ]
        
        return " ".join(clauses.compactMap { $0 }).asSQL()
    }
    
    // MARK: - DROP VIEW
    
    public func drop(ifExists: Bool = false) -> String {
        return drop("VIEW", tableName(), ifExists)
    }
    
}

extension VirtualTable {
    
    // MARK: - CREATE VIRTUAL TABLE
    
    public func create(_ using: Module, ifNotExists: Bool = false) -> String {
        let clauses: [Expressible?] = [
            create(VirtualTable.identifier, tableName(), nil, ifNotExists),
            Expression<Void>(literal: "USING"),
            using
        ]
        
        return " ".join(clauses.compactMap { $0 }).asSQL()
    }
    
    // MARK: - ALTER TABLE … RENAME TO
    
    public func rename(_ to: VirtualTable) -> String {
        return rename(to: to)
    }
    
}

@_functionBuilder
public struct TableFunctionalBuilder {
    public static func buildBlock(_ segments: Expressible...) -> [Expressible] {
        var definitions = [Expressible]()
        segments.forEach { definitions.append($0) }
        return definitions
    }
}


public func column<V : Value>(_ name: Expression<V>, unique: Bool = false, check: Expression<Bool>? = nil, defaultValue: Expression<V>? = nil)-> Expressible {
    return column(name, V.declaredDatatype, nil, false, unique, check, defaultValue, nil, nil)
}

public func column<V : Value>(_ name: Expression<V>, unique: Bool = false, check: Expression<Bool>? = nil, defaultValue: V)-> Expressible {
    return column(name, V.declaredDatatype, nil, false, unique, check, defaultValue, nil, nil)
}

public func column<V : Value>(_ name: Expression<V>, unique: Bool = false, check: Expression<Bool?>, defaultValue: Expression<V>? = nil)-> Expressible {
    return column(name, V.declaredDatatype, nil, false, unique, check, defaultValue, nil, nil)
}

public func column<V : Value>(_ name: Expression<V>, unique: Bool = false, check: Expression<Bool?>, defaultValue: V)-> Expressible {
    return column(name, V.declaredDatatype, nil, false, unique, check, defaultValue, nil, nil)
}

public func column<V : Value>(_ name: Expression<V?>, unique: Bool = false, check: Expression<Bool>? = nil, defaultValue: Expression<V>? = nil)-> Expressible {
    return column(name, V.declaredDatatype, nil, true, unique, check, defaultValue, nil, nil)
}

public func column<V : Value>(_ name: Expression<V?>, unique: Bool = false, check: Expression<Bool>? = nil, defaultValue: Expression<V?>)-> Expressible {
    return column(name, V.declaredDatatype, nil, true, unique, check, defaultValue, nil, nil)
}

public func column<V : Value>(_ name: Expression<V?>, unique: Bool = false, check: Expression<Bool>? = nil, defaultValue: V)-> Expressible {
    return column(name, V.declaredDatatype, nil, true, unique, check, defaultValue, nil, nil)
}

public func column<V : Value>(_ name: Expression<V?>, unique: Bool = false, check: Expression<Bool?>, defaultValue: Expression<V>? = nil)-> Expressible {
    return column(name, V.declaredDatatype, nil, true, unique, check, defaultValue, nil, nil)
}

public func column<V : Value>(_ name: Expression<V?>, unique: Bool = false, check: Expression<Bool?>, defaultValue: Expression<V?>)-> Expressible {
    return column(name, V.declaredDatatype, nil, true, unique, check, defaultValue, nil, nil)
}

public func column<V : Value>(_ name: Expression<V?>, unique: Bool = false, check: Expression<Bool?>, defaultValue: V)-> Expressible {
    return column(name, V.declaredDatatype, nil, true, unique, check, defaultValue, nil, nil)
}

public func column<V : Value>(_ name: Expression<V>, primaryKey: Bool, check: Expression<Bool>? = nil, defaultValue: Expression<V>? = nil)-> Expressible {
    return column(name, V.declaredDatatype, primaryKey ? .default : nil, false, false, check, defaultValue, nil, nil)
}

public func column<V : Value>(_ name: Expression<V>, primaryKey: Bool, check: Expression<Bool?>, defaultValue: Expression<V>? = nil)-> Expressible {
    return column(name, V.declaredDatatype, primaryKey ? .default : nil, false, false, check, defaultValue, nil, nil)
}

public func column<V : Value>(_ name: Expression<V>, primaryKey: PrimaryKey, check: Expression<Bool>? = nil)-> Expressible where V.Datatype == Int64 {
    return column(name, V.declaredDatatype, primaryKey, false, false, check, nil, nil, nil)
}

public func column<V : Value>(_ name: Expression<V>, primaryKey: PrimaryKey, check: Expression<Bool?>)-> Expressible where V.Datatype == Int64 {
    return column(name, V.declaredDatatype, primaryKey, false, false, check, nil, nil, nil)
}

public func column<V : Value>(_ name: Expression<V>, unique: Bool = false, check: Expression<Bool>? = nil, references table: QueryType, _ other: Expression<V>)-> Expressible where V.Datatype == Int64 {
    return column(name, V.declaredDatatype, nil, false, unique, check, nil, (table, other), nil)
}

public func column<V : Value>(_ name: Expression<V>, unique: Bool = false, check: Expression<Bool>? = nil, references table: QueryType, _ other: Expression<V>)-> Expressible where V.Datatype == String {
    return column(name, V.declaredDatatype, nil, false, unique, check, nil, (table, other), nil)
}

public func column<V : Value>(_ name: Expression<V>, unique: Bool = false, check: Expression<Bool?>, references table: QueryType, _ other: Expression<V>)-> Expressible where V.Datatype == Int64 {
    return column(name, V.declaredDatatype, nil, false, unique, check, nil, (table, other), nil)
}

public func column<V : Value>(_ name: Expression<V>, unique: Bool = false, check: Expression<Bool?>, references table: QueryType, _ other: Expression<V>)-> Expressible where V.Datatype == String {
    return column(name, V.declaredDatatype, nil, false, unique, check, nil, (table, other), nil)
}

public func column<V : Value>(_ name: Expression<V?>, unique: Bool = false, check: Expression<Bool>? = nil, references table: QueryType, _ other: Expression<V>)-> Expressible where V.Datatype == Int64 {
    return column(name, V.declaredDatatype, nil, true, unique, check, nil, (table, other), nil)
}

public func column<V : Value>(_ name: Expression<V?>, unique: Bool = false, check: Expression<Bool>? = nil, references table: QueryType, _ other: Expression<V>)-> Expressible where V.Datatype == String {
    return column(name, V.declaredDatatype, nil, true, unique, check, nil, (table, other), nil)
}

public func column<V : Value>(_ name: Expression<V?>, unique: Bool = false, check: Expression<Bool?>, references table: QueryType, _ other: Expression<V>)-> Expressible where V.Datatype == Int64 {
    return column(name, V.declaredDatatype, nil, true, unique, check, nil, (table, other), nil)
}

public func column<V : Value>(_ name: Expression<V?>, unique: Bool = false, check: Expression<Bool?>, references table: QueryType, _ other: Expression<V>)-> Expressible where V.Datatype == String {
    return column(name, V.declaredDatatype, nil, true, unique, check, nil, (table, other), nil)
}

public func column<V : Value>(_ name: Expression<V>, unique: Bool = false, check: Expression<Bool>? = nil, defaultValue: Expression<V>? = nil, collate: Collation)-> Expressible where V.Datatype == String {
    return column(name, V.declaredDatatype, nil, false, unique, check, defaultValue, nil, collate)
}

public func column<V : Value>(_ name: Expression<V>, unique: Bool = false, check: Expression<Bool>? = nil, defaultValue: V, collate: Collation)-> Expressible where V.Datatype == String {
    return column(name, V.declaredDatatype, nil, false, unique, check, defaultValue, nil, collate)
}

public func column<V : Value>(_ name: Expression<V>, unique: Bool = false, check: Expression<Bool?>, defaultValue: Expression<V>? = nil, collate: Collation)-> Expressible where V.Datatype == String {
    return column(name, V.declaredDatatype, nil, false, unique, check, defaultValue, nil, collate)
}

public func column<V : Value>(_ name: Expression<V>, unique: Bool = false, check: Expression<Bool?>, defaultValue: V, collate: Collation)-> Expressible where V.Datatype == String {
    return column(name, V.declaredDatatype, nil, false, unique, check, defaultValue, nil, collate)
}

public func column<V : Value>(_ name: Expression<V?>, unique: Bool = false, check: Expression<Bool>? = nil, defaultValue: Expression<V>? = nil, collate: Collation)-> Expressible where V.Datatype == String {
    return column(name, V.declaredDatatype, nil, true, unique, check, defaultValue, nil, collate)
}

public func column<V : Value>(_ name: Expression<V?>, unique: Bool = false, check: Expression<Bool>? = nil, defaultValue: Expression<V?>, collate: Collation)-> Expressible where V.Datatype == String {
    return column(name, V.declaredDatatype, nil, true, unique, check, defaultValue, nil, collate)
}

public func column<V : Value>(_ name: Expression<V?>, unique: Bool = false, check: Expression<Bool>? = nil, defaultValue: V, collate: Collation)-> Expressible where V.Datatype == String {
    return column(name, V.declaredDatatype, nil, true, unique, check, defaultValue, nil, collate)
}

public func column<V : Value>(_ name: Expression<V?>, unique: Bool = false, check: Expression<Bool?>, defaultValue: Expression<V>? = nil, collate: Collation)-> Expressible where V.Datatype == String {
    return column(name, V.declaredDatatype, nil, true, unique, check, defaultValue, nil, collate)
}

public func column<V : Value>(_ name: Expression<V?>, unique: Bool = false, check: Expression<Bool?>, defaultValue: Expression<V?>, collate: Collation)-> Expressible where V.Datatype == String {
    return column(name, V.declaredDatatype, nil, true, unique, check, defaultValue, nil, collate)
}

public func column<V : Value>(_ name: Expression<V?>, unique: Bool = false, check: Expression<Bool?>, defaultValue: V, collate: Collation)-> Expressible where V.Datatype == String {
    return column(name, V.declaredDatatype, nil, true, unique, check, defaultValue, nil, collate)
}

fileprivate func column(_ name: Expressible, _ datatype: String, _ primaryKey: PrimaryKey?, _ null: Bool, _ unique: Bool, _ check: Expressible?, _ defaultValue: Expressible?, _ references: (QueryType, Expressible)?, _ collate: Collation?) -> Expressible {
    return definition(name, datatype, primaryKey, null, unique, check, defaultValue, references, collate)
    //definitions.append()
}

// MARK: -

public func primaryKey<T : Value>(_ column: Expression<T>) -> Expressible {
    return primaryKey([column])
}

public func primaryKey<T : Value, U : Value>(_ compositeA: Expression<T>, _ b: Expression<U>) -> Expressible {
    return primaryKey([compositeA, b])
}

public func primaryKey<T : Value, U : Value, V : Value>(_ compositeA: Expression<T>, _ b: Expression<U>, _ c: Expression<V>) -> Expressible {
    return primaryKey([compositeA, b, c])
}

public func primaryKey<T : Value, U : Value, V : Value, W : Value>(_ compositeA: Expression<T>, _ b: Expression<U>, _ c: Expression<V>, _ d: Expression<W>) -> Expressible {
    return primaryKey([compositeA, b, c, d])
}

fileprivate func primaryKey(_ composite: [Expressible]) -> Expressible {
    //definitions.append("PRIMARY KEY".prefix(composite))
    return "PRIMARY KEY".prefix(composite)
}

public func unique(_ columns: Expressible...) -> Expressible {
    unique(columns)
}

public func unique(_ columns: [Expressible]) -> Expressible {
    //definitions.append("UNIQUE".prefix(columns))
    return "UNIQUE".prefix(columns)
}

public func check(_ condition: Expression<Bool>) -> Expressible {
    check(Expression<Bool?>(condition))
}

public func check(_ condition: Expression<Bool?>) -> Expressible {
    //definitions.append("CHECK".prefix(condition))
    return "CHECK".prefix(condition)
}

public enum Dependency: String {
    
    case noAction = "NO ACTION"
    
    case restrict = "RESTRICT"
    
    case setNull = "SET NULL"
    
    case setDefault = "SET DEFAULT"
    
    case cascade = "CASCADE"
    
}

public func foreignKey<T : Value>(_ column: Expression<T>, references table: QueryType, _ other: Expression<T>, update: Dependency? = nil, delete: Dependency? = nil) -> Expressible {
    return foreignKey(column, (table, other), update, delete)
}

public func foreignKey<T : Value>(_ column: Expression<T?>, references table: QueryType, _ other: Expression<T>, update: Dependency? = nil, delete: Dependency? = nil) -> Expressible {
    return foreignKey(column, (table, other), update, delete)
}

public func foreignKey<T : Value, U : Value>(_ composite: (Expression<T>, Expression<U>), references table: QueryType, _ other: (Expression<T>, Expression<U>), update: Dependency? = nil, delete: Dependency? = nil) -> Expressible {
    let composite = ", ".join([composite.0, composite.1])
    let references = (table, ", ".join([other.0, other.1]))
    
    return foreignKey(composite, references, update, delete)
}

public func foreignKey<T : Value, U : Value, V : Value>(_ composite: (Expression<T>, Expression<U>, Expression<V>), references table: QueryType, _ other: (Expression<T>, Expression<U>, Expression<V>), update: Dependency? = nil, delete: Dependency? = nil) -> Expressible {
    let composite = ", ".join([composite.0, composite.1, composite.2])
    let references = (table, ", ".join([other.0, other.1, other.2]))
    
    return foreignKey(composite, references, update, delete)
}

fileprivate func foreignKey(_ column: Expressible, _ references: (QueryType, Expressible), _ update: Dependency?, _ delete: Dependency?) -> Expressible {
    let clauses: [Expressible?] = [
        "FOREIGN KEY".prefix(column),
        reference(references),
        update.map { Expression<Void>(literal: "ON UPDATE \($0.rawValue)") },
        delete.map { Expression<Void>(literal: "ON DELETE \($0.rawValue)") }
    ]
    return " ".join(clauses.compactMap { $0 })
}

public enum PrimaryKey {
    
    case `default`
    
    case autoincrement
    
}

public struct Module {
    
    fileprivate let name: String
    
    fileprivate let arguments: [Expressible]
    
    public init(_ name: String, _ arguments: [Expressible]) {
        self.init(name: name.quote(), arguments: arguments)
    }
    
    init(name: String, arguments: [Expressible]) {
        self.name = name
        self.arguments = arguments
    }
    
}

extension Module : Expressible {
    
    public var expression: Expression<Void> {
        return name.wrap(arguments)
    }
    
}

// MARK: - Private

private extension QueryType {
    
    func create(_ identifier: String, _ name: Expressible, _ modifier: Modifier?, _ ifNotExists: Bool) -> Expressible {
        let clauses: [Expressible?] = [
            Expression<Void>(literal: "CREATE"),
            modifier.map { Expression<Void>(literal: $0.rawValue) },
            Expression<Void>(literal: identifier),
            ifNotExists ? Expression<Void>(literal: "IF NOT EXISTS") : nil,
            name
        ]
        
        return " ".join(clauses.compactMap { $0 })
    }
    
    func rename(to: Self) -> String {
        return " ".join([
            Expression<Void>(literal: "ALTER TABLE"),
            tableName(),
            Expression<Void>(literal: "RENAME TO"),
            Expression<Void>(to.clauses.from.name)
        ]).asSQL()
    }
    
    func drop(_ identifier: String, _ name: Expressible, _ ifExists: Bool) -> String {
        let clauses: [Expressible?] = [
            Expression<Void>(literal: "DROP \(identifier)"),
            ifExists ? Expression<Void>(literal: "IF EXISTS") : nil,
            name
        ]
        
        return " ".join(clauses.compactMap { $0 }).asSQL()
    }
    
}

private func definition(_ column: Expressible, _ datatype: String, _ primaryKey: PrimaryKey?, _ null: Bool, _ unique: Bool, _ check: Expressible?, _ defaultValue: Expressible?, _ references: (QueryType, Expressible)?, _ collate: Collation?) -> Expressible {
    let clauses: [Expressible?] = [
        column,
        Expression<Void>(literal: datatype),
        primaryKey.map { Expression<Void>(literal: $0 == .autoincrement ? "PRIMARY KEY AUTOINCREMENT" : "PRIMARY KEY") },
        null ? nil : Expression<Void>(literal: "NOT NULL"),
        unique ? Expression<Void>(literal: "UNIQUE") : nil,
        check.map { " ".join([Expression<Void>(literal: "CHECK"), $0]) },
        defaultValue.map { "DEFAULT".prefix($0) },
        references.map(reference),
        collate.map { " ".join([Expression<Void>(literal: "COLLATE"), $0]) }
    ]
    
    return " ".join(clauses.compactMap { $0 })
}

private func reference(_ primary: (QueryType, Expressible)) -> Expressible {
    return " ".join([
        Expression<Void>(literal: "REFERENCES"),
        primary.0.tableName(qualified: false),
        "".wrap(primary.1) as Expression<Void>
    ])
}

private enum Modifier : String {
    
    case unique = "UNIQUE"
    
    case temporary = "TEMPORARY"
    
}
