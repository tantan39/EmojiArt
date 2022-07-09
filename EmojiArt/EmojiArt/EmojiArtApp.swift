//
//  EmojiArtApp.swift
//  EmojiArt
//
//  Created by Tan Tan on 6/27/22.
//

import SwiftUI

@main
struct EmojiArtApp: App {
    @StateObject var viewModel = EmojiArtDocument()
    @StateObject var paletteStore = PaletteStore(name: "PaletteStore")
    
    var body: some Scene {
        WindowGroup {
            ContentView(viewModel: viewModel)
                .environmentObject(paletteStore)
        }
    }
}
