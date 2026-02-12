# 🚨 CRITICAL FIX REQUIRED - Remove Messages Extension Target in Xcode

## The Problem
The Messages Extension target still exists in your Xcode project and is causing the build error:
```
Build input file cannot be found: 'SpeakAny MessagesExtension/Info.plist'
```

## ✅ Solution: Delete Target in Xcode (2 minutes)

### Step-by-Step Instructions:

1. **Open Xcode** (should already be open)
   - Project: `SpeakAny.xcodeproj`

2. **Select the Project** in the Navigator
   - Click on "SpeakAny" (blue project icon) at the top of the left sidebar

3. **Go to Targets Section**
   - In the main editor area, you'll see "PROJECT" and "TARGETS" sections
   - Look at the TARGETS list

4. **You Should See 3 Targets:**
   - ✅ SpeakAny (keep this)
   - ❌ **SpeakAny MessagesExtension** (DELETE THIS ONE)
   - ✅ Romaji Keyboard (keep this)

5. **Delete the Messages Extension Target:**
   - Click on "SpeakAny MessagesExtension" to select it
   - Press the **Delete** key (or right-click → Delete)
   - When prompted, click **"Move to Trash"** or **"Delete"**

6. **Change Main App Type:**
   - Click on "SpeakAny" target
   - Go to "General" tab
   - Scroll down to "Deployment Info"
   - If you see any Messages-related settings, remove them

7. **Fix Main App Product Type:**
   - With "SpeakAny" target selected
   - Go to "Build Settings" tab  
   - Search for "PRODUCT_TYPE"
   - If it says `com.apple.product-type.application.messages`, change it to:
     `com.apple.product-type.application`

8. **Verify Keyboard Extension is Embedded:**
   - Click on "SpeakAny" target
   - Go to "General" tab
   - Scroll to "Frameworks, Libraries, and Embedded Content"
   - You should see "Romaji Keyboard.appex" listed
   - If not there, click the + button and add it

9. **Clean and Build:**
   - Press **⌘⇧K** (Clean Build Folder)
   - Press **⌘B** (Build)
   - The error should be gone!

## Verification

After deleting the target, you should only see **2 targets**:
- ✅ SpeakAny
- ✅ Romaji Keyboard

## If You Can't Find the Delete Option

**Alternative Method:**
1. Select "SpeakAny MessagesExtension" target
2. Go to menu: **Editor → Delete**
3. Or: Right-click on target → **Delete**

## After Deletion

The project will automatically:
- Remove all Messages Extension references
- Clean up the project.pbxproj file
- Update build settings

Then simply **Build (⌘B)** and the error will be resolved!

---

**This is the cleanest way to remove a target** - Xcode will handle all the cleanup automatically.
