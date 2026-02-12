import SwiftUI

struct ContentView: View {
    @State private var selectedTab: Int = 0
    
    var body: some View {
        TabView(selection: $selectedTab) {
            // Setup Tab
            SetupTabView()
                .tabItem {
                    Label("Setup", systemImage: "gear")
                }
                .tag(0)
            
            // Settings Tab
            SettingsTabView()
                .tabItem {
                    Label("Settings", systemImage: "slider.horizontal.3")
                }
                .tag(1)
            
            // About Tab
            AboutTabView()
                .tabItem {
                    Label("About", systemImage: "info.circle")
                }
                .tag(2)
        }
    }
}

// MARK: - Setup Tab

struct SetupTabView: View {
    var body: some View {
        NavigationView {
            VStack(spacing: 16) {
                Text("Romaji Keyboard")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                
                VStack(alignment: .leading, spacing: 12) {
                    Label("Install the Keyboard", systemImage: "keyboard")
                        .font(.headline)
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text("1. Open Settings > General > Keyboard > Keyboards")
                        Text("2. Tap \"Add New Keyboard...\"")
                        Text("3. Select \"Romaji Keyboard\"")
                        Text("4. Enable \"Allow Full Access\" for better functionality")
                    }
                    .font(.body)
                    .foregroundColor(.gray)
                }
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(10)
                
                VStack(alignment: .leading, spacing: 12) {
                    Label("Switch Keyboards", systemImage: "globe")
                        .font(.headline)
                    
                    Text("While typing, tap the globe icon at the bottom of the keyboard to switch between your keyboards.")
                        .font(.body)
                        .foregroundColor(.gray)
                }
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(10)
                
                Button(action: {
                    if let url = URL(string: UIApplication.openSettingsURLString) {
                        UIApplication.shared.open(url)
                    }
                }) {
                    Label("Open Settings", systemImage: "arrow.up.right")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                
                Spacer()
            }
            .padding()
            .navigationTitle("Setup")
        }
    }
}

// MARK: - Settings Tab

struct SettingsTabView: View {
    @StateObject private var themeManager = ThemeManager()
    @Environment(\.colorScheme) var systemColorScheme
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Keyboard Appearance")) {
                    Picker("Theme", selection: $themeManager.themeMode) {
                        ForEach(KeyboardTheme.ThemeMode.allCases, id: \.self) { mode in
                            Text(mode.displayName).tag(mode)
                        }
                    }
                    .onChange(of: themeManager.themeMode) { _ in
                        themeManager.updateTheme()
                    }
                    
                    HStack {
                        Text("Current System Appearance")
                        Spacer()
                        Text(systemColorScheme == .light ? "Light" : "Dark")
                            .foregroundColor(.gray)
                    }
                }
                
                Section(header: Text("Theme Preview")) {
                    ThemePreviewView(theme: themeManager.theme)
                }
                
                Section(header: Text("About")) {
                    HStack {
                        Text("App Version")
                        Spacer()
                        Text("1.0.0")
                            .foregroundColor(.gray)
                    }
                }
            }
            .navigationTitle("Settings")
        }
    }
}

// MARK: - Theme Preview

struct ThemePreviewView: View {
    let theme: KeyboardTheme
    
    var body: some View {
        VStack(spacing: 12) {
            // Background preview
            HStack {
                Text("Primary Background")
                    .font(.caption)
                Spacer()
                RoundedRectangle(cornerRadius: 8)
                    .fill(theme.backgroundColor.primary)
                    .frame(width: 50, height: 30)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(theme.borderColor.standard, lineWidth: 1)
                    )
            }
            
            // Key button preview
            HStack {
                Text("Key Button")
                    .font(.caption)
                Spacer()
                RoundedRectangle(cornerRadius: 6)
                    .fill(theme.backgroundColor.key)
                    .frame(width: 50, height: 30)
                    .overlay(
                        RoundedRectangle(cornerRadius: 6)
                            .stroke(theme.borderColor.standard, lineWidth: 1)
                    )
            }
            
            // Text preview
            HStack {
                Text("Text Color")
                    .font(.caption)
                Spacer()
                Text("Sample")
                    .foregroundColor(theme.textColor.primary)
            }
            
            // Accent preview
            HStack {
                Text("Accent Color")
                    .font(.caption)
                Spacer()
                RoundedRectangle(cornerRadius: 6)
                    .fill(theme.borderColor.active)
                    .frame(width: 50, height: 30)
            }
        }
        .padding()
        .background(theme.backgroundColor.primary)
        .cornerRadius(10)
    }
}

// MARK: - About Tab

struct AboutTabView: View {
    var body: some View {
        NavigationView {
            VStack(spacing: 16) {
                VStack(spacing: 8) {
                    Text("Romaji Keyboard")
                        .font(.title2)
                        .fontWeight(.bold)
                    Text("v1.0.0")
                        .foregroundColor(.gray)
                }
                .padding()
                
                VStack(alignment: .leading, spacing: 12) {
                    Text("Features")
                        .font(.headline)
                    
                    VStack(alignment: .leading, spacing: 8) {
                        FeatureRow(icon: "keyboard", title: "Japanese Kana Keyboard", description: "12-key kana input with flick support")
                        FeatureRow(icon: "a.circle", title: "ABC Mode", description: "English letter input with shift support")
                        FeatureRow(icon: "1.circle", title: "Numbers & Symbols", description: "Quick access to digits and special characters")
                        FeatureRow(icon: "face.smiling", title: "Emoji Support", description: "Built-in emoji keyboard")
                        FeatureRow(icon: "moon.stars", title: "Theme Support", description: "Light and dark mode with system appearance detection")
                    }
                }
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(10)
                
                Spacer()
                
                VStack(spacing: 8) {
                    Text("Made with ❤️")
                        .font(.caption)
                        .foregroundColor(.gray)
                    Text("© 2026 Romaji Keyboard")
                        .font(.caption2)
                        .foregroundColor(.gray)
                }
            }
            .padding()
            .navigationTitle("About")
        }
    }
}

// MARK: - Feature Row Component

struct FeatureRow: View {
    let icon: String
    let title: String
    let description: String
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundColor(.blue)
                .frame(width: 30)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                Text(description)
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            
            Spacer()
        }
    }
}

#Preview {
    ContentView()
}
