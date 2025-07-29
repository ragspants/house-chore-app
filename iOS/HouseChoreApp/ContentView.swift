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
            
            StatisticsView()
                .environmentObject(choreManager)
                .tabItem {
                    Image(systemName: "chart.bar.fill")
                    Text("Stats")
                }
            
            SettingsView()
                .environmentObject(choreManager)
                .tabItem {
                    Image(systemName: "gear")
                    Text("Settings")
                }
        }
        .accentColor(.blue)
    }
}

struct StatisticsView: View {
    @EnvironmentObject var choreManager: ChoreManager
    
    var body: some View {
        NavigationView {
            List {
                Section("Overview") {
                    StatRow(title: "Total Chores", value: "\(choreManager.chores.count)")
                    StatRow(title: "Completed", value: "\(choreManager.completedChores.count)")
                    StatRow(title: "Pending", value: "\(choreManager.pendingChores.count)")
                    StatRow(title: "Overdue", value: "\(choreManager.overdueChores.count)")
                }
                
                Section("Categories") {
                    ForEach(Chore.Category.allCases, id: \.self) { category in
                        let count = choreManager.chores.filter { $0.category == category }.count
                        if count > 0 {
                            HStack {
                                Image(systemName: category.icon)
                                    .foregroundColor(.blue)
                                Text(category.rawValue)
                                Spacer()
                                Text("\(count)")
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
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
                .fontWeight(.semibold)
                .foregroundColor(.blue)
        }
    }
}

struct SettingsView: View {
    @EnvironmentObject var choreManager: ChoreManager
    
    var body: some View {
        NavigationView {
            List {
                Section("App Info") {
                    HStack {
                        Text("Version")
                        Spacer()
                        Text("1.0.0")
                            .foregroundColor(.secondary)
                    }
                    
                    HStack {
                        Text("Build")
                        Spacer()
                        Text("1")
                            .foregroundColor(.secondary)
                    }
                }
                
                Section("Data") {
                    Button("Clear All Chores") {
                        // Add confirmation dialog
                    }
                    .foregroundColor(.red)
                    
                    Button("Reset to Sample Data") {
                        // Reset to sample data
                    }
                    .foregroundColor(.blue)
                }
                
                Section("About") {
                    Text("House Chore App helps families manage household tasks efficiently. Track chores, assign responsibilities, and maintain a clean home together.")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            .navigationTitle("Settings")
        }
    }
}

#Preview {
    ContentView()
} 