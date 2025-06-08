import Foundation

class Config {
    static let shared = Config()

    let supabaseURL: URL
    let supabaseKey: String
    let supabaseBucket: String

    private init() {
        guard let path = Bundle.main.path(forResource: "Credentials", ofType: "plist"),
              let config = NSDictionary(contentsOfFile: path) else {
            fatalError("Credentials.plist not found. Please create it from Credentials.plist.example.")
        }

        guard let urlString = config["SUPABASE_URL"] as? String,
              let url = URL(string: urlString) else {
            fatalError("SUPABASE_URL not found or invalid in Credentials.plist.")
        }

        guard let key = config["SUPABASE_KEY"] as? String else {
            fatalError("SUPABASE_KEY not found in Credentials.plist.")
        }

        guard let bucket = config["SUPABASE_BUCKET"] as? String else {
            fatalError("SUPABASE_BUCKET not found in Credentials.plist.")
        }

        self.supabaseURL = url
        self.supabaseKey = key
        self.supabaseBucket = bucket
    }
} 