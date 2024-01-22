//
//  Card.swift
//  
//
//  Created by pierre on 2021-05-16.
//

import Foundation

/*
 A card is a a presentation of a topic to study.
 */

public class CardBlueprint : CardElementBlueprint {

    public init() {
        super.init(.card)
    }

    public override func newInstance() -> Element  {
        return Card()
    }

    public override var instanceType: Element.Type {
        return Card.self
    }

}


public class Card : CardElement {
    
    @Published private(set) public var elements: [CardElement]
 
    private enum CodingKeys : String, CodingKey {
        case elements
    }

    public override init() {
        self.elements = [CardElement]()
        super.init()
    }

    
    // MARK: - Coding

    required public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        self.elements = ElementCoddingWrapper.map(elementsWrappers: try container.decode([ElementCoddingWrapper].self, forKey: .elements)) as? [CardElement] ?? [CardElement]()
        
        try super.init(from: decoder)

        // Now we need to resolve the faults
        ElementCoddingWrapper.finalizeDecoding(from: decoder)
     }

    public override func encode(to encoder: Encoder) throws {
        try super.encode(to: encoder)
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        try container.encode(ElementCoddingWrapper.map(elements: self.elements), forKey: .elements)
     }
     
    // MARK: - Boiler plate
    
    public override var description: String {
        return super.description
    }

    public static func == (lhs: Card, rhs: Card) -> Bool {
        return lhs.id == rhs.id
    }

}
