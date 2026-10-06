import SwiftUI

/// SchoolHang is the four-canvas accrochage.
/// Uneven 2 plus 2 fills the given canvas. Top pair is taller. Cells clip their plates.
struct SchoolHang: View {
    let school: School
    let tap: (Canvas) -> Void

    var body: some View {
        GeometryReader { geo in
            let gap = HangPad.gap
            heroGrid(in: geo.size, gap: gap)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .hangLift()
        .accessibilityElement(children: .contain)
        .accessibilityLabel("Four unlabeled paintings")
    }

    private func heroGrid(in size: CGSize, gap: CGFloat) -> some View {
        let topHeight = (size.height - gap) * 0.56
        let bottomHeight = size.height - gap - topHeight
        let tileWidth = (size.width - gap) / 2
        return VStack(spacing: gap) {
            HStack(spacing: gap) {
                tile(at: 0, width: tileWidth, height: topHeight)
                tile(at: 1, width: tileWidth, height: topHeight)
            }
            HStack(spacing: gap) {
                tile(at: 2, width: tileWidth, height: bottomHeight)
                tile(at: 3, width: tileWidth, height: bottomHeight)
            }
        }
        .frame(width: size.width, height: size.height, alignment: .top)
    }

    @ViewBuilder
    private func tile(at index: Int, width: CGFloat, height: CGFloat) -> some View {
        if school.canvases.indices.contains(index) {
            CanvasTile(canvas: school.canvases[index]) {
                tap(school.canvases[index])
            }
            .frame(width: max(HangPad.hit, width), height: max(HangPad.hit, height))
            .clipped()
        } else {
            RoundedRectangle(cornerRadius: HangRadius.card, style: .continuous)
                .fill(HangTone.surface)
                .frame(width: max(HangPad.hit, width), height: max(HangPad.hit, height))
        }
    }
}
