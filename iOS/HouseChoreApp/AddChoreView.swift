import SwiftUI

struct AddChoreView: View {
    @EnvironmentObject var choreManager: ChoreManager
    @Environment(\.dismiss) private var dismiss
    
    @State private var title = ""
    @State private var description = ""
    @State private var assignedTo = ""
    @State private var dueDate = Date()
    @State private var priority = Chore.Priority.medium
    @State private var category = Chore.Category.other
    
    private let familyMembers = ["Mom", "Dad", "Teen", "Child", "Everyone"]
    
    var body: some View {
        NavigationView {
            Form {
                Section("Chore Details") {
                    TextField("Title", text: $title)
                    
                    TextField("Description", text: $description, axis: .vertical)
                        .lineLimit(3...6)
                }
                
                Section("Assignment") {
                    Picker("Assigned To", selection: $assignedTo) {
                        Text("Select...").tag("")
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
                    Button("Add Chore") {
                        addChore()
                    }
                    .disabled(title.isEmpty || assignedTo.isEmpty)
                    .frame(maxWidth: .infinity)
                    .foregroundColor(.blue)
                }
            }
            .navigationTitle("Add New Chore")
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
    
    private func addChore() {
        let newChore = Chore(
            title: title,
            description: description,
            assignedTo: assignedTo,
            dueDate: dueDate,
            priority: priority,
            isCompleted: false,
            category: category,
            createdAt: Date()
        )
        
        choreManager.addChore(newChore)
        dismiss()
    }
}

#Preview {
    AddChoreView()
        .environmentObject(ChoreManager())
} 