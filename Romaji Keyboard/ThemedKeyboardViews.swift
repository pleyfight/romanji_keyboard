import SwiftUI

// MARK: - Themed Keyboard Views

/// Kana keyboard view with small kana and diacritic modifiers.
struct KanaKeyboardView: View {
    @ObservedObject var inputModel: KeyboardInputModel
    @State private var isSmallKanaMode: Bool = false
    @State private var activeDiacritic: DiacriticType = .none
    
    let theme: KeyboardTheme
    private let kanaGrid = KanaKeyboardLayout.standardJapanese

    var body: some View {
        VStack(spacing: theme.dimensions.buttonSpacing) {
            kanaGridView
            modifierRowView
        }
        .padding(theme.dimensions.padding)
    }
    
    @ViewBuilder
    private var kanaGridView: some View {
        ForEach(kanaGrid, id: \.self) { row in
            HStack(spacing: theme.dimensions.buttonSpacing) {
                ForEach(row, id: \.self) { kanaKey in
                    KanaKeyButton(
                        key: kanaKey,
                        isSmallKanaActive: isSmallKanaMode,
                        activeDiacritic: activeDiacritic,
                        theme: theme,
                        onSelect: {
                            handleKanaSelection(kanaKey, activeDiacritic)
                        }
                    )
                }
            }
        }
    }
    
    @ViewBuilder
    private var modifierRowView: some View {
        HStack(spacing: theme.dimensions.buttonSpacing) {
            ModifierToggle(label: "小", isActive: isSmallKanaMode, theme: theme) {
                isSmallKanaMode.toggle()
            }
            ModifierToggle(label: "゛", isActive: activeDiacritic == .dakuten, theme: theme) {
                activeDiacritic = activeDiacritic == .dakuten ? .none : .dakuten
            }
            ModifierToggle(label: "゜", isActive: activeDiacritic == .handakuten, theme: theme) {
                activeDiacritic = activeDiacritic == .handakuten ? .none : .handakuten
            }
            Spacer()
            SpecialKeyButton(label: "ー", theme: theme) { inputModel.insertText("ー") }
            SpecialKeyButton(label: "、", theme: theme) { inputModel.insertText("、") }
            SpecialKeyButton(label: "。", theme: theme) { inputModel.insertText("。") }
        }
    }
    
    private func handleKanaSelection(_ kanaKey: KanaKey, _ diacritic: DiacriticType) {
        let selectedKana = isSmallKanaMode ? kanaKey.smallKana : kanaKey.normalKana
        let finalKana = KanaDiacriticConverter.apply(selectedKana, diacritic: diacritic)
        inputModel.insertText(finalKana)
        
        if diacritic != .none {
            activeDiacritic = .none
        }
    }
}

/// ABC keyboard with English letters and shift support.
struct ABCKeyboardView: View {
    @ObservedObject var inputModel: KeyboardInputModel
    @State private var isShiftActive: Bool = false
    
    let theme: KeyboardTheme

    var body: some View {
        VStack(spacing: theme.dimensions.buttonSpacing) {
            letterGridView
            bottomRowView
        }
        .padding(theme.dimensions.padding)
    }
    
    @ViewBuilder
    private var letterGridView: some View {
        ForEach(Array(ABCKeyboardLayout.qwerty.letterRows.enumerated()), id: \.offset) { _, row in
            HStack(spacing: theme.dimensions.buttonSpacing) {
                ForEach(Array(row.enumerated()), id: \.offset) { _, letter in
                    LetterKeyButton(
                        letter: letter,
                        isShiftActive: isShiftActive,
                        theme: theme,
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
        HStack(spacing: theme.dimensions.buttonSpacing) {
            ShiftKeyButton(isActive: isShiftActive, theme: theme) {
                isShiftActive.toggle()
            }
            Spacer()
            SpecialKeyButton(label: ".", theme: theme) {
                inputModel.insertText(".")
            }
        }
    }
}

/// Numeric keypad (0–9).
struct NumbersKeyboardView: View {
    @ObservedObject var inputModel: KeyboardInputModel
    let theme: KeyboardTheme

    var body: some View {
        VStack(spacing: theme.dimensions.buttonSpacing) {
            ForEach(Array(NumericKeyboardLayout.standard.numberRows.enumerated()), id: \.offset) { _, row in
                HStack(spacing: theme.dimensions.buttonSpacing) {
                    ForEach(Array(row.enumerated()), id: \.offset) { _, digit in
                        CharacterKeyButton(character: digit, theme: theme) {
                            inputModel.insertText(digit)
                        }
                    }
                }
            }
        }
        .padding(theme.dimensions.padding)
    }
}

/// Symbol keypad.
struct SymbolsKeyboardView: View {
    @ObservedObject var inputModel: KeyboardInputModel
    let theme: KeyboardTheme

    var body: some View {
        VStack(spacing: theme.dimensions.buttonSpacing) {
            ForEach(Array(SymbolKeyboardLayout.standard.symbolRows.enumerated()), id: \.offset) { _, row in
                HStack(spacing: theme.dimensions.buttonSpacing) {
                    ForEach(Array(row.enumerated()), id: \.offset) { _, symbol in
                        CharacterKeyButton(character: symbol, theme: theme) {
                            inputModel.insertText(symbol)
                        }
                    }
                }
            }
        }
        .padding(theme.dimensions.padding)
    }
}

/// Emoji selector with common emojis.
struct EmojiKeyboardView: View {
    @ObservedObject var inputModel: KeyboardInputModel
    let theme: KeyboardTheme
    private let emojis = ["😀", "😂", "😍", "🤔", "😱", "😎", "🎉", "🎊", "❤️", "👍", "🔥", "✨"]

    var body: some View {
        VStack(spacing: theme.dimensions.buttonSpacing) {
            ForEach(0..<((emojis.count + 3) / 4), id: \.self) { rowIndex in
                HStack(spacing: theme.dimensions.buttonSpacing) {
                    ForEach(0..<4, id: \.self) { colIndex in
                        let emojiIndex = rowIndex * 4 + colIndex
                        if emojiIndex < emojis.count {
                            EmojiKeyButton(emoji: emojis[emojiIndex], theme: theme) {
                                inputModel.insertText(emojis[emojiIndex])
                            }
                        }
                    }
                }
            }
        }
        .padding(theme.dimensions.padding)
    }
}

// MARK: - Themed Button Components

struct ModeButton: View {
    let label: String
    let isActive: Bool
    let theme: KeyboardTheme
    let onSelect: () -> Void
    
    var body: some View {
        Button(action: onSelect) {
            Text(label)
                .font(theme.typography.modeButtonFont)
                .frame(maxWidth: .infinity)
                .frame(height: theme.dimensions.modeButtonHeight)
                .foregroundColor(isActive ? theme.textColor.accent : theme.textColor.primary)
                .background(isActive ? theme.backgroundColor.keyPressed : theme.backgroundColor.key)
                .cornerRadius(theme.dimensions.cornerRadius)
                .overlay(
                    RoundedRectangle(cornerRadius: theme.dimensions.cornerRadius)
                        .stroke(
                            isActive ? theme.borderColor.active : theme.borderColor.standard,
                            lineWidth: theme.dimensions.borderWidth
                        )
                )
        }
    }
}

struct KanaKeyButton: View {
    let key: KanaKey
    let isSmallKanaActive: Bool
    let activeDiacritic: DiacriticType
    let theme: KeyboardTheme
    let onSelect: () -> Void
    
    var body: some View {
        Button(action: onSelect) {
            VStack(spacing: 1) {
                let displayKana = isSmallKanaActive ? key.smallKana : key.normalKana
                Text(displayKana)
                    .font(theme.typography.keyFont)
                Text(key.base)
                    .font(theme.typography.keyLabelFont)
                    .opacity(0.6)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .foregroundColor(theme.textColor.primary)
            .background(theme.backgroundColor.key)
            .cornerRadius(theme.dimensions.cornerRadius)
            .overlay(
                RoundedRectangle(cornerRadius: theme.dimensions.cornerRadius)
                    .stroke(theme.borderColor.standard, lineWidth: theme.dimensions.borderWidth)
            )
        }
        .frame(minHeight: theme.dimensions.keyHeight)moji: String
    let theme: KeyboardTheme
    let onSelect: () -> Void
    
    var body: some View {
        Button(action: onSelect) {
            Text(emoji)
                .font(.system(size: 32))
                .frame(maxWidth: .infinity)
                .frame(height: theme.dimensions.keyHeight)
                .background(theme.backgroundColor.key)
                .cornerRadius(theme.dimensions.cornerRadius)
        }
    }
}

struct ModifierToggle: View {
    let label: String
    let isActive: Bool
    let theme: KeyboardTheme
    let onToggle: () -> Void
    
    var body: some View {
        Button(action: onToggle) {
            Text(label)
                .font(theme.typography.modifierFont)
                .frame(maxWidth: .infinity)
                .frame(height: theme.dimensions.modifierHeight)
                .foregroundColor(isActive ? theme.textColor.accent : theme.textColor.primary)
                .background(isActive ? theme.backgroundColor.keyPressed : theme.backgroundColor.key)
                .cornerRadius(theme.dimensions.cornerRadius)
                .overlay(
                    RoundedRectangle(cornerRadius: theme.dimensions.cornerRadius)
                        .stroke(
                            isActive ? theme.borderColor.active : theme.borderColor.standard,
                            lineWidth: theme.dimensions.borderWidth
                        )
                )
        }
    }
}

struct SpecialKeyButton: View {
    let label: String
    let theme: KeyboardTheme
    let onSelect: () -> Void
    
    var body: some View {
        Button(action: onSelect) {
            Text(label)
                .font(theme.typography.specialKeyFont)
                .frame(maxWidth: .infinity)
                .frame(height: theme.dimensions.modifierHeight)
                .foregroundColor(theme.textColor.primary)
                .background(theme.backgroundColor.key)
                .cornerRadius(theme.dimensions.cornerRadius)
                .overlay(
                    RoundedRectangle(cornerRadius: theme.dimensions.cornerRadius)
                        .stroke(theme.borderColor.standard, lineWidth: theme.dimensions.borderWidth)
                )
        }
    }
}
