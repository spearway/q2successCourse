//
//  ImageCardElement.swift
//  
//
//  Created by pierre on 2023-11-19.
//

import Foundation


public class ImageCardElementBlueprint : CardElementBlueprint {

    public init() {
        super.init(.cardImage)
    }

    public override func newInstance() -> Element  {
        return ImageCardElement()
    }

    public override var instanceType: Element.Type {
        return ImageCardElement.self
    }

}

public class ImageCardElement : CardElement, ImageItem {
    
    
    
    
    
}
