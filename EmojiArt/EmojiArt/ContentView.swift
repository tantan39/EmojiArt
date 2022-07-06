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
                        .scaleEffect(zoomScale)
                        .position(convertFromEmojiCoordinates((0,0), in: geometry))
                }
                .gesture(doubleTapToZoom(in: geometry.size))
                if viewModel.backgroundImageFetchStatus == .fetching {
                    ProgressView()
                } else {
                    ForEach(viewModel.emojis, id: \.id) { emoji in
                        Text(emoji.text)
                            .font(.system(size: fontSize(for: emoji)))
                            .scaleEffect(zoomScale)
                            .position(position(for: emoji, in: geometry))
                    }
                }
            }
            .clipped()
            .onDrop(of: [.plainText, .url, .image], isTargeted: nil) { providers, location in
                return drop(providers: providers, at: location, in: geometry)
            }
            .gesture(panGesture().simultaneously(with: zoomGesture()))
        }
    }
    
    private func drop(providers: [NSItemProvider], at location: CGPoint, in geometry: GeometryProxy) -> Bool {
        var found = providers.loadObjects(offType: URL.self) { url in
            viewModel.setBackground(.url(url.imageURL))
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
                                       size: emojiDefaultFontSize / zoomScale)
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
        let location = CGPoint(x: location.x - panOffset.width - center.x / zoomScale,
                               y: location.y - panOffset.height - center.y / zoomScale)
        return (Int(location.x), Int(location.y))
    }
    
    private func convertFromEmojiCoordinates(_ location: (x: Int, y: Int), in geometry: GeometryProxy) -> CGPoint {
        let center = geometry.frame(in: .local).center
        return CGPoint(x: center.x + CGFloat(location.x) * zoomScale + panOffset.width,
                       y: center.y + CGFloat(location.y) * zoomScale + panOffset.height)
    }
    
    private func fontSize(for emoji: EmojiArtModel.Emoji) -> CGFloat {
        CGFloat(emoji.size)
    }
    
    @State private var steadyStatePanOffset: CGSize = .zero
    @GestureState private var gesturePanOffset: CGSize = .zero
    
    private var panOffset: CGSize {
        (steadyStatePanOffset + gesturePanOffset) * zoomScale
    }
    
    private func panGesture() -> some Gesture {
        DragGesture()
            .updating($gesturePanOffset, body: { latestDragGestureValue, gesturePanOffset, transaction in
                gesturePanOffset = latestDragGestureValue.translation / zoomScale
            })
            .onEnded { finalDragGestureValue in
                steadyStatePanOffset = steadyStatePanOffset + (finalDragGestureValue.translation / zoomScale)
            }
    }
    
    private var zoomScale: CGFloat {
        steadyStateZoomScale * gestureZoomScale
    }
    
    @State private var steadyStateZoomScale: CGFloat = 1
    @GestureState private var gestureZoomScale: CGFloat = 1
    
    private func zoomGesture() -> some Gesture {
         MagnificationGesture()
            .updating($gestureZoomScale, body: { latestGestureScale, gestureZoomScale, transaction in
                gestureZoomScale = latestGestureScale
            })
            .onEnded { gestureScaleAtTheEnd in
                steadyStateZoomScale *= gestureScaleAtTheEnd
            }
    }
    
    private func doubleTapToZoom(in size: CGSize) -> some Gesture {
        TapGesture(count: 2)
            .onEnded {
                withAnimation {
                    zoomToFit(viewModel.backgroundImage, in: size)
                }
            }
    }
    
    private func zoomToFit(_ image: UIImage?, in size: CGSize) {
        guard let image = image, image.size.width > 0, image.size.height > 0, size.width > 0, size.height > 0  else { return }
        let hZoom = size.width / image.size.width
        let vZoom = size.height / image.size.height
        steadyStatePanOffset = .zero
        steadyStateZoomScale = min(hZoom, vZoom)
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
