import Foundation
import FirebaseCore
import FirebaseAuth
import FirebaseFirestore

/// Main Firebase service providing central access to all Firebase features
/// Initialize this in the App's init to configure Firebase
final class FirebaseService {
    
    // MARK: - Singleton
    static let shared = FirebaseService()
    
    // MARK: - Properties
    let auth: AuthManager
    let firestore: FirestoreManager
    
    private var isConfigured = false
    
    // MARK: - Initialization
    private init() {
        // Configure Firebase FIRST, before accessing any Firebase services
        FirebaseApp.configure()
        
        // Enable Firestore offline persistence
        let settings = FirestoreSettings()
        settings.cacheSettings = PersistentCacheSettings(sizeBytes: 100 * 1024 * 1024 as NSNumber) // 100MB cache
        Firestore.firestore().settings = settings
        
        // Now safe to create managers that access Firebase
        self.auth = AuthManager()
        self.firestore = FirestoreManager()

        // Setup auth state listener to persist login
        self.auth.setupAuthStateListener()

        isConfigured = true
        print("🔥 Firebase configured successfully")
    }
    
    /// Configure Firebase - call this once at app startup
    /// (Configuration now happens automatically in init)
    func configure() {
        // Auth state listener is now set up in init
        // This method kept for backwards compatibility
    }
}

// MARK: - Auth Convenience Methods
extension FirebaseService {
    /// Current authenticated user ID
    var currentUserId: String? {
        auth.currentUser?.uid
    }
    
    /// Check if user is logged in
    var isLoggedIn: Bool {
        auth.currentUser != nil
    }
}
