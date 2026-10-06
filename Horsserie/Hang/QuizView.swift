import SwiftUI

/// QuizView is the locked hang. Hang and Pluck fuse here. Explore, Saved, and Settings replace the root.
struct QuizView: View {
    @Bindable var chrome: HangChrome
    @Environment(\.dynamicTypeSize) private var typeSize
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        Group {
            if chrome.showsHangFault {
                errorPage
            } else if chrome.quizIsIdle {
                idlePage
            } else {
                populated
            }
        }
        .background(HangTone.background.ignoresSafeArea())
        .sensoryFeedback(.impact(weight: .medium), trigger: chrome.pluckPulse)
        .animation(HangMotion.snap(reduceMotion), value: chrome.hang.isHung)
        .animation(HangMotion.snap(reduceMotion), value: chrome.hang.isIdle)
    }

    private var idlePage: some View {
        VStack(alignment: .leading, spacing: 0) {
            chromeBar
            IdlePage(
                headline: chrome.recoveredNotice ? "The hang could not be read." : HangCopy.idleHeadline,
                line: chrome.recoveredNotice ? HangCopy.recoverLine : HangCopy.idleLine,
                actionTitle: "Explore"
            ) {
                chrome.present(.explore)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private var errorPage: some View {
        VStack(alignment: .leading, spacing: 0) {
            chromeBar
            IdlePage(
                headline: "Hang failed.",
                line: chrome.hangFault ?? HangCopy.writeFailed,
                actionTitle: "Hang"
            ) {
                chrome.hangSchool()
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private var populated: some View {
        VStack(alignment: .leading, spacing: HangPad.gap) {
            chromeBar
            jobLine
                .padding(.horizontal, HangPad.outer)
            hangBlock
                .padding(.horizontal, HangPad.outer)
            statusCaption
                .padding(.horizontal, HangPad.outer)
            fusedVerbs
                .padding(.horizontal, HangPad.outer)
            IsolatedRail(works: chrome.recentIsolated) {
                chrome.present(.saved)
            }
            .padding(.horizontal, HangPad.outer)
            markStat
                .padding(.horizontal, HangPad.outer)
        }
        .padding(.bottom, HangPad.inner)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
    }

    private var chromeBar: some View {
        HStack(spacing: HangPad.gap) {
            Text(HangCopy.brand)
                .font(HangType.font(.headline, size: typeSize))
                .foregroundStyle(HangTone.ink)
                .lineLimit(1)
                .minimumScaleFactor(0.8)
                .frame(minHeight: HangPad.hit, alignment: .leading)
            Spacer(minLength: HangPad.gap)
            iconButton("magnifyingglass", label: "Explore") {
                chrome.present(.explore)
            }
            iconButton("bookmark", label: "Saved") {
                chrome.present(.saved)
            }
            iconButton("gearshape", label: "Settings") {
                chrome.present(.settings)
            }
        }
        .padding(.horizontal, HangPad.outer)
        .padding(.top, HangPad.inner)
    }

    private func iconButton(_ symbol: String, label: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Image(systemName: symbol)
                .font(HangType.font(.headline, size: typeSize))
                .foregroundStyle(HangTone.ink)
                .frame(minWidth: HangPad.hit, minHeight: HangPad.hit)
                .contentShape(Rectangle())
        }
        .buttonStyle(HangIconStyle())
        .accessibilityLabel(label)
    }

    private var jobLine: some View {
        VStack(alignment: .leading, spacing: HangPad.inner) {
            Text(HangCopy.job)
                .font(HangType.font(.display, size: typeSize))
                .foregroundStyle(HangTone.ink)
                .lineLimit(2)
            Text(HangCopy.nextTap)
                .font(HangType.font(.caption, size: typeSize))
                .foregroundStyle(HangTone.ink)
                .lineLimit(2)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    @ViewBuilder
    private var hangBlock: some View {
        if let school = chrome.hang.school {
            SchoolHang(school: school) { canvas in
                chrome.tapCanvas(canvas)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        } else {
            vacantHang
        }
    }

    private var vacantHang: some View {
        ZStack {
            Image(chrome.showSuccess ? HangArt.successMark : HangArt.intrusTile)
                .hangCutout(maxWidth: .infinity, maxHeight: HangPad.step(22))
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .hangFlat()
        .hangLift()
        .accessibilityLabel(chrome.justPlucked ? "Stray saved" : "Hang is vacant")
    }

    private var statusCaption: some View {
        HStack(alignment: .firstTextBaseline, spacing: HangPad.gap) {
            Text(
                HangCopy.status(
                    hang: chrome.hang,
                    justPlucked: chrome.justPlucked,
                    hasRift: chrome.hasRiftOnHang
                )
            )
            .font(HangType.font(.headline, size: typeSize))
            .foregroundStyle(HangTone.ink)
            Text(
                HangCopy.statusLine(
                    hang: chrome.hang,
                    justPlucked: chrome.justPlucked,
                    hasRift: chrome.hasRiftOnHang
                )
            )
            .font(HangType.font(.caption, size: typeSize))
            .foregroundStyle(HangTone.muted)
            .lineLimit(2)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .accessibilityElement(children: .combine)
    }

    @ViewBuilder
    private var fusedVerbs: some View {
        if chrome.hangEnabled {
            HStack(alignment: .center, spacing: HangPad.gap) {
                Button(HangCopy.hangCommit) {
                    chrome.hangSchool()
                }
                .buttonStyle(HangPillStyle(tone: .hang, isLoading: chrome.hangBusy))
                .accessibilityHint("Writes four unlabeled canvases.")

                if chrome.retractEnabled {
                    Button(HangCopy.retractCommit) {
                        chrome.retractLastMark()
                    }
                    .buttonStyle(HangPillStyle(tone: .quiet, isLoading: chrome.retractBusy))
                    .accessibilityHint("Peels the last pick or miss.")
                }
            }
            .frame(maxWidth: .infinity)
        } else if chrome.retractEnabled, !chrome.hang.isHung {
            Button(HangCopy.retractCommit) {
                chrome.retractLastMark()
            }
            .buttonStyle(HangPillStyle(tone: .quiet, isLoading: chrome.retractBusy))
            .frame(maxWidth: .infinity)
        }
    }

    private var markStat: some View {
        HStack(alignment: .bottom, spacing: HangPad.gap) {
            VStack(alignment: .leading, spacing: HangPad.inner) {
                Text(HangFigures.whole(chrome.pluckMarks.count))
                    .font(HangType.font(.title, size: typeSize))
                    .foregroundStyle(HangTone.accent)
                    .monospacedDigit()
                    .lineLimit(1)
                Text(HangCopy.correctCount)
                    .font(HangType.font(.micro, size: typeSize))
                    .foregroundStyle(HangTone.ink)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(HangPad.card)
            .hangFlat()

            VStack(alignment: .leading, spacing: HangPad.inner) {
                Text(HangFigures.whole(chrome.riftMarks.count))
                    .font(HangType.font(.headline, size: typeSize))
                    .foregroundStyle(HangTone.ink)
                    .monospacedDigit()
                    .lineLimit(1)
                Text(HangCopy.missCount)
                    .font(HangType.font(.micro, size: typeSize))
                    .foregroundStyle(HangTone.ink)
            }
            .padding(HangPad.card)
            .hangFlat()
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .accessibilityElement(children: .combine)
        .accessibilityLabel(
            "\(HangFigures.whole(chrome.pluckMarks.count)) correct picks, \(HangFigures.whole(chrome.riftMarks.count)) misses"
        )
    }
}

/// IdlePage is empty Quiz. Full page cutout, headline, line, bottom Explore.
struct IdlePage: View {
    let headline: String
    let line: String
    let actionTitle: String
    var isLoading: Bool = false
    let action: () -> Void
    @Environment(\.dynamicTypeSize) private var typeSize

    var body: some View {
        VStack(alignment: .leading, spacing: HangPad.step(2)) {
            ViewThatFits(in: .vertical) {
                copyStack(showsSpacer: true)
                ScrollView {
                    copyStack(showsSpacer: false)
                }
                .scrollIndicators(.hidden)
            }
            Button(actionTitle, action: action)
                .buttonStyle(HangPillStyle(tone: .hang, isLoading: isLoading))
                .hangHit()
        }
        .padding(.horizontal, HangPad.outer)
        .padding(.top, HangPad.card)
        .padding(.bottom, HangPad.outer)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
        .background(HangTone.background)
    }

    private func copyStack(showsSpacer: Bool) -> some View {
        VStack(alignment: .leading, spacing: HangPad.step(2)) {
            Image(HangArt.emptyHome)
                .hangCutout(maxWidth: .infinity, maxHeight: HangPad.step(16))
            VStack(alignment: .leading, spacing: HangPad.inner) {
                Text(headline)
                    .font(HangType.font(.display, size: typeSize))
                    .foregroundStyle(HangTone.ink)
                    .lineLimit(3)
                Text(line)
                    .font(HangType.font(.body, size: typeSize))
                    .foregroundStyle(HangTone.ink)
                    .lineLimit(4)
            }
            .padding(HangPad.card)
            .frame(maxWidth: .infinity, alignment: .leading)
            .hangFlat()
            if showsSpacer {
                Spacer(minLength: HangPad.gap)
            }
        }
    }
}

/// QuietPage is a full-page empty or error for sheets.
struct QuietPage: View {
    let art: String
    let headline: String
    let line: String
    let actionTitle: String
    var isLoading: Bool = false
    let action: () -> Void
    @Environment(\.dynamicTypeSize) private var typeSize

    var body: some View {
        VStack(alignment: .leading, spacing: HangPad.step(2)) {
            ViewThatFits(in: .vertical) {
                copyStack(showsSpacer: true)
                ScrollView {
                    copyStack(showsSpacer: false)
                }
                .scrollIndicators(.hidden)
            }
            Button(actionTitle, action: action)
                .buttonStyle(HangPillStyle(tone: .hang, isLoading: isLoading))
                .hangHit()
        }
        .padding(.horizontal, HangPad.outer)
        .padding(.top, HangPad.card)
        .padding(.bottom, HangPad.outer)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
        .background(HangTone.background)
    }

    private func copyStack(showsSpacer: Bool) -> some View {
        VStack(alignment: .leading, spacing: HangPad.step(2)) {
            Image(art)
                .hangCutout(maxWidth: .infinity, maxHeight: HangPad.step(16))
            VStack(alignment: .leading, spacing: HangPad.inner) {
                Text(headline)
                    .font(HangType.font(.display, size: typeSize))
                    .foregroundStyle(HangTone.ink)
                    .lineLimit(3)
                Text(line)
                    .font(HangType.font(.body, size: typeSize))
                    .foregroundStyle(HangTone.ink)
                    .lineLimit(4)
            }
            .padding(HangPad.card)
            .frame(maxWidth: .infinity, alignment: .leading)
            .hangFlat()
            if showsSpacer {
                Spacer(minLength: HangPad.gap)
            }
        }
    }
}
