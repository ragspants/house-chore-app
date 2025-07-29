# House Chore App - iOS

A native iOS app built with SwiftUI to help families manage household chores and tasks efficiently.

## Features

- 📱 **Native iOS Experience**: Built with SwiftUI for optimal performance and native feel
- ✅ **Task Management**: Create, edit, and complete household chores
- 👥 **Family Assignment**: Assign tasks to different family members
- 📅 **Due Dates**: Set and track due dates with overdue notifications
- 🏷️ **Categories**: Organize chores by room/area (Kitchen, Bathroom, Living Room, etc.)
- 🔴 **Priority Levels**: Mark tasks as Low, Medium, or High priority
- 📊 **Statistics**: View completion rates and category breakdowns
- 🔍 **Search & Filter**: Find chores by status, category, or search terms
- 🎨 **Modern UI**: Clean, intuitive interface with iOS design guidelines

## Requirements

- iOS 17.0+
- Xcode 15.0+
- Swift 5.0+

## Installation

1. **Clone the repository**:
   ```bash
   git clone https://github.com/ragspants/house-chore-app.git
   cd house-chore-app/iOS
   ```

2. **Open in Xcode**:
   ```bash
   open HouseChoreApp.xcodeproj
   ```

3. **Build and Run**:
   - Select your target device (iPhone/iPad simulator or physical device)
   - Press `Cmd + R` to build and run the app

## Project Structure

```
HouseChoreApp/
├── HouseChoreAppApp.swift      # Main app entry point
├── ContentView.swift           # Main tab view with navigation
├── ChoreModel.swift           # Data models and business logic
├── ChoreListView.swift        # Main chore list with filtering
├── AddChoreView.swift         # Form to add new chores
├── ChoreDetailView.swift      # Detailed view and editing
├── Assets.xcassets/          # App icons and colors
└── Preview Content/          # SwiftUI preview assets
```

## Key Components

### Data Model
- `Chore`: Core data structure with all chore properties
- `ChoreManager`: Observable object managing chore data and operations
- Priority and Category enums with associated colors and icons

### Views
- **TabView**: Main navigation with Chores, Statistics, and Settings tabs
- **ChoreListView**: Main list with search, filtering, and swipe-to-delete
- **AddChoreView**: Form-based chore creation with validation
- **ChoreDetailView**: Detailed view with edit and delete options
- **StatisticsView**: Overview of completion rates and category breakdown

### Features
- **Real-time Updates**: All views update automatically when data changes
- **Search & Filter**: Filter by status (All, Pending, Completed, Overdue)
- **Swipe Actions**: Swipe to delete chores from the list
- **Form Validation**: Required fields prevent invalid data entry
- **Date Handling**: Smart due date formatting with overdue detection

## Development

### Adding New Features
1. **New Chore Properties**: Add to `Chore` struct in `ChoreModel.swift`
2. **New Views**: Create SwiftUI views in separate files
3. **Data Persistence**: Implement in `ChoreManager.saveChores()`

### Styling
- Uses iOS system colors and SF Symbols
- Consistent spacing and typography
- Accessibility support with proper labels

## Future Enhancements

- [ ] **Core Data Integration**: Persistent storage with Core Data
- [ ] **Notifications**: Local notifications for due dates
- [ ] **iCloud Sync**: Sync across family devices
- [ ] **Widgets**: iOS home screen widgets
- [ ] **Dark Mode**: Enhanced dark mode support
- [ ] **Voice Input**: Siri integration for adding chores
- [ ] **Photo Attachments**: Add photos to chores
- [ ] **Recurring Chores**: Set up repeating tasks

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test thoroughly
5. Submit a pull request

## License

MIT License - see main repository for details. 