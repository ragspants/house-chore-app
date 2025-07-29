import Foundation
import SwiftUI

struct Chore: Identifiable, Codable {
    var id = UUID()
    var title: String
    var description: String
    var assignedTo: String
    var dueDate: Date
    var priority: Priority
    var isCompleted: Bool
    var category: Category
    var createdAt: Date
    
    enum Priority: String, CaseIterable, Codable {
        case low = "Low"
        case medium = "Medium"
        case high = "High"
    }
    
    enum Category: String, CaseIterable, Codable {
        case cleaning = "Cleaning"
        case laundry = "Laundry"
        case cooking = "Cooking"
        case maintenance = "Maintenance"
        case shopping = "Shopping"
        case other = "Other"
    }
}

class ChoreManager: ObservableObject {
    @Published var chores: [Chore] = []
    
    init() {
        loadSampleData()
    }
    
    func addChore(_ chore: Chore) {
        chores.append(chore)
    }
    
    func updateChore(_ chore: Chore) {
        if let index = chores.firstIndex(where: { $0.id == chore.id }) {
            chores[index] = chore
        }
    }
    
    func deleteChore(_ chore: Chore) {
        chores.removeAll { $0.id == chore.id }
    }
    
    func toggleCompletion(for chore: Chore) {
        if let index = chores.firstIndex(where: { $0.id == chore.id }) {
            chores[index].isCompleted.toggle()
        }
    }
    
    var completedChores: [Chore] {
        chores.filter { $0.isCompleted }
    }
    
    var pendingChores: [Chore] {
        chores.filter { !$0.isCompleted }
    }
    
    var overdueChores: [Chore] {
        chores.filter { !$0.isCompleted && $0.dueDate < Date() }
    }
    
    private func loadSampleData() {
        chores = [
            Chore(title: "Wash Dishes", description: "Clean all dishes in the sink", assignedTo: "John", dueDate: Date().addingTimeInterval(3600), priority: .medium, isCompleted: false, category: .cleaning, createdAt: Date()),
            Chore(title: "Vacuum Living Room", description: "Vacuum the entire living room area", assignedTo: "Sarah", dueDate: Date().addingTimeInterval(7200), priority: .high, isCompleted: false, category: .cleaning, createdAt: Date()),
            Chore(title: "Grocery Shopping", description: "Buy groceries for the week", assignedTo: "Mike", dueDate: Date().addingTimeInterval(86400), priority: .high, isCompleted: false, category: .shopping, createdAt: Date()),
            Chore(title: "Do Laundry", description: "Wash and fold clothes", assignedTo: "Emma", dueDate: Date().addingTimeInterval(43200), priority: .medium, isCompleted: true, category: .laundry, createdAt: Date())
        ]
    }
} 