//
//  Question.swift
//  
//
//  Created by pierre on 2021-05-16.
//

import Foundation


/*
 A question is about a topic and can be included in a quiz
 */


public class QuestionBlueprint : QuestionElementBlueprint {

    public init() {
        super.init(.question)
    }

    public override func newInstance() -> Element  {
        return Question()
    }

    public override var instanceType: Element.Type {
        return Question.self
    }

}

public class Question : Element {
    
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
    
    public static func == (lhs: Question, rhs: Question) -> Bool {
        return lhs.id == rhs.id
    }
    
}
