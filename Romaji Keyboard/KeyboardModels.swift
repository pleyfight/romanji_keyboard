import Foundation
import SwiftUI
import Combine

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
    let label: String                   // Display Label (e.g. "か")
    let subLabel: String                // Sub Label (e.g. "ka")
    
    // Romaji Outputs for flicks
    let centerRomaji: String
    let upRomaji: String
    let rightRomaji: String
    let downRomaji: String
    let leftRomaji: String
    
    // Display characters (for the flick guides and button face)
    let centerDisplay: String
    let upDisplay: String
    let rightDisplay: String
    let downDisplay: String
    let leftDisplay: String
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
            KanaKey(label: "あ", subLabel: "a",
                    centerRomaji: "a", upRomaji: "i", rightRomaji: "u", downRomaji: "e", leftRomaji: "o",
                    centerDisplay: "あ", upDisplay: "い", rightDisplay: "う", downDisplay: "え", leftDisplay: "お"),
            KanaKey(label: "か", subLabel: "ka",
                    centerRomaji: "ka", upRomaji: "ki", rightRomaji: "ku", downRomaji: "ke", leftRomaji: "ko",
                    centerDisplay: "か", upDisplay: "き", rightDisplay: "く", downDisplay: "け", leftDisplay: "こ"),
            KanaKey(label: "さ", subLabel: "sa",
                    centerRomaji: "sa", upRomaji: "shi", rightRomaji: "su", downRomaji: "se", leftRomaji: "so",
                    centerDisplay: "さ", upDisplay: "し", rightDisplay: "す", downDisplay: "せ", leftDisplay: "そ"),
            KanaKey(label: "た", subLabel: "ta",
                    centerRomaji: "ta", upRomaji: "chi", rightRomaji: "tsu", downRomaji: "te", leftRomaji: "to",
                    centerDisplay: "た", upDisplay: "ち", rightDisplay: "つ", downDisplay: "て", leftDisplay: "と")
        ],
        [
            KanaKey(label: "な", subLabel: "na",
                    centerRomaji: "na", upRomaji: "ni", rightRomaji: "nu", downRomaji: "ne", leftRomaji: "no",
                    centerDisplay: "な", upDisplay: "に", rightDisplay: "ぬ", downDisplay: "ね", leftDisplay: "の"),
            KanaKey(label: "は", subLabel: "ha",
                    centerRomaji: "ha", upRomaji: "hi", rightRomaji: "fu", downRomaji: "he", leftRomaji: "ho",
                    centerDisplay: "は", upDisplay: "ひ", rightDisplay: "ふ", downDisplay: "へ", leftDisplay: "ほ"),
            KanaKey(label: "ま", subLabel: "ma",
                    centerRomaji: "ma", upRomaji: "mi", rightRomaji: "mu", downRomaji: "me", leftRomaji: "mo",
                    centerDisplay: "ま", upDisplay: "み", rightDisplay: "む", downDisplay: "め", leftDisplay: "も"),
            KanaKey(label: "や", subLabel: "ya",
                    centerRomaji: "ya", upRomaji: "yu", rightRomaji: "yu", downRomaji: "yo", leftRomaji: "yo", // Y row is special
                    centerDisplay: "や", upDisplay: "ゆ", rightDisplay: "ゆ", downDisplay: "よ", leftDisplay: "よ")
        ],
        [
            KanaKey(label: "ら", subLabel: "ra",
                    centerRomaji: "ra", upRomaji: "ri", rightRomaji: "ru", downRomaji: "re", leftRomaji: "ro",
                    centerDisplay: "ら", upDisplay: "り", rightDisplay: "る", downDisplay: "れ", leftDisplay: "ろ"),
            KanaKey(label: "わ", subLabel: "wa",
                    centerRomaji: "wa", upRomaji: "wo", rightRomaji: "nn", downRomaji: "wa", leftRomaji: "wo", // w row special
                    centerDisplay: "わ", upDisplay: "を", rightDisplay: "ん", downDisplay: "わ", leftDisplay: "を"),
            KanaKey(label: "が", subLabel: "ga", // Keeping the dakuten keys or generic? 
                    centerRomaji: "ga", upRomaji: "gi", rightRomaji: "gu", downRomaji: "ge", leftRomaji: "go",
                    centerDisplay: "が", upDisplay: "ぎ", rightDisplay: "ぐ", downDisplay: "げ", leftDisplay: "ご"),
            KanaKey(label: "ざ", subLabel: "za",
                    centerRomaji: "za", upRomaji: "ji", rightRomaji: "zu", downRomaji: "ze", leftRomaji: "zo",
                    centerDisplay: "ざ", upDisplay: "じ", rightDisplay: "ず", downDisplay: "ぜ", leftDisplay: "ぞ")
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

