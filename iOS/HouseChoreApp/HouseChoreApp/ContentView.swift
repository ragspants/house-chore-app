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
                StatRow(title: "Total Chores", value: "\(choreManager.chores.count)")
                StatRow(title: "Completed", value: "\(choreManager.completedChores.count)")
                StatRow(title: "Pending", value: "\(choreManager.pendingChores.count)")
                StatRow(title: "Overdue", value: "\(choreManager.overdueChores.count)")
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

struct SettingsView: View {
    @EnvironmentObject var choreManager: ChoreManager
    
    var body: some View {
        NavigationView {
            List {
                Section(header: Text("App Info")) {
                    HStack {
                        Text("Version")
                        Spacer()
                        Text("1.0.0")
                            .foregroundColor(.secondary)
                    }
                }
                
                Section(header: Text("Data")) {
                    Button("Clear All Chores") {
                        choreManager.chores.removeAll()
                    }
                    .foregroundColor(.red)
                }
            }
            .navigationTitle("Settings")
        }
    }
} 