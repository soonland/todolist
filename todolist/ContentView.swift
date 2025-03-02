import SwiftUI

struct Task: Identifiable, Codable {
    var id = UUID()
    var title: String
    var details: String
    var completed: Bool = false
}

struct TaskGroup: Identifiable, Codable {
    var id = UUID()
    var name: String
    var tasks: [Task]
}

class TaskViewModel: ObservableObject {
    @Published var groups: [TaskGroup] = [] {
        didSet {
            saveGroups()
        }
    }
    
    let key = "taskGroups"
    
    init() {
        loadGroups()
    }
    
    // Group Management
    func addGroup(name: String) {
        let newGroup = TaskGroup(id: UUID(), name: name, tasks: [])
        groups.append(newGroup)
    }
    
    func removeGroup(at offsets: IndexSet) {
        groups.remove(atOffsets: offsets)
    }
    
    func moveGroup(from source: IndexSet, to destination: Int) {
        groups.move(fromOffsets: source, toOffset: destination)
    }
    
    // Task Management within Groups
    func addTask(toGroup groupId: UUID, title: String, details: String) {
        if let groupIndex = groups.firstIndex(where: { $0.id == groupId }) {
            let newTask = Task(title: title, details: details)
            groups[groupIndex].tasks.append(newTask)
        }
    }
    
    func removeTask(fromGroup groupId: UUID, at offsets: IndexSet) {
        if let groupIndex = groups.firstIndex(where: { $0.id == groupId }) {
            groups[groupIndex].tasks.remove(atOffsets: offsets)
        }
    }
    
    func moveTask(inGroup groupId: UUID, from source: IndexSet, to destination: Int) {
        if let groupIndex = groups.firstIndex(where: { $0.id == groupId }) {
            groups[groupIndex].tasks.move(fromOffsets: source, toOffset: destination)
        }
    }
    
    func toggleTaskCompletion(inGroup groupId: UUID, taskId: UUID) {
        if let groupIndex = groups.firstIndex(where: { $0.id == groupId }),
           let taskIndex = groups[groupIndex].tasks.firstIndex(where: { $0.id == taskId }) {
            groups[groupIndex].tasks[taskIndex].completed.toggle()
        }
    }
    
    func updateTask(inGroup groupId: UUID, taskId: UUID, title: String, details: String) {
        if let groupIndex = groups.firstIndex(where: { $0.id == groupId }),
           let taskIndex = groups[groupIndex].tasks.firstIndex(where: { $0.id == taskId }) {
            groups[groupIndex].tasks[taskIndex].title = title
            groups[groupIndex].tasks[taskIndex].details = details
        }
    }
    
    func updateGroupName(_ groupId: UUID, newName: String) {
        if let groupIndex = groups.firstIndex(where: { $0.id == groupId }) {
            groups[groupIndex].name = newName
        }
    }
    
    func moveTaskToGroup(task: Task, fromGroupId: UUID, toGroupId: UUID) {
        guard fromGroupId != toGroupId,
              let fromGroupIndex = groups.firstIndex(where: { $0.id == fromGroupId }),
              let toGroupIndex = groups.firstIndex(where: { $0.id == toGroupId }),
              let taskIndex = groups[fromGroupIndex].tasks.firstIndex(where: { $0.id == task.id }) else {
            return
        }
        
        let taskToMove = groups[fromGroupIndex].tasks[taskIndex]
        groups[fromGroupIndex].tasks.remove(at: taskIndex)
        groups[toGroupIndex].tasks.append(taskToMove)
    }
    
    private func saveGroups() {
        if let encoded = try? JSONEncoder().encode(groups) {
            UserDefaults.standard.set(encoded, forKey: key)
        }
    }
    
    private func loadGroups() {
        if let savedGroups = UserDefaults.standard.data(forKey: key),
           let decodedGroups = try? JSONDecoder().decode([TaskGroup].self, from: savedGroups) {
            groups = decodedGroups
        }
    }
}

struct GroupSelectionView: View {
    @Environment(\.presentationMode) var presentationMode
    @ObservedObject var viewModel: TaskViewModel
    let currentGroupId: UUID
    let task: Task
    let onGroupSelected: (UUID) -> Void
    
    var body: some View {
        List {
            ForEach(viewModel.groups.filter { $0.id != currentGroupId }) { group in
                Button(action: {
                    onGroupSelected(group.id)
                    presentationMode.wrappedValue.dismiss()
                }) {
                    Text(group.name)
                        .foregroundColor(.primary)
                }
            }
        }
        .navigationBarTitle("Choisir un groupe")
        .navigationBarItems(leading: Button("Annuler") {
            presentationMode.wrappedValue.dismiss()
        })
    }
}

struct TaskDetailView: View {
    @ObservedObject var viewModel: TaskViewModel
    @Environment(\.presentationMode) var presentationMode
    let groupId: UUID
    var task: Task?
    
    @State private var title: String
    @State private var details: String
    @State private var isCompleted: Bool
    @State private var showDeleteAlert = false
    @State private var showMoveSheet = false
    
    init(viewModel: TaskViewModel, groupId: UUID, task: Task? = nil) {
        self.viewModel = viewModel
        self.groupId = groupId
        self.task = task
        _title = State(initialValue: task?.title ?? "")
        _details = State(initialValue: task?.details ?? "")
        _isCompleted = State(initialValue: task?.completed ?? false)
    }
    
    var body: some View {
        Form {
            TextField("Titre de la tâche", text: $title)
            TextEditor(text: $details)
                .frame(minHeight: 100)
                .overlay(
                    Group {
                        if details.isEmpty {
                            Text("Détails de la tâche")
                                .foregroundColor(.gray)
                                .padding(.leading, 5)
                                .padding(.top, 8)
                                .allowsHitTesting(false)
                        }
                    }
                )
            
            if task != nil {
                Button(action: {
                    viewModel.updateTask(inGroup: groupId, taskId: task!.id, title: title, details: details)
                    presentationMode.wrappedValue.dismiss()
                }) {
                    Text("Modifier")
                        .frame(maxWidth: .infinity)
                }
                .disabled(title.isEmpty)
                
                Button(action: {
                    if let taskId = task?.id {
                        viewModel.toggleTaskCompletion(inGroup: groupId, taskId: taskId)
                        presentationMode.wrappedValue.dismiss()
                    }
                }) {
                    Text(isCompleted ? "Réouvrir" : "Marquer comme terminé")
                        .frame(maxWidth: .infinity)
                }
                .tint(isCompleted ? .blue : .green)
                
                Button(action: {
                    showMoveSheet = true
                }) {
                    Text("Déplacer")
                        .frame(maxWidth: .infinity)
                }
                .tint(.orange)
                
                Button(role: .destructive) {
                    showDeleteAlert = true
                } label: {
                    Text("Supprimer")
                        .frame(maxWidth: .infinity)
                }
            } else {
                Button(action: {
                    viewModel.addTask(toGroup: groupId, title: title, details: details)
                    presentationMode.wrappedValue.dismiss()
                }) {
                    Text("Créer")
                        .frame(maxWidth: .infinity)
                }
                .disabled(title.isEmpty)
            }
        }
        .navigationBarTitle(task == nil ? "Nouvelle tâche" : "Modifier la tâche")
        .navigationBarItems(
            leading: Button("Annuler") {
                presentationMode.wrappedValue.dismiss()
            }
        )
        .sheet(isPresented: $showMoveSheet) {
            NavigationView {
                GroupSelectionView(
                    viewModel: viewModel,
                    currentGroupId: groupId,
                    task: task!,
                    onGroupSelected: { newGroupId in
                        viewModel.moveTaskToGroup(task: task!, fromGroupId: groupId, toGroupId: newGroupId)
                        presentationMode.wrappedValue.dismiss()
                    }
                )
            }
        }
        .alert("Supprimer la tâche ?", isPresented: $showDeleteAlert) {
            Button("Annuler", role: .cancel) {}
            Button("Supprimer", role: .destructive) {
                if let taskId = task?.id {
                    // Find task index
                    if let groupIndex = viewModel.groups.firstIndex(where: { $0.id == groupId }),
                       let taskIndex = viewModel.groups[groupIndex].tasks.firstIndex(where: { $0.id == taskId }) {
                        viewModel.removeTask(fromGroup: groupId, at: IndexSet([taskIndex]))
                        presentationMode.wrappedValue.dismiss()
                    }
                }
            }
        } message: {
            Text("Cette action est irréversible.")
        }
    }
}

struct ContentView: View {
    @StateObject var viewModel = TaskViewModel()
    @State private var isShowingTaskDetail = false
    @State private var isShowingGroupAlert = false
    @State private var groupNameInput = ""
    @State private var selectedGroup: TaskGroup?
    @State private var selectedTask: Task?
    @State private var groupToEdit: TaskGroup?
    
    var body: some View {
        NavigationView {
            List {
                ForEach(viewModel.groups) { group in
                    DisclosureGroup {
                        ForEach(group.tasks) { task in
                            HStack {
                                Button(action: {
                                    viewModel.toggleTaskCompletion(inGroup: group.id, taskId: task.id)
                                }) {
                                    Image(systemName: task.completed ? "checkmark.circle.fill" : "circle")
                                        .foregroundColor(task.completed ? .green : .gray)
                                }
                                
                                Text(task.title)
                                    .strikethrough(task.completed)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .contentShape(Rectangle())
                                    .onTapGesture {
                                        selectedGroup = group
                                        selectedTask = task
                                        isShowingTaskDetail = true
                                    }
                            }
                            .swipeActions(edge: .leading) {
                                Button(role: .none) {
                                    viewModel.toggleTaskCompletion(inGroup: group.id, taskId: task.id)
                                } label: {
                                    Label(task.completed ? "Réouvrir" : "Compléter", 
                                          systemImage: task.completed ? "arrow.uturn.backward" : "checkmark")
                                }
                                .tint(task.completed ? .blue : .green)
                            }
                        }
                        .onDelete { indices in
                            viewModel.removeTask(fromGroup: group.id, at: indices)
                        }
                        
                        Button(action: {
                            selectedGroup = group
                            selectedTask = nil
                            isShowingTaskDetail = true
                        }) {
                            HStack {
                                Image(systemName: "plus.circle.fill")
                                Text("Ajouter une tâche")
                            }
                            .foregroundColor(.blue)
                            .padding(.top, 8)
                        }
                    } label: {
                        HStack {
                            Text(group.name)
                            Spacer()
                            Text("\(group.tasks.filter { !$0.completed }.count) actives")
                                .foregroundColor(.gray)
                                .font(.caption)
                        }
                        .contextMenu {
                            Button(action: {
                                groupNameInput = group.name
                                groupToEdit = group
                                isShowingGroupAlert = true
                            }) {
                                Label("Modifier", systemImage: "pencil")
                            }
                        }
                    }
                }
                .onDelete(perform: viewModel.removeGroup)
                .onMove(perform: viewModel.moveGroup)
            }
            .navigationTitle("Groupes de tâches")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    EditButton()
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        groupNameInput = ""
                        groupToEdit = nil
                        isShowingGroupAlert = true
                    }) {
                        Image(systemName: "plus")
                    }
                }
            }
            .alert(groupToEdit == nil ? "Nouveau groupe" : "Modifier le groupe", isPresented: $isShowingGroupAlert) {
                TextField("Nom du groupe", text: $groupNameInput)
                Button("Annuler", role: .cancel) {
                    groupNameInput = ""
                    groupToEdit = nil
                }
                Button(groupToEdit == nil ? "Créer" : "Modifier") {
                    if !groupNameInput.isEmpty {
                        if let group = groupToEdit {
                            viewModel.updateGroupName(group.id, newName: groupNameInput)
                        } else {
                            viewModel.addGroup(name: groupNameInput)
                        }
                        groupNameInput = ""
                        groupToEdit = nil
                    }
                }
            }
            .sheet(isPresented: $isShowingTaskDetail) {
                if let group = selectedGroup {
                    TaskDetailView(viewModel: viewModel, groupId: group.id, task: selectedTask)
                }
            }
        }
    }
}

#Preview {
    ContentView()
}
