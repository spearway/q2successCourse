//
//  Connection.swift
//
//
//  Created by pierre on 2023-04-08.
//

import Foundation

/*
 A connection is the relation between 2 elements (node) in the graph
 */
public class Connection: ObservableObject, IdentifiableElement, Codable, Equatable {

    public let id: UUID
    @Published private(set) var from: Element
    @Published private(set) var to: Element

    public var isFault: Bool {
        return false
    }

    private enum CodingKeys : String, CodingKey {
        case id
        case from
        case to
    }

    public init(from: Element, to: Element) {
        self.id = UUID()
        self.from = from
        self.to = to
    }

    // MARK: - Coding

    required public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        self.id = try container.decode(UUID.self, forKey: .id)
        self.from = try container.decode(ElementCoddingWrapper.self, forKey: .from).element
        self.to = try container.decode(ElementCoddingWrapper.self, forKey: .to).element
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)

        try container.encode(self.id, forKey: .id)
        try container.encode(ElementCoddingWrapper(self.from), forKey: .from)
        try container.encode(ElementCoddingWrapper(self.to), forKey: .to)
    }

    // MARK: - Boiler plate

    public var description: String {
        return "id: \(self.id.uuidString), from: \(self.from.description), to: \(self.to.description)"
    }

    public var debugDescription: String {
        return self.description
    }

    public static func == (lhs: Connection, rhs: Connection) -> Bool {
        return lhs.id == rhs.id
    }

}

