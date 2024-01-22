//
//  QuestionElement.swift
//
//
//  Created by pierre on 2023-10-22.
//

import Foundation

public extension ElementBlueprint.Group {
    static let question = ElementBlueprint.Group("com.spearway.q2success.course.question")
}

public extension ElementBlueprint.Name {
    static let quiz = ElementBlueprint.Name("com.spearway.q2success.course.quiz")
    static let question = ElementBlueprint.Name("com.spearway.q2success.course.question")
    static let questionChoice = ElementBlueprint.Name("com.spearway.q2success.course.question.choice")
}

public class QuestionElementBlueprint : ElementBlueprint {
    
    
    init(_ name: ElementBlueprint.Name) {
        super.init(name, group: .question)
    }

    public static let allBlueprints = [
        QuizBlueprint(),
        QuestionBlueprint(),
        ChoiceQuestionElementBlueprint() 
    ]


}

public class QuestionElement : Element {
    
}
