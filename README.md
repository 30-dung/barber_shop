# My Flutter App

This is a Flutter application for booking salon services. It allows users to log in, register, view available services, select salons, and make bookings.

## Features

- User authentication (login and registration)
- View and select salon services
- Choose a salon for the selected service
- Select date and time for bookings
- View and manage user bookings

## Directory Structure

```
my_flutter_app
├── lib
│   ├── main.dart
│   ├── constants
│   │   └── app_constants.dart
│   ├── models
│   │   ├── user_model.dart
│   │   ├── service_model.dart
│   │   ├── salon_model.dart
│   │   └── booking_model.dart
│   ├── services
│   │   ├── api_service.dart
│   │   └── storage_service.dart
│   └── screens
│       ├── splash_screen.dart
│       ├── auth
│       │   ├── login_screen.dart
│       │   └── register_screen.dart
│       ├── home
│       │   └── home_screen.dart
│       ├── booking
│       │   ├── services_screen.dart
│       │   ├── salon_selection_screen.dart
│       │   ├── booking_datetime_screen.dart
│       │   ├── booking_confirmation_screen.dart
│       │   └── my_bookings_screen.dart
│       └── profile
│           └── profile_screen.dart
├── pubspec.yaml
└── README.md
```

## Setup Instructions

1. Clone the repository:
   ```
   git clone <repository-url>
   ```

2. Navigate to the project directory:
   ```
   cd my_flutter_app
   ```

3. Install dependencies:
   ```
   flutter pub get
   ```

4. Run the application:
   ```
   flutter run
   ```

## Usage

- Launch the app and navigate through the login or registration screens.
- After logging in, you can view available services and select a salon.
- Choose a date and time for your booking and confirm it.
- View your bookings in the "My Bookings" section.

## Contributing

Contributions are welcome! Please open an issue or submit a pull request for any improvements or bug fixes.