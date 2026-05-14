# SnapBuy

SnapBuy is a Flutter-based e-commerce mobile application built with Firebase. It includes user authentication, Google sign-in, product browsing, cart management, checkout, SSLCommerz sandbox payment testing, and order history management.

## Overview

SnapBuy is designed as a complete mobile shopping app for Android and iOS. The project focuses on a clean user interface, smooth shopping flow, Firebase integration, and payment gateway learning using SSLCommerz sandbox.

## Key Features

- User registration and login
- Email/password authentication
- Google sign-in
- Product catalog
- Product details screen
- Product search and category filtering
- Add to cart
- Update cart quantity
- Remove items from cart
- Checkout flow
- SSLCommerz sandbox payment integration
- Order creation after successful payment only
- Payment cancellation handling
- Order history
- Expand/collapse order details
- Delete order with undo option
- User profile and sign out
- Bottom navigation

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

  features/
    auth/
      data/
      presentation/
      provider/

    catalog/
      presentation/

    cart/
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

Cloud Firestore is used to store user and order-related data.

Example order data:

```text
orders/
  orderId/
    userId
    items
    totalAmount
    customerName
    phone
    address
    paymentGateway
    paymentStatus
    status
    transactionId
    createdAt
```

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
```

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
- Cart is cleared
- User can see the order in Orders screen

Expected result after cancelling payment:

- Order is not created as successful
- Cart remains unchanged
- User can retry checkout

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

## License

This project is developed for academic, learning, and portfolio purposes.