# Changelog

All notable changes to QuickChat are documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [2.1.0] - 2026-06-14

### Added
- Launcher shortcuts (long-press the app icon) for quick access.
- Home-screen widget for one-tap messaging to favorites.
- Quick Settings tile.
- Clickable deep links and Android App Links.
- Message-link sharing action.
- Guided broadcast for sending the same message to multiple recipients manually.
- Template categories.

### Changed
- Redesigned the Settings screen with a grouped, Material 3 layout.
- Switched to a proprietary license.

### Removed
- QR code scanner and the camera permission, to satisfy the Google Play
  16 KB page-size requirement and reduce application size. QR code generation
  and sharing remain available.

## [2.0.0] - 2026-06-13

### Added
- Favorites for frequent numbers, with a home-screen access bar.
- History search and day grouping; undo for deletions.
- Clipboard detection and shared-text handling to auto-fill numbers.
- wa.me link generation, sharing, and QR code generation.
- WhatsApp / WhatsApp Business selection.
- Additional languages: Spanish, Hindi, Portuguese, Indonesian, Urdu, Turkish.
- Accessibility improvements and a native splash screen.
- Automated test suite and continuous integration.

### Changed
- Refactored to a clean, layered architecture with the BLoC (Cubit) pattern.
- Locale-derived default country code.

## [1.0.0] - 2025-11-09

### Added
- Initial release.
- Open a WhatsApp conversation with any number without saving it to contacts.
- Country code selection with an optional message field.
- Local chat history and message templates.
- Light, dark, and system themes.
- Arabic and English interfaces with RTL support.
