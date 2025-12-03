# Union Shop - Complete Requirements Checklist

## Core Application Files

### `lib/main.dart` & `lib/routing.dart`
- [x] Flutter app entry point with Firebase initialization
- [x] Routing extracted to separate routing.dart file
- [x] GoRouter configuration for all routes
- [x] ChangeNotifierProvider for CartModel state management
- [x] Routes configured:
  - [x] `/` → HomeScreen
  - [x] `/about` → AboutPage
  - [x] `/collections` → CollectionsPage
  - [x] `/collections/:slug` → CollectionPage (dynamic routing)
  - [x] `/product` → ProductPage (with query parameters)
  - [x] `/search` → SearchPage (with query parameters)
  - [x] `/personalisation` → PersonalisationPage
  - [x] `/print-shack-about` → PrintShackAbout
  - [x] `/sign-in` → SignInPage
  - [x] `/register` → RegisterPage
  - [x] `/cart` → CartScreen
  - [x] `/order-history` → OrderHistoryPage
- [x] Error handling for unknown routes

### `lib/layout.dart`
- [x] **AppHeader widget**:
  - [x] Logo image with home navigation
  - [x] Search bar with TextField and search icon
  - [x] Search functionality navigates to `/search?q={query}`
  - [x] Desktop navigation menu (Home, Shop dropdown, Print Shack dropdown, Sale, About)
  - [x] Mobile hamburger menu icon
  - [x] Mobile search bar overflow fix with Expanded widget
  - [x] Shop dropdown with collections (Essential Range, Signature Range, Portsmouth City)
  - [x] Print Shack dropdown (About, Personalisation)
  - [x] User account icon with dropdown (Sign In, Register, Order History)
  - [x] Shopping cart icon with badge showing item count
  - [x] Cart icon navigates to `/cart`
  
- [x] **Mobile Menu (Bottom Sheet)**:
  - [x] ExpansionTile for Shop section
  - [x] ExpansionTile for Print Shack section
  - [x] Navigation to collections on tap
  - [x] ScrollView to prevent overflow
  - [x] Proper context handling for navigation
  
- [x] **AppFooter widget**:
  - [x] Multiple columns with links
  - [x] Social media icons
  - [x] Contact information
  - [x] Copyright notice
  - [x] Hover effects on links

### `lib/app_styles.dart`
- [x] Centralized text styles (title, subtitle, body)
- [x] Consistent color scheme
- [x] Reusable style definitions

### `lib/images_layout.dart`
- [x] **HoverImage widget**:
  - [x] Brightness effect on hover
  - [x] ColorFilter animation
  - [x] MouseRegion for desktop hover
  
- [x] **ProductCard widget**:
  - [x] Product image display
  - [x] Product title
  - [x] Price with discount support
  - [x] Strike-through for original price when discounted
  - [x] Navigation to ProductPage with all parameters
  - [x] GestureDetector for tap handling
  
- [x] **SquareImage widget**:
  - [x] Fixed aspect ratio square images
  - [x] Centered text overlay
  - [x] Hover effects
  - [x] Optional navigation on tap

---

## Page Components

### `lib/views/homepage.dart`
- [x] **Hero Section (Responsive Slideshow)**:
  - [x] PageView with 2 slides
  - [x] Slide 1: Essential Range promo
  - [x] Slide 2: Print Shack promo
  - [x] Each slide has unique title, subtitle, button text
  - [x] Background images with dark overlay
  - [x] Navigation arrows (previous/next)
  - [x] Page indicator dots
  - [x] Responsive height (300px mobile / 400px desktop)
  - [x] Responsive font sizes (24/48 title, 16/30 subtitle)
  - [x] Functional buttons navigating to routes
  
- [x] **Products Section (Responsive)**:
  - [x] Firebase integration with FutureBuilder
  - [x] Three product categories displayed
  - [x] 8 total products from Firebase
  - [x] _buildProductCard helper fetches from Firestore
  - [x] Price parsing and sanitization
  - [x] Discount price support
  - [x] Mobile: Column layout (stacked vertically)
  - [x] Desktop: Row layout (2 columns)
  - [x] Responsive padding (16px mobile / 40px desktop)
  - [x] Responsive spacing (24px mobile / 48px desktop)
  - [x] VIEW ALL button
  
- [x] **Our Range Section**:
  - [x] Wrap widget with 4 SquareImage widgets
  - [x] Categories: Clothing, Merchandise, Graduation, SALE
  - [x] Centered alignment
  - [x] Consistent spacing
  
- [x] **Personal Touch Section (Responsive)**:
  - [x] Mobile: Column layout (text above image)
  - [x] Desktop: Row layout (text left, image right)
  - [x] Heading and description text
  - [x] "Click here to add text!" button
  - [x] Print Shack logo image
  - [x] Navigation to personalisation page
  - [x] Responsive image sizing

- [x] SharedAppHeader and AppFooter integration
- [x] SingleChildScrollView for full-page scrolling

### `lib/views/about_page.dart`
- [x] Large centered "About Us" heading
- [x] Multi-paragraph about text
- [x] Company mission and values
- [x] Product range description
- [x] Delivery and collection information
- [x] Contact email (hello@upsu.net)
- [x] Team sign-off
- [x] Responsive padding
- [x] AppHeader and AppFooter integration

### `lib/views/collections_page.dart`
- [x] Grid of collection categories
- [x] GridView.builder with responsive columns
- [x] Mobile: 1 column
- [x] Tablet: 2 columns
- [x] Desktop: 3 columns
- [x] 15 collection items
- [x] Placeholder images for each collection
- [x] GestureDetector navigation to collection pages
- [x] Responsive spacing and padding
- [x] AppHeader and AppFooter integration

### `lib/views/collection_page.dart`
- [x] Dynamic routing with slug parameter
- [x] Firebase integration to fetch products by collection
- [x] Sort functionality:
  - [x] Featured (default)
  - [x] Alphabetical A-Z
  - [x] Alphabetical Z-A
  - [x] Price Low to High
  - [x] Price High to Low
- [x] Filter functionality by category
- [x] Item count display
- [x] **Responsive sort/filter controls**:
  - [x] Mobile: Stacked vertically
  - [x] Desktop: Horizontal layout
  - [x] Full-width dropdowns on mobile
- [x] GridView for products (1/2/3 columns based on screen width)
- [x] ProductCard rendering with Firebase data
- [x] Loading state with CircularProgressIndicator
- [x] Error handling
- [x] AppHeader and AppFooter integration

### `lib/views/product_page.dart`
- [x] Accepts product details via query parameters
- [x] Large product image display
- [x] Product title, price, discount price
- [x] Discount price displayed in red with strikethrough original
- [x] Category and collection badges
- [x] Size selector dropdown
- [x] Color selector dropdown
- [x] Quantity selector (- / + buttons)
- [x] "Add to Cart" button
- [x] Cart integration via Provider with discount price support
- [x] Product description section
- [x] Care instructions section
- [x] "You may also like" recommendations
- [x] Related products from same collection
- [x] Firebase query for related products
- [x] Responsive layout (mobile/desktop)
- [x] Footer overlap issue fixed
- [x] AppHeader and AppFooter integration

### `lib/views/search_page.dart`
- [x] Receives search query from URL parameters
- [x] Firebase query with text search
- [x] Searches across title, category, collection fields
- [x] Case-insensitive search
- [x] Sort functionality (same as collection page)
- [x] Filter by category
- [x] Results count display
- [x] GridView for search results
- [x] ProductCard rendering
- [x] Loading and error states
- [x] "No results" message
- [x] AppHeader and AppFooter integration

### `lib/views/print_shack/personalisation.dart`
- [x] Product selection section
- [x] Personalisation options dropdown
- [x] Text input fields for customization
- [x] Quantity selector with ValueNotifier
- [x] Price calculation (base + personalisation)
- [x] Real-time price updates
- [x] "Add to Cart" button
- [x] Cart integration with quantity support
- [x] **Mobile responsive design**:
  - [x] Column layout on mobile (< 600px)
  - [x] Row layout on desktop
  - [x] Responsive image sizing
  - [x] Adaptive padding
- [x] ValueNotifier optimization to prevent full rebuilds
- [x] AppHeader and AppFooter integration

### `lib/views/print_shack/print-shack_about.dart`
- [x] Print Shack service description
- [x] Pricing information
- [x] Customization options explained
- [x] Examples of personalisation
- [x] Call-to-action button
- [x] AppHeader and AppFooter integration

### `lib/views/sign_in.dart`
- [x] Email input field with validation
- [x] Password input field with obscure text
- [x] "Sign In" button
- [x] Firebase Authentication integration
- [x] Error handling for invalid credentials
- [x] Success navigation to home page
- [x] "Don't have an account? Register" link
- [x] Form validation
- [x] Loading state during authentication
- [x] Centered card layout with logo
- [x] AppHeader integration (optional)

### `lib/views/register_page.dart`
- [x] Email input field
- [x] Password input field
- [x] Confirm password field
- [x] Password matching validation
- [x] Firebase Authentication integration
- [x] User account creation
- [x] Error handling
- [x] Success navigation
- [x] "Already have an account? Sign In" link
- [x] Form validation
- [x] Loading state
- [x] Centered card layout

### `lib/views/cart_screen.dart`
- [x] Display all cart items
- [x] Cart item cards with image, title, price
- [x] Quantity display and controls
- [x] Remove item button
- [x] Increase/decrease quantity buttons
- [x] Total price calculation
- [x] Total quantity display
- [x] "Checkout" button
- [x] Empty cart message
- [x] "Continue Shopping" button when empty
- [x] Provider integration for cart state
- [x] Real-time updates when cart changes
- [x] Order creation on checkout
- [x] Navigation to order history after checkout
- [x] AppHeader and AppFooter integration

### `lib/views/order_history_page.dart`
- [x] Firebase integration to fetch user orders
- [x] Authentication check (redirect if not signed in)
- [x] Display all orders for current user
- [x] Order cards showing:
  - [x] Order date and time
  - [x] Order ID
  - [x] Items in order
  - [x] Total price
  - [x] Status (e.g., "Completed")
- [x] ListView for multiple orders
- [x] Loading state
- [x] Empty state message
- [x] Error handling
- [x] AppHeader and AppFooter integration

---

## Data Models

### `lib/models/cart_model.dart`
- [x] **CartItem class**:
  - [x] Properties: title, imageUrl, price, category, collection, color, size, quantity
  - [x] totalPrice getter (price × quantity)
  - [x] toMap() method for Firestore serialization
  - [x] fromMap() factory constructor for deserialization
  - [x] Handle optional fields gracefully
  - [x] Type conversion for price (int to double)

- [x] **CartModel class (ChangeNotifier)**:
  - [x] Private items map (key: lowercase title)
  - [x] Firebase Auth integration
  - [x] Firestore integration for cart persistence
  - [x] Auth state listener to load/clear cart
  - [x] Getters: items, itemCount, totalQuantity, totalPrice
  - [x] addProduct() method
  - [x] Increment quantity for existing products
  - [x] Case-insensitive product matching
  - [x] removeProduct() method (decrements quantity)
  - [x] removeProductCompletely() method
  - [x] clearCart() method
  - [x] _loadCartFromFirestore() private method
  - [x] _saveCartToFirestore() private method
  - [x] Automatic Firestore sync on changes
  - [x] Error handling with debug prints

### `lib/models/order_model.dart`
- [x] **OrderItem class**:
  - [x] Properties: title, imageUrl, price, quantity
  - [x] toMap() serialization
  - [x] fromMap() deserialization

- [x] **Order class**:
  - [x] Properties: orderId, items, totalPrice, orderDate, status
  - [x] toMap() for Firestore
  - [x] fromMap() factory constructor
  - [x] Timestamp handling

---

## Services

### `lib/services/auth_service.dart`
- [x] Firebase Authentication wrapper
- [x] signInWithEmailAndPassword() method
- [x] registerWithEmailAndPassword() method
- [x] signOut() method
- [x] getCurrentUser() getter
- [x] authStateChanges stream
- [x] Error handling for auth operations
- [x] User account management

### `lib/services/order_service.dart`
- [x] createOrder() method
- [x] Accept cart items and total price
- [x] Generate unique order ID
- [x] Save to Firestore (users/{uid}/orders/)
- [x] Include timestamp, status, items
- [x] getUserOrders() method
- [x] Fetch all orders for current user
- [x] Order by timestamp descending
- [x] Return List<Order>
- [x] Error handling

---

## Tests

### `test/homepage_test.dart`
- [ ] Test HomeScreen widget creation
- [ ] Test hero section renders
- [ ] Test products section renders
- [ ] Test navigation elements present
- [ ] AppHeader and AppFooter integration tests

### `test/about_page_test.dart`
- [ ] Test AboutPage widget creation
- [ ] Test heading renders
- [ ] Test about text renders
- [ ] Test AppHeader and AppFooter present

### `test/collections_page_test.dart`
- [ ] Test CollectionsPage widget creation
- [ ] Test grid renders
- [ ] Test collection items count
- [ ] Test responsive behavior

### `test/layout_test.dart`
- [x] Test AppHeader widget
- [x] Test AppFooter widget
- [x] Test navigation elements
- [x] Test logo presence
- [x] Test footer links

### `test/page_test/product_page_test.dart`
- [x] Test ProductPage widget (27 tests total)
- [x] Test product details display
- [x] Test add to cart functionality
- [x] Test quantity selector
- [x] Test price display (including discount prices)
- [x] Test size and color dropdowns
- [x] Test responsive layouts (mobile/desktop)
- [x] Test related products section

### `test/page_test/search_page_test.dart`
- [x] Test SearchPage widget (6 tests total)
- [x] Test search results display
- [x] Test empty search state
- [x] Test search navigation
- [x] Test Firebase integration with mocking
- [x] Test error handling
- [x] Test product card rendering in search results

### `test/services_tests/auth_service_test.dart`
- [x] Test AuthService implementation
- [x] Test sign-in functionality
- [x] Test registration functionality
- [x] Test sign-out functionality
- [x] Test getCurrentUser method
- [x] Test authStateChanges stream

### `test/services_tests/order_service_test.dart`
- [x] Test OrderService implementation
- [x] Test createOrder method
- [x] Test getUserOrders method
- [x] Test Firestore integration with mocking
- [x] Test order ID generation
- [x] Test order data serialization

### `test/model_tests.dart/cart_model_test.dart`
- [x] **CartItem tests** (14 tests):
  - [x] Create with required fields
  - [x] Create with all fields
  - [x] Calculate totalPrice
  - [x] Update totalPrice when quantity changes
  - [x] Convert to Map
  - [x] Create from Map
  - [x] Handle missing optional fields
  - [x] Handle missing price as 0
  - [x] Convert integer price to double

- [x] **CartModel tests**:
  - [x] Implemented with firebase_auth_mocks
  - [x] Implemented with fake_cloud_firestore
  - [x] Test cart item management
  - [x] Test Firestore synchronization

---

## Firebase Configuration

### Firestore Database Structure
- [x] **products/** collection:
  - [x] Fields: title, image_url, price, disc_price, category, coll (collection)
  - [x] Data sanitization (remove quotes)
  - [x] Support for multiple collections
  
- [x] **users/{uid}/cart/** subcollection:
  - [x] Fields: title, imageUrl, price, category, collection, color, size, quantity
  - [x] Auto-sync with CartModel
  - [x] Load on user sign-in
  - [x] Clear on sign-out
  
- [x] **users/{uid}/orders/** subcollection:
  - [x] Fields: orderId, items[], totalPrice, orderDate, status
  - [x] Created on checkout
  - [x] Persisted order history

### Firebase Authentication
- [x] Email/password authentication enabled
- [x] User registration flow
- [x] Sign-in flow
- [x] Sign-out functionality
- [x] Auth state listener in CartModel
- [x] Protected routes (order history)

### `firebase.json`
- [x] Hosting configuration
- [x] Public directory set to build/web
- [x] Rewrites for SPA routing
- [x] Ignore patterns configured

### `lib/firebase_options.dart`
- [x] Auto-generated Firebase configuration
- [x] Platform-specific options
- [x] API keys and project IDs configured

---

## Routing & Navigation

### GoRouter Configuration (`lib/main.dart`)
- [x] Route definitions for all pages
- [x] Dynamic routing with parameters (`:slug`)
- [x] Query parameter support (`?q=search`, `?title=Product`)
- [x] Navigation guards (optional, can add auth checks)
- [x] Error handling for 404 routes
- [x] Deep linking support
- [x] Browser back/forward button support

### Navigation Flows
- [x] Home → Collections → Collection Page → Product Page
- [x] Home → Search → Product Page
- [x] Home → Personalisation → Cart → Checkout → Order History
- [x] Header → Sign In → Register (and vice versa)
- [x] Cart Icon → Cart Screen
- [x] Mobile Menu → Various pages

---

## Responsive Design

### Breakpoints
- [x] Mobile: < 600px
- [x] Tablet: 600-900px
- [x] Desktop: > 800px

### Responsive Components
- [x] **Homepage** (100% complete):
  - [x] Hero section - responsive height and fonts (Step 1)
  - [x] Product cards section - column/row layouts (Step 2)
  - [x] Our Range section - Wrap widget handles wrapping automatically
  - [x] Personal Touch section - column/row layouts (Step 3)
  - [x] Responsive spacing throughout (16px/40px padding, 24px/48px spacing)
  
- [x] **Personalisation Page**:
  - [x] Column on mobile / Row on desktop
  - [x] Responsive image sizing
  
- [x] **Collection Page**:
  - [x] Sort/filter controls stack on mobile
  - [x] GridView adapts columns
  
- [x] **Collections Page**:
  - [x] GridView 1/2/3 columns
  
- [x] **Layout (Header/Footer)**:
  - [x] Mobile menu with ExpansionTile
  - [x] Desktop dropdown menus
  - [x] Responsive search bar

---

## State Management

- [x] Provider package integration
- [x] ChangeNotifierProvider for CartModel
- [x] Consumer widgets for cart updates
- [x] ValueNotifier for isolated rebuilds (personalisation)
- [x] setState for local component state
- [x] FutureBuilder for async data loading

---

## Asset Management

### `pubspec.yaml`
- [x] assets/images/ directory configured
- [x] All image assets properly declared
- [x] Dependencies configured:
  - [x] go_router: ^17.0.0
  - [x] firebase_core: ^3.5.0
  - [x] firebase_auth: ^5.3.0
  - [x] cloud_firestore: ^5.4.0
  - [x] provider (implicit via flutter)

### Image Assets
- [x] Local assets for products
- [x] Category/square images
- [x] Logo images
- [x] Hero slideshow backgrounds
- [x] Print Shack logo
- [x] All paths correctly reference assets/images/

---

## Code Quality

### Linting & Formatting
- [x] flutter_lints: ^2.0.0 configured
- [x] analysis_options.yaml present
- [x] Code follows Flutter style guide
- [x] Proper widget structure
- [x] Consistent naming conventions

### Error Handling
- [x] Firebase errors caught and displayed
- [x] Network errors handled
- [x] Form validation errors shown
- [x] Empty states handled (cart, orders, search)
- [x] Loading states with progress indicators
- [x] Debug prints for development

### Performance
- [x] ValueNotifier for isolated rebuilds
- [x] Const constructors where appropriate
- [x] Efficient Firebase queries
- [x] Image caching (automatic via Flutter)
- [x] Lazy loading with FutureBuilder

---

## Documentation

- [x] README.md with comprehensive project overview
- [x] Installation and setup instructions
- [x] Usage guide with user flows
- [x] Testing documentation
- [x] Project structure documentation
- [x] Technologies and dependencies list
- [x] Firebase configuration guide
- [x] Known issues and future enhancements
- [x] requirements.md → REQUIREMENTS.md (this file)
- [x] Code comments for complex logic
- [x] Widget documentation strings
- [x] Firebase structure documented in README

---

## TODO / Future Enhancements

### Testing
- [ ] Integration tests for Firebase operations
- [ ] Widget tests for all pages
- [ ] CartModel unit tests with proper mocking
- [ ] E2E tests for critical user flows
- [ ] Test coverage > 80%

### Features
- [ ] User profile page
- [ ] Edit account details
- [ ] Password reset functionality
- [ ] Product reviews and ratings
- [ ] Wishlist functionality
- [ ] Order tracking with statuses
- [ ] Admin panel for product management
- [ ] Image upload for personalisation preview
- [ ] Multiple payment methods
- [ ] Shipping address management
- [ ] Email notifications for orders


## Summary Statistics

**Total Files**: 25+ source files
**Pages**: 12 pages
**Reusable Widgets**: 5+ (ProductCard, HoverImage, SquareImage, AppHeader, AppFooter)
**Models**: 2 (CartModel, OrderModel)
**Services**: 2 (AuthService, OrderService)
**Tests**: 7 test files with 50+ total tests
  - layout_test.dart: Header/Footer tests
  - product_page_test.dart: 27 widget tests
  - search_page_test.dart: 6 widget tests
  - cart_model_test.dart: CartItem and CartModel tests
  - auth_service_test.dart: Authentication tests
  - order_service_test.dart: Order management tests
**Routes**: 12 configured routes
**Responsive Components**: 6 major components
**Firebase Collections**: 3 (products, users/cart, users/orders)
**Documentation**: Comprehensive README.md with installation, usage, and architecture guides

