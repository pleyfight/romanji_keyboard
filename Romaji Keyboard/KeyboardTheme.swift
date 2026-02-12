import SwiftUI
import UIKit
import Combine
import Combine

/// Comprehensive design system for keyboard UI.
/// Supports light and dark themes with automatic system appearance detection.
///
/// **Architecture**: Value type (struct) enables predictable state management.
/// **Responsibility**: Define all colors, typography, spacing, and styling constants.
/// **O(1)** access: All properties are computed or constants.
///
struct KeyboardTheme {
    // MARK: - Theme Mode
    
    enum ThemeMode: String, CaseIterable {
        case light = "light"
        case dark = "dark"
        case system = "system"  // Follows iOS system appearance
        
        var displayName: String {
            switch self {
            case .light:
                return "Light"
            case .dark:
                return "Dark"
            case .system:
                return "System"
            }
        }
    }
    
    // MARK: - Properties
    
    let mode: ThemeMode
    let colorScheme: ColorScheme?  // nil = system default
    
    // MARK: - Colors
    
    /// Background colors
    struct BackgroundColors {
        let primary: Color           // Main keyboard background
        let secondary: Color         // Mode selector background
        let key: Color              // Key button background
        let keyPressed: Color       // Key pressed state
        let gridLine: Color         // Separator lines
    }
    
    let backgroundColor: BackgroundColors
    
    /// Text colors
    struct TextColors {
        let primary: Color          // Main text
        let secondary: Color        // Secondary text/labels
        let accent: Color           // Active/selected state
    }
    
    let textColor: TextColors
    
    /// Border & stroke colors
    struct BorderColors {
        let standard: Color         // Standard borders
        let active: Color           // Active state border
        let pressed: Color          // Pressed state
    }
    
    let borderColor: BorderColors
    
    // MARK: - Spacing & Sizing
    
    struct Dimensions {
        let buttonSpacing: CGFloat = 4
        let padding: CGFloat = 4
        let cornerRadius: CGFloat = 6
        let borderWidth: CGFloat = 1
        
        let keyHeight: CGFloat = 50
        let keyHeightCompact: CGFloat = 40
        let modeButtonHeight: CGFloat = 32
        let modifierHeight: CGFloat = 40
    }
    
    let dimensions = Dimensions()
    
    // MARK: - Typography
    
    struct Typography {
        let keyFont = Font.system(size: 20, weight: .medium)
        let keyLabelFont = Font.system(size: 10, weight: .regular)
        let modeButtonFont = Font.system(size: 14, weight: .semibold)
        let modifierFont = Font.system(size: 16, weight: .semibold)
        let specialKeyFont = Font.system(size: 14, weight: .semibold)
    }
    
    let typography = Typography()
    
    // MARK: - Initializers
    
    /// Create theme with explicit mode
    init(mode: ThemeMode) {
        self.mode = mode
        
        // Determine actual color scheme based on mode
        switch mode {
        case .light:
            self.colorScheme = .light
        case .dark:
            self.colorScheme = .dark
        case .system:
            self.colorScheme = nil
        }
        
        // Set colors based on mode
        let colors = Self.colorScheme(for: mode)
        self.backgroundColor = colors.0
        self.textColor = colors.1
        self.borderColor = colors.2
    }
    
    // MARK: - Theme Generation
    
    /// Generate color scheme for a given mode
    static func colorScheme(
        for mode: ThemeMode
    ) -> (BackgroundColors, TextColors, BorderColors) {
        switch mode {
        case .light:
            return lightTheme()
        case .dark:
            return darkTheme()
        case .system:
            // Default to light; will be overridden by @Environment
            return lightTheme()
        }
    }
    
    /// Light theme colors
    private static func lightTheme() -> (BackgroundColors, TextColors, BorderColors) {
        let backgroundColors = BackgroundColors(
            primary: Color(UIColor(red: 0.95, green: 0.95, blue: 0.95, alpha: 1.0)),        // Light gray background
            secondary: Color(UIColor(red: 0.93, green: 0.93, blue: 0.93, alpha: 1.0)),      // Slightly darker gray
            key: Color.white,                                                                  // White keys
            keyPressed: Color(UIColor(red: 0.92, green: 0.92, blue: 0.92, alpha: 1.0)),    // Light pressed state
            gridLine: Color(UIColor.separator)                                                // System separator
        )
        
        let textColors = TextColors(
            primary: Color.black,
            secondary: Color(UIColor.gray),
            accent: Color.blue
        )
        
        let borderColors = BorderColors(
            standard: Color(UIColor.systemGray3),
            active: Color.blue,
            pressed: Color(UIColor.systemGray4)
        )
        
        return (backgroundColors, textColors, borderColors)
    }
    
    /// Dark theme colors
    private static func darkTheme() -> (BackgroundColors, TextColors, BorderColors) {
        let backgroundColors = BackgroundColors(
            primary: Color(UIColor(red: 0.15, green: 0.16, blue: 0.18, alpha: 1.0)),       // Dark background
            secondary: Color(UIColor(red: 0.20, green: 0.21, blue: 0.24, alpha: 1.0)),     // Slightly lighter
            key: Color(UIColor(red: 0.22, green: 0.23, blue: 0.26, alpha: 1.0)),           // Dark keys
            keyPressed: Color(UIColor(red: 0.30, green: 0.31, blue: 0.34, alpha: 1.0)),    // Lighter pressed state
            gridLine: Color(UIColor(red: 0.25, green: 0.26, blue: 0.29, alpha: 1.0))       // Dark separator
        )
        
        let textColors = TextColors(
            primary: Color.white,
            secondary: Color(UIColor.lightGray),
            accent: Color(UIColor(red: 0.4, green: 0.7, blue: 1.0, alpha: 1.0))            // Light blue for dark mode
        )
        
        let borderColors = BorderColors(
            standard: Color(UIColor(red: 0.35, green: 0.36, blue: 0.39, alpha: 1.0)),
            active: Color(UIColor(red: 0.4, green: 0.7, blue: 1.0, alpha: 1.0)),
            pressed: Color(UIColor(red: 0.40, green: 0.41, blue: 0.44, alpha: 1.0))
        )
        
        return (backgroundColors, textColors, borderColors)
    }
}

// MARK: - Theme Environment Key & Manager

class ThemeManager: ObservableObject {
    @Published var themeMode: KeyboardTheme.ThemeMode {
        didSet {
            saveThemePreference()
        }
    }
    
    @Published var theme: KeyboardTheme
    
    init() {
        // Load saved preference or default to system
        let savedMode = UserDefaults.standard.string(forKey: "keyboardThemeMode")
        self.themeMode = KeyboardTheme.ThemeMode(rawValue: savedMode ?? "system") ?? .system
        
        self.theme = KeyboardTheme(mode: themeMode)
    }
    
    /// Update theme based on system appearance or user preference
    func updateTheme() {
        let effectiveMode: KeyboardTheme.ThemeMode
        
        switch themeMode {
        case .light:
            effectiveMode = .light
        case .dark:
            effectiveMode = .dark
        case .system:
            // Detect system appearance (handled via @Environment in views)
            effectiveMode = .system
        }
        
        self.theme = KeyboardTheme(mode: effectiveMode)
    }
    
    /// Set theme mode and persist preference
    func setThemeMode(_ mode: KeyboardTheme.ThemeMode) {
        self.themeMode = mode
        updateTheme()
    }
    
    /// Save theme preference to UserDefaults
    private func saveThemePreference() {
        UserDefaults.standard.set(themeMode.rawValue, forKey: "keyboardThemeMode")
    }
}

// MARK: - SwiftUI Environment Extension

struct ThemeManagerKey: EnvironmentKey {
    static let defaultValue = ThemeManager()
}

extension EnvironmentValues {
    var themeManager: ThemeManager {
        get { self[ThemeManagerKey.self] }
        set { self[ThemeManagerKey.self] = newValue }
    }
}

// Background type for themed backgrounds (must not be nested in a protocol extension)
enum BackgroundType {
    case primary
    case secondary
}

// MARK: - Theme-Aware View Modifiers

extension View {
    /// Apply keyboard button styling with theme
    func themedKeyboardButton(
        isActive: Bool = false,
        isPressed: Bool = false,
        theme: KeyboardTheme
    ) -> some View {
        self
            .foregroundColor(theme.textColor.primary)
            .background(isPressed ? theme.backgroundColor.keyPressed : theme.backgroundColor.key)
            .cornerRadius(theme.dimensions.cornerRadius)
            .overlay(
                RoundedRectangle(cornerRadius: theme.dimensions.cornerRadius)
                    .stroke(
                        isActive ? theme.borderColor.active : theme.borderColor.standard,
                        lineWidth: theme.dimensions.borderWidth
                    )
            )
    }
    
    /// Apply themed background
    func themedBackground(theme: KeyboardTheme, type: BackgroundType = .primary) -> some View {
        let color = type == .primary ? theme.backgroundColor.primary : theme.backgroundColor.secondary
        return self.background(color)
    }
}

