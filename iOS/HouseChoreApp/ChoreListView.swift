import SwiftUI

struct ChoreListView: View {
    @EnvironmentObject var choreManager: ChoreManager
    @State private var showingAddChore = false
    @State private var searchText = ""
    @State private var selectedFilter: FilterOption = .all
    
    enum FilterOption: String, CaseIterable {
        case all = "All"
        case pending = "Pending"
        case completed = "Completed"
        case overdue = "Overdue"
    }
    
    var filteredChores: [Chore] {
        let filtered = choreManager.chores.filter { chore in
            if searchText.isEmpty {
                return true
            } else {
                return chore.title.localizedCaseInsensitiveContains(searchText) ||
                       chore.description.localizedCaseInsensitiveContains(searchText) ||
                       chore.assignedTo.localizedCaseInsensitiveContains(searchText)
            }
        }
        
        switch selectedFilter {
        case .all:
            return filtered
        case .pending:
            return filtered.filter { !$0.isCompleted }
        case .completed:
            return filtered.filter { $0.isCompleted }
        case .overdue:
            return filtered.filter { !$0.isCompleted && $0.dueDate < Date() }
        }
    }
    
    var body: some View {
        NavigationView {
            VStack {
                // Filter Picker
                Picker("Filter", selection: $selectedFilter) {
                    ForEach(FilterOption.allCases, id: \.self) { filter in
                        Text(filter.rawValue).tag(filter)
                    }
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding(.horizontal)
                
                List {
                    ForEach(filteredChores) { chore in
                        NavigationLink(destination: ChoreDetailView(chore: chore)) {
                            ChoreRowView(chore: chore)
                        }
                    }
                    .onDelete(perform: deleteChores)
                }
                .searchable(text: $searchText, prompt: "Search chores...")
            }
            .navigationTitle("House Chores")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        showingAddChore = true
                    }) {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showingAddChore) {
                AddChoreView()
                    .environmentObject(choreManager)
            }
        }
    }
    
    private func deleteChores(offsets: IndexSet) {
        for index in offsets {
            let chore = filteredChores[index]
            choreManager.deleteChore(chore)
        }
    }
}

struct ChoreRowView: View {
    let chore: Chore
    @EnvironmentObject var choreManager: ChoreManager
    
    var body: some View {
        HStack {
            // Completion Checkbox
            Button(action: {
                choreManager.toggleCompletion(for: chore)
            }) {
                Image(systemName: chore.isCompleted ? "checkmark.circle.fill" : "circle")
                    .foregroundColor(chore.isCompleted ? .green : .gray)
                    .font(.title2)
            }
            .buttonStyle(PlainButtonStyle())
            
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(chore.title)
                        .font(.headline)
                        .strikethrough(chore.isCompleted)
                    
                    Spacer()
                    
                    // Priority indicator
                    Circle()
                        .fill(chore.priority.color)
                        .frame(width: 12, height: 12)
                }
                
                Text(chore.description)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .lineLimit(2)
                
                HStack {
                    Image(systemName: chore.category.icon)
                        .foregroundColor(.blue)
                        .font(.caption)
                    
                    Text(chore.category.rawValue)
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Spacer()
                    
                    Text("Assigned to \(chore.assignedTo)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                HStack {
                    Image(systemName: "calendar")
                        .foregroundColor(.orange)
                        .font(.caption)
                    
                    Text(dueDateText)
                        .font(.caption)
                        .foregroundColor(dueDateColor)
                    
                    Spacer()
                }
            }
        }
        .padding(.vertical, 4)
    }
    
    private var dueDateText: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .short
        
        if chore.dueDate < Date() && !chore.isCompleted {
            return "Overdue: \(formatter.string(from: chore.dueDate))"
        } else {
            return "Due: \(formatter.string(from: chore.dueDate))"
        }
    }
    
    private var dueDateColor: Color {
        if chore.isCompleted {
            return .green
        } else if chore.dueDate < Date() {
            return .red
        } else {
            return .secondary
        }
    }
}

#Preview {
    ChoreListView()
        .environmentObject(ChoreManager())
} 