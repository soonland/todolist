import SwiftUI

struct ContentView: View {
    @StateObject private var viewModel = TaskViewModel()
    @State private var showingNewGroupSheet = false
    @State private var showingNewTaskSheet = false
    @State private var showingActionSheet = false
    @State private var selectedGroup: TaskGroup?
    
    var body: some View {
        NavigationSplitView(columnVisibility: .constant(.all)) {
            List(selection: $selectedGroup) {
                Section {
                    Button(action: { selectedGroup = nil }) {
                        Label("Toutes les tâches", systemImage: "tray.fill")
                    }
                    .accessibilityIdentifier("allTasks")
                    .buttonStyle(.plain)
                    
                    ForEach(viewModel.groups) { group in
                        Button(action: { selectedGroup = group }) {
                            Label(group.name, systemImage: "folder.fill")
                        }
                        .buttonStyle(.plain)
                        .accessibilityIdentifier("group-\(group.id)")
                    }
                } header: {
                    Text("Groupes")
                }
            }
            .navigationTitle("ToDo List")
            .frame(minWidth: 250)
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button(action: { showingActionSheet = true }) {
                        Image(systemName: "plus")
                    }
                    .accessibilityLabel("Ajouter")
                    .accessibilityIdentifier("addButton")
                }
            }
        } detail: {
            TaskListView(
                tasks: selectedGroup == nil ? viewModel.tasks : viewModel.tasksForGroup(selectedGroup?.id),
                group: selectedGroup,
                viewModel: viewModel
            )
            .navigationTitle(selectedGroup?.name ?? "Toutes les tâches")
        }
        .confirmationDialog("Ajouter", isPresented: $showingActionSheet) {
            Button("Nouveau groupe") {
                showingNewGroupSheet = true
            }
            .accessibilityIdentifier("menuNewGroup")
            
            Button("Nouvelle tâche") {
                showingNewTaskSheet = true
            }
            .accessibilityIdentifier("menuNewTask")
        }
        .sheet(isPresented: $showingNewGroupSheet) {
            NewGroupView(viewModel: viewModel)
        }
        .sheet(isPresented: $showingNewTaskSheet) {
            NewTaskView(viewModel: viewModel, group: selectedGroup)
        }
    }
}

struct TaskListView: View {
    @State private var showingActionSheet = false
    @State private var showingNewTaskSheet = false
    let tasks: [Task]
    let group: TaskGroup?
    let viewModel: TaskViewModel
    
    var body: some View {
        NavigationStack {
            List {
                ForEach(TaskStatus.allCases, id: \.self) { status in
                    Section(header: Text(status.rawValue)) {
                        ForEach(tasks.filter { $0.status == status }) { task in
                            TaskRow(task: task, viewModel: viewModel)
                                .accessibilityIdentifier("task-\(task.id)")
                                .swipeActions(edge: .trailing) {
                                    Button(role: .destructive) {
                                        // Add delete action when implemented
                                    } label: {
                                        Label("Supprimer", systemImage: "trash")
                                    }
                                }
                                .swipeActions(edge: .leading) {
                                    if task.status != .done {
                                        Button {
                                            viewModel.updateTaskStatus(id: task.id, newStatus: .done)
                                        } label: {
                                            Label("Terminer", systemImage: "checkmark")
                                        }
                                        .tint(.green)
                                    } else {
                                        Button {
                                            viewModel.updateTaskStatus(id: task.id, newStatus: .todo)
                                        } label: {
                                            Label("À faire", systemImage: "arrow.uturn.backward")
                                        }
                                        .tint(.blue)
                                    }
                                }
                        }
                    }
                }
            }
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button(action: { showingNewTaskSheet = true }) {
                        Image(systemName: "plus")
                    }
                    .accessibilityLabel("Ajouter")
                    .accessibilityIdentifier("addButton")
                }
            }
            .sheet(isPresented: $showingNewTaskSheet) {
                NewTaskView(viewModel: viewModel, group: group)
            }
        }
    }
}

struct TaskRow: View {
    let task: Task
    let viewModel: TaskViewModel
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(task.title)
                .font(.headline)
            Text(task.details)
                .font(.subheadline)
                .foregroundColor(.secondary)
            HStack {
                Label(task.priority.rawValue, systemImage: "flag.fill")
                    .foregroundColor(priorityColor(task.priority))
                Spacer()
                if task.status == .done {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.green)
                }
            }
        }
        .padding(.vertical, 4)
    }
    
    private func priorityColor(_ priority: TaskPriority) -> Color {
        switch priority {
        case .low: return .green
        case .medium: return .orange
        case .high: return .red
        }
    }
}

struct NewTaskView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var viewModel: TaskViewModel
    let group: TaskGroup?
    
    @State private var title = ""
    @State private var details = ""
    @State private var priority = TaskPriority.medium
    
    var body: some View {
        NavigationStack {
            Form {
                TextField("Titre", text: $title)
                    .accessibilityIdentifier("title")
                TextField("Détails", text: $details)
                    .accessibilityIdentifier("details")
                Picker("Priorité", selection: $priority) {
                    ForEach(TaskPriority.allCases, id: \.self) { priority in
                        Text(priority.rawValue).tag(priority)
                    }
                }
                .accessibilityIdentifier("priorityPicker")
            }
            .navigationTitle("Nouvelle tâche")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Annuler") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Ajouter tâche") {
                        viewModel.addTask(
                            title: title,
                            details: details,
                            priority: priority,
                            groupId: group?.id
                        )
                        dismiss()
                    }
                    .disabled(title.isEmpty)
                    .accessibilityIdentifier("addButton")
                }
            }
        }
    }
}

struct NewGroupView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var viewModel: TaskViewModel
    
    @State private var name = ""
    @State private var description = ""
    
    var body: some View {
        NavigationStack {
            Form {
                TextField("Nom du groupe", text: $name)
                    .accessibilityIdentifier("groupName")
                TextField("Description", text: $description)
                    .accessibilityIdentifier("groupDescription")
            }
            .navigationTitle("Nouveau groupe")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Annuler") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Créer") {
                        viewModel.addGroup(name: name, description: description)
                        dismiss()
                    }
                    .disabled(name.isEmpty)
                    .accessibilityIdentifier("createGroupButton")
                }
            }
        }
    }
}

#Preview {
    ContentView()
}
