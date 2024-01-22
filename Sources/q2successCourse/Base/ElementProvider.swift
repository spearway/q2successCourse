//
// ElementProvider.swift
//  
//
//  Created by pierre on 2023-04-09.
//

import Foundation
import UniformTypeIdentifiers

public final class ElementProvider: NSObject, NSItemProviderWriting, NSItemProviderReading, Identifiable {
    public enum ProviderError: Error {
        case unrecognizedIdentifier
    }

    public let blueprint: ElementBlueprint
    public var id: String {
        blueprint.id
    }

    public  init(blueprint: ElementBlueprint) {
        self.blueprint = blueprint
        super.init()
    }

    // MARK: - NSItemProviderWriting

    public static var writableTypeIdentifiersForItemProvider: [String] {
        return [UTType.data.identifier]
    }

    public var writableTypeIdentifiersForItemProvider: [String] {
        return [UTType.data.identifier]
    }

    public func loadData(withTypeIdentifier typeIdentifier: String, forItemProviderCompletionHandler completionHandler: @escaping (Data?, Error?) -> Void) -> Progress? {
        print("Item provider for \(typeIdentifier)")
        return Progress(totalUnitCount: 0)
    }

    public static func itemProviderVisibilityForRepresentation(withTypeIdentifier typeIdentifier: String) -> NSItemProviderRepresentationVisibility {
        return .ownProcess
    }

    public func itemProviderVisibilityForRepresentation(withTypeIdentifier typeIdentifier: String) -> NSItemProviderRepresentationVisibility {
        return .ownProcess
    }

    // MARK: - NSItemProviderReading

    public static var readableTypeIdentifiersForItemProvider: [String] {
        return [UTType.data.identifier]
    }

    public static func object(withItemProviderData data: Data, typeIdentifier: String) throws -> ElementProvider {
        if let blueprintWrapper = try NSKeyedUnarchiver.unarchivedObject(ofClass: ElementBlueprintCoddingWrapper.self,from: data) {
            return ElementProvider(blueprint: blueprintWrapper.blueprint)
        }
        throw ProviderError.unrecognizedIdentifier
    }


}
