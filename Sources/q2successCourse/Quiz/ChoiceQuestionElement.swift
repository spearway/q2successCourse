//
//  ChoiceQuestionElement.swift
//
//
//  Created by pierre on 2023-10-23.
//

import Foundation


public class ChoiceQuestionElementBlueprint : QuestionElementBlueprint {

    public init() {
        super.init(.questionChoice)
    }

    public override func newInstance() -> Element  {
        return ChoiceQuestionElement()
    }

    public override var instanceType: Element.Type {
        return ChoiceQuestionElement.self
    }

}

public class ChoiceQuestionElement : QuestionElement {
    
    
    
    
    
}
