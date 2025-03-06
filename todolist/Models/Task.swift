import SwiftUI

struct Task: Identifiable, Codable {
    var id = UUID()
    var title: String
    var details: String
    var status: TaskStatus = .todo
    var priority: TaskPriority = .medium
    var groupId: UUID?
}

enum TaskStatus: String, Codable, CaseIterable {
    case todo = "À faire"
    case inProgress = "En cours"
    case done = "Terminé"
}

enum TaskPriority: String, Codable, CaseIterable {
    case low = "Basse"
    case medium = "Moyenne"
    case high = "Haute"
}
