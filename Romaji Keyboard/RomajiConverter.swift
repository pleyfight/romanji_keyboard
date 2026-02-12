
import Foundation

class RomajiConverter {
    // Basic mapping for Romaji to Hiragana
    // This is a simplified map; a full implementation would cover all combinations.
    private static let mapping: [String: String] = [
        "a": "あ", "i": "い", "u": "う", "e": "え", "o": "お",
        "ka": "か", "ki": "き", "ku": "く", "ke": "け", "ko": "こ",
        "sa": "さ", "si": "し", "shi": "し", "su": "す", "se": "せ", "so": "そ",
        "ta": "た", "ti": "ち", "chi": "ち", "tu": "つ", "tsu": "つ", "te": "て", "to": "と",
        "na": "な", "ni": "に", "nu": "ぬ", "ne": "ね", "no": "の",
        "ha": "は", "hi": "ひ", "hu": "ふ", "fu": "ふ", "he": "へ", "ho": "ほ",
        "ma": "ま", "mi": "み", "mu": "む", "me": "め", "mo": "も",
        "ya": "や", "yu": "ゆ", "yo": "よ",
        "ra": "ら", "ri": "り", "ru": "る", "re": "れ", "ro": "ろ",
        "wa": "わ", "wo": "を", "nn": "ん",
        "ga": "が", "gi": "ぎ", "gu": "ぐ", "ge": "げ", "go": "ご",
        "za": "ざ", "ji": "じ", "zi": "じ", "zu": "ず", "ze": "ぜ", "zo": "ぞ",
        "da": "だ", "di": "ぢ", "du": "づ", "de": "で", "do": "ど",
        "ba": "ば", "bi": "び", "bu": "ぶ", "be": "べ", "bo": "ぼ",
        "pa": "ぱ", "pi": "ぴ", "pu": "ぷ", "pe": "ぺ", "po": "ぽ",
        "ja": "じゃ", "ju": "じゅ", "jo": "じょ",
        "kya": "きゃ", "kyu": "きゅ", "kyo": "きょ",
        "sha": "しゃ", "shu": "しゅ", "sho": "しょ",
        "cha": "ちゃ", "chu": "ちゅ", "cho": "ちょ",
        "nya": "にゃ", "nyu": "にゅ", "nyo": "にょ",
        "hya": "ひゃ", "hyu": "ひゅ", "hyo": "ひょ",
        "mya": "みゃ", "myu": "みゅ", "myo": "みょ",
        "rya": "りゃ", "ryu": "りゅ", "ryo": "りょ",
        "gya": "ぎゃ", "gyu": "ぎゅ", "gyo": "ぎょ",
        "bya": "びゃ", "byu": "びゅ", "byo": "びょ",
        "pya": "ぴゃ", "pyu": "ぴゅ", "pyo": "ぴょ"
    ]
    
    /// Converts a romaji string buffer to Japanese text.
    /// Returns a tuple: (convertedText, remainingBuffer)
    /// e.g. "ka" -> ("か", "")
    /// e.g. "k" -> ("", "k")
    /// e.g. "shi" -> ("し", "")
    /// e.g. "tt" -> ("っ", "t")
    /// e.g. "n" (at end) -> ("", "n")
    /// e.g. "nk" -> ("ん", "k")
    static func convert(_ buffer: String) -> (String, String) {
        // Simple greedy match from the end? No, from start.
        // Actually, we usually convert as soon as a valid syllable is formed.
        // For a simple implementation, we check if the buffer *matches* a key.
        
        // 1. Exact match
        if let kana = mapping[buffer] {
            return (kana, "")
        }
        
        // 2. Special case: "n" followed by consonant (except y)
        if buffer.hasPrefix("n") && buffer.count > 1 {
            let nextChar = buffer.dropFirst().first!
            if !"aeiouy".contains(nextChar) {
                return ("ん", String(buffer.dropFirst()))
            }
        }
        
        // 3. Special case: repeated consonant (sokuon) e.g. "tt", "kk", "ss"
        if buffer.count >= 2 {
            let first = buffer.first!
            let second = buffer.dropFirst().first!
            if first == second && !"aeioun".contains(first) {
                return ("っ", String(buffer.dropFirst()))
            }
        }
        
        // 4. No conversion yet
        return ("", buffer)
    }
    
    /// Checks if a string *could* be the start of a valid sequence
    static func isValidPrefix(_ text: String) -> Bool {
        // Verify if any key in the map starts with `text`
        // Optimization: In a real app we'd use a Trie.
        // For now, simple iteration or assumption.
        // Actually, practically any consonant is a valid prefix.
        if text.isEmpty { return true }
        // Simple heuristic: don't allow crazy long strings
        return text.count <= 3
    }
}
