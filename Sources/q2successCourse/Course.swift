//
//  Course.swift
//  
//
//  Created by pierre on 2021-05-02.
//

// http://swiftjson.guide


import Foundation

/*
 A course is a set of cards sequences and quizes.
 */
public class Course : Element {
    
    @Published private(set) public var cardSequences: [CardSequence]
    @Published private(set) public var quizes: [Quiz]


 
    private enum CodingKeys : String, CodingKey {
        case cardSequences
        case quizes
    }

    public override init() {
        self.cardSequences = [CardSequence]()
        self.quizes = [Quiz]()
        super.init()
    }
    
    // MARK: - Coding

    required public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        self.cardSequences = ElementCoddingWrapper.map(elementsWrappers: try container.decode([ElementCoddingWrapper].self, forKey: .cardSequences)) as? [CardSequence] ?? [CardSequence]()
        self.quizes = ElementCoddingWrapper.map(elementsWrappers: try container.decode([ElementCoddingWrapper].self, forKey: .quizes)) as? [Quiz] ?? [Quiz]()
        
        try super.init(from: decoder)

        // Now we need to resolve the faults
        ElementCoddingWrapper.finalizeDecoding(from: decoder)
     }

    public override func encode(to encoder: Encoder) throws {
        try super.encode(to: encoder)
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        try container.encode(ElementCoddingWrapper.map(elements: self.cardSequences), forKey: .cardSequences)
        try container.encode(ElementCoddingWrapper.map(elements: self.quizes), forKey: .quizes)
     }
 
    // MARK: - Connections

    @discardableResult
    public func addCardSequence(_ CardSequence: CardSequence, at index: Int = -1) -> CardSequence {
        guard let existing = self.cardSequences.filter({ $0 == CardSequence }).last else {
            self.cardSequences.append(CardSequence)
            return CardSequence
        }
        return existing
    }

    @discardableResult
    public func removeCardSequence(_ CardSequence: CardSequence) -> CardSequence? {
        guard let existing = self.cardSequences.filter({ $0 == CardSequence }).last else {
            return nil
        }
        self.cardSequences = self.cardSequences.filter({ $0 != CardSequence })
        return existing
    }

    @discardableResult
    public func addQuiz(_ Quiz: Quiz, at index: Int = -1) -> Quiz {
        self.quizes.append(Quiz)
        return Quiz
    }

    @discardableResult
    public func removeQuiz(_ Quiz: Quiz) -> Quiz? {
        guard let existing = self.quizes.filter({ $0 == Quiz }).last else {
            return nil
        }
        self.quizes = self.quizes.filter({ $0 != Quiz })
        return existing
    }

    // MARK: - NS Document support

    public var isEmpty: Bool {
        return self.cardSequences.isEmpty && self.quizes.isEmpty
    }

    public func data() throws -> Data {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        encoder.userInfo = [.processedElements:Processed<Element>(), .processedConnections:Processed<Connection>()]
        return try encoder.encode(self)
    }

    public static func read(from data: Data) throws -> Course {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        decoder.userInfo = [.processedElements:Processed<Element>(), .processedConnections:Processed<Connection>()]
        return try decoder.decode(Course.self, from: data)
    }

    public func read(from data: Data) throws {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        decoder.userInfo = [.processedElements:Processed<Element>(), .processedConnections:Processed<Connection>()]
        let newCourse = try decoder.decode(Course.self, from: data)
        self.id = newCourse.id
        self.cardSequences = newCourse.cardSequences
        self.quizes = newCourse.quizes
    }

    
    // MARK: - Boiler plate
    
    public override var description: String {
        return super.description
    }

    public static func == (lhs: Course, rhs: Course) -> Bool {
        return lhs.id == rhs.id
    }
    
}
