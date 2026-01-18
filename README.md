# Shikokiroku (Record of thoughts)

A comprehensive reminder application with mobile recharge tracking functionality, built with **MVVM architecture**, **BLoC state management**, **GoRouter navigation**, and **SharedPreferences storage**.

## 🌟 Features

### General Reminders
- ✅ Create, edit, and delete reminders **from any screen**
- 📅 Set date and time for reminders
- 🔄 Recurring reminders (Daily, Weekly, Monthly, Yearly)
- 📂 Categorize reminders (Personal, Work, Health, Shopping, Bills, Other)
- 🔔 Push notifications
- ✔️ Mark reminders as complete
- 🔍 Search functionality
- 📊 View active, completed, and overdue reminders
- ⚡ Quick actions: Swipe to edit/delete, long-press for options
- 🗑️ Quick delete with undo option

### Mobile Recharge Tracking
- 📱 Track multiple mobile recharges
- ⏰ Automatic expiry reminders
- 📈 Visual validity progress bars
- 💰 Store operator, amount, and validity details
- 🔔 Customizable reminder days before expiry
- 📜 Complete recharge history
- 🚨 Expiring soon alerts
- ✏️ Edit and delete from anywhere

### Settings & Customization
- ⚙️ **Settings Screen** with comprehensive options
- 🔔 Enable/disable notifications globally
- 🌓 Dark mode toggle (requires app restart)
- ⏰ Set default reminder time
- 📅 Configure default recharge reminder days
- 📊 View storage information
- 💾 Export/Import data (coming soon)
- 🗑️ Clear all data option
- ℹ️ About section with app info

### Architecture & Tech Stack
- 🏗️ **MVVM Architecture** - Clean separation of concerns
- 🧱 **BLoC Pattern** - Predictable state management
- 🗺️ **GoRouter** - Type-safe declarative navigation
- 💾 **SharedPreferences** - Local JSON storage
- 🎨 **Material Design 3** - Modern UI/UX
- 🌓 **Dark mode** support
- 🔄 **Reusable Components** - Action widgets for consistency

## 📁 Project Structure (MVVM)

```
lib/
├── main.dart                                    # App entry with DI
├── domain/
│   └── models/
│       └── reminder.dart                        # Business models (Equatable)
├── data/
│   ├── services/
│   │   ├── local_storage_service.dart          # SharedPreferences wrapper
│   │   └── notification_service.dart            # Notification handling
│   └── repositories/
│       ├── reminder_repository.dart             # Reminder data operations
│       └── recharge_repository.dart             # Recharge data operations
└── presentation/
    ├── bloc/
    │   ├── reminder/
    │   │   └── reminder_bloc.dart               # Reminder BLoC (Events/States)
    │   └── recharge/
    │       └── recharge_bloc.dart               # Recharge BLoC (Events/States)
    ├── router/
    │   └── app_router.dart                      # GoRouter configuration
    └── views/
        └── screens/
            ├── home_screen.dart                 # Dashboard screen
            ├── reminders_screen.dart            # Reminders list
            ├── recharge_screen.dart             # Recharge tracking
            ├── add_reminder_screen.dart         # Add/Edit reminder
            ├── add_recharge_screen.dart         # Add/Edit recharge
            └── recharge_history_screen.dart     # Recharge history
```

## 🏗️ Architecture Layers

### 1. **Domain Layer** (Business Logic)
- Pure Dart models
- No dependencies on Flutter
- Uses Equatable for value equality

### 2. **Data Layer** (Data Management)
- **Services**: Handle data sources (SharedPreferences, Notifications)
- **Repositories**: Coordinate between services and provide data to BLoC
- Repository pattern for clean data access

### 3. **Presentation Layer** (UI)
- **BLoC**: State management with events and states
- **Views**: UI screens that listen to BLoC states
- **Router**: Navigation configuration with GoRouter

## 🚀 Getting Started

### Prerequisites
- Flutter SDK (3.0.0 or higher)
- Dart SDK (3.0.0 or higher)
- Android Studio / VS Code with Flutter extensions
- Android SDK (for Android development)
- Xcode (for iOS development, Mac only)

### Installation Steps

1. **Create Flutter project**
   ```bash
   flutter create reminder_app
   cd reminder_app
   ```

2. **Replace `pubspec.yaml`**
   ```yaml
   dependencies:
     flutter:
       sdk: flutter
     flutter_bloc: ^8.1.3
     equatable: ^2.0.5
     shared_preferences: ^2.2.2
     go_router: ^13.0.0
     flutter_local_notifications: ^16.3.0
     timezone: ^0.9.2
     intl: ^0.18.1
     uuid: ^4.2.2
     flutter_slidable: ^3.0.1
     google_fonts: ^6.1.0
   ```

3. **Install dependencies**
   ```bash
   flutter pub get
   ```

4. **Copy all files to their respective folders**
    - Create the folder structure as shown above
    - Place each file in its correct location

5. **Update AndroidManifest.xml**
   Add permissions in `android/app/src/main/AndroidManifest.xml`:
   ```xml
   <uses-permission android:name="android.permission.RECEIVE_BOOT_COMPLETED"/>
   <uses-permission android:name="android.permission.VIBRATE" />
   <uses-permission android:name="android.permission.SCHEDULE_EXACT_ALARM"/>
   <uses-permission android:name="android.permission.POST_NOTIFICATIONS"/>
   ```

6. **For iOS (Info.plist)**
   Add in `ios/Runner/Info.plist`:
   ```xml
   <key>UIBackgroundModes</key>
   <array>
       <string>remote-notification</string>
   </array>
   ```

7. **Run the app**
   ```bash
   flutter run
   ```

## 🎯 Usage Guide

### BLoC Events (How to Trigger Actions)

#### Reminders
```dart
// Load reminders
context.read<ReminderBloc>().add(LoadReminders());

// Add reminder
context.read<ReminderBloc>().add(AddReminder(reminder));

// Update reminder
context.read<ReminderBloc>().add(UpdateReminder(reminder));

// Delete reminder
context.read<ReminderBloc>().add(DeleteReminder(id));

// Toggle complete
context.read<ReminderBloc>().add(ToggleReminderComplete(id));

// Search
context.read<ReminderBloc>().add(SearchReminders(query));
```

#### Recharges
```dart
// Load recharges
context.read<RechargeBloc>().add(LoadRecharges());

// Add recharge
context.read<RechargeBloc>().add(AddRecharge(recharge));

// Update recharge
context.read<RechargeBloc>().add(UpdateRecharge(recharge));

// Delete recharge
context.read<RechargeBloc>().add(DeleteRecharge(id));
```

### Navigation with GoRouter

```dart
// Navigate to screen
context.go(AppRouter.home);
context.push(AppRouter.addReminder);

// Navigate with data
context.push(AppRouter.editReminder, extra: reminder);

// Go back
context.pop();
```

### Listening to States

```dart
BlocBuilder<ReminderBloc, ReminderState>(
  builder: (context, state) {
    if (state is ReminderLoading) {
      return CircularProgressIndicator();
    }
    if (state is ReminderLoaded) {
      return ListView(children: [...]);
    }
    return Text('Error');
  },
)

BlocListener<ReminderBloc, ReminderState>(
  listener: (context, state) {
    if (state is ReminderOperationSuccess) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(state.message)),
      );
    }
  },
  child: YourWidget(),
)
```

## 🔧 Key Differences from Traditional Approach

| Aspect | This Project | Traditional |
|--------|-------------|-------------|
| **State Management** | BLoC (Events/States) | Provider/setState |
| **Storage** | SharedPreferences (JSON) | SQLite |
| **Navigation** | GoRouter (Declarative) | Navigator (Imperative) |
| **Architecture** | MVVM (Layers) | No specific pattern |
| **Data Flow** | Repository → BLoC → View | Direct service calls |
| **Testing** | Easy to test BLoCs | Harder to test |

## 📦 Dependencies Explained

- **flutter_bloc**: BLoC state management
- **equatable**: Value equality for models
- **shared_preferences**: Local key-value storage
- **go_router**: Declarative navigation
- **flutter_local_notifications**: Push notifications
- **timezone**: Timezone support for notifications
- **intl**: Date formatting
- **uuid**: Unique ID generation
- **flutter_slidable**: Swipe actions
- **google_fonts**: Custom fonts

## 🐛 Troubleshooting

### BLoC not updating UI
- Ensure models extend Equatable
- Check if props are properly overridden
- Verify BlocProvider is wrapping the widget tree

### Navigation not working
- Check route paths in AppRouter
- Ensure GoRouter is used in MaterialApp.router
- Verify extra parameter types match

### Storage not persisting
- Check SharedPreferences initialization
- Ensure JSON serialization is correct
- Verify toJson/fromJson methods

### Build errors
```bash
flutter clean
flutter pub get
flutter run
```

## 🔐 Data Storage Format

### SharedPreferences Keys
- `reminders` - JSON array of all reminders
- `recharges` - JSON array of all recharges

### JSON Structure
```json
{
  "reminders": [
    {
      "id": "uuid",
      "title": "string",
      "description": "string",
      "dateTime": "ISO8601",
      "category": 0,
      "repeat": 0,
      "isCompleted": false,
      "notificationEnabled": true
    }
  ]
}
```

## 🚀 Future Enhancements

- [ ] Cloud sync with Firebase + BLoC
- [ ] Offline-first architecture
- [ ] Multiple device support
- [ ] Export/Import data
- [ ] Recurring recharge templates
- [ ] Statistics dashboard
- [ ] Voice reminders
- [ ] Location-based reminders
- [ ] Shared reminders
- [ ] Custom notification sounds
- [ ] Backup and restore
- [ ] Widget support

## 📄 License

This project is free to use and modify for personal and commercial purposes.

## 🤝 Contributing

Feel free to fork this project and submit pull requests for any improvements.

---

**Built with ❤️ using Flutter, BLoC, and MVVM Architecture**