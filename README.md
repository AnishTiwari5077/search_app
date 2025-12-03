 #Flutter Search & Item Management App

A modern Flutter application demonstrating search, add, edit, and delete functionality with a clean UI, provider state management, and Firebase integration.

🌟 Features

Add new items with validation

Edit existing items

Delete items with confirmation

Real-time search with suggestions

View item details

Cloud-based storage using Firebase Firestore

Clean and responsive UI

Empty state & error handling widgets

SnackBar notifications for actions


##Screenshot
<img width="315" height="700" alt="Screenshot_1764754142" src="https://github.com/user-attachments/assets/f5f5e794-5e8b-4a0f-a776-081d39f0c677" />
<img width="315" height="700" alt="Screenshot_1764754136" src="https://github.com/user-attachments/assets/d265d557-3cb7-4edc-8fa1-c43e78e445a0" />
<img width="315" height="700" alt="Screenshot_1764754129" src="https://github.com/user-attachments/assets/4269a7f1-5286-4bfd-abdb-53e2ae4bc1a5" />
<img width="315" height="700" alt="Screenshot_1764754116" src="https://github.com/user-attachments/assets/a42f2068-62f9-4f51-a774-4fefa43139bc" />
<img width="315" height="700" alt="Screenshot_1764754091" src="https://github.com/user-attachments/assets/b8b48952-2efa-4b92-a641-a37de3c90a71" />
<img width="315" height="700" alt="Screenshot_1764754086" src="https://github.com/user-attachments/assets/380b273d-c935-4341-9661-7c6cc294ea87" />
<img width="315" height="700" alt="Screenshot_1764754080" src="https://github.com/user-attachments/assets/8e30ba2b-a6d2-4f75-b3f7-8f9553cabd5e" />


📂 Folder Structure
lib/
├── main.dart                  # App entry point
├── provider/
│   └── search_provider.dart   # Provider for managing items
├── screens/
│   ├── search_screen.dart     # Main search & display screen
│   └── item_detail_screen.dart # Item detail view
├── widgets/
│   ├── add_items_dialog.dart  # Dialog to add items
│   ├── edit_items_dialog.dart # Dialog to edit items
│   ├── empty_state_widget.dart# Empty state UI
│   └── error_display_widget.dart # Error handling UI
└── utils/                     # Optional utilities (e.g., validators)

💻 Getting Started
1. Clone the repository
git clone https://github.com/anishTiwari5077/flutter-search-items.git
cd flutter-search-items

2. Install dependencies
flutter pub get

3. Configure Firebase

Create a Firebase project.

Enable Cloud Firestore.

Add google-services.json (Android) and GoogleService-Info.plist (iOS) to your project.

Initialize Firebase in main.dart:

await Firebase.initializeApp();

4. Run the app
flutter run

⚡ Usage

Add Item: Click the + button or the "Add Your First Item" button in the empty state.

Search Item: Type in the search bar to filter items.

Edit Item: Tap an item or use the edit icon to update its name.

Delete Item: Tap the delete icon and confirm deletion.

View Details: Tap an item to view details including ID and name.

🛠️ Dependencies

flutter >= 3.0.0

provider ^6.0.5

firebase_core ^2.20.0

cloud_firestore ^5.8.0

🎨 UI / UX Highlights

Animated empty state when there are no items

SnackBar notifications for success and error messages

Dialogs for add/edit actions with form validation

Responsive and modern Material 3 design

📌 Notes

All actions are real-time using Firebase Firestore streams.

The project uses Provider for state management, ensuring only necessary widgets rebuild.

Error and empty states are handled gracefully with reusable widgets.









