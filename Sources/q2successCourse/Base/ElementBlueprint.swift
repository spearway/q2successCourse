//
//  ElementBlueprint.swift
//  
//
//  Created by pierre on 2023-04-08.
//

import Foundation

public class ElementBlueprint: Identifiable, Equatable, CustomStringConvertible, CustomDebugStringConvertible {
    
    // MARK: - Registry Initialization

    private static var _registry: Registry?
    public static var registry: Registry {
        if ElementBlueprint._registry == nil {
            let registry = Registry()
            registry.add(blueprints: CardElementBlueprint.allBlueprints)
            registry.add(blueprints: QuestionElementBlueprint.allBlueprints)
            ElementBlueprint._registry = registry
        }
        return ElementBlueprint._registry!
    }

    // MARK: - Identifiable

    public var id: String {
        return self.name.rawValue
    }

    /**
     Name of that element. This is mainly used for display purpose. Must be unique
      */
    public let name: ElementBlueprint.Name
    
    /**
     Group of that element. This is mainly used for display purpose. Must be unique
     */
    public let group: ElementBlueprint.Group

    init(_ name: ElementBlueprint.Name, group: ElementBlueprint.Group) {
        self.name = name
        self.group = group
    }

    /**
     create a new instance of teh element
     This must be overwritten by concrete classes
     */
    public func newInstance() -> Element {
        fatalError("This method must be overwritten.")
    }
    
    public var instanceType: Element.Type {
        fatalError("This method must be overwritten.")
    }
    
    public var inConnectors: [Connector] {
        return [Connector]()
    }
    
    public var outConnectors: [Connector] {
        return [Connector]()
    }
    
    public static func == (lhs: ElementBlueprint, rhs: ElementBlueprint) -> Bool {
        return lhs.group == rhs.group && lhs.name == rhs.name
    }
    
    public var description: String {
        return self.name.rawValue
    }
    
    public var debugDescription: String {
        return self.description
    }
    
}

public extension ElementBlueprint {
    
    struct Group: Codable, Hashable, Equatable, RawRepresentable, CustomStringConvertible, CustomDebugStringConvertible {
        public let rawValue: String

        public init(_ rawValue: String) {
            self.rawValue = rawValue
        }
        
        public init(rawValue: String) {
            self.rawValue = rawValue
        }
        
        public static func == (lhs: Group, rhs: Group) -> Bool {
            return lhs.rawValue == rhs.rawValue
        }
        
        public var description: String {
            return self.rawValue
        }
        
        public var debugDescription: String {
            return self.description
        }
        
    }
    
    struct Name: Codable, Hashable, Equatable, RawRepresentable, CustomStringConvertible, CustomDebugStringConvertible {
        
        public let rawValue: String
        
        public init(_ rawValue: String) {
            self.rawValue = rawValue
        }
        
        public init(rawValue: String) {
            self.rawValue = rawValue
        }
        
        public static func == (lhs: Name, rhs: Name) -> Bool {
            return lhs.rawValue == rhs.rawValue
        }
        
        public var description: String {
            return self.rawValue
        }
        
        public var debugDescription: String {
            return self.description
        }
        
    }
    
}

public extension ElementBlueprint {
    
    class Registry: ObservableObject, CustomStringConvertible, CustomDebugStringConvertible {

        public final class BlueprintNode: Identifiable {
            public let id: String
            public let child: [BlueprintNode]?

            public let key: String
            public let icon: String

            public let blueprint: ElementBlueprint?
        
            public let bundle: Bundle = Bundle(for: ElementBlueprint.self)

            public init(registry: [Group: [ElementBlueprint]]) {
                self.id = "com.spearway.q2success.elements"
                self.key = "com.spearway.q2success.elements"
                self.icon = "pencil.circle"
                self.blueprint = nil
                self.child = registry.map { (group, blueprints) in BlueprintNode(group: group, blueprints: blueprints) }
            }

            private init(group: Group, blueprints: [ElementBlueprint]) {
                self.id = group.rawValue
                self.key = group.rawValue
                self.icon = "pencil.circle"
                self.blueprint = nil
                self.child = blueprints.map { BlueprintNode(blueprint: $0) }
            }

            private init(blueprint: ElementBlueprint) {
                self.id = blueprint.id
                self.key = blueprint.name.rawValue
                self.icon = "pencil.circle"
                self.blueprint = blueprint
                self.child = nil
           }

        }


        @Published private(set) var nameRegistry = [String: Name]()
        @Published private(set) var groupRegistry = [String: Group]()
        @Published private(set) var groupNameRegistry = [Group: [Name]]()
        @Published private(set) var blueprintRegistry = [Group: [ElementBlueprint]]()
        
        fileprivate init() {
        }
        
        /**
         * Register a newly created name
         */
        fileprivate func register(name: Name) {
            guard self.nameRegistry[name.rawValue] == nil else {
                return
            }
            self.nameRegistry[name.rawValue] = name
        }
        
        /**
         * Register a newly created group
         */
        fileprivate func register(group: Group) {
            guard self.groupRegistry[group.rawValue] == nil else {
                return
            }
            self.groupRegistry[group.rawValue] = group
        }
        
        public func register(name: Name, for group: Group) {
            var list = self.groupNameRegistry[group] ?? [Name]()
            if !list.contains(name) {
                list.append(name)
            }
            self.groupNameRegistry[group] = list
        }
        
        /**
         Get the element name
         
         - Parameters:
         - name: Element name
         */
        public subscript(name: String) -> Name? {
            get {
                return self.nameRegistry[name]
            }
        }
        
        /**
         Get the element class
         
         - Parameters:
         - group: Element group
         */
        public subscript(group: String) -> Group? {
            get {
                return self.groupRegistry[group]
            }
        }
        
        /**
         Get the element names for a group
         
         - Parameters:
         - group: Element group
         */
        public subscript(group: Group) -> [Name] {
            get {
                return self.groupNameRegistry[group] ?? [Name]()
            }
        }
        
        /**
         Get all the declared names
         */
        public var names: [Name] {
            var list = [Name]()
            list.append(contentsOf: self.nameRegistry.values)
            return list
        }
        
        /**
         Get all the declared group
         */
        public var groups: [Group] {
            var list = [Group]()
            list.append(contentsOf: self.groupRegistry.values)
            return list
        }
        
        public func blueprint(for name: Name) -> ElementBlueprint {
            guard let blueprint = self.blueprints.filter({$0.name == name}).last else {
                fatalError("Unregistered blueprint for \(name)")
            }
            return blueprint
        }

        public func blueprint(for name: Name, in group: Group) -> ElementBlueprint {
            return blueprint(for: name)
        }

        public func blueprints(for group: Group) -> [ElementBlueprint] {
            return self.blueprintRegistry[group, default: [ElementBlueprint]()]
        }
        
        public var blueprints: [ElementBlueprint] {
            return self.blueprintRegistry.reduce(into: [ElementBlueprint]()) { (result, value) in
                result.append(contentsOf: value.value)
            }
        }
        
        public func add(blueprint: ElementBlueprint) {
            self.register(name: blueprint.name)
            self.register(group: blueprint.group)
            self.register(name: blueprint.name, for: blueprint.group)
            
            var list = self.blueprints(for: blueprint.group)
            if !list.contains(blueprint) {
                list.append(blueprint)
            }
            self.blueprintRegistry[blueprint.group] = list
        }
        
        public func add(blueprints: [ElementBlueprint]) {
            blueprints.forEach({ self.add(blueprint: $0) })
        }

        public var tree: BlueprintNode {
            return BlueprintNode(registry: self.blueprintRegistry)
        }

        public var description: String {
            var log = ""
            self.groups.forEach({ group in
                log = log + "\n" + group.description + ": " + self.blueprints(for: group).map({ $0.description }).joined(separator: ", ")
            })
            log = log + "\n"
          return log
        }

        public var debugDescription: String {
            return self.description
        }

    }
}

public extension ElementBlueprint {
    
    struct Connector: Hashable, Equatable, RawRepresentable, CustomStringConvertible, CustomDebugStringConvertible {
        
        public let rawValue: String
        
        public init(_ rawValue: String) {
            self.rawValue = rawValue
        }
        
        public init(rawValue: String) {
            self.rawValue = rawValue
        }
        
        public static func == (lhs: Connector, rhs: Connector) -> Bool {
            return lhs.rawValue == rhs.rawValue
        }
        
        public var description: String {
            return self.rawValue
        }
        
        public var debugDescription: String {
            return self.description
        }
        
    }
    
}

public extension ElementBlueprint.Connector {
    static let singleStreamConnector = ElementBlueprint.Connector("com.spearway.q2success.connector.stream.single")
    static let multipleStreamConnector = ElementBlueprint.Connector("com.spearway.q2success.connector.stream.multiple")
    static let scalarConnector = ElementBlueprint.Connector("com.apple.spearway.q2success.connector.scalar")
}
