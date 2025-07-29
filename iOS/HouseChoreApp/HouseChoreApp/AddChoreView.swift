import SwiftUI

struct AddChoreView: View {
    @EnvironmentObject var choreManager: ChoreManager
    @Environment(\.presentationMode) var presentationMode
    
    @State private var title = ""
    @State private var description = ""
    @State private var assignedTo = ""
    @State private var dueDate = Date()
    @State private var priority = Chore.Priority.medium
    @State private var category = Chore.Category.cleaning
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Chore Details")) {
                    TextField("Title", text: $title)
                    TextField("Description", text: $description)
                    TextField("Assigned To", text: $assignedTo)
                }
                
                Section(header: Text("Due Date")) {
                    DatePicker("Due Date", selection: $dueDate, displayedComponents: [.date, .hourAndMinute])
                }
                
                Section(header: Text("Priority")) {
                    Picker("Priority", selection: $priority) {
                        ForEach(Chore.Priority.allCases, id: \.self) { priority in
                            Text(priority.rawValue).tag(priority)
                        }
                    }
                    .pickerStyle(SegmentedPickerStyle())
                }
                
                Section(header: Text("Category")) {
                    Picker("Category", selection: $category) {
                        ForEach(Chore.Category.allCases, id: \.self) { category in
                            Text(category.rawValue).tag(category)
                        }
                    }
                    .pickerStyle(MenuPickerStyle())
                }
            }
            .navigationTitle("Add Chore")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        saveChore()
                    }
                    .disabled(title.isEmpty)
                }
            }
        }
    }
    
    private func saveChore() {
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
        presentationMode.wrappedValue.dismiss()
    }
} 