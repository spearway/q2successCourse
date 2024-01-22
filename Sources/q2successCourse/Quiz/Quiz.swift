//
//  File.swift
//  
//
//  Created by pierre on 2021-05-16.
//

import Foundation

/*
 A Quiz is a set of questions to simulate a test
 */


public class QuizBlueprint : QuestionElementBlueprint {

    public init() {
        super.init(.quiz)
    }

    public override func newInstance() -> Element  {
        return Quiz()
    }

    public override var instanceType: Element.Type {
        return Quiz.self
    }

}


public class Quiz : Element {

    @Published private(set) public var questions: [Question]

    private enum CodingKeys : String, CodingKey {
        case questions
    }

    public override init() {
        self.questions = [Question]()
        super.init()
    }

    
    // MARK: - Coding

    required public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        self.questions = ElementCoddingWrapper.map(elementsWrappers: try container.decode([ElementCoddingWrapper].self, forKey: .questions)) as? [Question] ?? [Question]()
        
        try super.init(from: decoder)

        // Now we need to resolve the faults
        ElementCoddingWrapper.finalizeDecoding(from: decoder)
     }


    public override func encode(to encoder: Encoder) throws {
        try super.encode(to: encoder)
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        try container.encode(ElementCoddingWrapper.map(elements: self.questions), forKey: .questions)
    }

    
    
    
    
    // MARK: - Boiler plate
    
    public override var description: String {
        return super.description
    }

    public static func == (lhs: Quiz, rhs: Quiz) -> Bool {
        return lhs.id == rhs.id
    }
    
}
