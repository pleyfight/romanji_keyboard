import Foundation
import SwiftUI
import Combine
import UIKit

// MARK: - Keyboard Modes

enum KeyboardMode: Equatable, Hashable {
    case kana
    case abc
    case numbers
    case symbols
    case emoji
}

// MARK: - Diacritic Types

enum DiacriticType: Equatable, Hashable {
    case none
    case dakuten
    case handakuten
}

/// Pure diacritic converter: applies dakuten/handakuten transformations to kana.
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

// MARK: - Kana Key Model

struct KanaKey: Equatable, Hashable, Identifiable {
    let id = UUID()
    var base: String
    var normalKana: String
    var smallKana: String
}

// MARK: - Keyboard Input Model

final class KeyboardInputModel: ObservableObject {
    private weak var textDocumentProxy: UITextDocumentProxy?
    
    @Published var mode: KeyboardMode = .kana
    @Published var composedText: String = ""
    @Published var activeDiacritic: DiacriticType = .none
    
    init(textDocumentProxy: UITextDocumentProxy? = nil) {
        self.textDocumentProxy = textDocumentProxy
    }
    
    func insertText(_ text: String) {
        if let proxy = textDocumentProxy {
            proxy.insertText(text)
        } else {
            composedText += text
        }
    }
    
    func insert(_ text: String) { insertText(text) }
    
    func deleteBackward() {
        if let proxy = textDocumentProxy {
            proxy.deleteBackward()
        } else {
            guard !composedText.isEmpty else { return }
            composedText.removeLast()
        }
    }
    
    func apply(diacritic: DiacriticType) { activeDiacritic = diacritic }
}

// MARK: - Layouts

struct KanaKeyboardLayout {
    static let standardJapanese: [[KanaKey]] = [
        [
            KanaKey(base: "a", normalKana: "あ", smallKana: "ぁ"),
            KanaKey(base: "i", normalKana: "い", smallKana: "ぃ"),
            KanaKey(base: "u", normalKana: "う", smallKana: "ぅ"),
            KanaKey(base: "e", normalKana: "え", smallKana: "ぇ"),
            KanaKey(base: "o", normalKana: "お", smallKana: "ぉ")
        ],
        [
            KanaKey(base: "ka", normalKana: "か", smallKana: "ヵ"),
            KanaKey(base: "ki", normalKana: "き", smallKana: "き"),
            KanaKey(base: "ku", normalKana: "く", smallKana: "く"),
            KanaKey(base: "ke", normalKana: "け", smallKana: "ヶ"),
            KanaKey(base: "ko", normalKana: "こ", smallKana: "こ")
        ],
        [
            KanaKey(base: "sa", normalKana: "さ", smallKana: "さ"),
            KanaKey(base: "shi", normalKana: "し", smallKana: "し"),
            KanaKey(base: "su", normalKana: "す", smallKana: "す"),
            KanaKey(base: "se", normalKana: "せ", smallKana: "せ"),
            KanaKey(base: "so", normalKana: "そ", smallKana: "そ")
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
