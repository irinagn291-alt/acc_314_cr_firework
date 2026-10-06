import SwiftUI
import UIKit

/// WorkThumb paints one clipped plate. The cell never carries title or maker type.
/// A missing JPEG is a flat tint, never a second caption and never a broken-image glyph.
struct WorkThumb: View {
    var accession: String = ""
    var url: URL?
    var fills: Bool = true

    @State private var bitmap: UIImage?

    var body: some View {
        Color.clear
            .overlay {
                ZStack {
                    HangTone.muted.opacity(0.18)
                    if let bitmap {
                        Image(uiImage: bitmap)
                            .resizable()
                            .aspectRatio(contentMode: fills ? .fill : .fit)
                    }
                }
            }
            .clipped()
            .allowsHitTesting(false)
            .accessibilityHidden(true)
            .task(id: loadKey) {
                bitmap = await PlateBitmap.load(accession: accession, url: url)
            }
    }

    private var loadKey: String {
        "\(accession)|\(url?.absoluteString ?? "")"
    }
}

/// PlateSlot is one fixed, clipped artwork cell. Type lives beside or below it, never inside.
struct PlateSlot: View {
    var accession: String
    var url: URL?
    var width: CGFloat? = nil
    var height: CGFloat
    var fills: Bool = true

    var body: some View {
        WorkThumb(accession: accession, url: url, fills: fills)
            .frame(width: width, height: height)
            .frame(maxWidth: width == nil ? .infinity : nil)
            .clipShape(RoundedRectangle(cornerRadius: HangRadius.chip, style: .continuous))
            .clipped()
            .accessibilityHidden(true)
    }
}

/// PlateBitmap loads a JPEG into a UIImage. Failure stays nil so the cell stays a tint.
enum PlateBitmap {
    @MainActor
    static func load(accession: String, url: URL?) async -> UIImage? {
        if let file = PlateLedger.shared.fileURL(accession: accession),
           let image = UIImage(contentsOfFile: file.path) {
            return image
        }
        if let bundled = WorkPlate.bundledURL(accession: accession),
           let image = UIImage(contentsOfFile: bundled.path) {
            return image
        }
        guard let url, url.scheme == "https" else { return nil }
        var request = URLRequest(url: url, timeoutInterval: 12)
        request.setValue(CatalogClient.userAgent, forHTTPHeaderField: "User-Agent")
        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            if let http = response as? HTTPURLResponse, !(200...299).contains(http.statusCode) {
                return nil
            }
            guard data.count > 32, data[0] == 0xFF, data[1] == 0xD8 else { return nil }
            return UIImage(data: data)
        } catch {
            return nil
        }
    }
}
