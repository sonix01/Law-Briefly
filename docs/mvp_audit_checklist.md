# MVP Audit Checklist
## Law Briefly — Pre-Release Quality Gate

**File:** `docs/mvp_audit_checklist.md`  
**Last Updated:** June 2026  
**Version:** 1.0.0  
**Auditor:** ___________________  
**Date Audited:** ___________________  
**Build Number:** ___________________  
**Target:** First debug APK → First release APK

---

## How to Use This Checklist

Work through every section in order before attempting `flutter build apk --release`.  
Every item marked 🔴 is a **build blocker** — the APK must not be distributed with these unresolved.  
Items marked 🟡 are **release blockers** — acceptable for a debug APK, not for public release.  
Items marked 🟢 are **post-MVP** — log them, do not block the first release on them.

Mark each item:
- `[x]` — Verified and passing
- `[-]` — Not applicable for this build
- `[!]` — Failing — add note below item

---

## 1. Routing

### 1.1 Route Registration
- [ ] 🔴 All named routes are registered in `app_router.dart`
- [ ] 🔴 No duplicate route names exist across `RouteNames` constants
- [ ] 🔴 No duplicate route paths exist across `RoutePaths` constants
- [ ] 🔴 Every route has a `pageBuilder` — no routes use `builder` only
- [ ] 🔴 All path parameters (`actId`, `sectionId`, `partId`, `articleId`) are declared in `RouteParams`

### 1.2 Route Transitions
- [ ] 🔴 Splash → Login transition is fade (not slide)
- [ ] 🔴 Login → Home transition is scaleUp
- [ ] 🔴 Home → Acts transition is slide
- [ ] 🔴 Acts → ActDetail transition is slide
- [ ] 🔴 ActDetail → Reader transition is slide
- [ ] 🔴 Home → Constitution transition is slide
- [ ] 🔴 Constitution → Reader (article) transition is slide
- [ ] 🔴 Home → Settings transition is slide
- [ ] 🔴 Settings → About transition is slide
- [ ] 🔴 My Notes → Note Editor transition is slideUp

### 1.3 Route Guards (Redirect)
- [ ] 🔴 Unauthenticated user navigating to `/home` is redirected to `/login`
- [ ] 🔴 Authenticated user navigating to `/login` is redirected to `/home`
- [ ] 🔴 Splash screen redirects to login when session is absent
- [ ] 🔴 Splash screen redirects to home when session is present
- [ ] 🔴 Guest session grants access to all non-premium routes
- [ ] 🔴 Router refresh triggers on auth state change (`refreshListenable`)

### 1.4 Deep Link Integrity
- [ ] 🔴 `ActDetailScreen` receives `actId`, `actName`, `year` correctly from `ActDetailNavArgs` extra
- [ ] 🔴 `ReaderScreen.actSection` receives `actId` and `sectionId` from path parameters
- [ ] 🔴 `ReaderScreen.constitutionArticle` receives `partId` and `articleId` from path parameters
- [ ] 🔴 `ConstitutionScreen` receives `initialPartId` when navigating to a specific part
- [ ] 🔴 `PdfReaderScreen` receives `pdfId`, `title`, `assetPath` from `PdfReaderArgs` extra
- [ ] 🔴 `NoteEditorScreen` receives existing note data when editing

### 1.5 Back Navigation
- [ ] 🔴 Back button on every screen pops correctly
- [ ] 🔴 Back from Reader returns to ActDetail or Constitution (not Home)
- [ ] 🔴 Back from ActDetail returns to Acts list
- [ ] 🔴 Back from Settings returns to Home
- [ ] 🔴 Back from Note Editor returns to My Notes
- [ ] 🔴 Android system back button behaves identically to in-app back button

### 1.6 Error Handling
- [ ] 🟡 Router `errorBuilder` displays a readable error message for unknown routes
- [ ] 🟡 Navigating to a non-existent `actId` does not crash — shows error state
- [ ] 🟡 Navigating to a non-existent `articleId` does not crash — shows error state

---

## 2. Reader Flow

### 2.1 Act Section Loading
- [ ] 🔴 Reader screen loads when `actId` and `sectionId` are provided
- [ ] 🔴 Section title displays correctly in content area
- [ ] 🔴 Section number badge displays correctly (`Section 103` format)
- [ ] 🔴 Body text renders in Georgia font
- [ ] 🔴 App bar title shows section label in accent colour
- [ ] 🔴 App bar subtitle shows act name in secondary text

### 2.2 Constitution Article Loading
- [ ] 🔴 Reader screen loads when `partId` and `articleId` are provided
- [ ] 🔴 Article title displays correctly
- [ ] 🔴 Article number badge displays correctly (`Article 21` format)
- [ ] 🔴 Preamble displays badge as "Preamble" not "Article Preamble"
- [ ] 🔴 App bar title shows article label in accent colour
- [ ] 🔴 App bar subtitle shows "Constitution of India"

### 2.3 Content Block Rendering
- [ ] 🔴 `ContentBlockType.main` renders as full-width Georgia body text
- [ ] 🔴 `ContentBlockType.explanation` renders with left accent border, italic, indented
- [ ] 🔴 `ContentBlockType.proviso` renders with left gold border, italic, indented
- [ ] 🔴 `ContentBlockType.subSection` renders indented with 10% reduced opacity
- [ ] 🔴 Explanation label ("Explanation —") appears in accent colour above explanation text
- [ ] 🔴 Proviso label ("Provided that —") appears in gold above proviso text
- [ ] 🔴 Paragraph spacing of 20px exists between every content block

### 2.4 Entrance Animations
- [ ] 🟡 App bar fades in from 0→1 opacity in first 360ms
- [ ] 🟡 App bar slides down from -25% offset
- [ ] 🟡 Content fades in starting at 160ms
- [ ] 🟡 Bottom nav bar rises from below screen starting at 440ms
- [ ] 🟡 No animation jank on mid-range Android device (Snapdragon 665 class)

### 2.5 Loading State
- [ ] 🔴 Skeleton placeholder appears while content loads
- [ ] 🔴 Skeleton pulses between 35% and 85% opacity
- [ ] 🔴 Skeleton matches approximate layout of real content (badge + title + body lines)
- [ ] 🔴 No white flash between skeleton and content

### 2.6 Error State
- [ ] 🔴 Error state appears when content fails to load
- [ ] 🔴 Error state shows "Content Unavailable" title
- [ ] 🔴 "Try Again" button triggers reload
- [ ] 🔴 Error message text is readable and not truncated

### 2.7 Empty Content State
- [ ] 🔴 "Content coming soon." message appears when content blocks are empty
- [ ] 🔴 App does not crash when `content.content` is an empty list

### 2.8 Text Selection
- [ ] 🟡 Legal content is wrapped in `SelectionArea`
- [ ] 🟡 Student can select and copy text on both Android and iOS
- [ ] 🟡 Selection handles do not interfere with scrolling

### 2.9 Scrolling
- [ ] 🔴 `BouncingScrollPhysics` is active
- [ ] 🔴 Bottom padding is sufficient that last paragraph is not obscured by nav bar
- [ ] 🔴 Scroll position resets to top when section changes

---

## 3. Case Law Flow

### 3.1 Case Law List in Reader
- [ ] 🔴 Case laws section only appears when `content.hasCaseLaws` is true
- [ ] 🔴 Case law section is hidden when content has no case law IDs
- [ ] 🔴 Gradient divider appears above case law section
- [ ] 🔴 Gavel icon and "Linked Case Laws" label appear
- [ ] 🔴 Count badge shows correct number of linked case laws
- [ ] 🔴 Each case law renders as a tappable row with Georgia italic title
- [ ] 🔴 Trailing chevron `>` appears on each row

### 3.2 Case Law Tap → Popup
- [ ] 🔴 Tapping a case law row calls `showCaseLawPopup(context, caseLawId)`
- [ ] 🔴 `showCaseLawPopup` is imported from `case_law_popup.dart`
- [ ] 🔴 The correct `caseLawId` from `content.caseLawIds` is passed to the popup
- [ ] 🔴 Press state (accent tint background) activates on tap down
- [ ] 🔴 `HapticFeedback.selectionClick()` fires on tap down

### 3.3 Case Law Popup Modal
- [ ] 🔴 Modal opens as a bottom sheet
- [ ] 🔴 Modal reaches 80–90% of screen height
- [ ] 🔴 Modal has glass blur backdrop
- [ ] 🔴 Drag handle is visible at top of modal
- [ ] 🔴 Modal is scrollable
- [ ] 🔴 Modal can be dismissed by dragging down

### 3.4 Case Law Data Display
- [ ] 🔴 Case name displays prominently
- [ ] 🔴 Citation displays in accent colour
- [ ] 🔴 Court and year display in secondary text
- [ ] 🔴 Facts section renders with correct label and body text
- [ ] 🔴 Issues section renders as numbered list
- [ ] 🔴 Judgment section renders correctly
- [ ] 🔴 Reasoning section renders correctly
- [ ] 🔴 Significance section renders correctly
- [ ] 🔴 Loading state appears while case law data is fetched
- [ ] 🔴 Error state appears when case law ID is not found

### 3.5 Case Law Data Source
- [ ] 🔴 Case law data loads from `assets/data/case_laws/sample_case_laws.json`
- [ ] 🔴 `CaseLawRepositoryImpl` correctly parses the JSON
- [ ] 🔴 Unknown case law IDs return an error state, not a crash

---

## 4. Academic Notes Flow

### 4.1 Academic Notes Screen
- [ ] 🔴 Academic Notes screen opens from Home card tap
- [ ] 🔴 Subject list renders correctly
- [ ] 🔴 Each subject shows title and subtitle
- [ ] 🔴 Premium subjects show a premium indicator
- [ ] 🔴 Non-premium subjects are tappable

### 4.2 PDF Reader Navigation
- [ ] 🔴 Tapping a non-premium subject navigates to PDF reader
- [ ] 🔴 Tapping a premium subject shows a premium gate bottom sheet, not a crash
- [ ] 🔴 Premium gate bottom sheet opens and closes correctly

### 4.3 PDF Reader Screen
- [ ] 🔴 `PdfReaderScreen` opens with correct `pdfId`, `title`, and `assetPath`
- [ ] 🔴 Loading state appears while PDF loads
- [ ] 🔴 Error state appears gracefully when PDF asset does not exist
- [ ] 🔴 Error state does not crash the app
- [ ] 🔴 Page indicator shows current page / total pages
- [ ] 🔴 Back button returns to Academic Notes
- [ ] 🔴 Glass overlay controls appear and function
- [ ] 🔴 Controls auto-hide after 4 seconds

---

## 5. Bookmarks

### 5.1 Bookmark State in Reader
- [ ] 🔴 Bookmark button icon is `bookmark_border_rounded` when not bookmarked
- [ ] 🔴 Bookmark button icon is `bookmark_rounded` when bookmarked
- [ ] 🔴 Bookmark icon colour is secondary text when not bookmarked
- [ ] 🔴 Bookmark icon colour is accent when bookmarked
- [ ] 🔴 Label reads "Bookmark" when not bookmarked
- [ ] 🔴 Label reads "Saved" when bookmarked
- [ ] 🔴 Label colour is tertiary when not bookmarked
- [ ] 🔴 Label colour is accent when bookmarked
- [ ] 🔴 `isBookmarkedProvider(content.id)` is watched and drives the UI state

### 5.2 Bookmark Toggle
- [ ] 🔴 Tapping bookmark when not bookmarked calls `controller.addBookmark()`
- [ ] 🔴 Tapping bookmark when bookmarked calls `controller.removeBookmark()`
- [ ] 🔴 `HapticFeedback.mediumImpact()` fires on bookmark toggle
- [ ] 🔴 Loading spinner appears during toggle operation
- [ ] 🔴 Spinner disappears and correct icon appears after toggle completes
- [ ] 🔴 `isBookmarkedProvider` is invalidated after toggle to force re-read from Isar
- [ ] 🔴 Double-tapping bookmark does not create duplicate operations (`_isToggling` guard)

### 5.3 Bookmark Persistence
- [ ] 🔴 Bookmark survives app close and reopen
- [ ] 🔴 Bookmark survives device restart
- [ ] 🔴 Bookmarked state is correct when Reader opens for a previously bookmarked section
- [ ] 🔴 Removed bookmark does not reappear after app reopen

### 5.4 My Notes & Bookmarks Screen — Bookmarks Tab
- [ ] 🔴 Bookmarks tab loads all saved bookmarks from Isar
- [ ] 🔴 Each bookmark shows title and source
- [ ] 🔴 Tapping a bookmark navigates to the correct Reader screen
- [ ] 🔴 Loading state appears while bookmarks load
- [ ] 🔴 Empty state appears when no bookmarks exist
- [ ] 🔴 Error state appears if Isar read fails

### 5.5 Bookmark Data Integrity
- [ ] 🔴 Unique index on `linkedContentId` prevents duplicate bookmarks for the same content
- [ ] 🔴 `contentType` field is correctly set to `"article"` or `"section"`
- [ ] 🔴 `createdAt` timestamp is set correctly
- [ ] 🔴 `displayTitle` is populated for list view rendering

---

## 6. Notes

### 6.1 Notes List
- [ ] 🔴 Notes tab in My Notes & Bookmarks screen loads from Isar
- [ ] 🔴 Notes are sorted by `updatedAt` descending (most recently edited first)
- [ ] 🔴 Each note shows title and last modified time
- [ ] 🔴 Empty state appears when no notes exist
- [ ] 🔴 FAB opens Note Editor in create mode

### 6.2 Note Editor — Create Mode
- [ ] 🔴 Note editor opens with empty title and content fields
- [ ] 🔴 Title field accepts input
- [ ] 🔴 Content field accepts long-form input
- [ ] 🔴 Word count and character count update as user types
- [ ] 🔴 Georgia font is used in the content field
- [ ] 🔴 Save button is disabled when both title and content are empty
- [ ] 🔴 Saving a new note writes to Isar
- [ ] 🔴 New note appears in the notes list after save
- [ ] 🔴 Back navigation from editor with unsaved changes shows confirmation dialog

### 6.3 Note Editor — Edit Mode
- [ ] 🔴 Tapping an existing note opens editor with existing title and content
- [ ] 🔴 Editing and saving updates the existing note in Isar
- [ ] 🔴 `updatedAt` timestamp is updated on edit
- [ ] 🔴 Note order in list updates to reflect new `updatedAt`

### 6.4 Note Deletion
- [ ] 🟡 Notes can be deleted from the list (swipe or long press)
- [ ] 🟡 Deletion requires confirmation
- [ ] 🟡 Deleted note is removed from Isar and from the list

### 6.5 Note Search
- [ ] 🟡 Search field in notes tab filters by title
- [ ] 🟡 Search is case-insensitive
- [ ] 🟡 Clearing search restores full list

### 6.6 Note Persistence
- [ ] 🔴 Notes survive app close and reopen
- [ ] 🔴 Notes survive device restart
- [ ] 🔴 Long notes (1000+ words) save and load correctly without truncation

---

## 7. Session Management

### 7.1 Login Flow
- [ ] 🔴 Login screen renders correctly on first launch (no session)
- [ ] 🔴 Entering email and tapping "Sign In" creates a logged-in session
- [ ] 🔴 Session is saved via `SessionService.saveSession()`
- [ ] 🔴 App navigates to Home after successful login
- [ ] 🔴 Empty email field shows validation error "Please enter your email."
- [ ] 🔴 Loading spinner appears during login operation
- [ ] 🔴 Error message appears if session save fails

### 7.2 Guest Flow
- [ ] 🔴 "Continue as Guest" creates a guest session via `SessionService.saveGuestSession()`
- [ ] 🔴 App navigates to Home after guest session creation
- [ ] 🔴 Loading spinner appears during guest session creation
- [ ] 🔴 Error message appears if guest session creation fails

### 7.3 Session Persistence
- [ ] 🔴 Session persists across app close and reopen
- [ ] 🔴 On reopen with valid session, SplashScreen redirects directly to Home
- [ ] 🔴 On reopen with no session, SplashScreen redirects to Login

### 7.4 Logout Flow
- [ ] 🔴 Tapping "Sign Out" in Settings shows confirmation dialog
- [ ] 🔴 Confirmation dialog has "Cancel" and "Sign Out" buttons
- [ ] 🔴 Cancelling dialog leaves user on Settings screen
- [ ] 🔴 Confirming logout calls `SessionService.clearSession()`
- [ ] 🔴 After logout, app navigates to Login screen
- [ ] 🔴 After logout, navigating back does not return to Home (route guard active)
- [ ] 🔴 Theme is reset to system default after logout
- [ ] 🔴 Loading spinner appears during logout
- [ ] 🔴 Error message appears if logout fails

### 7.5 Session Data
- [ ] 🔴 `UserSession.isLoggedIn` is true for email-based sessions
- [ ] 🔴 `UserSession.isGuest` is true for guest sessions
- [ ] 🔴 `UserSession.empty` factory returns a session where `hasAccess` is false
- [ ] 🔴 `SessionService.hasSession()` returns true when a session exists
- [ ] 🔴 `SessionService.isSessionActive()` correctly validates session state

---

## 8. Theme System

### 8.1 Theme Initialisation
- [ ] 🔴 App launches with `ThemeMode.system` (follows device setting)
- [ ] 🔴 `themeModeNotifier` is a global `ValueNotifier<ThemeMode>`
- [ ] 🔴 `MaterialApp.router` wraps root in `ValueListenableBuilder` on `themeModeNotifier`
- [ ] 🔴 Theme changes propagate instantly without app restart

### 8.2 Theme Toggle in Settings
- [ ] 🔴 Dark Mode switch in Settings reflects current theme
- [ ] 🔴 Toggling switch changes `themeModeNotifier.value`
- [ ] 🔴 UI updates immediately across all currently visible screens
- [ ] 🔴 `HapticFeedback.lightImpact()` fires on toggle

### 8.3 Design Token Validation
- [ ] 🔴 `AppColors.accent` = `#1C4ED8`
- [ ] 🔴 `AppColors.gold` = `#D4AF37`
- [ ] 🔴 `AppColors.error` = `#EF4444`
- [ ] 🔴 `AppBlur.md` = 14 (used in cards and app bar)
- [ ] 🔴 `AppBlur.xl` = 20 (used in bottom nav and modals)
- [ ] 🔴 `AppRadius.card` = `BorderRadius.circular(24)`
- [ ] 🔴 `AppReader.lineHeight` = 1.78
- [ ] 🔴 `AppReader.baseFontSize` = 16
- [ ] 🔴 `AppReader.titleFontSize` = 22
- [ ] 🔴 `AppReader.paragraphSpacing` = 20
- [ ] 🔴 `AppAnimation.pressScale` = 0.97
- [ ] 🔴 `AppAnimation.fast` = 150ms
- [ ] 🔴 `AppAnimation.standard` = 250ms

### 8.4 Glass Components
- [ ] 🔴 `GlassAppBar` renders with `ImageFilter.blur` backdrop
- [ ] 🔴 `GlassCard` renders with correct border, shadow, and blur
- [ ] 🔴 `GlassBottomSheet` renders with blur and rounded top corners
- [ ] 🔴 `GlassButton` renders with correct gradient and shadow

---

## 9. Dark Mode

### 9.1 Screen Coverage
- [ ] 🔴 Home screen renders correctly in dark mode
- [ ] 🔴 Acts screen renders correctly in dark mode
- [ ] 🔴 Act Detail screen renders correctly in dark mode
- [ ] 🔴 Constitution screen renders correctly in dark mode
- [ ] 🔴 Reader screen renders correctly in dark mode
- [ ] 🔴 Case Law popup renders correctly in dark mode
- [ ] 🔴 Academic Notes screen renders correctly in dark mode
- [ ] 🔴 My Notes & Bookmarks screen renders correctly in dark mode
- [ ] 🔴 Note Editor renders correctly in dark mode
- [ ] 🔴 Settings screen renders correctly in dark mode
- [ ] 🔴 Login screen renders correctly in dark mode
- [ ] 🔴 Splash screen renders correctly in dark mode

### 9.2 Colour Correctness in Dark Mode
- [ ] 🔴 Reader background is `#0D1117` (not pure black)
- [ ] 🔴 Accent in dark mode is `AppColors.accentLight` (`#93C5FD`), not `#1C4ED8`
- [ ] 🔴 All text has sufficient contrast ratio (minimum 4.5:1 for body text)
- [ ] 🔴 Glass card backgrounds use dark translucent values, not light values
- [ ] 🔴 Section number badge uses `accentLight` in dark mode
- [ ] 🔴 Explanation left border uses `accentLight` in dark mode
- [ ] 🔴 Proviso left border is gold in both light and dark mode

### 9.3 System UI in Dark Mode
- [ ] 🔴 `SystemUiOverlayStyle.light` is set when dark mode is active
- [ ] 🔴 Status bar icons are light (white) in dark mode
- [ ] 🔴 Navigation bar is transparent in dark mode

---

## 10. JSON Content Validation

### 10.1 Acts JSON
- [ ] 🔴 `assets/data/acts/bns_2023.json` exists and is valid JSON
- [ ] 🔴 `act_id`, `act_name`, `year` fields are present
- [ ] 🔴 `chapters` array is present and non-empty
- [ ] 🔴 Each chapter has `id`, `number`, `roman_numeral`, `name`, `sections`
- [ ] 🔴 Each section has `id`, `number`, `title`
- [ ] 🔴 Each section with content has a `content` array
- [ ] 🔴 Each content block has `type` and `text` fields
- [ ] 🔴 `type` values are one of: `main`, `explanation`, `proviso`, `subSection`
- [ ] 🔴 `case_law_ids` is an array (can be empty, not null)

### 10.2 Constitution JSON
- [ ] 🔴 `assets/data/constitution/constitution_part_1.json` exists and is valid JSON
- [ ] 🔴 `id`, `number`, `name`, `articles` fields are present
- [ ] 🔴 Each article has `id`, `number`, `title`
- [ ] 🔴 `is_preamble`, `is_repealed`, `is_omitted` fields are boolean
- [ ] 🔴 `case_law_ids` is an array (can be empty, not null)

### 10.3 Case Laws JSON
- [ ] 🔴 `assets/data/case_laws/sample_case_laws.json` exists and is valid JSON
- [ ] 🔴 At least one case law entry exists
- [ ] 🔴 Each entry has `id`, `title`, `citation`, `court`, `year`
- [ ] 🔴 Each entry has `facts`, `issues`, `judgment`, `reasoning`, `significance`
- [ ] 🔴 `issues` is an array of strings
- [ ] 🔴 All `case_law_ids` referenced in Acts and Constitution JSON exist in case laws JSON
- [ ] 🔴 No case law ID is referenced but missing from the data file

### 10.4 JSON Parsing Errors
- [ ] 🔴 App does not crash on malformed JSON — shows error state
- [ ] 🔴 App does not crash on missing optional fields — uses defaults
- [ ] 🔴 `JsonValidatorService` validates act and constitution JSON at load time
- [ ] 🔴 Validation failures are logged with the file path and field name

---

## 11. Asset Registration

### 11.1 pubspec.yaml Asset Entries
- [ ] 🔴 `assets/data/` is registered
- [ ] 🔴 `assets/data/acts/` is registered
- [ ] 🔴 `assets/data/constitution/` is registered
- [ ] 🔴 `assets/data/case_laws/` is registered
- [ ] 🔴 `assets/data/academic/` is registered
- [ ] 🔴 `assets/pdfs/` is registered
- [ ] 🔴 `assets/images/` is registered

### 11.2 Asset File Existence
- [ ] 🔴 Every path registered in `pubspec.yaml` exists on disk
- [ ] 🔴 Every JSON file referenced in repository code exists in `assets/`
- [ ] 🔴 No asset paths contain typos (case-sensitive on Android)
- [ ] 🔴 `flutter pub get` completes without asset warnings

### 11.3 Asset Loading at Runtime
- [ ] 🔴 `rootBundle.loadString()` succeeds for at least one act JSON
- [ ] 🔴 `rootBundle.loadString()` succeeds for at least one constitution JSON
- [ ] 🔴 `rootBundle.loadString()` succeeds for case laws JSON
- [ ] 🔴 No `FlutterError: Unable to load asset` errors in debug console

---

## 12. Isar Database

### 12.1 Initialization
- [ ] 🔴 `IsarDatabaseService.instance.initialize()` is called in `main.dart` before `runApp`
- [ ] 🔴 Initialization completes without throwing in debug build
- [ ] 🔴 If initialization fails, app continues with graceful fallback (no crash)
- [ ] 🔴 Debug console shows `✅ Opened "law_briefly_v1"` on successful init

### 12.2 Schema Registration
- [ ] 🔴 `BookmarkEntitySchema` is registered (`bookmark_entity.dart` — `bookmarks_v2`)
- [ ] 🔴 `NoteEntitySchema` is registered (`note_entity.dart` — `notes_v2`)
- [ ] 🔴 `ReaderProgressEntitySchema` is registered (`database_models.dart` — `reader_progress`)
- [ ] 🔴 `PdfProgressEntitySchema` is registered (`database_models.dart` — `pdf_progress`)
- [ ] 🔴 `UserProfileEntitySchema` is registered (`database_models.dart` — `user_profiles`)
- [ ] 🔴 No duplicate class name `BookmarkEntity` exists (removed from `database_models.dart`)
- [ ] 🔴 No duplicate class name `NoteEntity` or `PersonalNoteEntity` conflict exists

### 12.3 Code Generation
- [ ] 🔴 `dart run build_runner build --delete-conflicting-outputs` completes without errors
- [ ] 🔴 `database_models.g.dart` exists and is not empty
- [ ] 🔴 `bookmark_entity.g.dart` exists and is not empty
- [ ] 🔴 `note_entity.g.dart` exists and is not empty
- [ ] 🔴 No `.g.dart` file has been manually edited
- [ ] 🔴 All `part '*.g.dart';` directives match actual generated file names

### 12.4 Read / Write Operations
- [ ] 🔴 Writing a bookmark to Isar completes without error
- [ ] 🔴 Reading bookmarks from Isar returns correct data
- [ ] 🔴 Writing a note to Isar completes without error
- [ ] 🔴 Reading notes from Isar returns correct data sorted by `updatedAt`
- [ ] 🔴 Unique index on `BookmarkEntity.linkedContentId` prevents duplicate writes
- [ ] 🔴 Unique index on `NoteEntity.noteId` prevents duplicate note records

### 12.5 Isar Inspector (Debug Only)
- [ ] 🟡 Isar inspector is accessible in debug builds at `http://localhost:8080`
- [ ] 🟡 `bookmarks_v2` collection is visible in inspector
- [ ] 🟡 `notes_v2` collection is visible in inspector
- [ ] 🟡 Inspector is disabled in release builds (`inspector: inspector && kDebugMode`)

---

## 13. Performance

### 13.1 Startup
- [ ] 🟡 App reaches Home screen within 3 seconds on mid-range Android (cold start)
- [ ] 🟡 Splash screen animation completes before Home is shown
- [ ] 🟡 Isar initialization does not block the UI thread
- [ ] 🟡 No `ANR` (Application Not Responding) during startup

### 13.2 Reader Screen
- [ ] 🟡 Reader content appears within 500ms of navigation on local asset load
- [ ] 🟡 Scrolling in Reader maintains 60fps on mid-range Android
- [ ] 🟡 `BackdropFilter` blur in app bar does not cause jank on scroll
- [ ] 🟡 `BackdropFilter` blur in bottom nav does not cause jank on scroll
- [ ] 🟡 Entrance animation runs at 60fps

### 13.3 Lists
- [ ] 🟡 Acts list with 20 items scrolls smoothly
- [ ] 🟡 Constitution list with 22 parts scrolls smoothly
- [ ] 🟡 Bookmarks list with 100+ items scrolls smoothly
- [ ] 🟡 Notes list with 100+ items scrolls smoothly

### 13.4 Memory
- [ ] 🟡 No memory leaks from `AnimationController` objects (all disposed in `dispose()`)
- [ ] 🟡 No memory leaks from `ScrollController` objects
- [ ] 🟡 No memory leaks from `TextEditingController` objects
- [ ] 🟡 No memory leaks from `FocusNode` objects
- [ ] 🟡 Isar in-memory cache for JSON content is bounded (does not grow unboundedly)

### 13.5 Flutter Analyze
- [ ] 🔴 `flutter analyze` returns zero errors
- [ ] 🟡 `flutter analyze` returns zero warnings
- [ ] 🟡 No `deprecated` API usage in production code
- [ ] 🟡 No `print()` statements in production code (use `debugPrint`)

---

## 14. Release Build

### 14.1 Pre-Build Checklist
- [ ] 🔴 `flutter pub get` completes without errors
- [ ] 🔴 `dart run build_runner build --delete-conflicting-outputs` completes without errors
- [ ] 🔴 `flutter analyze` returns zero errors
- [ ] 🔴 All TODO comments in routing and schema registration are resolved
- [ ] 🔴 `debugShowCheckedModeBanner: false` in `MaterialApp.router`
- [ ] 🔴 `debugLogDiagnostics: false` in `GoRouter` (or set to release only)
- [ ] 🔴 Isar inspector disabled in release (`inspector: inspector && kDebugMode`)
- [ ] 🔴 Riverpod logger disabled in release (`observers: kDebugMode ? [...] : const []`)
- [ ] 🔴 No hardcoded API keys or secrets in source code

### 14.2 Android Build Configuration
- [ ] 🔴 `minSdkVersion` is 21 or higher (Isar requires minimum API 18, recommend 21)
- [ ] 🔴 `targetSdkVersion` is 34 or higher
- [ ] 🟡 `applicationId` is set to production value (not `com.example.*`)
- [ ] 🟡 Version name matches `pubspec.yaml` version string
- [ ] 🟡 Version code is incremented from previous build
- [ ] 🟡 ProGuard / R8 rules do not strip Isar native libraries
- [ ] 🟡 `android:extractNativeLibs="true"` if required by Isar for your Gradle version

### 14.3 Debug APK Verification
- [ ] 🔴 `flutter build apk --debug` completes without errors
- [ ] 🔴 APK installs successfully on physical Android device
- [ ] 🔴 App launches without crash on install
- [ ] 🔴 All core flows complete (Login → Home → Acts → Reader → Bookmark → Settings → Logout)
- [ ] 🔴 Dark mode toggle works in installed APK
- [ ] 🔴 Bookmarks persist after app kill and reopen on device

### 14.4 Release APK Verification
- [ ] 🟡 `flutter build apk --release` completes without errors
- [ ] 🟡 APK size is reasonable (under 40MB for MVP without PDFs)
- [ ] 🟡 Release APK installs and launches on physical device
- [ ] 🟡 All flows that passed in debug build also pass in release build
- [ ] 🟡 Isar database opens successfully in release build (no ProGuard stripping issue)
- [ ] 🟡 JSON assets load correctly in release build

### 14.5 Post-Release Items (Log and Track)
- [ ] 🟢 Launcher icon configured for all densities (`mipmap-mdpi` through `mipmap-xxxhdpi`)
- [ ] 🟢 Adaptive launcher icon configured for Android 8.0+
- [ ] 🟢 Splash screen branding image configured
- [ ] 🟢 Georgia font bundled as asset (currently system font fallback)
- [ ] 🟢 `applicationId` set to final production identifier
- [ ] 🟢 App signing keystore configured for Play Store distribution
- [ ] 🟢 Privacy policy URL live and linked from Settings
- [ ] 🟢 Terms of use URL live and linked from Settings
- [ ] 🟢 Crash reporting integration (Firebase Crashlytics or Sentry)
- [ ] 🟢 Analytics integration for reading session tracking
- [ ] 🟢 At least 10 Acts with full section content
- [ ] 🟢 All 22 Constitution parts with full article content
- [ ] 🟢 At least 50 case law entries

---

## Audit Sign-Off

| Section | Status | Auditor | Notes |
|---|---|---|---|
| 1. Routing | | | |
| 2. Reader Flow | | | |
| 3. Case Law Flow | | | |
| 4. Academic Notes Flow | | | |
| 5. Bookmarks | | | |
| 6. Notes | | | |
| 7. Session Management | | | |
| 8. Theme System | | | |
| 9. Dark Mode | | | |
| 10. JSON Content Validation | | | |
| 11. Asset Registration | | | |
| 12. Isar Database | | | |
| 13. Performance | | | |
| 14. Release Build | | | |

---

## Outstanding Issues Log

Use this section to track items that failed audit and require resolution.

| # | Section | Item | Severity | Assigned To | Resolved |
|---|---|---|---|---|---|
| 1 | | | 🔴/🟡/🟢 | | ☐ |
| 2 | | | | | ☐ |
| 3 | | | | | ☐ |
| 4 | | | | | ☐ |
| 5 | | | | | ☐ |

---

## Build Commands Reference

```bash
# Step 1 — Fetch dependencies
flutter pub get

# Step 2 — Generate Isar schemas and other code
dart run build_runner build --delete-conflicting-outputs

# Step 3 — Static analysis
flutter analyze

# Step 4 — Debug build (install and test on device)
flutter build apk --debug
flutter install

# Step 5 — Release build
flutter build apk --release

# Step 6 — Check APK size
ls -lh build/app/outputs/flutter-apk/app-release.apk
```

---

*End of checklist.*
