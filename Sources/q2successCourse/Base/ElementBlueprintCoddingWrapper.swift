//
//  ElementBlueprintCoddingWrapper.swift
//  
//
//  Created by pierre on 2023-04-08.
//

import Foundation

public class ElementBlueprintCoddingWrapper: NSObject, Identifiable, Codable, NSSecureCoding {
    public let blueprint: ElementBlueprint
    public let id: String

    private enum CodingKeys : String, CodingKey {
        case blueprintName
    }

    public init(_ blueprint: ElementBlueprint) {
        self.blueprint = blueprint
        self.id = blueprint.name.rawValue
    }

    // MARK: Codable


    required public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        let name = try container.decode(ElementBlueprint.Name.self, forKey: .blueprintName)
        self.blueprint = ElementBlueprint.registry.blueprint(for: name)
        self.id = name.rawValue

    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)

        try container.encode(self.blueprint.name, forKey: .blueprintName)

    }

    // MARK: - NSSecureCoding

    public static var supportsSecureCoding = true

    public func encode(with coder: NSCoder) {
        coder.encode(blueprint.name.rawValue, forKey: CodingKeys.blueprintName.rawValue)
    }

    public required init?(coder decoder: NSCoder) {
        let name = (decoder.decodeObject(of: NSString.self, forKey: CodingKeys.blueprintName.rawValue) ?? "") as String
        let blueprint = ElementBlueprint.registry.blueprint(for: ElementBlueprint.Name(name))

        self.blueprint = blueprint
        self.id = blueprint.name.rawValue
    }

    // MARK: - Boiler plate

    public override var description: String {
        return "blueprint: \(self.blueprint)"
    }

    public override var debugDescription: String {
        return self.description
    }

    public static func == (lhs: ElementBlueprintCoddingWrapper, rhs: ElementBlueprintCoddingWrapper) -> Bool {
        return lhs.id == rhs.id
    }

}
