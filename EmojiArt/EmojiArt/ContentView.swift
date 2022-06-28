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
        GeometryReader { geometry in
            ZStack {
                Color.yellow
                ForEach(viewModel.emojis, id: \.id) { emoji in
                    Text(emoji.text)
                        .font(.system(size: fontSize(for: emoji)))
                        .position(position(for: emoji, in: geometry))
                }
            }
        }
    }
    
    private func position(for emoji: EmojiArtModel.Emoji, in geometry: GeometryProxy) -> CGPoint {
        convertFromEmojiCoordinates((emoji.x, emoji.y), in: geometry)
    }
    
    private func convertFromEmojiCoordinates(_ location: (x: Int, y: Int), in geometry: GeometryProxy) -> CGPoint {
        let center = geometry.frame(in: .local).center
        return CGPoint(x: center.x + CGFloat(location.x), y: center.y + CGFloat(location.y))
    }
    
    private func fontSize(for emoji: EmojiArtModel.Emoji) -> CGFloat {
        CGFloat(emoji.size)
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
