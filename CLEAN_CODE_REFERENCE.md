# Clean Code Quick Reference: Keyboard Extension
**Guidelines Applied:** Clean Code + Efficiency Codex 1.2.0

---

## 🎯 Key Architecture Patterns

### Functional Core + Imperative Shell

```
Pure Functions (Domain)        Imperative Side Effects (UI/Infrastructure)
├─ KanaDiacriticConverter      ├─ UIKit KeyboardViewController
├─ KanaKeyboardLayout          ├─ SwiftUI Views
└─ Conversion logic            └─ UITextDocumentProxy calls
```

**Why:** Domain logic is testable without UI framework. Infrastructure calls wrapped in injectable model.

---

## 📝 Naming Conventions

### Booleans: `is` or `has` prefixes (yes/no questions)

```swift
✅ isSmallKanaMode
✅ isShiftActive
✅ isActive

❌ smallKana
❌ shifted
```

### Callbacks: `on` + Action

```swift
✅ onSelect, onToggle, onTap
✅ action: { ... }

❌ handlePress, doAction
```

### Parameters: Semantic + Specific

```swift
✅ label          // Button text
✅ isActive       // Boolean state indicator
✅ onSelect       // Callback when selected

❌ title          // Too vague
❌ flag           // What flag?
❌ action         // Which action?
```

---

## 🏗️ Dependency Injection Pattern

**Do NOT:** Create models inside views

```swift
❌ WRONG
struct MyView: View {
    let model = KeyboardInputModel(...)  // Hard to test
}
```

**Do:** Inject as parameter

```swift
✅ CORRECT
struct MyView: View {
    @ObservedObject var inputModel: KeyboardInputModel  // Injected
}
```

---

## 🧩 DRY: Extract Duplicated Layouts

**Before (Duplication):**
```swift
struct ABCKeyboardView {
    let rows = [["q", "w", ...], ...]
}
struct NumbersKeyboardView {
    let rows = [["1", "2", ...], ...]
}
```

**After (Single Source of Truth):**
```swift
enum ABCKeyboardLayout {
    static let qwerty = ABCLayoutData(
        letterRows: [["q", "w", ...], ...]
    )
}

struct ABCKeyboardView {
    private let layout = ABCKeyboardLayout.qwerty
}
```

---

## 🔍 CQS: Separate Commands from Queries

**Command** (mutates state, returns void):
```swift
func deleteBackward() {
    textDocumentProxy.deleteBackward()
}
```

**Query** (reads state, no side effects):
```swift
func apply(_ kana: String, diacritic: DiacriticType) -> String {
    // Pure function
}
```

---

## 📊 Cognitive Complexity Checklist

| Score | Status | Action |
|-------|--------|--------|
| 0–10 | 🟢 Green | Ship it |
| 11–15 | 🟡 Yellow | Refactor if easy; add tests |
| 16+ | 🔴 Red | MUST refactor |

**How to reduce:**
1. Extract nested conditionals into `@ViewBuilder` properties
2. Move data definitions to constants (not inline)
3. Split complex functions into helpers

---

## ✅ Pre-Code Checklist

Before writing a new keyboard view or mode:

- [ ] What is `n` (input size)?
- [ ] What is the time complexity? (Should be O(1) or O(n) for fixed layouts)
- [ ] Does it do one thing? (SLAP)
- [ ] Are parameters ≤ 3? (Use parameter object if not)
- [ ] Are there boolean parameters? (Split into two functions if yes)
- [ ] Is state injected or hardcoded? (Should be injected)
- [ ] Is there duplication? (Extract to constant/helper)
- [ ] Will tests be easy to write? (Pure functions = easy)

---

## 🚀 Adding a New Keyboard Mode

**Step 1: Create layout constant**
```swift
enum MyKeyboardLayout {
    static let myLayout = MyLayoutData(
        rows: [["key1", "key2", ...], ...]
    )
}
```

**Step 2: Add enum case**
```swift
enum KeyboardMode {
    case kana, abc, numbers, symbols, emoji
    case myMode  // ← Add here
}
```

**Step 3: Create view**
```swift
struct MyKeyboardView: View {
    @ObservedObject var inputModel: KeyboardInputModel
    private let layout = MyKeyboardLayout.myLayout
    
    var body: some View {
        // Use layout.rows to render
    }
}
```

**Step 4: Add to root view switch**
```swift
@ViewBuilder
private var modeView: some View {
    switch selectedMode {
    case .myMode:
        MyKeyboardView(inputModel: inputModel)
    // ... other cases
    }
}
```

---

## 🧪 Writing Testable Code

### Pure Function (Easy to Test)
```swift
func testDiacriticConversion() {
    let result = KanaDiacriticConverter.apply("か", diacritic: .dakuten)
    XCTAssertEqual(result, "が")
}
```

### UI State (Harder; Use Snapshot Testing)
```swift
func testSmallKanaToggleAppearsInButton() {
    // Verify UI rendering; use snapshot tests
}
```

---

## 📐 Code Organization

**File Structure:**
```
KeyboardViewController.swift
├─ KeyboardViewController (UIKit bridge)
├─ KeyboardRootView (SwiftUI root orchestrator)
├─ Mode-Specific Views (KanaKeyboardView, ABCKeyboardView, ...)
├─ Button Components (ModeButton, LetterKeyButton, ...)
├─ Shared Extensions (keyboardButtonStyle)
├─ Domain Models (KanaDiacriticConverter, KanaKey)
├─ Layout Constants (KanaKeyboardLayout, ABCKeyboardLayout, ...)
└─ Input Model (KeyboardInputModel)
```

**Read Top-Down:** High-level logic first; implementation details last (stepdown rule).

---

## 🎨 UI Styling: DRY with Extensions

**Don't repeat:**
```swift
❌ .cornerRadius(6).overlay(RoundedRectangle(...).stroke(...))
```

**Use extension:**
```swift
✅ .keyboardButtonStyle()

extension View {
    func keyboardButtonStyle() -> some View {
        self.cornerRadius(6)
            .overlay(RoundedRectangle(cornerRadius: 6).stroke(...))
    }
}
```

---

## 🐛 Debugging Tips

### Cognitive Complexity Too High?
- Count nested `if`, `for`, `switch` statements
- Each level adds complexity
- Extract inner logic to helper function

### State Management Tangled?
- Verify single `@ObservedObject` per view
- Check dependency injection (no hardcoded models)
- Use `@State` for local-only state (not shared)

### Naming Unclear?
- Boolean: should read as "is {condition}?"
- Function: should be a verb
- Variable: should be a noun + descriptor

---

## 📚 Further Reading

See **REFACTORING_REPORT.md** for:
- Complete before/after analysis
- SOLID compliance details
- Testing recommendations
- Performance metrics

---

**Guideline:** Clean Code + Efficiency Codex 1.2.0  
**Status:** ✅ Code is clean, efficient, and maintainable
