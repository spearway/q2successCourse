//
//  IconCardElement.swift
//
//
//  Created by pierre on 2023-11-19.
//

import Foundation



public class IconCardElementBlueprint : CardElementBlueprint {

    public init() {
        super.init(.cardIcon)
    }

    public override func newInstance() -> Element  {
        return IconCardElement()
    }

    public override var instanceType: Element.Type {
        return IconCardElement.self
    }

}

public class IconCardElement : CardElement, IconItem {
    
    
    
    
    
}
