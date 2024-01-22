//
//  HtmlCardElement.swift
//
//
//  Created by pierre on 2023-11-23.
//

import Foundation



public class HtmlCardElementBlueprint : CardElementBlueprint {

    public init() {
        super.init(.cardHtml)
    }

    public override func newInstance() -> Element  {
        return HtmlCardElement()
    }

    public override var instanceType: Element.Type {
        return HtmlCardElement.self
    }

}

public class HtmlCardElement : CardElement, HtmlItem {
    
    @Published private(set) public var html: String

 
    private enum CodingKeys : String, CodingKey {
        case html
    }

    public override init() {
        self.html = ""
        super.init()
    }

    
    // MARK: - Coding

    required public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        self.html = try container.decode(String.self, forKey: .html)
        
        try super.init(from: decoder)

        // Now we need to resolve the faults
        ElementCoddingWrapper.finalizeDecoding(from: decoder)
    }

    public override func encode(to encoder: Encoder) throws {
        try super.encode(to: encoder)
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        try container.encode(self.html, forKey: .html)
    }
    
    // MARK: - Boiler plate
    
    public override var description: String {
        return super.description + "html \(self.html)"
    }
    
    public static func == (lhs: HtmlCardElement, rhs: HtmlCardElement) -> Bool {
        return lhs.id == rhs.id
    }
}
