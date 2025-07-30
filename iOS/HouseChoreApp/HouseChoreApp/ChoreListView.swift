import SwiftUI

struct ChoreListView: View {
    @EnvironmentObject var choreManager: ChoreManager
    @State private var showingAddChore = false
    @State private var searchText = ""
    @State private var selectedFilter: ChoreFilter = .all
    @State private var showingClearOptions = false
    @State private var showConfetti = false
    
    enum ChoreFilter {
        case all, pending, completed, weekly
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
        case .weekly:
            return chores.filter { $0.isWeeklyChore }
        }
    }
    
    var body: some View {
        ZStack {
            NavigationView {
                VStack(spacing: 0) {
                    // Filter Picker
                    Picker("Filter", selection: $selectedFilter) {
                        Text("All").tag(ChoreFilter.all)
                        Text("Pending").tag(ChoreFilter.pending)
                        Text("Completed").tag(ChoreFilter.completed)
                        Text("Weekly").tag(ChoreFilter.weekly)
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    .padding()
                    
                    List {
                        Section(header: Text("Chores")) {
                            ForEach(filteredChores) { chore in
                                NavigationLink(destination: ChoreDetailView(chore: chore)) {
                                    ChoreRowView(chore: chore, onComplete: {
                                        print("🎉 Chore completed, triggering confetti")
                                        // Reset confetti state first, then trigger after a short delay
                                        showConfetti = false
                                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                            showConfetti = true
                                        }
                                    })
                                }
                            }
                            .onDelete(perform: deleteChores)
                            
                            if !choreManager.completedChores.isEmpty {
                                Button(action: {
                                    showingClearOptions = true
                                }) {
                                    HStack {
                                        Image(systemName: "trash.circle.fill")
                                            .foregroundColor(.red)
                                        Text("Clear Completed Tasks")
                                            .foregroundColor(.red)
                                    }
                                }
                            }
                        }
                    }
                    .searchable(text: $searchText, prompt: "Search chores")
                }
                .navigationTitle("Chores")
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
                .actionSheet(isPresented: $showingClearOptions) {
                    ActionSheet(
                        title: Text("Clear Completed Tasks"),
                        message: Text("Choose what to clear"),
                        buttons: [
                            .default(Text("Clear All Completed")) {
                                choreManager.clearCompletedChores()
                            },
                            .default(Text("Clear Only Weekly Completed")) {
                                choreManager.clearCompletedWeeklyChores()
                            },
                            .default(Text("Clear Only Manual Completed")) {
                                choreManager.clearCompletedManualChores()
                            },
                            .cancel()
                        ]
                    )
                }
            }
            
            if showConfetti {
                ConfettiView(isVisible: $showConfetti)
                    .allowsHitTesting(false)
                    .zIndex(9999)
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
    let onComplete: (() -> Void)?
    
    init(chore: Chore, onComplete: (() -> Void)? = nil) {
        self.chore = chore
        self.onComplete = onComplete
    }
    
    var body: some View {
        HStack {
            Button(action: {
                let wasCompleted = chore.isCompleted
                choreManager.toggleCompletion(for: chore)
                
                // Get the updated chore to check if it was just completed
                if let updatedChore = choreManager.chores.first(where: { $0.id == chore.id }) {
                    let isNowCompleted = updatedChore.isCompleted
                    
                    // Trigger completion callback if chore was just completed (changed from false to true)
                    if !wasCompleted && isNowCompleted {
                        print("🎉 Chore completed: \(chore.title)")
                        print("🎉 wasCompleted: \(wasCompleted), isNowCompleted: \(isNowCompleted)")
                        onComplete?()
                    }
                }
            }) {
                Image(systemName: chore.isCompleted ? "checkmark.circle.fill" : "circle")
                    .foregroundColor(chore.isCompleted ? .green : .gray)
            }
            .buttonStyle(PlainButtonStyle())
            
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(chore.title)
                        .font(.headline)
                        .strikethrough(chore.isCompleted)
                    
                    Spacer()
                    
                    if chore.isWeeklyChore {
                        Text("Weekly")
                            .font(.caption2)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(Color.blue.opacity(0.2))
                            .cornerRadius(4)
                    }
                }
                
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