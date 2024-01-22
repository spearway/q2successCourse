//
//  TextCardElement.swift
//  
//
//  Created by pierre on 2023-11-19.
//

import Foundation


public class TextCardElementBlueprint : CardElementBlueprint {

    public init() {
        super.init(.cardText)
    }

    public override func newInstance() -> Element  {
        return TextCardElement()
    }

    public override var instanceType: Element.Type {
        return TextCardElement.self
    }

}

public class TextCardElement : CardElement, TextItem {
    
    @Published private(set) public var text: String

 
    private enum CodingKeys : String, CodingKey {
        case text
    }

    public override init() {
        self.text = ""
        super.init()
    }

    
    // MARK: - Coding

    required public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        self.text = try container.decode(String.self, forKey: .text)
        
        try super.init(from: decoder)

        // Now we need to resolve the faults
        ElementCoddingWrapper.finalizeDecoding(from: decoder)
    }

    public override func encode(to encoder: Encoder) throws {
        try super.encode(to: encoder)
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        try container.encode(self.text, forKey: .text)
    }
    
    // MARK: - Boiler plate
    
    public override var description: String {
        return super.description + "text \(self.text)"
    }
    
    public static func == (lhs: TextCardElement, rhs: TextCardElement) -> Bool {
        return lhs.id == rhs.id
    }
    
}
