//
//  PaletteChooserView.swift
//  EmojiArt
//
//  Created by Tan Tan on 7/8/22.
//

import SwiftUI


struct PaletteChooserView: View {
    let emojiDefaultFontSize: CGFloat = 40
    var emojiFont: Font { .system(size: emojiDefaultFontSize) }
    
    @EnvironmentObject var store: PaletteStore
    
    var body: some View {
        let palette = store.palette(at: 2)
        HStack {
            Text(palette.name)
            ScrollingEmojisView(emojis: palette.emojis)
                .font(emojiFont)
        }
    }
    
}

struct ScrollingEmojisView: View {
    let emojis: String
    
    var body: some View {
        ScrollView(.horizontal) {
            HStack {
                ForEach(emojis.map { String($0) }, id: \.self) { emoji in
                    Text(emoji)
                        .onDrag {
                            return NSItemProvider(object: emoji as NSString)
                        }
                }
            }
        }
    }
}

struct PaletteChooserView_Previews: PreviewProvider {
    static var previews: some View {
        PaletteChooserView()
    }
}
