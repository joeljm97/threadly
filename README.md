# Threadly — Flutter fashion shopping app

A Myntra-style clothing store built with Flutter (Material 3 + Provider), running on mock data so it works with no backend.

## Features
- **Home** – search bar, category circles, auto-scrolling sale banners, "Under ₹X" budget tiles, Deal of the Day, Recently Viewed, Trending grid
- **Categories** – Men / Women / Kids / Footwear / Accessories with expandable sub-categories
- **Product listing** – 2-column grid, rating chips, wishlist hearts, **Sort** (popularity, new, price, discount, rating) and a full-screen **Filter** (category, brand, price range, discount)
- **Search** – live suggestions, recent & popular searches
- **Product detail** – image carousel with Hero animation, size selector + size chart, pincode delivery check, similar products, Wishlist / Add to Bag
- **Wishlist** – move to bag with size picker
- **Bag** – quantity picker, remove / move to wishlist, free-delivery nudge, full price breakdown (MRP, discount, platform & delivery fee)
- **Checkout** – validated address form → payment options → order confirmation
- **Profile** – orders history and account menu

## Run it
```bash
flutter create --org com.threadly --project-name threadly --platforms=android,ios .   # first time only: generates android/ & ios/
flutter pub get
flutter run
```

## Build the APK
- **Windows:** double-click `build_apk.bat`. The APK lands in `build\app\outputs\flutter-apk\app-release.apk`.
- **Any OS:** `flutter build apk --release` (or `--split-per-abi` for smaller APKs).
- **In the cloud:** push this folder to a GitHub repo — `.github/workflows/build-apk.yml` builds the APK and attaches it to the run under *Artifacts*.

The release APK is signed with the debug key by default, which is fine for installing on your phone. For the Play Store, set up a release keystore first.

## Project structure
```
lib/
  main.dart                 app + routes
  theme.dart                colours, ₹ formatting, theme
  models/product.dart       Product, CartItem, Order
  data/mock_data.dart       ~80 generated products, banners, categories
  providers/shop_provider.dart  cart, wishlist, orders, recently viewed
  widgets/product_card.dart     card, grid, price row, rating chip, app-bar icons
  screens/                  home, categories, list+filter, detail, search,
                            wishlist, cart, checkout, profile/orders
```

## Next steps
Swap `mock_data.dart` for a real API or Firebase, add login, and plug in a payment gateway (Razorpay/Cashfree) on the payment step. Product images are placeholders from picsum.photos.
