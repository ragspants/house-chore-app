import SwiftUI

struct ChoreListView: View {
    @EnvironmentObject var choreManager: ChoreManager
    @State private var showingAddChore = false
    @State private var searchText = ""
    @State private var selectedFilter: ChoreFilter = .all
    
    enum ChoreFilter {
        case all, pending, completed
    }
    
    var filteredChores: [Chore] {
        let chores = choreManager.chores.filter { chore in
            searchText.isEmpty || chore.title.localizedCaseInsensitiveContains(searchText)
        }
        
        switch selectedFilter {
        case .all:
            return chores
        case .pending:
            return chores.filter { !$0.isCompleted }
        case .completed:
            return chores.filter { $0.isCompleted }
        }
    }
    
    var body: some View {
        NavigationView {
            VStack {
                Picker("Filter", selection: $selectedFilter) {
                    Text("All").tag(ChoreFilter.all)
                    Text("Pending").tag(ChoreFilter.pending)
                    Text("Completed").tag(ChoreFilter.completed)
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding()
                
                List {
                    ForEach(filteredChores) { chore in
                        NavigationLink(destination: ChoreDetailView(chore: chore)) {
                            ChoreRowView(chore: chore)
                        }
                    }
                    .onDelete(perform: deleteChores)
                }
                .searchable(text: $searchText, prompt: "Search chores")
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
            }
        }
    }
    
    private func deleteChores(offsets: IndexSet) {
        let choresToDelete = offsets.map { filteredChores[$0] }
        for chore in choresToDelete {
            choreManager.deleteChore(chore)
        }
    }
}

struct ChoreRowView: View {
    @EnvironmentObject var choreManager: ChoreManager
    let chore: Chore
    
    var body: some View {
        HStack {
            Button(action: {
                choreManager.toggleCompletion(for: chore)
            }) {
                Image(systemName: chore.isCompleted ? "checkmark.circle.fill" : "circle")
                    .foregroundColor(chore.isCompleted ? .green : .gray)
            }
            .buttonStyle(PlainButtonStyle())
            
            VStack(alignment: .leading, spacing: 4) {
                Text(chore.title)
                    .font(.headline)
                    .strikethrough(chore.isCompleted)
                
                Text(chore.description)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .lineLimit(1)
                
                HStack {
                    Text(chore.assignedTo)
                        .font(.caption)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 2)
                        .background(Color.blue.opacity(0.2))
                        .cornerRadius(4)
                    
                    Text(chore.category.rawValue)
                        .font(.caption)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 2)
                        .background(Color.orange.opacity(0.2))
                        .cornerRadius(4)
                    
                    Spacer()
                    
                    Text(chore.dueDate, style: .date)
                        .font(.caption)
                        .foregroundColor(chore.dueDate < Date() && !chore.isCompleted ? .red : .secondary)
                }
            }
        }
        .padding(.vertical, 4)
    }
} 