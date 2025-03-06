import SwiftUI

class TaskViewModel: ObservableObject {
    @Published var tasks: [Task] = []
    @Published var groups: [TaskGroup] = []
    
    // MARK: - Task Management
    
    func addTask(title: String, details: String, priority: TaskPriority, groupId: UUID? = nil) {
        let newTask = Task(title: title, details: details, priority: priority, groupId: groupId)
        tasks.append(newTask)
    }
    
    func updateTaskStatus(id: UUID, newStatus: TaskStatus) {
        if let index = tasks.firstIndex(where: { $0.id == id }) {
            tasks[index].status = newStatus
        }
    }
    
    func moveTask(taskId: UUID, toGroupId: UUID?) {
        if let index = tasks.firstIndex(where: { $0.id == taskId }) {
            tasks[index].groupId = toGroupId
        }
    }
    
    // MARK: - Group Management
    
    func addGroup(name: String, description: String) {
        let newGroup = TaskGroup(name: name, description: description)
        groups.append(newGroup)
    }
    
    func deleteGroup(id: UUID) {
        groups.removeAll { $0.id == id }
        // Remove group reference from tasks
        for (index, task) in tasks.enumerated() {
            if task.groupId == id {
                tasks[index].groupId = nil
            }
        }
    }
    
    func updateGroup(id: UUID, name: String, description: String) {
        if let index = groups.firstIndex(where: { $0.id == id }) {
            groups[index].name = name
            groups[index].description = description
        }
    }
    
    // MARK: - Helpers
    
    func tasksForGroup(_ groupId: UUID?) -> [Task] {
        return tasks.filter { $0.groupId == groupId }
    }
    
    func ungroupedTasks() -> [Task] {
        return tasks.filter { $0.groupId == nil }
    }
}
