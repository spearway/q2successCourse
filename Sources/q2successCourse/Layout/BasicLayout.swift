//
//  BasicLayout.swift
//
//
//  Created by pierre on 2023-11-24.
//

import Foundation

public class BasicLayout : Layout {
    
    private(set) public var id: UUID

    private enum CodingKeys : String, CodingKey {
        case id
    }

    public init() {
        self.id = UUID()
    }

    init(id: UUID) {
        self.id = id
    }
    
    // MARK: - Coding

    required public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        self.id = try container.decode(UUID.self, forKey: .id)
     }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        try container.encode(self.id, forKey: .id)
    }
 
    // MARK: - Boiler plate
    
    public var description: String {
        if self.isFault {
            return "id: \(self.id.uuidString) is fault"
        } else {
            return "id: \(self.id.uuidString) element"
        }
    }
    
    public static func == (lhs: BasicLayout, rhs: BasicLayout) -> Bool {
        return lhs.id == rhs.id
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

}
