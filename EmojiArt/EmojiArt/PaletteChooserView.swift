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
    @State var chosenPaletteIndex: Int = 0
    
    var body: some View {
        HStack {
            paletteControlButton
            bodyPaletteView(for: store.palette(at: chosenPaletteIndex))
        }
        .clipped()
    }
    
    var paletteControlButton: some View {
        Button {
            withAnimation {
                chosenPaletteIndex = (chosenPaletteIndex + 1) % store.palettes.count
            }
        } label: {
            Image(systemName: "paintpalette")
        }
        .font(emojiFont)
    }
    
    func bodyPaletteView(for palette: Palette) -> some View {
        HStack {
            Text(palette.name)
            ScrollingEmojisView(emojis: palette.emojis)
                .font(emojiFont)

        }
        .id(palette.id)
        .transition(rollTransition())
    }
    
    func rollTransition() -> AnyTransition {
        AnyTransition.asymmetric(
            insertion: .offset(x: 0, y: emojiDefaultFontSize),
            removal: .offset(x: 0, y: -emojiDefaultFontSize))
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
