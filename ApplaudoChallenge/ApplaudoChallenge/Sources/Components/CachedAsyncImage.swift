import SwiftUI

struct CachedAsyncImage<Content: View, Placeholder: View>: View {

    let url: URL?
    @ViewBuilder let content: (Image) -> Content
    @ViewBuilder let placeholder: () -> Placeholder

    @State private var phase: AsyncImagePhase = .empty

    var body: some View {
        Group {
            switch phase {
            case .success(let image):
                content(image)
            case .failure:
                placeholder()
            case .empty:
                ProgressView()
                    .task { await loadImage() }
            @unknown default:
                placeholder()
            }
        }
    }

    private func loadImage() async {
        guard let url else {
            phase = .failure(URLError(.badURL))
            return
        }

        if let cached = ImageCache.shared[url] {
            phase = .success(Image(uiImage: cached))
            return
        }

        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            guard let uiImage = UIImage(data: data) else {
                phase = .failure(URLError(.cannotDecodeContentData))
                return
            }
            ImageCache.shared[url] = uiImage
            phase = .success(Image(uiImage: uiImage))
        } catch {
            phase = .failure(error)
        }
    }
}

final class ImageCache {
    static let shared = ImageCache()

    private let cache = NSCache<NSURL, UIImage>()

    private init() {
        cache.countLimit = 200
    }

    subscript(url: URL) -> UIImage? {
        get { cache.object(forKey: url as NSURL) }
        set {
            if let newValue {
                cache.setObject(newValue, forKey: url as NSURL)
            } else {
                cache.removeObject(forKey: url as NSURL)
            }
        }
    }
}
