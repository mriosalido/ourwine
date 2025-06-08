import SwiftUI
import Supabase

struct RemoteImage: View {
    let storagePath: String
    @State private var imageUrl: URL?

    private let supabase: SupabaseClient = SupabaseManager.shared.client

    var body: some View {
        Group {
            if let imageUrl {
                AsyncImage(url: imageUrl) { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                } placeholder: {
                    ProgressView()
                }
            } else {
                Rectangle()
                    .fill(Color.gray.opacity(0.3))
                    .overlay {
                        Image(systemName: "photo")
                            .font(.largeTitle)
                            .foregroundColor(.gray)
                    }
            }
        }
        .onAppear(perform: loadImage)
    }

    private func loadImage() {
        do {
            let url = try supabase.storage
                .from(SupabaseManager.winePhotosBucket)
                .getPublicURL(path: storagePath)
            self.imageUrl = url
        } catch {
            print("Error getting public URL for \(storagePath): \(error)")
        }
    }
} 