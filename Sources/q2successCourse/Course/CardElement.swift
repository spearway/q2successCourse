//
//  CardElement.swift
//  
//
//  Created by pierre on 2023-10-22.
//

import Foundation

public extension ElementBlueprint.Group {
    static let card = ElementBlueprint.Group("com.spearway.q2success.course.card")
}

public extension ElementBlueprint.Name {
    static let card = ElementBlueprint.Name("com.spearway.q2success.course.card")
    static let cardSequence = ElementBlueprint.Name("com.spearway.q2success.course.card.sequence")
    static let cardLabel = ElementBlueprint.Name("com.spearway.q2success.course.card.label")
    static let cardIcon = ElementBlueprint.Name("com.spearway.q2success.course.card.icon")
    static let cardImage = ElementBlueprint.Name("com.spearway.q2success.course.card.image")
    static let cardText = ElementBlueprint.Name("com.spearway.q2success.course.card.text")
    static let cardHtml = ElementBlueprint.Name("com.spearway.q2success.course.card.html")
}

public class CardElementBlueprint : ElementBlueprint {
    
    
    init(_ name: ElementBlueprint.Name) {
        super.init(name, group: .card)
    }

    public static let allBlueprints = [
        CardBlueprint(),
        CardSequenceBlueprint(),
        HtmlCardElementBlueprint(),
        IconCardElementBlueprint(),
        ImageCardElementBlueprint(),
        LabelCardElementBlueprint(),
        TextCardElementBlueprint(),
    ]

}

public class CardElement : Element {
    
}
