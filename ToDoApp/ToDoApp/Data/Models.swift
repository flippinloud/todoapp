//
//  Models.swift
//  ToDoApp
//
//  Created by Steve Gregory on 25/5/2023.
//

import Foundation

class ToDoModel: ObservableObject, Identifiable, Codable {
    @Published var id: Int
    @Published var title: String
    @Published var completed: Bool

    init(id: Int, title: String, completed: Bool) {
        self.id = id
        self.title = title
        self.completed = completed
    }

    enum CodingKeys: CodingKey {
        case id, title, completed
    }

    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = Int(try container.decode(Int.self, forKey: .id))
        title = try container.decode(String.self, forKey: .title)
        completed = try container.decode(Bool.self, forKey: .completed)
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(title, forKey: .title)
        try container.encode(completed, forKey: .completed)
    }
}
