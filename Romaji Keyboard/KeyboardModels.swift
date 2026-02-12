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

struct KanaKey: Equatable, Hashable, Identifiable {
    let id = UUID()
    var base: String
    var diacritics: [DiacriticType] = []
    var label: String { base }
}

// MARK: - Keyboard Input Model (Observable)

final class KeyboardInputModel: ObservableObject {
    // The current mode of the keyboard (kana/abc/numeric/symbols)
    @Published var mode: KeyboardMode = .kana

    // The composed text buffer that would be committed to the textDocumentProxy
    @Published var composedText: String = ""

    // Active diacritic selection when applicable
    @Published var activeDiacritic: DiacriticType = .none

    // Simple API used by views
    func insert(_ text: String) { composedText += text }
    func deleteBackward() {
        guard !composedText.isEmpty else { return }
        composedText.removeLast()
    }
    func apply(diacritic: DiacriticType) { activeDiacritic = diacritic }
}

// MARK: - Layout Placeholders

struct KanaKeyboardLayout {
    // Simple 2D layout of kana keys; replace with real layout later
    static let rows: [[KanaKey]] = [
        [KanaKey(base: "あ"), KanaKey(base: "い"), KanaKey(base: "う"), KanaKey(base: "え"), KanaKey(base: "お")],
        [KanaKey(base: "か"), KanaKey(base: "き"), KanaKey(base: "く"), KanaKey(base: "け"), KanaKey(base: "こ")],
        [KanaKey(base: "さ"), KanaKey(base: "し"), KanaKey(base: "す"), KanaKey(base: "せ"), KanaKey(base: "そ")]
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
