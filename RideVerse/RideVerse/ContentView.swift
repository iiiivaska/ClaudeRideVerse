import SwiftUI

struct ContentView: View {
    @AppStorage("onboarding_complete") private var onboardingComplete = false

    var body: some View {
        if onboardingComplete {
            PrototypeView()
        } else {
            OnboardingView {
                onboardingComplete = true
            }
        }
    }
}

#Preview {
    ContentView()
}
