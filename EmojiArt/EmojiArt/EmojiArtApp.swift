//
//  EmojiArtApp.swift
//  EmojiArt
//
//  Created by Tan Tan on 6/27/22.
//

import SwiftUI

@main
struct EmojiArtApp: App {
    let viewModel = EmojiArtDocument()
    
    var body: some Scene {
        WindowGroup {
            ContentView(viewModel: viewModel)
        }
    }
}
