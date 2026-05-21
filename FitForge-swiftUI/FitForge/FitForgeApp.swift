import SwiftUI

@main
struct FitForgeApp: App {
    @StateObject private var store = AppStore()

    var body: some Scene {
        WindowGroup {
            if store.character == nil {
                CharacterCreationView()
                    .environmentObject(store)
            } else {
                MainTabView()
                    .environmentObject(store)
            }
        }
    }
}
