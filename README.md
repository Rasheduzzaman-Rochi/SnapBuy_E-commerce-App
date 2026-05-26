# SnapBuy

SnapBuy is a Flutter-based e-commerce mobile application built with Firebase. It includes user authentication, Google sign-in, product browsing, persistent Firestore cart management, checkout, SSLCommerz sandbox payment testing, order history management, and shared app branding.

## Overview

SnapBuy is designed as a complete mobile shopping app for Android and iOS. The project focuses on a clean user interface, smooth shopping flow, Firebase integration, and payment gateway learning using SSLCommerz sandbox.

## Key Features

- User registration and login
- Email/password authentication
- Google sign-in
- Product catalog
- Product details screen
- Product search and category filtering
- Add to cart with Firestore persistence
- Load saved cart after login or app reopen
- Update cart quantity with Firestore sync
- Remove items from cart with Firestore sync
- Clear local and Firestore cart after successful order/payment
- Checkout flow
- SSLCommerz sandbox payment integration
- Order creation after successful payment only
- Payment cancellation handling
- Order history
- Expand/collapse order details
- Delete order with undo option
- User profile and sign out
- Bottom navigation
- Shared SnapBuy logo widget using `assets/logo.png`

## Tech Stack

- Flutter
- Dart
- Provider
- Firebase Core
- Firebase Authentication
- Cloud Firestore
- Google Sign-In
- SSLCommerz Flutter Plugin
- flutter_dotenv
- intl

## Project Structure

```text
lib/
  core/
    constants.dart
    theme.dart
    widgets/
      app_logo.dart
      main_nav_bar.dart

  features/
    auth/
      data/
      presentation/
      provider/

    catalog/
      presentation/

    cart/
      models/
      presentation/
      provider/

    checkout/
      presentation/

    orders/
      presentation/
      provider/

    payment/
      sslcommerz_payment_service.dart

  models/
  services/
    cart_service.dart
  firebase_options.dart
  main.dart
```

## Main App Flow

```text
Login / Sign Up
      ↓
Home / Product Catalog
      ↓
Product Details
      ↓
Cart
      ↓
Checkout
      ↓
SSLCommerz Sandbox Payment
      ↓
Order Success
      ↓
Orders History
```

## Authentication

SnapBuy uses Firebase Authentication for user management.

Supported authentication methods:

- Email and password login
- Email and password registration
- Google sign-in
- User sign-out

For Google sign-in on Android, SHA-1 and SHA-256 fingerprints must be added in Firebase project settings.

## Firestore Usage

Cloud Firestore is used to store products, users, carts, and orders.

### Product Catalog

Products are loaded from:

```text
products/{productId}
```

The app maps Firestore product documents into `Product` models. Supported product fields include:

```text
name
price
category
imageUrl
description
sellerId
sellerName
```

### Persistent Cart

Logged-in users have a Firestore-backed cart:

```text
users/{uid}/cart/{productId}
  productId
  name
  price
  imageUrl
  sellerId
  sellerName
  quantity
  addedAt
  updatedAt
```

The cart document ID is the `productId`, so adding the same product increments quantity instead of creating duplicates.

Cart behavior:

- `CartProvider.loadCartFromFirestore()` loads saved cart items after login/app reopen.
- `CartService.addToCart()` uses a Firestore transaction to increment quantity safely.
- Quantity updates are synced to Firestore.
- Quantity `0` or less deletes the cart document.
- Removing an item deletes `users/{uid}/cart/{productId}`.
- Successful checkout clears both local provider state and Firestore cart documents.

If no user is logged in, Firestore cart writes are blocked and the app shows a login-friendly error.

### Orders

Example order data:

```text
orders/
  orderId/
    orderId
    userId
    userEmail
    items
    total
    customerName
    customerPhone
    customerAddress
    status
    createdAt
```

### Firestore Security Rules

Prototype Firestore rules are available at the repository root:

```text
../firestore.rules
```

The cart rule only allows users to access their own cart:

```javascript
match /users/{userId}/cart/{cartItemId} {
  allow read, write: if request.auth != null && request.auth.uid == userId;
}
```

Review and harden all Firestore rules before production release.

## Payment System

SnapBuy uses the SSLCommerz Flutter plugin for sandbox payment testing and learning purposes.

The app opens the SSLCommerz sandbox payment interface and allows users to test payment methods such as:

- Cards
- Mobile Banking
- Net Banking

### Payment Logic

Orders are created only after payment is successful.

Successful statuses:

```text
VALID
VALIDATED
SUCCESS
SUCCESSFUL
```

Cancelled or failed statuses:

```text
CLOSED
CANCELLED
CANCELED
FAILED
FAIL
INVALID
null
```

If the user closes the SSLCommerz payment UI, the app treats it as a cancelled payment.

In that case:

- Order is not created as successful
- Cart is not cleared
- User can retry payment
- A cancellation message is shown

### Important Payment Note

This project uses SSLCommerz through the Flutter plugin for sandbox testing and learning. SSLCommerz credentials are loaded from a `.env` file so they are not pushed to GitHub.

However, Flutter `.env` values are still bundled inside the app build. For a production payment system, SSLCommerz Session API, IPN, and Order Validation should be handled from a secure backend.

## Environment Variables

Create a `.env` file in the project root:

```env
SSLC_STORE_ID=your_sslcommerz_store_id
SSLC_STORE_PASSWORD=your_sslcommerz_store_password
SSLC_SANDBOX=true
```

The `.env` file should be added to `.gitignore`:

```gitignore
.env
```

Also register `.env` in `pubspec.yaml`:

```yaml
flutter:
  uses-material-design: true
  assets:
    - .env
    - assets/logo.png
```

## App Logo

The shared app logo is stored at:

```text
assets/logo.png
```

It is registered in `pubspec.yaml` and used through:

```text
lib/core/widgets/app_logo.dart
```

Use `AppLogo` anywhere the SnapBuy brand/logo is shown. Normal action icons, such as password fields, navigation icons, cart buttons, and profile avatars, should stay as standard Material icons unless they are being used as a brand logo.

## Prerequisites

Before running the project, make sure you have:

- Flutter SDK installed
- Dart SDK installed
- Android Studio or Xcode configured
- Firebase project created
- Firebase Authentication enabled
- Cloud Firestore enabled
- Android/iOS device or emulator

Check Flutter setup:

```bash
flutter doctor
```

## Installation

Clone the repository:

```bash
git clone <your-repository-url>
cd <project-folder>
```

Install dependencies:

```bash
flutter pub get
```

Configure Firebase:

- Add `google-services.json` to:

```text
android/app/google-services.json
```

- Add `GoogleService-Info.plist` to:

```text
ios/Runner/GoogleService-Info.plist
```

Run the app:

```bash
flutter run
```

## Firebase Setup

### 1. Create Firebase Project

Create a Firebase project from Firebase Console.

### 2. Register Android App

Use the Android package name configured in your project.

Current development package name:

```text
com.example.e_commerce_cse464
```

### 3. Enable Authentication

Go to Firebase Console:

```text
Authentication → Sign-in method
```

Enable:

- Email/Password
- Google

### 4. Enable Firestore

Go to:

```text
Firestore Database → Create database
```

Use test mode during development, then update security rules before production.

### 5. Add SHA Fingerprints

For Google sign-in on Android, add SHA-1 and SHA-256 fingerprints.

After adding SHA fingerprints:

1. Download updated `google-services.json`
2. Replace the old file in `android/app/`
3. Rebuild the app

```bash
flutter clean
flutter pub get
flutter run
```

## Build Commands

Build debug APK:

```bash
flutter build apk --debug
```

Build release APK:

```bash
flutter build apk --release
```

Build Android App Bundle:

```bash
flutter build appbundle --release
```

## Launcher Icon

This project uses `flutter_launcher_icons`.

Icon configuration is available in `pubspec.yaml`.

Generate launcher icons:

```bash
dart run flutter_launcher_icons
```

## State Management

SnapBuy uses Provider with `ChangeNotifier`.

Main providers:

- `AuthProvider`
- `CartProvider`
- `OrdersProvider`

These providers are registered at app root using `MultiProvider`.

### Cart State

`CartProvider` keeps the UI state in memory and syncs logged-in cart changes through `CartService`.

Important cart methods:

- `loadCartFromFirestore()`
- `addItem(product)`
- `updateQuantity(productId, quantity)`
- `increaseQuantity(productId)`
- `decreaseQuantity(productId)`
- `removeItem(productId)`
- `clearCart()`

The app loads cart data from Firestore when the auth gate detects a logged-in user and when the cart screen opens.

## Order Management

The Orders screen supports:

- Viewing order history
- Expanding order details
- Collapsing order details
- Deleting orders
- Undo delete action

Order expansion state is handled by order ID, so deleting one order does not automatically open another order.

## Testing Payment Flow

To test SSLCommerz sandbox payment:

1. Add products to cart
2. Go to Cart screen
3. Proceed to Checkout
4. Fill customer information
5. Tap Pay with SSLCommerz
6. Select a sandbox payment method
7. Complete the payment

Expected result after successful payment:

- Order is created
- Local cart is cleared
- Firestore cart under `users/{uid}/cart` is cleared
- User can see the order in Orders screen

Expected result after cancelling payment:

- Order is not created as successful
- Cart remains unchanged
- User can retry checkout

## Testing Cart Persistence

To test Firestore cart persistence:

1. Log in with email/password or Google.
2. Add a product to cart.
3. Confirm Firestore has a document at `users/{uid}/cart/{productId}`.
4. Close and reopen the app, or log out and log back in.
5. Open the cart screen and confirm the item is restored.
6. Increase/decrease quantity and confirm Firestore updates.
7. Remove the item and confirm the Firestore cart document is deleted.
8. Complete a successful checkout and confirm the Firestore cart collection is empty.

## Testing Logo Display

To test the shared logo:

1. Open the login screen and confirm the auth header uses `assets/logo.png`.
2. Open sign up or OTP screens and confirm the same auth header logo appears.
3. Log in and confirm the home app bar uses the same SnapBuy logo.

## Troubleshooting

### Google Sign-In Not Working

Check:

- Google sign-in is enabled in Firebase Authentication
- SHA-1 and SHA-256 are added in Firebase project settings
- Correct `google-services.json` is placed in `android/app/`
- Android package name matches Firebase project settings
- App was rebuilt after Firebase config update

Run:

```bash
flutter clean
flutter pub get
flutter run
```

### Firebase Initialization Error

Check:

- `firebase_options.dart` exists
- Firebase config files are in the correct folders
- Firebase project matches Android/iOS app configuration

### Cart Does Not Persist

Check:

- User is logged in before adding to cart
- Firestore is enabled
- Firestore security rules allow `users/{uid}/cart/{productId}` for the signed-in user
- Product documents have valid `name`, `price`, and `imageUrl` fields
- App was rebuilt after Firebase config changes

### Logo Not Showing

Check:

- `assets/logo.png` exists
- `assets/logo.png` is registered under `flutter.assets` in `pubspec.yaml`
- `flutter pub get` was run after changing assets
- The UI uses `AppLogo` for brand/logo display

### SSLCommerz Credentials Missing

Check:

- `.env` exists in project root
- `.env` is registered in `pubspec.yaml`
- `flutter_dotenv` is loaded before `runApp()`
- Variable names match exactly:

```env
SSLC_STORE_ID=
SSLC_STORE_PASSWORD=
SSLC_SANDBOX=
```

## Current Limitations

- SSLCommerz is integrated using Flutter plugin for sandbox testing
- Production payment validation backend is not included
- Inventory management is not connected to a backend admin system
- Cart merge between guest and logged-in sessions is not implemented
- No push notification system yet
- No product review or wishlist system yet

## Future Improvements

- Add secure backend-based SSLCommerz integration
- Add IPN and Order Validation API support
- Add admin dashboard
- Add inventory management
- Add product reviews and ratings
- Add wishlist feature
- Add order tracking
- Add push notifications
- Add unit and widget tests
- Add CI/CD pipeline
- Improve accessibility and localization

## Development Notes

- App name: SnapBuy
- Current Android application ID: `com.example.e_commerce_cse464`
- Update package name, app icon, and Firebase config before production release
- Keep `.env` file private and never commit real credentials
- Keep shared brand usage centralized through `AppLogo`
- Keep Firestore security rules reviewed before public testing

## License

All rights reserved.

This project is provided for portfolio and demonstration purposes only. No permission is granted to copy, modify, distribute, use, or create derivative works from this project without written permission from the author.
