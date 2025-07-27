# Pawsinus 🐕

A Tinder-style iOS app for dog adoption, connecting potential adopters with dogs from Korean animal shelters.

## Features

- **Swipe Interface**: Tinder-like card swiping to browse adoptable dogs
- **Smart Matching**: Filter by size, age, energy level, and compatibility
- **Likes Management**: Save and review dogs you're interested in
- **User Profiles**: Customize preferences and manage your adoption journey
- **Korean Localization**: Full support for Korean shelters and users

## Architecture

Built with Clean Architecture principles (based on the original [Clean Architecture for SwiftUI](https://nalexn.github.io/clean-architecture-swiftui/) template):
- **SwiftUI** for modern, declarative UI
- **SwiftData** for local persistence
- **Supabase** for backend services
- **Combine** for reactive programming
- **iOS 18.0+** minimum deployment target

## Getting Started

### Prerequisites

- Xcode 15+
- iOS 18.0+ device or simulator
- Supabase account

### Installation

1. Clone the repository:
   ```bash
   git clone https://github.com/yourusername/pawsinus.git
   cd pawsinus
   ```

2. Open in Xcode:
   ```bash
   open PawsInUs.xcodeproj
   ```

3. Configure Supabase:
   - Create a Supabase project
   - Run the setup script from `docs/sql/setup_database.sql`
   - Update credentials in `SupabaseConfig.swift`

4. Build and run (⌘R)

## Project Structure

```
PawsInUs/
├── Core/               # App lifecycle and state management
├── DependencyInjection/# DI container and configuration
├── Interactors/        # Business logic layer
├── Repositories/       # Data access layer
│   ├── Models/         # Data models
│   └── Supabase/       # Backend integration
├── UI/                 # SwiftUI views
│   ├── Auth/           # Authentication screens
│   ├── SwipeView/      # Main swiping interface
│   ├── Likes/          # Liked dogs view
│   └── Profile/        # User profile
└── Utilities/          # Helper classes and extensions
```

## Documentation

- [Deployment Guide](docs/DEPLOYMENT.md) - TestFlight and App Store deployment
- [Database Setup](docs/sql/setup_database.sql) - Supabase schema
- [Supabase Setup](SUPABASE_SETUP.md) - Backend configuration

## Contributing

This project is currently in development. Contributions are welcome!

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Acknowledgments

- Original Clean Architecture template by [Alexey Naumov](https://github.com/nalexn/clean-architecture-swiftui)
- Dog images from Unsplash
- Korean animal shelter data based on public information

---

**Note**: This is a demonstration project. For production use, ensure you have proper agreements with animal shelters and comply with all relevant regulations.
