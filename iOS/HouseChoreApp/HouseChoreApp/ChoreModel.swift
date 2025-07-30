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
    var isWeeklyChore: Bool = false
    var weekNumber: Int?
    
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

struct HouseholdMember: Identifiable, Codable {
    var id = UUID()
    var name: String
    var color: String // Store as hex string
    var isActive: Bool = true
}

struct WeeklyChoreTemplate: Identifiable, Codable {
    var id = UUID()
    var title: String
    var description: String
    var category: Chore.Category
    var estimatedTime: Int // in minutes
    var priority: Chore.Priority
}

class ChoreManager: ObservableObject {
    @Published var chores: [Chore] = []
    @Published var householdMembers: [HouseholdMember] = []
    @Published var weeklyChoreTemplates: [WeeklyChoreTemplate] = []
    @Published var lastDistributionDate: Date?
    
    init() {
        loadSampleData()
    }
    
    // MARK: - Household Management
    
    func addHouseholdMember(_ member: HouseholdMember) {
        householdMembers.append(member)
    }
    
    func removeHouseholdMember(_ member: HouseholdMember) {
        householdMembers.removeAll { $0.id == member.id }
        // Remove chores assigned to this member
        chores.removeAll { $0.assignedTo == member.name }
    }
    
    func updateHouseholdMember(_ member: HouseholdMember) {
        if let index = householdMembers.firstIndex(where: { $0.id == member.id }) {
            householdMembers[index] = member
        }
    }
    
    // MARK: - Weekly Chore Templates
    
    func addWeeklyChoreTemplate(_ template: WeeklyChoreTemplate) {
        weeklyChoreTemplates.append(template)
    }
    
    func removeWeeklyChoreTemplate(_ template: WeeklyChoreTemplate) {
        weeklyChoreTemplates.removeAll { $0.id == template.id }
    }
    
    func updateWeeklyChoreTemplate(_ template: WeeklyChoreTemplate) {
        if let index = weeklyChoreTemplates.firstIndex(where: { $0.id == template.id }) {
            weeklyChoreTemplates[index] = template
        }
    }
    
    // MARK: - Weekly Distribution
    
    func distributeWeeklyChores() {
        guard !householdMembers.isEmpty && !weeklyChoreTemplates.isEmpty else { return }
        
        let activeMembers = householdMembers.filter { $0.isActive }
        guard !activeMembers.isEmpty else { return }
        
        // Clear previous weekly chores
        chores.removeAll { $0.isWeeklyChore }
        
        // Get current week number
        let calendar = Calendar.current
        let weekNumber = calendar.component(.weekOfYear, from: Date())
        
        // Distribute chores evenly
        for (index, template) in weeklyChoreTemplates.enumerated() {
            let assignedMember = activeMembers[index % activeMembers.count]
            
            let chore = Chore(
                title: template.title,
                description: template.description,
                assignedTo: assignedMember.name,
                dueDate: getNextSunday(),
                priority: template.priority,
                isCompleted: false,
                category: template.category,
                createdAt: Date(),
                isWeeklyChore: true,
                weekNumber: weekNumber
            )
            
            chores.append(chore)
        }
        
        lastDistributionDate = Date()
    }
    
    private func getNextSunday() -> Date {
        let calendar = Calendar.current
        let today = Date()
        let weekday = calendar.component(.weekday, from: today)
        let daysUntilSunday = 7 - weekday + 1 // +1 because Sunday is 1
        return calendar.date(byAdding: .day, value: daysUntilSunday, to: today) ?? today
    }
    
    func shouldDistributeWeeklyChores() -> Bool {
        guard let lastDistribution = lastDistributionDate else { return true }
        
        let calendar = Calendar.current
        let today = Date()
        let daysSinceLastDistribution = calendar.dateComponents([.day], from: lastDistribution, to: today).day ?? 0
        
        return daysSinceLastDistribution >= 7
    }
    
    // MARK: - Chore Management
    
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
    
    func clearCompletedChores() {
        chores.removeAll { $0.isCompleted }
    }
    
    func clearCompletedWeeklyChores() {
        chores.removeAll { $0.isCompleted && $0.isWeeklyChore }
    }
    
    func clearCompletedManualChores() {
        chores.removeAll { $0.isCompleted && !$0.isWeeklyChore }
    }
    
    // MARK: - Computed Properties
    
    var completedChores: [Chore] {
        chores.filter { $0.isCompleted }
    }
    
    var pendingChores: [Chore] {
        chores.filter { !$0.isCompleted }
    }
    
    var overdueChores: [Chore] {
        chores.filter { !$0.isCompleted && $0.dueDate < Date() }
    }
    
    var weeklyChores: [Chore] {
        chores.filter { $0.isWeeklyChore }
    }
    
    var completedWeeklyChores: [Chore] {
        chores.filter { $0.isWeeklyChore && $0.isCompleted }
    }
    
    var manualChores: [Chore] {
        chores.filter { !$0.isWeeklyChore }
    }
    
    var activeHouseholdMembers: [HouseholdMember] {
        householdMembers.filter { $0.isActive }
    }
    
    // MARK: - Sample Data
    
    private func loadSampleData() {
        // Sample household members
        householdMembers = [
            HouseholdMember(name: "John", color: "#FF6B6B"),
            HouseholdMember(name: "Sarah", color: "#4ECDC4"),
            HouseholdMember(name: "Mike", color: "#45B7D1"),
            HouseholdMember(name: "Emma", color: "#96CEB4")
        ]
        
        // Sample weekly chore templates
        weeklyChoreTemplates = [
            WeeklyChoreTemplate(title: "Vacuum Living Room", description: "Vacuum the entire living room area", category: .cleaning, estimatedTime: 15, priority: .medium),
            WeeklyChoreTemplate(title: "Wash Dishes", description: "Clean all dishes in the sink", category: .cleaning, estimatedTime: 10, priority: .high),
            WeeklyChoreTemplate(title: "Do Laundry", description: "Wash and fold clothes", category: .laundry, estimatedTime: 30, priority: .medium),
            WeeklyChoreTemplate(title: "Grocery Shopping", description: "Buy groceries for the week", category: .shopping, estimatedTime: 45, priority: .high),
            WeeklyChoreTemplate(title: "Clean Bathroom", description: "Clean bathroom surfaces and fixtures", category: .cleaning, estimatedTime: 20, priority: .medium),
            WeeklyChoreTemplate(title: "Take Out Trash", description: "Empty all trash bins", category: .cleaning, estimatedTime: 5, priority: .low)
        ]
        
        // Sample manual chores
        chores = [
            Chore(title: "Fix Leaky Faucet", description: "Repair the kitchen faucet", assignedTo: "Mike", dueDate: Date().addingTimeInterval(86400), priority: .high, isCompleted: false, category: .maintenance, createdAt: Date()),
            Chore(title: "Organize Closet", description: "Sort and organize bedroom closet", assignedTo: "Sarah", dueDate: Date().addingTimeInterval(172800), priority: .low, isCompleted: true, category: .cleaning, createdAt: Date())
        ]
    }
} 