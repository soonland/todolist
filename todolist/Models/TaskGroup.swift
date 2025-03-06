import Foundation

struct TaskGroup: Identifiable, Codable, Hashable {
    var id = UUID()
    var name: String
    var description: String
    var createdAt: Date
    
    init(name: String, description: String) {
        self.name = name
        self.description = description
        self.createdAt = Date()
    }
}
