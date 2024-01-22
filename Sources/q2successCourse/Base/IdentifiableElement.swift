//
//  IdentifiableElement.swift
//  
//
//  Created by pierre on 2021-05-16.
//

import Foundation

/*
 * This protocol enable unification during deserialization
 */
public protocol IdentifiableElement: Identifiable, CustomStringConvertible, CustomDebugStringConvertible {
    
    var id: UUID { get }
    
    var isFault: Bool { get }
    
}

public protocol Fault {

}

public extension IdentifiableElement {

    var isFault: Bool {
        return self is Fault
    }
    
    var debugDescription: String { self.description }

}
