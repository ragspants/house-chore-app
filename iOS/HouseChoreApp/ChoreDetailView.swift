import SwiftUI

struct ChoreDetailView: View {
    let chore: Chore
    @EnvironmentObject var choreManager: ChoreManager
    @State private var showingEditSheet = false
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Header with completion status
                HStack {
                    VStack(alignment: .leading) {
                        Text(chore.title)
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .strikethrough(chore.isCompleted)
                        
                        Text(chore.description)
                            .font(.body)
                            .foregroundColor(.secondary)
                    }
                    
                    Spacer()
                    
                    Button(action: {
                        choreManager.toggleCompletion(for: chore)
                    }) {
                        Image(systemName: chore.isCompleted ? "checkmark.circle.fill" : "circle")
                            .font(.system(size: 40))
                            .foregroundColor(chore.isCompleted ? .green : .gray)
                    }
                }
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(12)
                
                // Status Card
                VStack(alignment: .leading, spacing: 12) {
                    Text("Status")
                        .font(.headline)
                    
                    HStack {
                        StatusBadge(
                            title: chore.isCompleted ? "Completed" : "Pending",
                            color: chore.isCompleted ? .green : .orange
                        )
                        
                        if !chore.isCompleted && chore.dueDate < Date() {
                            StatusBadge(title: "Overdue", color: .red)
                        }
                        
                        Spacer()
                    }
                }
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(12)
                
                // Details Card
                VStack(alignment: .leading, spacing: 12) {
                    Text("Details")
                        .font(.headline)
                    
                    DetailRow(icon: "person.fill", title: "Assigned to", value: chore.assignedTo)
                    DetailRow(icon: "calendar", title: "Due Date", value: formatDate(chore.dueDate))
                    DetailRow(icon: "flag.fill", title: "Priority", value: chore.priority.rawValue, color: chore.priority.color)
                    DetailRow(icon: chore.category.icon, title: "Category", value: chore.category.rawValue)
                    DetailRow(icon: "clock", title: "Created", value: formatDate(chore.createdAt))
                }
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(12)
                
                // Actions
                VStack(spacing: 12) {
                    Button(action: {
                        showingEditSheet = true
                    }) {
                        HStack {
                            Image(systemName: "pencil")
                            Text("Edit Chore")
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                    }
                    
                    Button(action: {
                        choreManager.deleteChore(chore)
                        // Navigate back
                    }) {
                        HStack {
                            Image(systemName: "trash")
                            Text("Delete Chore")
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.red)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                    }
                }
            }
            .padding()
        }
        .navigationTitle("Chore Details")
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $showingEditSheet) {
            EditChoreView(chore: chore)
                .environmentObject(choreManager)
        }
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}

struct StatusBadge: View {
    let title: String
    let color: Color
    
    var body: some View {
        Text(title)
            .font(.caption)
            .fontWeight(.semibold)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(color.opacity(0.2))
            .foregroundColor(color)
            .cornerRadius(8)
    }
}

struct DetailRow: View {
    let icon: String
    let title: String
    let value: String
    var color: Color = .primary
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(color)
                .frame(width: 20)
            
            Text(title)
                .foregroundColor(.secondary)
            
            Spacer()
            
            Text(value)
                .fontWeight(.medium)
        }
    }
}

struct EditChoreView: View {
    let chore: Chore
    @EnvironmentObject var choreManager: ChoreManager
    @Environment(\.dismiss) private var dismiss
    
    @State private var title: String
    @State private var description: String
    @State private var assignedTo: String
    @State private var dueDate: Date
    @State private var priority: Chore.Priority
    @State private var category: Chore.Category
    @State private var isCompleted: Bool
    
    private let familyMembers = ["Mom", "Dad", "Teen", "Child", "Everyone"]
    
    init(chore: Chore) {
        self.chore = chore
        _title = State(initialValue: chore.title)
        _description = State(initialValue: chore.description)
        _assignedTo = State(initialValue: chore.assignedTo)
        _dueDate = State(initialValue: chore.dueDate)
        _priority = State(initialValue: chore.priority)
        _category = State(initialValue: chore.category)
        _isCompleted = State(initialValue: chore.isCompleted)
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section("Chore Details") {
                    TextField("Title", text: $title)
                    
                    TextField("Description", text: $description, axis: .vertical)
                        .lineLimit(3...6)
                }
                
                Section("Status") {
                    Toggle("Completed", isOn: $isCompleted)
                }
                
                Section("Assignment") {
                    Picker("Assigned To", selection: $assignedTo) {
                        ForEach(familyMembers, id: \.self) { member in
                            Text(member).tag(member)
                        }
                    }
                    .pickerStyle(MenuPickerStyle())
                }
                
                Section("Schedule") {
                    DatePicker("Due Date", selection: $dueDate, displayedComponents: [.date, .hourAndMinute])
                }
                
                Section("Priority & Category") {
                    Picker("Priority", selection: $priority) {
                        ForEach(Chore.Priority.allCases, id: \.self) { priority in
                            HStack {
                                Circle()
                                    .fill(priority.color)
                                    .frame(width: 12, height: 12)
                                Text(priority.rawValue)
                            }
                            .tag(priority)
                        }
                    }
                    .pickerStyle(MenuPickerStyle())
                    
                    Picker("Category", selection: $category) {
                        ForEach(Chore.Category.allCases, id: \.self) { category in
                            HStack {
                                Image(systemName: category.icon)
                                    .foregroundColor(.blue)
                                Text(category.rawValue)
                            }
                            .tag(category)
                        }
                    }
                    .pickerStyle(MenuPickerStyle())
                }
                
                Section {
                    Button("Save Changes") {
                        saveChanges()
                    }
                    .disabled(title.isEmpty || assignedTo.isEmpty)
                    .frame(maxWidth: .infinity)
                    .foregroundColor(.blue)
                }
            }
            .navigationTitle("Edit Chore")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
    }
    
    private func saveChanges() {
        var updatedChore = chore
        updatedChore.title = title
        updatedChore.description = description
        updatedChore.assignedTo = assignedTo
        updatedChore.dueDate = dueDate
        updatedChore.priority = priority
        updatedChore.category = category
        updatedChore.isCompleted = isCompleted
        
        choreManager.updateChore(updatedChore)
        dismiss()
    }
}

#Preview {
    NavigationView {
        ChoreDetailView(chore: Chore(
            title: "Sample Chore",
            description: "This is a sample chore description",
            assignedTo: "Mom",
            dueDate: Date(),
            priority: .medium,
            isCompleted: false,
            category: .kitchen,
            createdAt: Date()
        ))
        .environmentObject(ChoreManager())
    }
} 