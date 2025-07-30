import SwiftUI

struct ContentView: View {
    @StateObject private var choreManager = ChoreManager()
    
    var body: some View {
        TabView {
            ChoreListView()
                .environmentObject(choreManager)
                .tabItem {
                    Image(systemName: "list.bullet")
                    Text("Chores")
                }
            
            WeeklyView()
                .environmentObject(choreManager)
                .tabItem {
                    Image(systemName: "calendar")
                    Text("Weekly")
                }
            
            HouseholdView()
                .environmentObject(choreManager)
                .tabItem {
                    Image(systemName: "person.3")
                    Text("Household")
                }
            
            StatisticsView()
                .environmentObject(choreManager)
                .tabItem {
                    Image(systemName: "chart.bar.fill")
                    Text("Stats")
                }
        }
        .accentColor(.blue)
    }
}

struct WeeklyView: View {
    @EnvironmentObject var choreManager: ChoreManager
    @State private var showingAddTemplate = false
    @State private var showingActionSheet = false
    @State private var showingAddChore = false
    @State private var showingAddMember = false
    @State private var showingClearOptions = false
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Weekly Distribution Banner
                if choreManager.shouldDistributeWeeklyChores() {
                    WeeklyDistributionBanner()
                        .environmentObject(choreManager)
                }
                
                List {
                    Section(header: Text("Weekly Tasks")) {
                        ForEach(choreManager.weeklyChoreTemplates) { template in
                            WeeklyTemplateRow(template: template)
                        }
                        .onDelete(perform: deleteTemplates)
                    }
                    
                    Section(header: Text("This Week's Chores")) {
                        ForEach(choreManager.weeklyChores) { chore in
                            WeeklyChoreRow(chore: chore)
                        }
                        
                        if !choreManager.completedWeeklyChores.isEmpty {
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
            }
            .navigationTitle("Weekly Chores")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        showingActionSheet = true
                    }) {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showingAddTemplate) {
                AddWeeklyTemplateView()
            }
            .sheet(isPresented: $showingAddChore) {
                AddChoreView()
            }
            .sheet(isPresented: $showingAddMember) {
                AddHouseholdMemberView()
            }
            .actionSheet(isPresented: $showingActionSheet) {
                ActionSheet(
                    title: Text("Add New"),
                    buttons: [
                        .default(Text("Add Weekly Task")) {
                            showingAddTemplate = true
                        },
                        .default(Text("Add Manual Chore")) {
                            showingAddChore = true
                        },
                        .cancel()
                    ]
                )
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
                        .cancel()
                    ]
                )
            }
        }
    }
    
    private func deleteTemplates(offsets: IndexSet) {
        let templatesToDelete = offsets.map { choreManager.weeklyChoreTemplates[$0] }
        for template in templatesToDelete {
            choreManager.removeWeeklyChoreTemplate(template)
        }
    }
}

struct WeeklyDistributionBanner: View {
    @EnvironmentObject var choreManager: ChoreManager
    @State private var isDistributing = false
    
    var body: some View {
        VStack(spacing: 16) {
            HStack {
                Image(systemName: "calendar.badge.clock")
                    .font(.title2)
                    .foregroundColor(.white)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("Weekly Distribution Ready")
                        .font(.headline)
                        .foregroundColor(.white)
                    
                    Text("\(choreManager.weeklyChoreTemplates.count) tasks • \(choreManager.activeHouseholdMembers.count) members")
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.8))
                }
                
                Spacer()
            }
            
            HStack(spacing: 12) {
                Button(action: {
                    withAnimation(.easeInOut(duration: 0.3)) {
                        isDistributing = true
                    }
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                        choreManager.distributeWeeklyChores()
                        withAnimation(.easeInOut(duration: 0.3)) {
                            isDistributing = false
                        }
                    }
                }) {
                    HStack(spacing: 8) {
                        if isDistributing {
                            ProgressView()
                                .scaleEffect(0.8)
                                .progressViewStyle(CircularProgressViewStyle(tint: .blue))
                        } else {
                            Image(systemName: "arrow.triangle.2.circlepath")
                        }
                        
                        Text(isDistributing ? "Distributing..." : "Distribute Now")
                            .fontWeight(.semibold)
                    }
                    .foregroundColor(.blue)
                    .padding(.horizontal, 24)
                    .padding(.vertical, 12)
                    .background(Color.white)
                    .cornerRadius(10)
                }
                .disabled(isDistributing)
                
                Button(action: {
                    // Preview functionality
                }) {
                    HStack(spacing: 6) {
                        Image(systemName: "eye")
                        Text("Preview")
                            .fontWeight(.medium)
                    }
                    .foregroundColor(.white)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
                    .background(Color.white.opacity(0.2))
                    .cornerRadius(10)
                }
                .disabled(isDistributing)
            }
        }
        .padding(20)
        .background(
            LinearGradient(
                gradient: Gradient(colors: [Color.blue, Color.blue.opacity(0.8)]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .cornerRadius(16)
        .shadow(color: .blue.opacity(0.3), radius: 8, x: 0, y: 4)
        .padding(.horizontal)
        .padding(.top)
    }
}

struct WeeklyTemplateRow: View {
    let template: WeeklyChoreTemplate
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text(template.title)
                    .font(.headline)
                
                Spacer()
                
                Text("\(template.estimatedTime) min")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Text(template.description)
                .font(.caption)
                .foregroundColor(.secondary)
            
            HStack {
                Text(template.category.rawValue)
                    .font(.caption)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 2)
                    .background(Color.orange.opacity(0.2))
                    .cornerRadius(4)
                
                Text(template.priority.rawValue)
                    .font(.caption)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 2)
                    .background(priorityColor.opacity(0.2))
                    .cornerRadius(4)
            }
        }
        .padding(.vertical, 4)
    }
    
    private var priorityColor: Color {
        switch template.priority {
        case .high: return .red
        case .medium: return .orange
        case .low: return .green
        }
    }
}

struct WeeklyChoreRow: View {
    @EnvironmentObject var choreManager: ChoreManager
    let chore: Chore
    @State private var showConfetti = false
    
    var body: some View {
        ZStack {
            HStack {
                Button(action: {
                    let wasCompleted = chore.isCompleted
                    choreManager.toggleCompletion(for: chore)
                    
                    // Show confetti if chore was just completed
                    if !wasCompleted && chore.isCompleted {
                        showConfetti = true
                    }
                }) {
                    Image(systemName: chore.isCompleted ? "checkmark.circle.fill" : "circle")
                        .foregroundColor(chore.isCompleted ? .green : .gray)
                }
                .buttonStyle(PlainButtonStyle())
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(chore.title)
                        .font(.headline)
                        .strikethrough(chore.isCompleted)
                    
                    HStack {
                        Text(chore.assignedTo)
                            .font(.caption)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 2)
                            .background(Color.blue.opacity(0.2))
                            .cornerRadius(4)
                        
                        Spacer()
                        
                        Text(chore.dueDate, style: .date)
                            .font(.caption)
                            .foregroundColor(chore.dueDate < Date() && !chore.isCompleted ? .red : .secondary)
                    }
                }
            }
            
            if showConfetti {
                ConfettiView(isVisible: $showConfetti)
            }
        }
        .padding(.vertical, 4)
    }
}

struct HouseholdView: View {
    @EnvironmentObject var choreManager: ChoreManager
    @State private var showingAddMember = false
    @State private var showingActionSheet = false
    @State private var showingAddChore = false
    @State private var showingAddTemplate = false
    
    var body: some View {
        NavigationView {
            List {
                Section(header: Text("Household Members")) {
                    ForEach(choreManager.householdMembers) { member in
                        HouseholdMemberRow(member: member)
                    }
                    .onDelete(perform: deleteMembers)
                    
                    Button(action: {
                        showingAddMember = true
                    }) {
                        HStack {
                            Image(systemName: "person.badge.plus")
                                .foregroundColor(.blue)
                            Text("Add Member")
                                .foregroundColor(.blue)
                        }
                    }
                }
                
                Section(header: Text("Quick Stats")) {
                    StatRow(title: "Active Members", value: "\(choreManager.activeHouseholdMembers.count)")
                    StatRow(title: "Weekly Tasks", value: "\(choreManager.weeklyChoreTemplates.count)")
                    StatRow(title: "Last Distribution", value: choreManager.lastDistributionDate?.formatted(date: .abbreviated, time: .omitted) ?? "Never")
                }
            }
            .navigationTitle("Household")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        showingActionSheet = true
                    }) {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showingAddMember) {
                AddHouseholdMemberView()
            }
            .sheet(isPresented: $showingAddChore) {
                AddChoreView()
            }
            .sheet(isPresented: $showingAddTemplate) {
                AddWeeklyTemplateView()
            }
            .actionSheet(isPresented: $showingActionSheet) {
                ActionSheet(
                    title: Text("Add New"),
                    buttons: [
                        .default(Text("Add Weekly Task")) {
                            showingAddTemplate = true
                        },
                        .default(Text("Add Manual Chore")) {
                            showingAddChore = true
                        },
                        .cancel()
                    ]
                )
            }
        }
    }
    
    private func deleteMembers(offsets: IndexSet) {
        let membersToDelete = offsets.map { choreManager.householdMembers[$0] }
        for member in membersToDelete {
            choreManager.removeHouseholdMember(member)
        }
    }
}

struct HouseholdMemberRow: View {
    let member: HouseholdMember
    
    var body: some View {
        HStack {
            Circle()
                .fill(Color(hex: member.color))
                .frame(width: 12, height: 12)
            
            Text(member.name)
                .font(.headline)
            
            Spacer()
            
            if !member.isActive {
                Text("Inactive")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .opacity(member.isActive ? 1.0 : 0.6)
    }
}

struct StatisticsView: View {
    @EnvironmentObject var choreManager: ChoreManager
    
    var body: some View {
        NavigationView {
            List {
                Section(header: Text("Overview")) {
                    StatRow(title: "Total Chores", value: "\(choreManager.chores.count)")
                    StatRow(title: "Completed", value: "\(choreManager.completedChores.count)")
                    StatRow(title: "Pending", value: "\(choreManager.pendingChores.count)")
                    StatRow(title: "Overdue", value: "\(choreManager.overdueChores.count)")
                }
                
                Section(header: Text("Weekly Progress")) {
                    StatRow(title: "Weekly Chores", value: "\(choreManager.weeklyChores.count)")
                    StatRow(title: "Household Members", value: "\(choreManager.activeHouseholdMembers.count)")
                }
            }
            .navigationTitle("Statistics")
        }
    }
}

struct StatRow: View {
    let title: String
    let value: String
    
    var body: some View {
        HStack {
            Text(title)
            Spacer()
            Text(value)
                .fontWeight(.bold)
        }
    }
} 

// Color extension for hex support
extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }

        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
} 