import Foundation
import SwiftUI

// MARK: - Keyboard Modes

enum KeyboardMode: Equatable, Hashable {
    case kana
    case abc
    case numeric
    case symbols
}

// MARK: - Diacritic Types

enum DiacriticType: Equatable, Hashable {
    case none
    case dakuten
    case handakuten
}

// MARK: - Kana Key Model

// MARK: - Kana Key Model

struct KanaKey: Hashable {
    let base: String                    // Romanized base (e.g., "ka")
    let normalKana: String              // Standard kana (e.g., "か")
    let smallKana: String               // Small variant (e.g., "ヵ")
    let upKana: String                  // Flick up variant
    let rightKana: String               // Flick right variant
    let downKana: String                // Flick down variant
    let leftKana: String                // Flick left variant
}

// MARK: - Keyboard Input Model (Observable)

/// Manages text input delegation and insertion.
/// **Responsibility**: Wrap UITextDocumentProxy operations.
/// **Architecture**: Imperative shell delegating to iOS keyboard API.
/// **O(1)** per operation: direct proxy calls.
///
class KeyboardInputModel: ObservableObject {
    private let textDocumentProxy: UITextDocumentProxy
    
    // The current mode of the keyboard (kana/abc/numeric/symbols)
    @Published var mode: KeyboardMode = .kana
    
    // Romaji Input Buffer
    @Published var romajiBuffer: String = ""
    
    // Active diacritic selection when applicable
    @Published var activeDiacritic: DiacriticType = .none

    init(textDocumentProxy: UITextDocumentProxy) {
        self.textDocumentProxy = textDocumentProxy
    }
    
    /// Insert text into the active text input.
    /// Handles Romaji conversion if in Kana mode and buffer is active.
    func insertText(_ text: String) {
        if mode == .kana {
            // Append to buffer
            romajiBuffer += text
            
            // Attempt conversion
            let (converted, remaining) = RomajiConverter.convert(romajiBuffer)
            
            if !converted.isEmpty {
                // If we converted something, we need to "commit" it.
                // However, the proxy (and UI) might be showing the "k" "ka" letters during typing?
                // Standard behavior: The Composition Text shows "k", then "ka", then changes to "か".
                // Since we don't have full `setMarkedText` control (requires custom UIInputViewController logic beyond proxy),
                // we'll use a simpler approach:
                // 1. We insert the raw text into the proxy? No, that messes up the document.
                // 2. We ONLY insert the FINAL converted Kana.
                // 3. We show the BUFFER in our own floating view (already planned in next step).
                
                textDocumentProxy.insertText(converted)
                romajiBuffer = remaining
            }
            
            // If the buffer gets too long without conversion (e.g. "kx"), maybe force flush?
            if romajiBuffer.count > 4 {
                 textDocumentProxy.insertText(romajiBuffer)
                 romajiBuffer = ""
            }
        } else {
            // Direct input for other modes
            textDocumentProxy.insertText(text)
        }
    }
    
    /// Delete one character backward.
    func deleteBackward() {
        if !romajiBuffer.isEmpty {
            romajiBuffer.removeLast()
        } else {
            textDocumentProxy.deleteBackward()
        }
    }
    
    func apply(diacritic: DiacriticType) { activeDiacritic = diacritic }
}

// MARK: - Layout Placeholders

struct KanaKeyboardLayout {
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

struct ABCKeyboardLayout {
    static let rows: [[String]] = [
        ["Q","W","E","R","T","Y","U","I","O","P"],
        ["A","S","D","F","G","H","J","K","L"],
        ["Z","X","C","V","B","N","M"]
    ]
}

struct NumericKeyboardLayout {
    static let rows: [[String]] = [
        ["1","2","3"],
        ["4","5","6"],
        ["7","8","9"],
        ["0"]
    ]
}

struct SymbolKeyboardLayout {
    static let rows: [[String]] = [
        ["-","/",":",";","(",")","$","&","@","\""],
        [".",",","?","!","'","#","%","^","*","+"]
    ]
}
