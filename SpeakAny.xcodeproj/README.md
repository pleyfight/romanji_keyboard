# RomajiKeyboard
Go
A minimal SwiftUI-based custom keyboard extension that outputs romaji syllables using a 12-key style layout. This project includes:

- iOS app target (SwiftUI) for onboarding/setup
- Keyboard extension target hosting a SwiftUI keyboard UI

## Features

- 3x4 consonant grid
- Tap inserts consonant + "a" with Hepburn exceptions (shi/chi/tsu/fu/ji)
- SwiftUI layout inside UIInputViewController

## Getting Started

1. Build and run the iOS app on a device or simulator.
2. On a real device, go to Settings > General > Keyboard > Keyboards > Add New Keyboard… and add "RomajiKeyboard".
3. Tap the newly added keyboard and toggle "Allow Full Access" if needed.
4. In any text field, switch keyboards (globe button) to "RomajiKeyboard".

## Project Structure

- RomajiKeyboardApp.swift — App entry point
- ContentView.swift — Setup instructions UI
- KeyboardExtension/KeyboardViewController.swift — Keyboard extension and SwiftUI keyboard UI
- KeyboardExtension/Info.plist — Extension configuration

## Next Steps

- Implement flick gestures to choose vowels (a/i/u/e/o)
- Add functional keys: delete, space, return, next keyboard
- Improve mappings and add modes (hiragana/katakana)
- Accessibility and haptic feedback

## Notes

- Some settings (like enabling the extension) can only be done in the Settings app.
- Simulators can show the keyboard extension UI, but input routing differs from devices.
