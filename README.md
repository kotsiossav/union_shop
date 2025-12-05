# 🛍️ Union Shop - Flutter E-Commerce Application

A fully-functional e-commerce mobile and web application built with Flutter and Firebase for the University of Portsmouth Union Shop. This app provides a complete shopping experience with product browsing, cart management, user authentication, order history, and a custom product personalization service.

![Flutter](https://img.shields.io/badge/Flutter-3.0+-blue.svg)
![Firebase](https://img.shields.io/badge/Firebase-Enabled-orange.svg)
![Platform](https://img.shields.io/badge/Platform-Android%20%7C%20iOS%20%7C%20Web-green.svg)

---

## 📋 Table of Contents

- [Features](#-features)
- [Installation & Setup](#-installation--setup)
- [Usage](#-usage)
- [Running Tests](#-running-tests)
- [Project Structure](#-project-structure)
- [Technologies Used](#-technologies-used)
- [Firebase Configuration](#-firebase-configuration)
- [Known Issues](#-known-issues)
- [Future Enhancements](#-future-enhancements)
- [Contributing](#-contributing)
- [License](#-license)
- [Contact](#-contact)

---

## ✨ Features

### Core Functionality
- **🏠 Homepage**: Dynamic slideshow hero section with featured collections and products
- **🛒 Shopping Cart**: Full cart management with add/remove items, quantity adjustment, and persistent storage
- **🔐 User Authentication**: Firebase Authentication with email/password sign-up and login
- **📦 Product Catalog**: Browse products by collections with filtering and sorting options
- **🔍 Search**: Full-text search across all products with real-time results
- **💳 Checkout**: Complete order placement with order history tracking
- **👤 User Account**: Profile management with order history and sign-out functionality

### Advanced Features
- **🎨 Product Personalization**: Custom text/logo personalization service with dynamic form controls
- **📱 Responsive Design**: Fully responsive layout optimized for mobile, tablet, and desktop
- **🔥 Firebase Integration**: Real-time data sync with Cloud Firestore
- **🎯 Dynamic Routing**: SEO-friendly URL structure with go_router
- **💾 Cart Persistence**: Cart items saved to Firestore and synced across devices
- **🏷️ Sale Prices**: Support for discounted pricing with strikethrough original prices
- **📊 Order History**: View past orders with details and status tracking
- **🎭 Interactive UI**: Hover effects, smooth animations, and loading states

### Pages Included
1. **Home** - Hero carousel, featured products, collections preview
2. **Collections** - Grid view of all product collections
3. **Collection Detail** - Products filtered by collection with sort/filter options
4. **Product Detail** - Full product information with size/color selection
5. **Search** - Search functionality with results display
6. **Cart** - Shopping cart with quantity management and checkout
7. **Login/Register** - User authentication forms
8. **Order History** - Past order tracking
9. **About** - Company information
10. **Print Shack About** - Custom printing service information
11. **Personalization** - Dynamic personalization form
12. **Sale** - Discounted products collection


## 🚀 Installation & Setup

### Prerequisites

Before you begin, ensure you have the following installed:

- **Flutter SDK** (3.0.0 or higher) - [Install Flutter](https://docs.flutter.dev/get-started/install)
- **Dart SDK** (2.17.0 or higher) - Comes with Flutter
- **Android Studio** or **VS Code** with Flutter extensions
- **Git** - [Install Git](https://git-scm.com/downloads)
- **Firebase CLI** (optional, for Firebase configuration) - [Install Firebase CLI](https://firebase.google.com/docs/cli)

### Step 1: Clone the Repository

```bash
git clone https://github.com/kotsiossav/union_shop.git
cd union_shop
```

### Step 2: Install Dependencies

```bash
flutter pub get
```

### Step 3: Firebase Configuration

This app requires Firebase for authentication and data storage. You'll need to set up a Firebase project:

1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Create a new project or use an existing one
3. Enable **Authentication** (Email/Password provider)
4. Enable **Cloud Firestore** database
5. Download configuration files:
   - For Android: Download `google-services.json` and place in `android/app/`
   - For iOS: Download `GoogleService-Info.plist` and place in `ios/Runner/`
   - For Web: Copy Firebase config from console

6. Initialize Firebase in your project:

```bash
# If using Firebase CLI
flutterfire configure
```

Or manually update `lib/firebase_options.dart` with your Firebase configuration.

### Step 4: Set Up Firestore Database

Create the following collections in your Firestore database:

**products** collection with documents containing:
```json
{
  "title": "Product Name",
  "image_url": "path/to/image",
  "price": 29.99,
  "disc_price": 24.99,  // Optional discount price
  "cat": "Clothing",
  "coll": "essential-range,apparel"  // Comma-separated collections
}
```

**users/{uid}/cart** subcollection (auto-created by app)

**users/{uid}/orders** subcollection (auto-created by app)

### Step 5: Add Product Images

Place your product images in the `assets/images/` directory. Update `pubspec.yaml` if you add new image directories.

### Step 6: Run the Application

#### For Mobile (Android/iOS):
```bash
# List available devices
flutter devices

# Run on connected device
flutter run

# Or run on specific device
flutter run -d <device_id>
```

#### For Web:
```bash
flutter run -d chrome
```

#### For Desktop (Windows/macOS/Linux):
```bash
flutter run -d windows   # Windows
flutter run -d macos     # macOS
flutter run -d linux     # Linux
```

---

## 💡 Usage

### Basic User Flow

1. **Browse Products**
   - Open the app to view the homepage with featured products
   - Click on collections to view category-specific items
   - Use the search bar to find specific products

2. **Add to Cart**
   - Click on any product to view details
   - Select size and color (for clothing items)
   - Adjust quantity using +/- buttons
   - Click "Add to Cart" button

3. **Manage Cart**
   - Click the cart icon in the header to view your cart
   - Adjust quantities or remove items
   - View total price calculation

4. **Create Account / Sign In**
   - Click the user icon in the header
   - Choose "Register" to create a new account or "Sign In" to log in
   - Fill in your email and password

5. **Checkout**
   - From the cart page, click "Checkout"
   - Order is automatically placed and saved to your account
   - View order confirmation

6. **View Order History**
   - Sign in to your account
   - Click on user icon → "Order History"
   - View all past orders with details

7. **Product Personalization**
   - Navigate to "The Print Shack" → "Personalisation"
   - Select personalization type (text lines, logo)
   - Enter custom text or upload logo
   - Add to cart with personalization details

### Admin Features

To add/modify products, use the Firebase Console:
- Navigate to Cloud Firestore
- Edit the `products` collection
- Add new documents or modify existing ones

---

## 🧪 Running Tests

This project includes comprehensive unit and widget tests.

### Run All Tests
```bash
flutter test
```

### Run Specific Test File
```bash
flutter test test/page_test/product_page_test.dart
```

### Run Tests with Coverage
```bash
flutter test --coverage
```

### View Coverage Report
```bash
# Generate HTML coverage report (requires lcov)
genhtml coverage/lcov.info -o coverage/html

# Open in browser
open coverage/html/index.html  # macOS
start coverage/html/index.html  # Windows
xdg-open coverage/html/index.html  # Linux
```

### Test Structure

- `test/page_test/` - Widget tests for all pages
- `test/model_tests.dart/` - Unit tests for data models
- `test/services_tests/` - Unit tests for services
- `test/layout_test.dart` - Tests for header/footer components

### Testing Limitations

Due to Firebase integration throughout the application, dependency injection was required for a significant portion of the test suite. Mock implementations (`fake_cloud_firestore` and `firebase_auth_mocks`) were used to simulate Firebase services during testing. However, this approach has limitations:

- Some code paths that heavily interact with Firebase could not be thoroughly tested
- Certain Firebase-specific behaviors and edge cases are difficult to replicate with mocks
- Test coverage may not reflect the full complexity of Firebase interactions in production
- Real-time listeners and authentication state changes have limited test coverage due to the constraints of mocked services

While we achieved comprehensive coverage of core business logic and UI components, complete end-to-end testing would require integration tests with actual Firebase instances, which falls outside the scope of unit and widget testing.

---

## 📁 Project Structure

```
union_shop/
├── android/                    # Android-specific configuration
├── ios/                        # iOS-specific configuration
├── web/                        # Web-specific configuration
├── assets/                     # Static assets
│   └── images/                 # Product images
├── lib/
│   ├── main.dart              # App entry point
│   ├── routing.dart           # Route configuration
│   ├── layout.dart            # Header/Footer widgets
│   ├── app_styles.dart        # Global styles
│   ├── images_layout.dart     # Reusable image widgets
│   ├── firebase_options.dart  # Firebase configuration
│   ├── models/
│   │   ├── cart_model.dart    # Shopping cart state management
│   │   └── order_model.dart   # Order data model
│   ├── services/
│   │   ├── auth_service.dart  # Authentication service
│   │   └── order_service.dart # Order management service
│   └── views/
│       ├── homepage.dart      # Home page
│       ├── about_page.dart    # About page
│       ├── cart_screen.dart   # Shopping cart
│       ├── collection_page.dart       # Single collection view
│       ├── collections_page.dart      # All collections grid
│       ├── product_page.dart          # Product details
│       ├── search_page.dart           # Search functionality
│       ├── sign_in_page.dart          # Login page
│       ├── register_page.dart         # Registration page
│       ├── order_history_page.dart    # Order history
│       └── print_shack/
│           ├── personalisation.dart   # Personalization form
│           └── print-shack_about.dart # Print service info
├── test/                      # Test files
│   ├── page_test/            # Widget tests
│   ├── model_tests.dart/     # Model tests
│   └── services_tests/       # Service tests
├── pubspec.yaml              # Dependencies
└── README.md                 # This file
```

### Key Files

- **`lib/main.dart`**: Application entry point, Firebase initialization, Provider setup
- **`lib/routing.dart`**: Centralized route definitions with go_router
- **`lib/layout.dart`**: Reusable AppHeader and AppFooter widgets
- **`lib/models/cart_model.dart`**: Shopping cart state with ChangeNotifier and Firestore sync
- **`lib/services/auth_service.dart`**: Authentication wrapper for Firebase Auth
- **`lib/services/order_service.dart`**: Order creation and retrieval logic

---

## 🛠️ Technologies Used

### Framework & Language
- **Flutter** 3.0+ - Cross-platform UI framework
- **Dart** 2.17+ - Programming language

### State Management
- **Provider** 6.1.1 - State management solution
- **ChangeNotifier** - Built-in Flutter state management

### Backend & Database
- **Firebase Core** 3.5.0 - Firebase initialization
- **Firebase Authentication** 5.3.0 - User authentication
- **Cloud Firestore** 5.4.0 - NoSQL cloud database

### Routing & Navigation
- **go_router** 17.0.0 - Declarative routing with deep linking support
- **url_strategy** 0.2.0 - Clean URLs for web

### UI & Assets
- **Cupertino Icons** 1.0.0 - iOS-style icons
- Custom assets and images

### Development & Testing
- **flutter_test** - Flutter testing framework
- **flutter_lints** 2.0.0 - Recommended lints for Flutter
- **network_image_mock** 2.1.1 - Mock network images in tests
- **fake_cloud_firestore** 3.0.3 - Mock Firestore for testing
- **firebase_auth_mocks** 0.14.1 - Mock Firebase Auth for testing

---

## 🔥 Firebase Configuration

### Firestore Database Structure

#### Collections Schema

**products/**
```json
{
  "title": "Essential Hoodie",
  "image_url": "assets/images/hoodie.png",
  "price": 29.99,
  "disc_price": 24.99,  // Optional
  "cat": "Clothing",
  "coll": "essential-range,apparel,sale"
}
```

**users/{userId}/cart/**
```json
{
  "title": "Product Name",
  "imageUrl": "path/to/image",
  "price": 29.99,
  "quantity": 2,
  "category": "Clothing",
  "collection": "essential-range",
  "color": "Black",      // Optional
  "size": "M"            // Optional
}
```

**users/{userId}/orders/**
```json
{
  "orderId": "unique-order-id",
  "items": [...],  // Array of cart items
  "totalPrice": 59.98,
  "orderDate": Timestamp,
  "status": "pending"
}
```

### Security Rules

Set up appropriate Firestore security rules:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Products are readable by everyone
    match /products/{product} {
      allow read: if true;
      allow write: if false;  // Admin only via console
    }
    
    // User cart and orders are private
    match /users/{userId}/{document=**} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
  }
}
```

---

## ⚠️ Known Issues & Limitations

### Current Limitations

1. **Payment Integration**: Currently simulated checkout (no real payment processing)
2. **Image Upload**: Personalization doesn't support actual image uploads yet
3. **Email Verification**: Users can register without email verification
4. **Admin Panel**: No built-in admin interface for product management

### Browser Compatibility (Web)
- Best experienced on Chrome, Firefox, Safari, and Edge
- Some CSS features may not work on older browsers

---

## 🚀 Future Enhancements

### Recommended Features for Future implementation

- [ ] **Payment Integration**: Stripe/PayPal integration for real transactions
- [ ] **Product Reviews**: User ratings and reviews system
- [ ] **Wishlist**: Save products for later
- [ ] **Admin Dashboard**: Manage products, orders, and users
- [ ] **Email Notifications**: Order confirmations and updates
- [ ] **Image Upload**: Real image upload for personalization
- [ ] **Order Tracking**: Real-time order status updates
- [ ] **Multiple Addresses**: Save and manage shipping addresses
- [ ] **Promo Codes**: Discount code system


---

### Development Guidelines

- Follow Flutter/Dart style guide
- Write tests for new features
- Update documentation as needed
- Keep commits atomic and descriptive

---

## 📄 License

This project was created as coursework for the University of Portsmouth. 

For educational purposes only.

---

## 📧 Contact

**Developer**: Savvas Kotsiossavvas  
**University**: University of Portsmouth  
**Course**: Year 2 Programming Applications  
**GitHub**: [@kotsiossav](https://github.com/kotsiossav)

### Support

For questions or issues:
- Open an issue on GitHub
- Email: [Your Email]
- Portfolio: [Your Portfolio Link]

---

## Acknowledgments

- University of Portsmouth for the coursework specification
- Flutter team for the framework
- Firebase for backend services
- The Flutter community for packages and inspiration

---

**Built with ❤️ using Flutter**

*Last Updated: December 2025*
