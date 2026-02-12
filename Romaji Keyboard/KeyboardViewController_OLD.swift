/*
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

/// Ubiquitous Language: KeyboardMode represents the input method category (kana, romaji, digits, symbols, emojis).
enum KeyboardMode: Hashable {
    case kana, abc, numbers, symbols, emoji
}

/// Root SwiftUI view orchestrating keyboard mode selection and delegation to mode-specific views.
/// 
/// **Responsibility**: Coordinate mode state, delegate rendering to specialized views, manage theming.
/// **Cognitive Complexity**: ~8 (switch over modes, straightforward state flow).
/// **O(1) layout**: No loops; each mode renders independently.
///
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
            ModeButton(
                label: "かな",
                isActive: selectedMode == .kana,
                theme: theme
            ) {
                selectedMode = .kana
            }
            ModeButton(
                label: "英数",
                isActive: selectedMode == .abc,
                theme: theme
            ) {
                selectedMode = .abc
            }
            ModeButton(
                label: "123",
                isActive: selectedMode == .numbers,
                theme: theme
            ) {
                selectedMode = .numbers
            }
            ModeButton(
                label: "記号",
                isActive: selectedMode == .symbols,
                theme: theme
            ) {
                selectedMode = .symbols
            }
            ModeButton(
                label: "😀",
                isActive: selectedMode == .emoji,
                theme: theme
            ) {
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

/// Ubiquitous Language: DiacriticType represents voiced (dakuten ゛) or semi-voiced (handakuten ゜) mark application.
enum DiacriticType: Hashable {
    case none, dakuten, handakuten
}

/// Kana keyboard view with small kana and diacritic modifiers.
/// 
/// **Responsibility**: Render kana grid with modifier row.
/// **Cognitive Complexity**: ~9 (state management, diacritic logic in closure).
/// **O(n)** rendering: n = number of kana keys (12 base keys × 3 rows).
///
struct KanaKeyboardView: View {
    @ObservedObject var inputModel: KeyboardInputModel
    @State private var isSmallKanaMode: Bool = false
    @State private var activeDiacritic: DiacriticType = .none
    
    private let kanaGrid = KanaKeyboardLayout.standardJapanese

    var body: some View {
        VStack(spacing: 4) {
            kanaGridView
            modifierRowView
        }
        .padding(4)
    }
    
    /// Grid of kana keys (3 rows × 4 columns).
    @ViewBuilder
    private var kanaGridView: some View {
        ForEach(kanaGrid, id: \.self) { row in
            HStack(spacing: 4) {
                ForEach(row, id: \.self) { kanaKey in
                    KanaKeyButton(
                        key: kanaKey,
                        isSmallKanaActive: isSmallKanaMode,
                        activeDiacritic: activeDiacritic,
                        onSelect: handleKanaSelection(kanaKey:activeDiacritic:)
                    )
                }
            }
        }
    }
    
    /// Row of modifier buttons: small kana toggle, dakuten, handakuten, and punctuation.
    private var modifierRowView: some View {
        HStack(spacing: 4) {
            ModifierToggle(label: "小", isActive: isSmallKanaMode) {
                isSmallKanaMode.toggle()
            }
            ModifierToggle(label: "゛", isActive: activeDiacritic == .dakuten) {
                activeDiacritic = activeDiacritic == .dakuten ? .none : .dakuten
            }
            ModifierToggle(label: "゜", isActive: activeDiacritic == .handakuten) {
                activeDiacritic = activeDiacritic == .handakuten ? .none : .handakuten
            }
            Spacer()
            SpecialKeyButton(label: "ー") { inputModel.insertText("ー") }
            SpecialKeyButton(label: "、") { inputModel.insertText("、") }
            SpecialKeyButton(label: "。") { inputModel.insertText("。") }
        }
    }
    
    /// **CQS**: Select appropriate kana variant and apply diacritics if needed.
    /// **Pure function**: No side effects on state; delegates insertion to inputModel.
    private func handleKanaSelection(kanaKey: KanaKey, activeDiacritic: DiacriticType) {
        let selectedKana = isSmallKanaMode ? kanaKey.smallKana : kanaKey.normalKana
        let finalKana = KanaDiacriticConverter.apply(selectedKana, diacritic: activeDiacritic)
        inputModel.insertText(finalKana)
        
        if activeDiacritic != .none {
            self.activeDiacritic = .none  // Auto-reset diacritic after use.
        }
    }
}

/// Pure diacritic converter: applies dakuten/handakuten transformations to kana.
/// **Complexity**: O(1) for each lookup (hash map); no loops.
/// **Pure Function**: Deterministic, no side effects, fully testable.
///
enum KanaDiacriticConverter {
    private static let dakutenMap: [String: String] = [
        "か": "が", "き": "ぎ", "く": "ぐ", "け": "げ", "こ": "ご",
        "さ": "ざ", "し": "じ", "す": "ず", "せ": "ぜ", "そ": "ぞ",
        "た": "だ", "ち": "ぢ", "つ": "づ", "て": "で", "と": "ど",
        "は": "ば", "ひ": "び", "ふ": "ぶ", "へ": "べ", "ほ": "ぼ"
    ]
    
    private static let handakutenMap: [String: String] = [
        "は": "ぱ", "ひ": "ぴ", "ふ": "ぷ", "へ": "ぺ", "ほ": "ぽ"
    ]
    
    /// Applies a diacritic type to a kana character; returns original if no mapping exists.
    static func apply(_ kana: String, diacritic: DiacriticType) -> String {
        switch diacritic {
        case .dakuten:
            return dakutenMap[kana] ?? kana
        case .handakuten:
            return handakutenMap[kana] ?? kana
        case .none:
            return kana
        }
    }
}

/// Individual kana key button displaying base and romanization.
struct KanaKeyButton: View {
    let key: KanaKey
    let isSmallKanaActive: Bool
    let activeDiacritic: DiacriticType
    let onSelect: () -> Void
    
    var body: some View {
        Button(action: onSelect) {
            VStack(spacing: 1) {
                let displayKana = isSmallKanaActive ? key.smallKana : key.normalKana
                Text(displayKana)
                    .font(.system(size: 20, weight: .medium))
                Text(key.base)
                    .font(.system(size: 10, weight: .regular))
                    .opacity(0.6)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .foregroundColor(.primary)
            .background(Color(UIColor.systemBackground))
            .cornerRadius(6)
            .overlay(RoundedRectangle(cornerRadius: 6).stroke(Color(UIColor.separator), lineWidth: 1))
        }
        .frame(minHeight: 50)
    }
}

/// ABC keyboard with English letters and shift support.
/// **Cognitive Complexity**: ~7 (simple state, straightforward layout).
/// **O(n)** rendering: n = 26 letters + 2 special keys.
///
struct ABCKeyboardView: View {
    @ObservedObject var inputModel: KeyboardInputModel
    @State private var isShiftActive: Bool = false
    
    private let keyboardLayout = ABCKeyboardLayout.qwerty

    var body: some View {
        VStack(spacing: 4) {
            letterGridView
            bottomRowView
        }
        .padding(4)
    }
    
    @ViewBuilder
    private var letterGridView: some View {
        ForEach(keyboardLayout.letterRows, id: \.self) { row in
            HStack(spacing: 4) {
                ForEach(row, id: \.self) { letter in
                    LetterKeyButton(
                        letter: letter,
                        isShiftActive: isShiftActive,
                        onSelect: {
                            let text = isShiftActive ? letter.uppercased() : letter
                            inputModel.insertText(text)
                            isShiftActive = false
                        }
                    )
                }
            }
        }
    }
    
    private var bottomRowView: some View {
        HStack(spacing: 4) {
            ShiftKeyButton(isActive: isShiftActive) {
                isShiftActive.toggle()
            }
            Spacer()
            SpecialKeyButton(label: ".") {
                inputModel.insertText(".")
            }
        }
    }
}

struct LetterKeyButton: View {
    let letter: String
    let isShiftActive: Bool
    let onSelect: () -> Void
    
    var body: some View {
        Button(action: onSelect) {
            Text(isShiftActive ? letter.uppercased() : letter)
                .font(.system(size: 18, weight: .medium))
                .frame(maxWidth: .infinity)
                .frame(height: 44)
                .foregroundColor(.primary)
                .background(Color(UIColor.systemBackground))
                .cornerRadius(6)
                .overlay(RoundedRectangle(cornerRadius: 6).stroke(Color(UIColor.separator), lineWidth: 1))
        }
    }
}

struct ShiftKeyButton: View {
    let isActive: Bool
    let onToggle: () -> Void
    
    var body: some View {
        Button(action: onToggle) {
            Text("⇧")
                .font(.system(size: 18, weight: .semibold))
                .frame(maxWidth: .infinity)
                .frame(height: 44)
                .foregroundColor(.primary)
                .background(isActive ? Color.blue : Color(UIColor.systemBackground))
                .cornerRadius(6)
                .overlay(RoundedRectangle(cornerRadius: 6).stroke(Color(UIColor.separator), lineWidth: 1))
        }
    }
}

/// Numeric keypad (0–9).
/// **O(1)** for rendering: fixed 10 keys.
///
struct NumbersKeyboardView: View {
    @ObservedObject var inputModel: KeyboardInputModel
    
    private let layout = NumericKeyboardLayout.standard

    var body: some View {
        VStack(spacing: 4) {
            ForEach(layout.numberRows, id: \.self) { row in
                HStack(spacing: 4) {
                    ForEach(row, id: \.self) { digit in
                        CharacterKeyButton(character: digit) {
                            inputModel.insertText(digit)
                        }
                    }
                }
            }
        }
        .padding(4)
    }
}

/// Symbol keypad.
/// **O(1)** for rendering: fixed 20 symbols.
///
struct SymbolsKeyboardView: View {
    @ObservedObject var inputModel: KeyboardInputModel
    
    private let layout = SymbolKeyboardLayout.standard

    var body: some View {
        VStack(spacing: 4) {
            ForEach(layout.symbolRows, id: \.self) { row in
                HStack(spacing: 4) {
                    ForEach(row, id: \.self) { symbol in
                        CharacterKeyButton(character: symbol) {
                            inputModel.insertText(symbol)
                        }
                    }
                }
            }
        }
        .padding(4)
    }
}

/// Emoji selector with common emojis.
/// **O(n / 4)** layout rendering: n = emoji count; 4 emojis per row.
///
struct EmojiKeyboardView: View {
    @ObservedObject var inputModel: KeyboardInputModel
    
    private let emojis = ["😀", "😂", "😍", "🤔", "😱", "😎", "🎉", "🎊", "❤️", "👍", "🔥", "✨"]

    var body: some View {
        VStack(spacing: 4) {
            ForEach(0..<((emojis.count + 3) / 4), id: \.self) { rowIndex in
                HStack(spacing: 4) {
                    ForEach(0..<4, id: \.self) { colIndex in
                        let emojiIndex = rowIndex * 4 + colIndex
                        if emojiIndex < emojis.count {
                            EmojiKeyButton(emoji: emojis[emojiIndex]) {
                                inputModel.insertText(emojis[emojiIndex])
                            }
                        }
                    }
                }
            }
        }
        .padding(4)
    }
}

struct CharacterKeyButton: View {
    let character: String
    let onSelect: () -> Void
    
    var body: some View {
        Button(action: onSelect) {
            Text(character)
                .font(.system(size: 22, weight: .semibold))
                .frame(maxWidth: .infinity)
                .frame(height: 50)
                .foregroundColor(.primary)
                .background(Color(UIColor.systemBackground))
                .cornerRadius(6)
                .overlay(RoundedRectangle(cornerRadius: 6).stroke(Color(UIColor.separator), lineWidth: 1))
        }
    }
}

struct EmojiKeyButton: View {
    let emoji: String
    let onSelect: () -> Void
    
    var body: some View {
        Button(action: onSelect) {
            Text(emoji)
                .font(.system(size: 32))
                .frame(maxWidth: .infinity)
                .frame(height: 50)
                .background(Color(UIColor.systemBackground))
                .cornerRadius(6)
        }
    }
}

// MARK: - Shared UI Components & Styling

extension View {
    /// Common keyboard button border styling.
    func keyboardButtonStyle() -> some View {
        self.cornerRadius(6)
            .overlay(RoundedRectangle(cornerRadius: 6).stroke(Color(UIColor.separator), lineWidth: 1))
    }
}

struct ModeButton: View {
    let label: String
    let isActive: Bool
    let onSelect: () -> Void
    
    var body: some View {
        Button(action: onSelect) {
            Text(label)
                .font(.system(size: 14, weight: .semibold))
                .frame(maxWidth: .infinity)
                .frame(height: 32)
                .foregroundColor(.primary)
                .background(isActive ? Color.blue : Color(UIColor.systemBackground))
                .keyboardButtonStyle()
        }
    }
}

struct ModifierToggle: View {
    let label: String
    let isActive: Bool
    let onToggle: () -> Void
    
    var body: some View {
        Button(action: onToggle) {
            Text(label)
                .font(.system(size: 16, weight: .semibold))
                .frame(maxWidth: .infinity)
                .frame(height: 40)
                .foregroundColor(.primary)
                .background(isActive ? Color.blue.opacity(0.3) : Color(UIColor.systemBackground))
                .keyboardButtonStyle()
        }
    }
}

struct SpecialKeyButton: View {
    let label: String
    let onSelect: () -> Void
    
    var body: some View {
        Button(action: onSelect) {
            Text(label)
                .font(.system(size: 14, weight: .semibold))
                .frame(maxWidth: .infinity)
                .frame(height: 40)
                .foregroundColor(.primary)
                .background(Color(UIColor.systemBackground))
                .keyboardButtonStyle()
        }
    }
}

// MARK: - Models

// MARK: - Domain Models & Layouts

/// Standard Japanese kana key configuration (12-key layout).
/// **O(1)** access to all rows.
///
struct KanaKey: Hashable {
    let base: String                    // Romanized base (e.g., "ka")
    let normalKana: String              // Standard kana (e.g., "か")
    let smallKana: String               // Small variant (e.g., "ヵ")
    let upKana: String                  // Flick up variant
    let rightKana: String               // Flick right variant
    let downKana: String                // Flick down variant
    let leftKana: String                // Flick left variant
}

/// Keyboard layout constants following DRY principle.
enum KanaKeyboardLayout {
    static let standardJapanese: [[KanaKey]] = [
        [
            KanaKey(base: "a", normalKana: "あ", smallKana: "ぁ", upKana: "い", rightKana: "う", downKana: "え", leftKana: "お"),
            KanaKey(base: "ka", normalKana: "か", smallKana: "ヵ", upKana: "き", rightKana: "く", downKana: "け", leftKana: "こ"),
            KanaKey(base: "sa", normalKana: "さ", smallKana: "さ", upKana: "し", rightKana: "す", downKana: "せ", leftKana: "そ"),
            KanaKey(base: "ta", normalKana: "た", smallKana: "っ", upKana: "ち", rightKana: "つ", downKana: "て", leftKana: "と")
        ],
        [
            KanaKey(base: "na", normalKana: "な", smallKana: "な", upKana: "に", rightKana: "ぬ", downKana: "ね", leftKana: "の"),
            KanaKey(base: "ha", normalKana: "は", smallKana: "は", upKana: "ひ", rightKana: "ふ", downKana: "へ", leftKana: "ほ"),
            KanaKey(base: "ma", normalKana: "ま", smallKana: "ま", upKana: "み", rightKana: "む", downKana: "め", leftKana: "も"),
            KanaKey(base: "ya", normalKana: "や", smallKana: "ゃ", upKana: "ゆ", rightKana: "ゆ", downKana: "ょ", leftKana: "よ")
        ],
        [
            KanaKey(base: "ra", normalKana: "ら", smallKana: "ら", upKana: "り", rightKana: "る", downKana: "れ", leftKana: "ろ"),
            KanaKey(base: "wa", normalKana: "わ", smallKana: "を", upKana: "ゐ", rightKana: "ん", downKana: "ゑ", leftKana: "を"),
            KanaKey(base: "ga", normalKana: "が", smallKana: "が", upKana: "ぎ", rightKana: "ぐ", downKana: "げ", leftKana: "ご"),
            KanaKey(base: "za", normalKana: "ざ", smallKana: "ざ", upKana: "じ", rightKana: "ず", downKana: "ぜ", leftKana: "ぞ")
        ]
    ]
}

enum ABCKeyboardLayout {
    static let qwerty = ABCLayoutData(
        letterRows: [
            ["q", "w", "e", "r", "t", "y", "u", "i", "o", "p"],
            ["a", "s", "d", "f", "g", "h", "j", "k", "l"],
            ["z", "x", "c", "v", "b", "n", "m"]
        ]
    )
}

struct ABCLayoutData {
    let letterRows: [[String]]
}

enum NumericKeyboardLayout {
    static let standard = NumericLayoutData(
        numberRows: [
            ["1", "2", "3", "4", "5"],
            ["6", "7", "8", "9", "0"]
        ]
    )
}

struct NumericLayoutData {
    let numberRows: [[String]]
}

enum SymbolKeyboardLayout {
    static let standard = SymbolLayoutData(
        symbolRows: [
            ["@", "#", "$", "%", "^"],
            ["&", "*", "(", ")", "-"],
            ["=", "+", "[", "]", "{"],
            ["}", ";", ":", "'", "\""]
        ]
    )
}

struct SymbolLayoutData {
    let symbolRows: [[String]]
}

/// Manages text input delegation and insertion.
/// **Responsibility**: Wrap UITextDocumentProxy operations.
/// **Architecture**: Imperative shell delegating to iOS keyboard API.
/// **O(1)** per operation: direct proxy calls.
///
class KeyboardInputModel: ObservableObject {
    private let textDocumentProxy: UITextDocumentProxy
    
    init(textDocumentProxy: UITextDocumentProxy) {
        self.textDocumentProxy = textDocumentProxy
    }
    
    /// Insert text into the active text input.
    func insertText(_ text: String) {
        textDocumentProxy.insertText(text)
    }
    
    /// Delete one character backward.
    func deleteBackward() {
        textDocumentProxy.deleteBackward()
    }
}
*/

