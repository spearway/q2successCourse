//
//  ElementCoddingWrapper.swift
//  
//
//  Created by pierre on 2021-05-23.
//

import Foundation


class ElementCoddingWrapper: IdentifiableElement, Codable, Equatable {
    let element: Element
    let id: UUID
    let blueprintName: ElementBlueprint.Name
    
    public var isFault: Bool {
        return false
    }

    private enum CodingKeys : String, CodingKey {
        case id
        case blueprintName
        case element
    }

    init(_ element: Element) {
        self.element = element
        self.id = element.id
        self.blueprintName = element.blueprintName
    }

    required public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        self.id = try container.decode(UUID.self, forKey: .id)
        self.blueprintName = try container.decode(ElementBlueprint.Name.self, forKey: .blueprintName)

        let blueprint = ElementBlueprint.registry.blueprint(for: self.blueprintName)
        if let element =  try container.decodeIfPresent(blueprint.instanceType, forKey: .element) {
            self.element = element
            Processed<Element>.info(userInfo: decoder.userInfo).add(item: self.element)
        } else if let element = Processed<Element>.info(userInfo: decoder.userInfo)[self.id] {
            self.element = element
        } else {
            self.element = ElementFault(id: self.id)
         }
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)

        try container.encode(self.id, forKey: .id)
        try container.encode(self.blueprintName, forKey: .blueprintName)
        if !Processed<Element>.info(userInfo: encoder.userInfo).contains(id: self.id) {
            Processed<Element>.info(userInfo: encoder.userInfo).add(item: self.element)
            try container.encode(self.element, forKey: .element)
        }

    }

    public static func map(elements: [Element]) -> [ElementCoddingWrapper] {
        return elements.map({ ElementCoddingWrapper($0) })
    }

    public static func map(elementsWrappers: [ElementCoddingWrapper]) -> [Element] {
        return elementsWrappers.map({ $0.element })
    }

    public static func finalizeDecoding(from decoder: Decoder) {
        let processed = Processed<Element>.info(userInfo: decoder.userInfo)
        processed.values.forEach({ element in
//            let precessorConnections = element.predecessors.filter({ $0.from.isFault })
//            precessorConnections.forEach({ connection in
//                if let targetElement = processed[connection.from.id] {
//                    element.removePredecessor(connection.from)
//                    element.addPredecessor(targetElement)
//                } else {
//                    fatalError("We have an element fault without a real element \(connection.from.id.uuidString)")
//                }
//            })
//            let sucessorConnections = element.successors.filter({ $0.to.isFault })
//            sucessorConnections.forEach({ connection in
//                if let targetElement = processed[connection.to.id] {
//                    element.removeSuccessor(connection.to)
//                    element.addSuccessor(targetElement)
//                } else {
//                    fatalError("We have an element fault without a real element \(connection.to.id.uuidString)")
//                }
//            })
       })
    }

    // MARK: - Boiler plate

    public var description: String {
        return "id: \(self.id.uuidString)"
    }

    public var debugDescription: String {
        return self.description
    }

    public static func == (lhs: ElementCoddingWrapper, rhs: ElementCoddingWrapper) -> Bool {
        return lhs.id == rhs.id
    }

}

public enum CodingError: Error {
    case MissingElement(id: UUID)
}

public extension CodingUserInfoKey {
    static let processedConnections = CodingUserInfoKey(rawValue: "com.spearway.q2success.processed.connections")!
    static let processedElements = CodingUserInfoKey(rawValue: "com.spearway.q2success.processed.elements")!
    static let faultElements = CodingUserInfoKey(rawValue: "com.spearway.q2success.processed.faults")!
}

class Processed<T: IdentifiableElement>: CustomStringConvertible, CustomDebugStringConvertible {
    private var _values: [UUID: T]

    public static func info(userInfo: [CodingUserInfoKey : Any]) -> Processed<T> {
        if let processed = userInfo[.processedElements] as? Processed<T> {
            return processed
        }
        if let processed = userInfo[.processedConnections] as? Processed<T> {
            return processed
        }
        if let processed = userInfo[.faultElements] as? Processed<T> {
            return processed
        }
        fatalError("userInfo missing required key")
    }

    init() {
        self._values = [UUID: T]()
    }

    public var count:Int {
        return self._values.count
    }

    public subscript(id: UUID) -> T? {
        get {
            return self._values[id]
        }
        set {
            self._values[id] = newValue
        }
    }

    public var values: [T] {
        var list = [T]()
        list.append(contentsOf: self._values.values)
        return list
    }

    public func add(item: T) {
        self._values[item.id] = item
    }

    public func add(items: [T]) {
        items.forEach({self.add(item: $0)})
    }

    public func contains(id: UUID) -> Bool {
        return self[id] != nil
    }

    public func contains(item: T) -> Bool {
        return self[item.id] != nil
    }

    // MARK: - Boiler plate

    public var description: String {
        var log = "Processed:/n"
        self._values.forEach({ (key, value) in
            log.append("/t\(key.uuidString): \(value.description)/n")
        })
        return log
    }

    public var debugDescription: String {
        return self.description
    }

}

class ElementFault: Element, Fault {

    public init(id: UUID) {
        super.init()
        self.id = id
   }
    
    required public init(from decoder: Decoder) throws {
        fatalError("init(from:) has not been implemented")
    }
    

}
