//
//  CardSequence.swift
//
//
//  Created by pierre on 2023-11-23.
//

import Foundation

/*
 A card is a a presentation of a topic to study.
 */

public class CardSequenceBlueprint : CardElementBlueprint {

    public init() {
        super.init(.cardSequence)
    }

    public override func newInstance() -> Element  {
        return CardSequence()
    }

    public override var instanceType: Element.Type {
        return CardSequence.self
    }

}

public class CardSequence : CardElement {
    
    @Published private(set) public var cards: [Card]
 
    private enum CodingKeys : String, CodingKey {
        case cards
    }

    public override init() {
        self.cards = [Card]()
        super.init()
    }

    
    // MARK: - Coding

    required public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        self.cards = ElementCoddingWrapper.map(elementsWrappers: try container.decode([ElementCoddingWrapper].self, forKey: .cards)) as? [Card] ?? [Card]()
        
        try super.init(from: decoder)

        // Now we need to resolve the faults
        ElementCoddingWrapper.finalizeDecoding(from: decoder)
     }

    public override func encode(to encoder: Encoder) throws {
        try super.encode(to: encoder)
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        try container.encode(ElementCoddingWrapper.map(elements: self.cards), forKey: .cards)
     }
     
    // MARK: - Boiler plate
    
    public override var description: String {
        return super.description
    }

    public static func == (lhs: CardSequence, rhs: CardSequence) -> Bool {
        return lhs.id == rhs.id
    }

}
