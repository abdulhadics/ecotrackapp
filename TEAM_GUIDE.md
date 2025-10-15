# EcoTrack Lite - Team Development Guide 👥

## 🎯 Project Overview

**EcoTrack Lite** is a Flutter app that helps users track eco-friendly daily habits and earn points for sustainable actions. The app uses Hive for local storage, making it completely offline and free to use.

## 👥 Team Roles & Responsibilities

### 👤 Person 1: Authentication & Dashboard
**Primary Focus:** User experience and main app flow

**Key Files:**
- `lib/screens/home_screen.dart` - Main dashboard
- `lib/widgets/points_badge.dart` - Points display widget
- `lib/screens/profile_screen.dart` - User profile management
- `lib/services/hive_service.dart` - User data management

**Tasks:**
- ✅ User profile setup and editing
- ✅ Dashboard UI with points and streak display
- ✅ Dark/light mode toggle
- ✅ Quick actions and navigation
- ✅ User statistics display

**How to work independently:**
1. Focus on the home screen and profile functionality
2. Test user data persistence with Hive
3. Implement theme switching
4. Add user-friendly error handling

### 👤 Person 2: Habit Tracker
**Primary Focus:** Core habit management functionality

**Key Files:**
- `lib/screens/add_habit_screen.dart` - Add new habits
- `lib/screens/habit_list_screen.dart` - View all habits
- `lib/widgets/habit_card.dart` - Individual habit display
- `lib/models/habit_model.dart` - Habit data structure

**Tasks:**
- ✅ Habit creation form with validation
- ✅ Habit list with filtering and sorting
- ✅ Habit completion tracking
- ✅ Category system implementation
- ✅ Points assignment system

**How to work independently:**
1. Start with the habit model and data structure
2. Build the add habit form with all validations
3. Create the habit list with filtering options
4. Implement habit completion logic

### 👤 Person 3: Analytics & Rewards
**Primary Focus:** Data visualization and gamification

**Key Files:**
- `lib/screens/summary_screen.dart` - Charts and analytics
- `lib/screens/rewards_screen.dart` - Badges and achievements
- `lib/models/badge_model.dart` - Badge system
- `lib/services/hive_service.dart` - Analytics methods

**Tasks:**
- ✅ Weekly progress charts using FL Chart
- ✅ Badge system with achievement unlocking
- ✅ Statistics calculations and display
- ✅ Category breakdown analysis
- ✅ Progress tracking toward goals

**How to work independently:**
1. Focus on the chart implementation first
2. Build the badge system and achievement logic
3. Create analytics calculations
4. Implement progress tracking

## 🛠️ Development Setup

### Prerequisites
```bash
# Ensure you have Flutter 3.0+
flutter --version

# Install dependencies
flutter pub get

# Generate Hive adapters
flutter packages pub run build_runner build
```

### Running the App
```bash
# Debug mode
flutter run --debug

# Release mode
flutter run --release
```

## 📱 App Architecture

### Data Flow
```
User Input → HiveService → Hive Database → UI Update
```

### Key Components
- **Models**: Define data structures (Habit, User, Badge)
- **Services**: Handle business logic and data persistence
- **Screens**: UI screens for different app sections
- **Widgets**: Reusable UI components
- **Utils**: Constants, themes, and helper functions

## 🔧 Working with Hive

### Adding New Data Fields
1. Update the model class with `@HiveField` annotation
2. Run `flutter packages pub run build_runner build`
3. Update the service methods to handle new fields

### Example:
```dart
@HiveField(8)
final String newField;
```

## 🎨 UI/UX Guidelines

### Color Scheme
- **Primary**: Green (#4CAF50) - represents sustainability
- **Secondary**: Blue (#2196F3) - represents water/clean energy
- **Accent**: Orange (#FF9800) - represents energy/warmth
- **Success**: Green (#4CAF50) - completed actions
- **Warning**: Orange (#FF9800) - attention needed
- **Error**: Red (#F44336) - errors and failures

### Typography
- **Font Family**: Poppins (Google Fonts)
- **Headings**: Bold, clear hierarchy
- **Body Text**: Readable, appropriate sizing
- **Buttons**: Clear call-to-action styling

### Spacing
- **Small**: 8px
- **Medium**: 16px
- **Large**: 24px
- **Extra Large**: 32px

## 🧪 Testing Strategy

### Unit Testing
- Test individual functions and methods
- Mock Hive service for isolated testing
- Test data validation and business logic

### Widget Testing
- Test UI components in isolation
- Test user interactions
- Test different states (loading, error, success)

### Integration Testing
- Test complete user flows
- Test data persistence
- Test navigation between screens

## 🐛 Common Issues & Solutions

### Build Errors
```bash
# Clean and rebuild
flutter clean
flutter pub get
flutter packages pub run build_runner build
```

### Hive Adapter Issues
- Ensure all models have proper `@HiveType` and `@HiveField` annotations
- Run build_runner after model changes
- Check that adapters are registered in the service

### UI Issues
- Check theme consistency
- Ensure proper error handling
- Test on different screen sizes

## 📋 Development Checklist

### Before Starting Work
- [ ] Pull latest changes from main branch
- [ ] Run `flutter pub get`
- [ ] Run `flutter packages pub run build_runner build`
- [ ] Test that app runs without errors

### During Development
- [ ] Follow the established code style
- [ ] Add comments for complex logic
- [ ] Test your changes thoroughly
- [ ] Update related documentation

### Before Submitting
- [ ] Run `flutter analyze` to check for issues
- [ ] Test on both light and dark themes
- [ ] Test on different screen sizes
- [ ] Ensure all features work as expected

## 🚀 Deployment

### Debug Build
```bash
flutter build apk --debug
```

### Release Build
```bash
flutter build apk --release
```

### App Bundle (for Play Store)
```bash
flutter build appbundle --release
```

## 📞 Communication

### Daily Standups
- What did you work on yesterday?
- What are you working on today?
- Any blockers or issues?

### Code Reviews
- Review each other's code before merging
- Provide constructive feedback
- Ask questions about implementation choices

### Issue Tracking
- Use GitHub issues for bug reports
- Use pull requests for feature additions
- Document any breaking changes

## 🎯 Success Metrics

### Technical Goals
- [ ] App runs without crashes
- [ ] All features work as designed
- [ ] Code is well-documented
- [ ] UI is responsive and accessible

### User Experience Goals
- [ ] Intuitive navigation
- [ ] Smooth animations and transitions
- [ ] Clear feedback for user actions
- [ ] Engaging gamification elements

## 📚 Learning Resources

### Flutter
- [Flutter Documentation](https://docs.flutter.dev/)
- [Flutter Widget Catalog](https://docs.flutter.dev/development/ui/widgets)
- [Material Design 3](https://m3.material.io/)

### Hive
- [Hive Documentation](https://docs.hivedb.dev/)
- [Hive Flutter Package](https://pub.dev/packages/hive_flutter)

### Charts
- [FL Chart Documentation](https://pub.dev/packages/fl_chart)

---

**Happy Coding! 🚀**

Remember: This is a learning project. Don't be afraid to experiment and ask questions. The goal is to build something great while learning Flutter and mobile development!

