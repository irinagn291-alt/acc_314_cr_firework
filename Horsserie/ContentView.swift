import SwiftUI
import UIKit

/// ContentView is the hang-locked shell. Onboarding cover, then Quiz. ReviewScreen fires after onboarding.
struct ContentView: View {
    @State private var chrome: HangChrome
    @Environment(\.scenePhase) private var scenePhase
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    init(chrome: HangChrome = HangChrome.live()) {
        _chrome = State(wrappedValue: chrome)
    }

    var body: some View {
        ZStack {
            HangTone.background.ignoresSafeArea()
            if chrome.isBooting {
                Image(HangArt.splash)
                    .resizable()
                    .scaledToFill()
                    .ignoresSafeArea()
                    .accessibilityHidden(true)
            } else if chrome.showsOnboarding {
                OnboardingView(
                    onSkip: { chrome.finishOnboarding() },
                    onFinish: { chrome.finishOnboarding() }
                )
            } else {
                switch chrome.cover {
                case .explore:
                    ExploreView(chrome: chrome)
                case .saved:
                    SavedView(chrome: chrome)
                case .settings:
                    SettingsView(chrome: chrome)
                case .goals:
                    AccrochageView(chrome: chrome)
                case nil:
                    QuizView(chrome: chrome)
                }
            }
        }
        .preferredColorScheme(.light)
        .tint(HangTone.accent)
        .animation(HangMotion.snap(reduceMotion), value: chrome.showsOnboarding)
        .animation(HangMotion.snap(reduceMotion), value: chrome.isBooting)
        .animation(HangMotion.snap(reduceMotion), value: chrome.cover)
        .task { await chrome.boot() }
        .task {
            for await notice in NotificationCenter.default.notifications(named: .hangJob) {
                if let job = HangJob.parse(notification: notice) {
                    chrome.handle(job)
                }
            }
        }
        .onChange(of: scenePhase) { _, phase in
            Task { await chrome.handle(phase: phase) }
        }
        .onOpenURL { chrome.handle(url: $0) }
        .onReceive(NotificationCenter.default.publisher(for: UIApplication.significantTimeChangeNotification)) { _ in
            chrome.refreshDay()
        }
    }
}

#Preview {
    ContentView()
}
