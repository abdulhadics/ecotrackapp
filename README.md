# EcoTrack Lite - Smart Sustainability Tracker 🌱

A beautiful Flutter app that helps users track eco-friendly daily habits and earn points for sustainable actions. Built with Hive for local storage, this app works completely offline and requires no paid APIs.

## ✨ Features

### 🏠 Dashboard
- **Points System**: Track your eco points and daily progress
- **Streak Counter**: Maintain daily habit streaks
- **Quick Actions**: Add habits and view progress easily
- **Eco Tips**: Daily motivational tips and quotes

### 📝 Habit Tracking
- **Add Custom Habits**: Create personalized eco-friendly habits
- **Category System**: Organize habits by type (Water, Energy, Waste, etc.)
- **Point Values**: Assign points based on habit difficulty
- **Completion Tracking**: Mark habits as done/undone
- **Date Selection**: Track habits for specific dates

### 📊 Analytics & Charts
- **Weekly Progress**: Visual charts showing your weekly habit completion
- **Statistics**: View total points, completion rates, and streaks
- **Category Breakdown**: See which eco categories you focus on most
- **Achievement Preview**: Quick view of recent accomplishments

### 🏆 Rewards & Badges
- **Achievement System**: Unlock badges for milestones
- **Progress Tracking**: See progress toward next badge
- **Category Badges**: Special badges for different habit categories
- **Motivational Quotes**: Encouraging messages based on your progress

### 👤 Profile & Settings
- **User Profile**: Customize name, avatar, and eco goals
- **Dark Mode**: Toggle between light and dark themes
- **Statistics**: View your personal eco journey stats
- **App Information**: Version and app details

## 🛠️ Technical Stack

- **Framework**: Flutter 3.0+
- **Local Storage**: Hive (NoSQL database)
- **State Management**: Provider
- **Charts**: FL Chart
- **Animations**: Lottie
- **UI**: Material Design 3 with custom theming
- **Fonts**: Google Fonts (Poppins)
- **Notifications**: Awesome Notifications

## 📱 Screenshots

The app features a modern, colorful interface with:
- Green color scheme representing sustainability
- Smooth animations and transitions
- Intuitive navigation with bottom tabs
- Beautiful cards and progress indicators
- Responsive design for all screen sizes

## 🚀 Getting Started

### Prerequisites
- Flutter SDK 3.0 or higher
- Dart SDK 3.0 or higher
- Android Studio / VS Code with Flutter extensions

### Installation

1. **Clone the repository**
   ```bash
   git clone <repository-url>
   cd ecotrack_lite
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Generate Hive adapters**
   ```bash
   flutter packages pub run build_runner build
   ```

4. **Run the app**
   ```bash
   flutter run
   ```

## 📁 Project Structure

```
lib/
├── main.dart                 # App entry point
├── models/                   # Data models
│   ├── habit_model.dart     # Habit data structure
│   ├── user_model.dart      # User profile data
│   └── badge_model.dart     # Achievement badges
├── services/                 # Business logic
│   └── hive_service.dart    # Local storage service
├── screens/                  # UI screens
│   ├── splash_screen.dart   # App launch screen
│   ├── home_screen.dart     # Main dashboard
│   ├── add_habit_screen.dart # Add new habits
│   ├── habit_list_screen.dart # View all habits
│   ├── summary_screen.dart  # Analytics & charts
│   ├── rewards_screen.dart  # Badges & achievements
│   └── profile_screen.dart  # User profile & settings
├── widgets/                  # Reusable components
│   ├── points_badge.dart    # Points display widget
│   └── habit_card.dart      # Individual habit card
└── utils/                    # Utilities & constants
    ├── constants.dart       # App constants & colors
    └── theme.dart           # Theme configuration
```

## 🎯 Team Development Guide

This project is designed for a 3-member student team:

### 👤 Person 1: Authentication & Dashboard
**Files to focus on:**
- `lib/screens/home_screen.dart`
- `lib/widgets/points_badge.dart`
- `lib/screens/profile_screen.dart`
- `lib/services/hive_service.dart` (user management)

**Responsibilities:**
- User profile management
- Dashboard UI and functionality
- Points system implementation
- Theme switching (dark/light mode)

### 👤 Person 2: Habit Tracker
**Files to focus on:**
- `lib/screens/add_habit_screen.dart`
- `lib/screens/habit_list_screen.dart`
- `lib/widgets/habit_card.dart`
- `lib/models/habit_model.dart`

**Responsibilities:**
- Habit CRUD operations
- Category system
- Habit completion tracking
- Form validation and UI

### 👤 Person 3: Analytics & Rewards
**Files to focus on:**
- `lib/screens/summary_screen.dart`
- `lib/screens/rewards_screen.dart`
- `lib/models/badge_model.dart`
- `lib/services/hive_service.dart` (analytics methods)

**Responsibilities:**
- Charts and analytics
- Badge system
- Progress tracking
- Statistics calculations

## 🔧 Key Features Implementation

### Hive Local Storage
- **No internet required**: All data stored locally
- **Fast performance**: Quick read/write operations
- **Type-safe**: Generated adapters for data models
- **Offline-first**: Works without any network connection

### Points System
- **Configurable points**: 5-50 points per habit
- **Category-based**: Different categories have different point values
- **Streak tracking**: Maintain daily completion streaks
- **Achievement unlocking**: Automatic badge unlocking based on points

### Modern UI/UX
- **Material Design 3**: Latest design guidelines
- **Custom theming**: Light and dark mode support
- **Smooth animations**: Lottie animations and transitions
- **Responsive design**: Works on all screen sizes
- **Accessibility**: Screen reader support and proper contrast

## 🎨 Customization

### Adding New Habit Categories
1. Update `HabitCategory` class in `habit_model.dart`
2. Add new category to the `all` list
3. Add icon mapping in the `icons` map
4. Update UI components to handle new category

### Adding New Badges
1. Add new badge to `BadgeDefinitions.allBadges` in `badge_model.dart`
2. Define required points and category
3. Badge will automatically appear in rewards screen

### Customizing Colors
1. Update `AppColors` class in `constants.dart`
2. Modify theme colors in `theme.dart`
3. Restart app to see changes

## 🐛 Troubleshooting

### Common Issues

1. **Build errors after adding new models**
   ```bash
   flutter packages pub run build_runner build --delete-conflicting-outputs
   ```

2. **Hive adapter not found**
   - Ensure you've run the build_runner command
   - Check that models have proper Hive annotations

3. **App not starting**
   - Check Flutter version compatibility
   - Run `flutter clean` and `flutter pub get`

## 📄 License

This project is created for educational purposes. Feel free to use and modify for learning.

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test thoroughly
5. Submit a pull request

## 📞 Support

For questions or issues:
- Check the troubleshooting section
- Review Flutter and Hive documentation
- Create an issue in the repository

---

**Happy Eco Tracking! 🌍✨**

Made with ❤️ using Flutter and Hive
