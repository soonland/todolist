import SwiftUI

struct Task: Identifiable, Codable {
    var id = UUID()
    var title: String
    var details: String
    var completed: Bool = false // Track the completion status
}

class TaskViewModel: ObservableObject {
    @Published var tasks: [Task] = [] {
        didSet {
            saveTasks()
        }
    }
    
    let key = "tasks"
    
    init() {
        loadTasks()
    }
    
    func addTask(title: String, details: String) {
        let newTask = Task(title: title, details: details)
        tasks.append(newTask)
    }
    
    func removeTask(at offsets: IndexSet) {
        tasks.remove(atOffsets: offsets)
    }
    
    func moveTask(from source: IndexSet, to destination: Int) {
        tasks.move(fromOffsets: source, toOffset: destination)
    }
    
    func toggleTaskCompletion(id: UUID) {
        if let index = tasks.firstIndex(where: { $0.id == id }) {
            tasks[index].completed.toggle() // Toggle the completion status
        }
    }
    
    func saveTasks() {
        if let encoded = try? JSONEncoder().encode(tasks) {
            UserDefaults.standard.set(encoded, forKey: key)
        }
    }
    
    func loadTasks() {
        if let savedTasks = UserDefaults.standard.data(forKey: key),
           let decodedTasks = try? JSONDecoder().decode([Task].self, from: savedTasks) {
            tasks = decodedTasks
        }
    }
}

struct TaskDetailView: View {
    var task: Task
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(task.title)
                .font(.largeTitle)
                .padding()
            
            Text(task.details)
                .padding()
            
            Spacer()
        }
        .navigationTitle("Détail de la tâche")
    }
}

struct ContentView: View {
    @StateObject var viewModel = TaskViewModel()
    @State private var newTaskTitle = ""
    @State private var newTaskDetails = ""
    
    var body: some View {
        NavigationView {
            VStack {
                HStack {
                    VStack {
                        TextField("Nouvelle tâche", text: $newTaskTitle)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                        TextField("Détails", text: $newTaskDetails)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                    }
                    Button(action: {
                        guard !newTaskTitle.isEmpty else { return }
                        viewModel.addTask(title: newTaskTitle, details: newTaskDetails)
                        newTaskTitle = ""
                        newTaskDetails = ""
                    }) {
                        Image(systemName: "plus.circle.fill")
                            .foregroundColor(.blue)
                            .font(.largeTitle)
                    }
                }
                .padding()
                
                List {
                    ForEach(viewModel.tasks) { task in
                        HStack {
                            NavigationLink(destination: TaskDetailView(task: task)) {
                                Text(task.title)
                                    .strikethrough(task.completed) // Strike-through if completed
                                    .frame(maxWidth: .infinity, alignment: .leading)
                            }
                            .buttonStyle(PlainButtonStyle())

                            Button(action: {
                                if let index = viewModel.tasks.firstIndex(where: { $0.id == task.id }) {
                                    viewModel.removeTask(at: IndexSet(integer: index))
                                }
                            }) {
                                Image(systemName: "trash")
                                    .foregroundColor(.red)
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                        .swipeActions(edge: .leading) { // Change to `.leading` for swipe-left
                            if task.completed {
                                // Reopen task if it's completed
                                Button(action: {
                                    viewModel.toggleTaskCompletion(id: task.id)
                                }) {
                                    Label("Reopen", systemImage: "arrow.uturn.left.circle.fill")
                                }
                                .tint(.blue)
                            } else {
                                // Mark task as completed
                                Button(action: {
                                    viewModel.toggleTaskCompletion(id: task.id)
                                }) {
                                    Label("Complete", systemImage: "checkmark.circle.fill")
                                }
                                .tint(.green)
                            }
                        }
                    }
                    .onMove(perform: viewModel.moveTask)
                    .onDelete(perform: viewModel.removeTask)
                }
                .toolbar {
                    EditButton() // Automatically toggles edit mode for List
                }
            }
            .navigationTitle("To-Do List")
        }
    }
}

#Preview {
    ContentView()
}
