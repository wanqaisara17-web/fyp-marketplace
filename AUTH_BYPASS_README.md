// AUTHENTICATION BYPASS DOCUMENTATION
// =====================================
// 
// This file documents the temporary authentication bypass setup for development.
// All authentication features have been disabled to allow quick testing of core features.
// 
// ============================================================================
// CHANGES MADE
// ============================================================================
// 
// 1. CREATED: lib/features/auth/models/user_model.dart
//    - User model with dummy data factory method
//    - Dummy user: id: 1, name: "Test User", email: "0123456789@student.uitm.edu.my"
// 
// 2. CREATED: lib/features/auth/providers/auth_provider.dart
//    - AuthProvider that always returns logged-in state
//    - All auth methods (login, register, verifyOtp) are dummy methods
//    - Always initializes with User.dummy() on startup
//    - Includes dummy logout for compatibility
// 
// 3. MODIFIED: lib/main.dart
//    - Added AuthProvider to MultiProvider list
//    - AuthProvider is initialized before app runs
// 
// 4. MODIFIED: lib/routes/app_router.dart
//    - Initial route changed to: home (was: splash)
//    - Auth routes are disabled but still accessible for testing
//    - Added comments noting authentication bypass
// 
// 5. MODIFIED: lib/features/marketplace/screens/profile_screen.dart
//    - Now uses AuthProvider to display user data
//    - Shows dummy user information from AuthProvider
//    - Includes address and phone from dummy user
// 
// ============================================================================
// HOW IT WORKS
// ============================================================================
// 
// APP STARTUP FLOW:
// 1. main.dart runs
// 2. AuthProvider is created and initializes with dummy user
// 3. App starts at home screen (MarketplaceShell)
// 4. User is already "logged in" with dummy user data
// 5. No redirect to login screen occurs
// 
// DUMMY USER DATA:
// ├─ ID: 1
// ├─ Name: Test User
// ├─ Email: 0123456789@student.uitm.edu.my
// ├─ Phone: +60123456789
// └─ Address: UiTM Jasin Campus, Melaka
// 
// AUTHENTICATION ENDPOINTS (DISABLED):
// ├─ Login: Still callable but doesn't actually authenticate
// ├─ Register: Still callable but doesn't actually register
// ├─ OTP Verification: Still callable but doesn't verify anything
// └─ Logout: Maintains logged-in state (doesn't actually log out)
// 
// ============================================================================
// FEATURES THAT WORK WITHOUT AUTHENTICATION
// ============================================================================
// 
// ✅ Home Screen
//    - Loads dummy products
//    - Product browsing
//    - Product search
//    - Refresh functionality
// 
// ✅ Shopping Cart
//    - Add to cart
//    - Remove from cart
//    - Cart total calculation
//    - Cart badge count
// 
// ✅ Product Details
//    - View product details
//    - View product images
//    - View features and specifications
//    - Add to cart from detail screen
// 
// ✅ Search Screen
//    - Search products
//    - Filter results
// 
// ✅ Profile Screen
//    - Display dummy user information
//    - Orders, Favorites, Addresses, etc.
//    - All navigation maintained (just UI)
// 
// ✅ Bottom Navigation
//    - All tabs work
//    - Navigation between screens works
//    - Cart badge updates
// 
// ============================================================================
// TESTING CORE FEATURES
// ============================================================================
// 
// 1. Launch app - automatically shows home screen
// 2. Browse products - all dummy products load
// 3. Tap product - goes to detail screen
// 4. Add to cart - item added to marketplace provider
// 5. Search products - search functionality works
// 6. View profile - shows "Test User" information
// 7. Tap logout - stays logged in (logout disabled)
// 
// ============================================================================
// REVERTING TO NORMAL AUTHENTICATION
// ============================================================================
// 
// To re-enable normal authentication:
// 1. Change initialLocation in app_router.dart back to: splash
// 2. Remove AuthProvider from main.dart providers list
// 3. Create auth guard/redirect based on isAuthenticated state
// 4. Remove Consumer<AuthProvider> from screens that use it
// 5. Update API calls to actually call backend endpoints
// 
// ============================================================================
// IMPORTANT NOTES
// ============================================================================
// 
// ⚠️  DO NOT DELETE AUTHENTICATION CODE
//     - All auth files are preserved
//     - Auth code can be easily re-enabled when needed
//     - This is a temporary bypass for development only
// 
// ⚠️  DUMMY USER DATA
//     - Accessible throughout the app via AuthProvider
//     - Replace with real user data by modifying AuthProvider
//     - Frontend features work without backend API calls
// 
// ⚠️  API SERVICE
//     - ApiService class still exists but not called
//     - All endpoints in ApiService are functional but not invoked
//     - Ready to re-enable when auth is restored
// 
// ⚠️  MARKETPLACE FEATURES
//     - All marketplace features work with dummy products
//     - Real backend integration can be added later
//     - Currently using provider pattern for state management
//
