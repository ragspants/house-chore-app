import SwiftUI

struct ChoreDetailView: View {
    @EnvironmentObject var choreManager: ChoreManager
    @Environment(\.presentationMode) var presentationMode
    @State private var chore: Chore
    @State private var isEditing = false
    @State private var showConfetti = false
    
    init(chore: Chore) {
        _chore = State(initialValue: chore)
    }
    
    var body: some View {
        ZStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // Header
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Text(chore.title)
                                .font(.largeTitle)
                                .fontWeight(.bold)
                            
                            Spacer()
                            
                            Button(action: {
                                let wasCompleted = chore.isCompleted
                                choreManager.toggleCompletion(for: chore)
                                if let updatedChore = choreManager.chores.first(where: { $0.id == chore.id }) {
                                    chore = updatedChore
                                }
                                
                                // Show confetti if chore was just completed
                                if !wasCompleted && chore.isCompleted {
                                    showConfetti = true
                                }
                            }) {
                                Image(systemName: chore.isCompleted ? "checkmark.circle.fill" : "circle")
                                    .font(.title)
                                    .foregroundColor(chore.isCompleted ? .green : .gray)
                            }
                        }
                        
                        Text(chore.description)
                            .font(.body)
                            .foregroundColor(.secondary)
                    }
                
                Divider()
                
                // Details
                VStack(alignment: .leading, spacing: 12) {
                    DetailRow(title: "Assigned To", value: chore.assignedTo)
                    DetailRow(title: "Category", value: chore.category.rawValue)
                    DetailRow(title: "Priority", value: chore.priority.rawValue)
                    DetailRow(title: "Due Date", value: chore.dueDate, style: .medium)
                    DetailRow(title: "Created", value: chore.createdAt, style: .medium)
                    DetailRow(title: "Status", value: chore.isCompleted ? "Completed" : "Pending")
                }
                
                Spacer()
            }
            .padding()
        }
        
        if showConfetti {
            ConfettiView(isVisible: $showConfetti)
        }
        }
        .navigationTitle("Chore Details")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Edit") {
                    isEditing = true
                }
            }
        }
        .sheet(isPresented: $isEditing) {
            EditChoreView(chore: chore) { updatedChore in
                choreManager.updateChore(updatedChore)
                chore = updatedChore
            }
        }
    }
}

struct DetailRow: View {
    let title: String
    let value: String
    
    init(title: String, value: String) {
        self.title = title
        self.value = value
    }
    
    init(title: String, value: Date, style: DateFormatter.Style) {
        self.title = title
        let formatter = DateFormatter()
        formatter.dateStyle = style
        self.value = formatter.string(from: value)
    }
    
    var body: some View {
        HStack {
            Text(title)
                .fontWeight(.medium)
                .foregroundColor(.secondary)
            Spacer()
            Text(value)
                .fontWeight(.semibold)
        }
    }
}

struct EditChoreView: View {
    @Environment(\.presentationMode) var presentationMode
    @State private var chore: Chore
    let onSave: (Chore) -> Void
    
    init(chore: Chore, onSave: @escaping (Chore) -> Void) {
        _chore = State(initialValue: chore)
        self.onSave = onSave
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Chore Details")) {
                    TextField("Title", text: $chore.title)
                    TextField("Description", text: $chore.description)
                    TextField("Assigned To", text: $chore.assignedTo)
                }
                
                Section(header: Text("Due Date")) {
                    DatePicker("Due Date", selection: $chore.dueDate, displayedComponents: [.date, .hourAndMinute])
                }
                
                Section(header: Text("Priority")) {
                    Picker("Priority", selection: $chore.priority) {
                        ForEach(Chore.Priority.allCases, id: \.self) { priority in
                            Text(priority.rawValue).tag(priority)
                        }
                    }
                    .pickerStyle(SegmentedPickerStyle())
                }
                
                Section(header: Text("Category")) {
                    Picker("Category", selection: $chore.category) {
                        ForEach(Chore.Category.allCases, id: \.self) { category in
                            Text(category.rawValue).tag(category)
                        }
                    }
                    .pickerStyle(MenuPickerStyle())
                }
            }
            .navigationTitle("Edit Chore")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        onSave(chore)
                        presentationMode.wrappedValue.dismiss()
                    }
                    .disabled(chore.title.isEmpty)
                }
            }
        }
    }
} 