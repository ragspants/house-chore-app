import Foundation
import SwiftUI

struct Chore: Identifiable, Codable {
    let id = UUID()
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
        
        var color: Color {
            switch self {
            case .low: return .green
            case .medium: return .orange
            case .high: return .red
            }
        }
    }
    
    enum Category: String, CaseIterable, Codable {
        case kitchen = "Kitchen"
        case bathroom = "Bathroom"
        case livingRoom = "Living Room"
        case bedroom = "Bedroom"
        case laundry = "Laundry"
        case outdoor = "Outdoor"
        case other = "Other"
        
        var icon: String {
            switch self {
            case .kitchen: return "house.fill"
            case .bathroom: return "drop.fill"
            case .livingRoom: return "sofa.fill"
            case .bedroom: return "bed.double.fill"
            case .laundry: return "washer.fill"
            case .outdoor: return "leaf.fill"
            case .other: return "ellipsis.circle.fill"
            }
        }
    }
}

class ChoreManager: ObservableObject {
    @Published var chores: [Chore] = []
    
    init() {
        loadSampleData()
    }
    
    func addChore(_ chore: Chore) {
        chores.append(chore)
        saveChores()
    }
    
    func updateChore(_ chore: Chore) {
        if let index = chores.firstIndex(where: { $0.id == chore.id }) {
            chores[index] = chore
            saveChores()
        }
    }
    
    func deleteChore(_ chore: Chore) {
        chores.removeAll { $0.id == chore.id }
        saveChores()
    }
    
    func toggleCompletion(for chore: Chore) {
        if let index = chores.firstIndex(where: { $0.id == chore.id }) {
            chores[index].isCompleted.toggle()
            saveChores()
        }
    }
    
    var completedChores: [Chore] {
        chores.filter { $0.isCompleted }
    }
    
    var pendingChores: [Chore] {
        chores.filter { !$0.isCompleted }
    }
    
    var overdueChores: [Chore] {
        pendingChores.filter { $0.dueDate < Date() }
    }
    
    private func saveChores() {
        // In a real app, you'd save to UserDefaults or Core Data
        // For now, we'll just keep them in memory
    }
    
    private func loadSampleData() {
        chores = [
            Chore(
                title: "Wash Dishes",
                description: "Clean all dishes and put them away",
                assignedTo: "Mom",
                dueDate: Date().addingTimeInterval(3600),
                priority: .medium,
                isCompleted: false,
                category: .kitchen,
                createdAt: Date()
            ),
            Chore(
                title: "Vacuum Living Room",
                description: "Vacuum the entire living room area",
                assignedTo: "Dad",
                dueDate: Date().addingTimeInterval(7200),
                priority: .low,
                isCompleted: false,
                category: .livingRoom,
                createdAt: Date()
            ),
            Chore(
                title: "Take Out Trash",
                description: "Empty all trash bins and take to curb",
                assignedTo: "Teen",
                dueDate: Date().addingTimeInterval(-3600), // Overdue
                priority: .high,
                isCompleted: false,
                category: .other,
                createdAt: Date()
            ),
            Chore(
                title: "Do Laundry",
                description: "Wash, dry, and fold all dirty clothes",
                assignedTo: "Mom",
                dueDate: Date().addingTimeInterval(10800),
                priority: .medium,
                isCompleted: true,
                category: .laundry,
                createdAt: Date()
            )
        ]
    }
} 