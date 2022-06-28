//
//  ContentView.swift
//  EmojiArt
//
//  Created by Tan Tan on 6/27/22.
//

import SwiftUI

struct ContentView: View {
    @ObservedObject var viewModel: EmojiArtDocument
    let emojiDefaultFontSize: CGFloat = 40
    
    var body: some View {
        VStack(spacing: 0) {
            documentBodyView
            paletteView
        }
    }
    
    var documentBodyView: some View {
        Color.yellow
    }
    
    var paletteView: some View {
        ScrollingEmojisView(emojis: testEmoji)
            .font(.system(size: emojiDefaultFontSize))
    }
    
    var testEmoji = "😀😆😜🤒🤕🤧💀☠️👻😈👹👺🐞🪲🕷🐶🐼🐸🍄☘️🌻🍏🍎🍉🥝🌭🍔🍕🍞🍼🍺🍾⏱🔌💡🕯"
    
}

struct ScrollingEmojisView: View {
    let emojis: String
    
    var body: some View {
        ScrollView(.horizontal) {
            HStack {
                ForEach(emojis.map { String($0) }, id: \.self) { emoji in
                    Text(emoji)
                }
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView(viewModel: EmojiArtDocument())
    }
}
