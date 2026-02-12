import UIKit
import SwiftUI
import Combine

/// Keyboard extension controller that bridges UIKit keyboard hosting with SwiftUI UI layer.
/// 
/// **Responsibility**: Instantiate and manage SwiftUI keyboard view lifecycle with theme support.
/// **Domain**: Keyboard rendering, text input delegation, theme management.
/// **Architecture**: Imperative shell wrapping SwiftUI functional core.
///
class KeyboardViewController: UIInputViewController {
    private var hostingController: UIHostingController<KeyboardRootView>?
    private let themeManager = ThemeManager()

    override func viewDidLoad() {
        super.viewDidLoad()
        embedKeyboardUI()
    }
    
    /// Embeds SwiftUI keyboard UI into UIKit keyboard container with theme support.
    /// **O(1)** setup; no loops or recursive calls.
    private func embedKeyboardUI() {
        let keyboardView = KeyboardRootView(
            textDocumentProxy: textDocumentProxy,
            themeManager: themeManager
        )
        let hostingController = UIHostingController(rootView: keyboardView)
        
        addChild(hostingController)
        view.addSubview(hostingController.view)
        
        constrainToFillSafeArea(hostingController.view)
        hostingController.didMove(toParent: self)
        
        self.hostingController = hostingController
    }
    
    /// Constrains a view to fill its superview (safe area).
    private func constrainToFillSafeArea(_ subview: UIView) {
        subview.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            subview.topAnchor.constraint(equalTo: view.topAnchor),
            subview.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            subview.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            subview.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
    }
    
    // UITextInput delegate methods (no-op; handled by textDocumentProxy).
    override func textWillChange(_ textInput: UITextInput?) {}
    override func textDidChange(_ textInput: UITextInput?) {}
}

struct KeyboardRootView: View {
    @ObservedObject private var inputModel: KeyboardInputModel
    @ObservedObject private var themeManager: ThemeManager
    @State private var selectedMode: KeyboardMode = .kana
    @Environment(\.colorScheme) var systemColorScheme
    
    init(
        textDocumentProxy: UITextDocumentProxy,
        themeManager: ThemeManager
    ) {
        self.inputModel = KeyboardInputModel(textDocumentProxy: textDocumentProxy)
        self.themeManager = themeManager
    }
    
    var body: some View {
        VStack(spacing: 0) {
            modeSelector
            modeView
            specialKeysRow
        }
        .background(theme.backgroundColor.primary)
        .onAppear(perform: updateThemeForSystemAppearance)
        .onChange(of: systemColorScheme) { _ in
            updateThemeForSystemAppearance()
        }
    }
    
    /// Current active theme based on ThemeManager
    private var theme: KeyboardTheme {
        themeManager.theme
    }
    
    /// Update theme when system appearance changes
    private func updateThemeForSystemAppearance() {
        if themeManager.themeMode == .system {
            themeManager.updateTheme()
        }
    }
    
    /// Horizontal mode selector bar with active state indication.
    private var modeSelector: some View {
        HStack(spacing: theme.dimensions.buttonSpacing) {
            ModeButton(label: "かな", isActive: selectedMode == .kana, theme: theme) {
                selectedMode = .kana
            }
            ModeButton(label: "英数", isActive: selectedMode == .abc, theme: theme) {
                selectedMode = .abc
            }
            ModeButton(label: "123", isActive: selectedMode == .numbers, theme: theme) {
                selectedMode = .numbers
            }
            ModeButton(label: "記号", isActive: selectedMode == .symbols, theme: theme) {
                selectedMode = .symbols
            }
            ModeButton(label: "😀", isActive: selectedMode == .emoji, theme: theme) {
                selectedMode = .emoji
            }
            Spacer()
        }
        .padding(theme.dimensions.padding)
        .background(theme.backgroundColor.secondary)
    }
    
    /// Renders the view corresponding to the currently selected mode.
    @ViewBuilder
    private var modeView: some View {
        switch selectedMode {
        case .kana:
            KanaKeyboardView(inputModel: inputModel, theme: theme)
        case .abc:
            ABCKeyboardView(inputModel: inputModel, theme: theme)
        case .numbers:
            NumbersKeyboardView(inputModel: inputModel, theme: theme)
        case .symbols:
            SymbolsKeyboardView(inputModel: inputModel, theme: theme)
        case .emoji:
            EmojiKeyboardView(inputModel: inputModel, theme: theme)
        }
    }
    
    /// Bottom utility row: delete, space, return.
    private var specialKeysRow: some View {
        HStack(spacing: theme.dimensions.buttonSpacing) {
            SpecialKeyButton(label: "del", theme: theme) {
                inputModel.deleteBackward()
            }
            Spacer()
            SpecialKeyButton(label: "space", theme: theme) {
                inputModel.insertText(" ")
            }
            Spacer()
            SpecialKeyButton(label: "return", theme: theme) {
                inputModel.insertText("\n")
            }
        }
        .padding(theme.dimensions.padding)
    }
}

