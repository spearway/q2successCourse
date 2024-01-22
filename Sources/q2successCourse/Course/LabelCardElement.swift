//
//  LabelCardElement.swift
//  
//
//  Created by pierre on 2023-10-23.
//

import Foundation


public class LabelCardElementBlueprint : CardElementBlueprint {

    public init() {
        super.init(.cardLabel)
    }

    public override func newInstance() -> Element  {
        return LabelCardElement()
    }

    public override var instanceType: Element.Type {
        return LabelCardElement.self
    }

}

public class LabelCardElement : CardElement, LabelItem {
    
    @Published private(set) public var label: String

 
    private enum CodingKeys : String, CodingKey {
        case label
    }

    public override init() {
        self.label = ""
        super.init()
    }

    
    // MARK: - Coding

    required public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        self.label = try container.decode(String.self, forKey: .label)
        
        try super.init(from: decoder)

        // Now we need to resolve the faults
        ElementCoddingWrapper.finalizeDecoding(from: decoder)
    }

    public override func encode(to encoder: Encoder) throws {
        try super.encode(to: encoder)
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        try container.encode(self.label, forKey: .label)
    }
    
    // MARK: - Boiler plate
    
    public override var description: String {
        return super.description + "label \(self.label)"
    }
    
    public static func == (lhs: LabelCardElement, rhs: LabelCardElement) -> Bool {
        return lhs.id == rhs.id
    }
}
