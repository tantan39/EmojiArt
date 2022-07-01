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
                Color.white.overlay {
                    OptionalImage(uiImage: viewModel.backgroundImage)
                        .position(convertFromEmojiCoordinates((0,0), in: geometry))
                }
                if viewModel.backgroundImageFetchStatus == .fetching {
                    ProgressView()
                } else {
                    ForEach(viewModel.emojis, id: \.id) { emoji in
                        Text(emoji.text)
                            .font(.system(size: fontSize(for: emoji)))
                            .position(position(for: emoji, in: geometry))
                    }
                }
            }
            .onDrop(of: [.plainText, .url, .image], isTargeted: nil) { providers, location in
                return drop(providers: providers, at: location, in: geometry)
            }
        }
    }
    
    private func drop(providers: [NSItemProvider], at location: CGPoint, in geometry: GeometryProxy) -> Bool {
        var found = providers.loadObjects(offType: URL.self) { url in
            viewModel.setBackground(.url(url))
        }
        
        if !found {
            found = providers.loadObjects(offType: UIImage.self) { image in
                if let data = image.jpegData(compressionQuality: 1) {
                    viewModel.setBackground(.imageData(data))
                }
            }
        }
        
        if !found {
            found = providers.loadObjects(offType: String.self) { string in
                if let emoji = string.first, emoji.isEmoji {
                    viewModel.addEmoji(String(emoji),
                                       at: convertToEmojiCoordinates(location, in: geometry),
                                       size: emojiDefaultFontSize)
                }
            }
        }
        
        return found
    }
    
    private func position(for emoji: EmojiArtModel.Emoji, in geometry: GeometryProxy) -> CGPoint {
        convertFromEmojiCoordinates((emoji.x, emoji.y), in: geometry)
    }
    
    private func convertToEmojiCoordinates(_ location: CGPoint, in geometry: GeometryProxy) -> (x: Int, y: Int) {
        let center = geometry.frame(in: .local).center
        let location = CGPoint(x: location.x - center.x, y: location.y - center.y)
        return (Int(location.x), Int(location.y))
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
                        .onDrag {
                            return NSItemProvider(object: emoji as NSString)
                        }
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
