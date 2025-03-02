import SwiftUI

struct Task: Identifiable, Codable {
    var id = UUID()
    var title: String
    var details: String
    var status: TaskStatus = .todo
    var priority: TaskPriority = .medium
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

class TaskViewModel: ObservableObject {
    @Published var tasks: [Task] = []
    
    func addTask(title: String, details: String, priority: TaskPriority) {
        let newTask = Task(title: title, details: details, priority: priority)
        tasks.append(newTask)
    }
    
    func updateTaskStatus(id: UUID, newStatus: TaskStatus) {
        if let index = tasks.firstIndex(where: { $0.id == id }) {
            tasks[index].status = newStatus
        }
    }
}

struct ContentView: View {
    @StateObject var viewModel = TaskViewModel()
    @State private var newTaskTitle = ""
    @State private var newTaskDetails = ""
    @State private var selectedPriority = TaskPriority.medium

    var body: some View {
        NavigationView {
            VStack {
                TextField("Titre de la tâche", text: $newTaskTitle)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                TextField("Détails de la tâche", text: $newTaskDetails)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                Picker("Priorité", selection: $selectedPriority) {
                    ForEach(TaskPriority.allCases, id: \.self) { priority in
                        Text(priority.rawValue).tag(priority)
                    }
                }
                .pickerStyle(SegmentedPickerStyle())

                Button("Ajouter Tâche") {
                    guard !newTaskTitle.isEmpty else { return }
                    viewModel.addTask(title: newTaskTitle, details: newTaskDetails, priority: selectedPriority)
                    newTaskTitle = ""
                    newTaskDetails = ""
                }
                .padding()

                List {
                    ForEach(TaskStatus.allCases, id: \.self) { status in
                        Section(header: Text(status.rawValue)) {
                            ForEach(viewModel.tasks.filter { $0.status == status }) { task in
                                Text(task.title)
                            }
                        }
                    }
                }
            }
            .navigationTitle("Gestion de Tâches")
        }
    }
}

#Preview {
    ContentView()
}
