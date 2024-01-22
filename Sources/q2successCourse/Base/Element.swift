//
//  Element.swift
//  
//
//  Created by pierre on 2021-05-23.
//

// http://swiftjson.guide

import Foundation
/*
 A course is a set of cards and questions.
 */
public class Element: ObservableObject, IdentifiableElement, Codable, Equatable, Hashable {

    internal(set) public var id: UUID
    @Published private(set) var predecessors: [Connection]
    @Published private(set) var successors: [Connection]

    private enum CodingKeys : String, CodingKey {
        case id
        case predecessors
        case successors
    }

    public init() {
        self.id = UUID()
        self.predecessors = [Connection]()
        self.successors = [Connection]()
    }

    // MARK: - Coding

    required public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        self.id = try container.decode(UUID.self, forKey: .id)
        self.predecessors = try container.decode([Connection].self, forKey: .predecessors)
        self.successors = try container.decode([Connection].self, forKey: .successors)
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        try container.encode(self.id, forKey: .id)
        try container.encode(self.predecessors, forKey: .predecessors)
        try container.encode(self.successors, forKey: .successors)
    }

    // MARK: - Inheritence

    public var blueprintName: ElementBlueprint.Name {
        fatalError("This method must be overwritten.")
    }

    public var blueprintGroup: ElementBlueprint.Group {
        fatalError("This method must be overwritten.")
    }

    public var blueprint: ElementBlueprint {
        return ElementBlueprint.registry.blueprint(for: self.blueprintName)
    }

    // MARK: - Connections

    public var possibleInConnectors: Int {
        return blueprint.inConnectors.count
    }

    public var possibleOutConnectors: Int {
        return blueprint.outConnectors.count
    }

    public var predecessorElements: [Element] {
        return self.predecessors.map({ $0.from })
    }

    public var successorElements: [Element] {
        return self.successors.map({ $0.to })
    }

    @discardableResult
    public func addPredecessor(_ element: Element) -> Connection {
        if let connection = self.predecessorConnection(for: element) {
            return connection
        } else {
            let connection = Connection(from: element, to: self)
            self.predecessors.append(connection)
            element.successors.append(connection)
            return connection
        }
    }

    @discardableResult
    public func removePredecessor(_ element: Element) -> Connection? {
        guard let connection = self.predecessorConnection(for: element) else {
            return nil
        }
        element.successors = element.successors.filter({ $0 != connection })
        self.predecessors = self.predecessors.filter({ $0 != connection })
        return connection
    }

    @discardableResult
    public func addSuccessor(_ element: Element) -> Connection {
        if let connection = self.successorConnection(for: element) {
            return connection
        } else {
            let connection = Connection(from: self, to: element)
            element.predecessors.append(connection)
            self.successors.append(connection)
            return connection
        }
    }

    @discardableResult
    public func removeSuccessor(_ element: Element) -> Connection? {
        guard let connection = self.successorConnection(for: element) else {
            return nil
        }
        self.successors = self.successors.filter({ $0 != connection })
        element.predecessors = element.predecessors.filter({ $0 != connection })
        return connection
    }

    private func predecessorConnection(for element: Element) -> Connection? {
        return self.predecessors.filter({ $0.from == element}).last
    }

    private func successorConnection(for element: Element) -> Connection? {
        return self.successors.filter({ $0.to == element}).last
    }

    // MARK: - Directed acyclic graph visualization Layout

    public var isJoin: Bool {
        return ( blueprint.outConnectors.count > 0 ) && ( blueprint.inConnectors.count > blueprint.outConnectors.count )
    }

    public var isSplit: Bool {
        return ( blueprint.inConnectors.count > 0 ) && ( blueprint.inConnectors.count < blueprint.outConnectors.count )
    }

    public var sucessorJoins: Int {
        return reduceSuccessorElements(into: 0) { (result, element) in
            result = result + ( element.isJoin ? 1 : 0 )
        }
    }

    public var predecessorJoins: Int {
        return reducePredecessorElements(into: 0) { (result, element) in
            result = result + ( element.isJoin ? 1 : 0 )
        }
    }

    public var sucessorSplits: Int {
        return reduceSuccessorElements(into: 0) { (result, element) in
            result = result + ( element.isSplit ? 1 : 0 )
        }
    }

    public var predecessorSplits: Int {
        return reducePredecessorElements(into: 0) { (result, element) in
            result = result + ( element.isSplit ? 1 : 0 )
        }
    }

    public var predecessorsWidth: Int {
        var visited = Set<UUID>()
        return reducePredecessorElements(into: width) { (result, element) in
            result = max(result, element.predecessorsWidth(visited: &visited))
        }
    }

    func predecessorsWidth(visited: inout Set<UUID>) -> Int {
        if visited.insert(id).inserted {
            var result = width
            predecessorElements.forEach { element in
                result = max(result, element.predecessorsWidth(visited: &visited))
            }
            return result
        } else {
            return 0
        }
    }

    public var successorsWidth: Int {
        var visited = Set<UUID>()
        return reduceSuccessorElements(into: width) { (result, element) in
            result = max(result, element.successorsWidth(visited: &visited))
        }
    }

    func successorsWidth(visited: inout Set<UUID>) -> Int {
        if visited.insert(id).inserted {
            var result = width
            successorElements.forEach { element in
                result = max(result, element.successorsWidth(visited: &visited))
            }
            return result
        } else {
            return 0
        }
    }

    public var predecessorsDepth: Int {
        return reducePredecessorElements(into: 0) { (result, element) in
            result = max(result, element.predecessorsDepth)
        } + 1
    }

    public var sucessorsDepth: Int {
        return reduceSuccessorElements(into: 0) { (result, element) in
            result = max(result, element.sucessorsDepth)
        } + 1
    }

    public var width: Int {
        return max(blueprint.inConnectors.count, blueprint.outConnectors.count)
    }

    public var depth: Int {
        var depth = 0
        var visited = Set<UUID>()
        predecessorElements.forEach {
            depth = max($0.depth(visited: &visited, depth: 0), depth)
        }
        return depth
    }

    private func depth(visited: inout Set<UUID>, depth currentDepth: Int) -> Int {
        if visited.insert(id).inserted {
            var depth = currentDepth + 1
            predecessorElements.forEach {
                depth = max($0.depth(visited: &visited, depth: currentDepth + 1), depth)
            }
            return depth
        } else {
            return currentDepth
        }
    }

    // MARK: - Elements Collection Support

    public func forEachSuccessorElements(_ body: (Element) throws -> Void) rethrows {
        var visited = Set<UUID>()
        try self.forEachSuccessorElements(visited: &visited, body)
     }

    func forEachSuccessorElements(visited: inout Set<UUID>, _ body: (Element) throws -> Void) rethrows {
        if visited.insert(id).inserted {
            try body(self)
            try successorElements.forEach { try $0.forEachSuccessorElements(visited: &visited, body) }
        }
    }

    public func forEachPredecessorElements(_ body: (Element) throws -> Void) rethrows {
        var visited = Set<UUID>()
        try self.forEachPredecessorElements(visited: &visited, body)
     }

    func forEachPredecessorElements(visited: inout Set<UUID>, _ body: (Element) throws -> Void) rethrows {
        if visited.insert(id).inserted {
            try body(self)
            try predecessorElements.forEach { try $0.forEachPredecessorElements(visited: &visited, body) }
        }
    }

    public func reduceSuccessorElements<Result>(_ initialResult: Result, _ nextPartialResult: (Result, Element) throws -> Result) rethrows -> Result {
        var visited = Set<UUID>()
        return try self.reduceSuccessorElements(initialResult, visited: &visited, nextPartialResult)
    }

    func reduceSuccessorElements<Result>(_ initialResult: Result, visited: inout Set<UUID>, _ nextPartialResult: (Result, Element) throws -> Result) rethrows -> Result {
        if visited.insert(id).inserted {
            var result = initialResult
            try successorElements.forEach {
                result = try nextPartialResult(result, $0)
                result = try $0.reduceSuccessorElements(result, visited: &visited, nextPartialResult)
            }
            return result
        } else {
            return initialResult
        }
    }

    public func reducePredecessorElements<Result>(_ initialResult: Result, _ nextPartialResult: (Result, Element) throws -> Result) rethrows -> Result {
        var visited = Set<UUID>()
        return try self.reducePredecessorElements(initialResult, visited: &visited, nextPartialResult)
    }

    func reducePredecessorElements<Result>(_ initialResult: Result, visited: inout Set<UUID>, _ nextPartialResult: (Result, Element) throws -> Result) rethrows -> Result {
        if visited.insert(id).inserted {
            var result = initialResult
            try predecessorElements.forEach {
                result = try nextPartialResult(result, $0)
                result = try $0.reducePredecessorElements(result, visited: &visited, nextPartialResult)
            }
            return result
        } else {
            return initialResult
        }
    }

    public func reduceSuccessorElements<Result>(into initialResult: Result, _ updateAccumulatingResult: (inout Result, Element) throws -> ()) rethrows -> Result {
        var visited = Set<UUID>()
        return try self.reduceSuccessorElements(into: initialResult, visited: &visited, updateAccumulatingResult)
    }

    func reduceSuccessorElements<Result>(into initialResult: Result, visited: inout Set<UUID>, _ updateAccumulatingResult: (inout Result, Element) throws -> ()) rethrows -> Result {
        if visited.insert(id).inserted {
            var result = initialResult
            try successorElements.forEach {
                try updateAccumulatingResult(&result, $0)
                result = try $0.reduceSuccessorElements(into: result, visited: &visited, updateAccumulatingResult)
            }
            return result
        } else {
            return initialResult
        }
    }

    public func reducePredecessorElements<Result>(into initialResult: Result, _ updateAccumulatingResult: (inout Result, Element) throws -> ()) rethrows -> Result {
        var visited = Set<UUID>()
        return try self.reducePredecessorElements(into: initialResult, visited: &visited, updateAccumulatingResult)
    }

    func reducePredecessorElements<Result>(into initialResult: Result, visited: inout Set<UUID>, _ updateAccumulatingResult: (inout Result, Element) throws -> ()) rethrows -> Result {
        if visited.insert(id).inserted {
            var result = initialResult
            try predecessorElements.forEach {
                try updateAccumulatingResult(&result, $0)
                result = try $0.reducePredecessorElements(into: result, visited: &visited, updateAccumulatingResult)
            }
            return result
        } else {
            return initialResult
        }
    }

    public func compactMapSuccessorElements<ElementOfResult>(_ transform: (Element) throws -> ElementOfResult?) rethrows -> [ElementOfResult] {
        var visited = Set<UUID>()
        return try self.compactMapSuccessorElements(visited: &visited, transform)
    }

    func compactMapSuccessorElements<ElementOfResult>(visited: inout Set<UUID>, _ transform: (Element) throws -> ElementOfResult?) rethrows -> [ElementOfResult] {
        if visited.insert(id).inserted {
            var results = [ElementOfResult]()
            if let elementOfResult = try transform(self) {
                results.append(elementOfResult)
            }
            try successorElements.forEach { results.append(contentsOf: try $0.compactMapSuccessorElements(visited: &visited, transform)) }
            return results
        } else {
            return [ElementOfResult]()
        }
    }

    public func compactMapPredecessorElements<ElementOfResult>(_ transform: (Element) throws -> ElementOfResult?) rethrows -> [ElementOfResult] {
        var visited = Set<UUID>()
        return try self.compactMapPredecessorElements(visited: &visited, transform)
    }

    func compactMapPredecessorElements<ElementOfResult>(visited: inout Set<UUID>, _ transform: (Element) throws -> ElementOfResult?) rethrows -> [ElementOfResult] {
        if visited.insert(id).inserted {
            var results = [ElementOfResult]()
            if let elementOfResult = try transform(self) {
                results.append(elementOfResult)
            }
            try predecessorElements.forEach { results.append(contentsOf: try $0.compactMapPredecessorElements(visited: &visited, transform)) }
            return results
        } else {
            return [ElementOfResult]()
        }
    }

    // MARK: - Boiler plate

    public var description: String {
        if self.isFault {
            return "id: \(self.id.uuidString) is fault"
        } else {
            return "id: \(self.id.uuidString) blueprint group: \(self.blueprintGroup),  blueprint name: \(self.blueprintName)"
        }
    }

    public var debugDescription: String {
        return self.description
    }

    public static func == (lhs: Element, rhs: Element) -> Bool {
        return lhs.id == rhs.id
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

}
