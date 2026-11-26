# Mood Tracker

A daily mood tracking app built with Flutter. Users can log how they feel each day, browse their history, and edit or delete moods.

## Features

- **Log a mood (Create):** pick a date, choose one of 6 moods, and add an optional note.
- **Mood list (Read):** history is grouped by day ("Hari Ini", "Kemarin", or the full date), newest entries first.
- **Edit a mood (Update):** change the mood, date, and note from the three-dot menu on a card.
- **Delete a mood (Delete):** remove an entry from the three-dot menu, with a confirmation dialog.
- **Streak:** shows how many consecutive days have at least one mood entry.
- **Local storage:** data is saved with Hive and loaded again when the app starts.

Available moods: Senang (Happy), Sedih (Sad), Marah (Angry), Tenang (Calm), Cemas (Anxious), and Bersemangat (Excited).

## Project Status

| Item | Status |
|---|---|
| Basic widgets and UI (Home, Add/Edit Mood) | Done |
| Navigation between pages | Done |
| Mood CRUD with Hive storage | Done |
| Onboarding screens | Not yet |
| Dark mode (optional) | Not yet |
| Mood chart (optional) | Not yet |

## Tech Stack

- [Flutter](https://flutter.dev/) and Dart
- [Hive](https://pub.dev/packages/hive_flutter) for local storage
- [google_fonts](https://pub.dev/packages/google_fonts) (Poppins font)
- [material_ui](https://pub.dev/packages/material_ui) for Material widgets

## Project Structure

```
lib/
  main.dart                    # entry point, models (Mood, MoodEntry), HomePage, and UI components
  pages/
    add_edit_mood_page.dart    # Add / Edit Mood page
assets/
  images/moods/                # emoji image for each mood (.png)
test/
  widget_test.dart             # widget test
```

## Data Storage

Each entry is stored as a `Map` in a Hive box named `moods`, using the entry `id` as the key.

| Field | Type | Description |
|---|---|---|
| `id` | String | unique identifier of the entry |
| `mood` | String | mood name (for example `senang`) |
| `time` | String | timestamp in ISO 8601 format |
| `note` | String | note text, may be empty |

## Getting Started

Prerequisite: the [Flutter SDK](https://docs.flutter.dev/get-started/install) is installed. Check with `flutter doctor`.

```bash
# 1. Install dependencies
flutter pub get

# 2. Run the app (example: in Chrome)
flutter run -d chrome
```

To use another device (emulator or phone), list the available ones with `flutter devices`, then run `flutter run -d <device_id>`.

## Running Tests

```bash
flutter test
```
