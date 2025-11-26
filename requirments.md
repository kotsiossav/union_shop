# Project Requirements Checklist

## Home Page (`homepage.dart`)

- [x] Created **3 main sections** on the homepage:
  - [x] Hero section with large background image and “Browse Products” button.
  - [x] Products section showing multiple product cards in rows.
  - [x] “Our Range” section with four square category images and an “Add a Personal Touch” promo block.

- [x] Convert the **hero section into a slideshow**:
  - [x] Use multiple slides that automatically or manually switch.
  - [x] Each slide must have a **different title**.
  - [x] Each slide must have a **different subtitle**.
  - [x] Each slide must have a **button with different text**.

- [x] Implemented reusable **header (`AppHeader`) and footer (`AppFooter`)**:
  - [x] Header with navigation links: Home, Shop, Sale, Print Shack, About.
  - [x] Footer with multiple columns and helpful links (e.g. Search, Terms & Conditions of Sale Policy).

- [x] Made all main homepage images **local assets**:
  - [x] Product images (hoodies, t‑shirts, postcards, magnets, bookmarks, etc.).
  - [x] Category / square images (Clothing, Merchandise, Graduation, SALE).
  - [x] “Add a Personal Touch” / Print Shack logo image.

- [x] Added **buttons** on the homepage:
  - [x] “BROWSE PRODUCTS” button in the hero section.
  - [x] “VIEW ALL” button below the product grid.
  - [x] “Click here to add text” button in the “Add a Personal Touch” section.

- [x] Styled buttons with:
  - [x] Custom background colour.
  - [x] White text colour.
  - [x] Extra padding.
  - [x] Square corners (no border radius).

- [x] Implemented **hover effects for images**:
  - [x] Product images use `_HoverImage` to brighten on hover.
  - [x] Square category images use `_HoverImage` with grey shading overlay on hover.

- [x] Implemented **labels on square images**:
  - [x] Each `_SquareImage` shows centred white text (e.g. Clothing, Merchandise, Graduation, SALE).

- [x] Implemented **hover styling for footer links**:
  - [x] “Search” link gets lighter on hover.
  - [x] “Terms & Conditions of Sale Policy” link gets lighter on hover.

- [x] Created a reusable **`ProductCard`** widget:
  - [x] Displays image, title and price.
  - [x] Wrapped in `MouseRegion` / `GestureDetector` for clickable behaviour.

- [x] Created a reusable **`_SquareImage`** widget:
  - [x] Uses `_HoverImage` with optional `label` and fixed square size.

## About Page (`about_page.dart`)

- [x] Implemented **About page** with shared header and footer.
- [x] Big centred **“About Us”** heading with large font size.
- [x] Added multi‑paragraph **about text**:
  - [x] Explains purpose of the Union Shop.
  - [x] Describes product range and personalisation service.
  - [x] Mentions delivery / in‑store collection options.
  - [x] Provides contact email: `hello@upsu.net`.
  - [x] Ends with “Happy shopping!” and team sign‑off.

- [x] Navigation:
  - [x] “About” button in header navigates to `AboutPage` (`/about` route).
  - [x] About page header allows navigation back to home (`/`).

- [x] Inlined **text styles** directly in `about_page.dart` (no dependency on `app_styles.dart`).

## Collections Page (lib/collections_page.dart)
- [x] CollectionsPage widget created (StatelessWidget).
- [x] Uses SingleChildScrollView + Column for vertical scrolling.
- [x] Includes shared header and footer: `const AppHeader()` and `const AppFooter()`.
- [x] Centered, bold page heading "collections" with vertical padding.
- [x] Defined local asset list: `static const List<String> _assetImages`.
- [x] Generates 5 rows, each row containing 3 images.
- [x] Per-row outer padding (left/right/top/bottom) applied.
- [x] Per-item horizontal gutter padding between images.
- [x] Images built with `LayoutBuilder` to compute `itemWidth` from available space.
- [x] Image height computed (no hardcoded height) using an `aspectRatio` and capped by a fraction of screen height (`MediaQuery`).
- [x] Each image rendered with `HoverImage` and `BoxFit.cover`.
- [x] Images are taller-than-wide by aspect-ratio calculation (visually elongated).
- [x] Row padding was adjusted (tripled) per request.
- [x] Text overlay on all images: each image displays centered white text without background (labels for category/square images and optional captions for products).

## Sign In Page (lib/sign_in.dart)

- [x] SignInPage widget created (StatefulWidget).
- [x] Centered white card in the middle of the screen (max width constraint, rounded corners, subtle shadow).
- [x] Displays logo image at top of the card: `assets/images/logo2.png`.
- [x] Heading "Sign in" shown below the logo (bold, centered).
- [x] Email input field (TextFormField) present and wired to a controller.
- [x] Continue button present below the email field and initially deactivated (onPressed == null).
- [ ] Continue button becomes enabled when a valid email address is entered (validation + enable/disable behavior).
- [ ] Continue button action: navigate or proceed when enabled (implement and test).

## General

- [x] Used `SingleChildScrollView` + `Column` for vertically scrollable pages.
- [x] Used `SizedBox` / `ConstrainedBox` to keep content centred and limited to a max width on large screens.
- [x] All image paths correctly configured as Flutter **assets** in `pubspec.yaml`.