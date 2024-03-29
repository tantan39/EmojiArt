//
//  ContentView.swift
//  EmojiArt
//
//  Created by Tan Tan on 6/27/22.
//

import SwiftUI

struct ContentView: View {
    @Environment(\.undoManager) var undoManager
    @ObservedObject var viewModel: EmojiArtDocument
    let emojiDefaultFontSize: CGFloat = 40
    @State private var alertToShow: IdentifiableAlert?
    @State private var autoZoom: Bool = false
    
    var body: some View {
        VStack(spacing: 0) {
            documentBodyView
            PaletteChooserView()
        }
    }
    
    var documentBodyView: some View {
        GeometryReader { geometry in
            ZStack {
                Color.white
                OptionalImage(uiImage: viewModel.backgroundImage)
                    .scaleEffect(zoomScale)
                    .position(convertFromEmojiCoordinates((0,0), in: geometry))
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
            .alert(item: $alertToShow) { alertToShow in
                alertToShow.alert()
            }
            .onChange(of: viewModel.backgroundImageFetchStatus) { newValue in
                switch newValue {
                case .failed(let url):
                    showBackgroundImageFetchFailedAlert(url)
                default:
                    break
                }
            }
            .onReceive(viewModel.$backgroundImage) { image in
                if autoZoom {
                    zoomToFit(image, in: geometry.size)
                }
            }
            .compactableToolbar {
                AnimateActionButton(title: "Paste Background", systemImage: "doc.on.clipboard") {
                    pasteBackground()
                }
                
                if Camera.isAvailable {
                    AnimateActionButton(title: "Camera", systemImage: "camera") {
                        
                    }
                }
                
                if let undoManager = undoManager {
                    if undoManager.canUndo {
                        AnimateActionButton(title: undoManager.undoActionName, systemImage: "arrow.uturn.backward") {
                            undoManager.undo()
                        }
                        
                    }
                    
                    if undoManager.canRedo {
                        AnimateActionButton(title: undoManager.redoActionName, systemImage: "arrow.uturn.forward") {
                            undoManager.redo()
                        }
                    }
                }
            }
            .sheet(item: $backgroundPicker) { picker in
                switch picker {
                case .camera:
                    Camera { image in
                        handlePickedBackgroundImage(image)
                    }
                case .library:
                    EmptyView()
                }
            }
        }
    }
    
    @State private var backgroundPicker: BackgroundPickerType?
    
    enum BackgroundPickerType: String, Identifiable {
        var id: String { rawValue }
        case camera
        case library
    }
    
    private func handlePickedBackgroundImage(_ image: UIImage?) {
        autoZoom = true
        if let imageData = image?.jpegData(compressionQuality: 1.0) {
            viewModel.setBackground(.imageData(imageData), undoManager: undoManager)
        }
        backgroundPicker = nil
    }
    
    private func pasteBackground() {
        if let imageData = UIPasteboard.general.image?.jpegData(compressionQuality: 1.0) {
            viewModel.setBackground(.imageData(imageData), undoManager: undoManager)
        } else if let url = UIPasteboard.general.url?.imageURL {
            viewModel.setBackground(.url(url), undoManager: undoManager)
        } else {
            alertToShow = IdentifiableAlert(id: "failed", alert: {
                Alert(title: Text("Paste Background"), message: Text("There is no image currently on pasteboard"), dismissButton: .default(Text("OK")))
            })
        }
    }
    
    private func showBackgroundImageFetchFailedAlert(_ url: URL) {
        alertToShow = IdentifiableAlert(id: "failed" + url.absoluteString, alert: {
            Alert(title: Text("Background Image Fetch"), message: Text("Couldn't load image \(url.absoluteString)"), dismissButton: .default(Text("OK")))
        })
    }
    
    private func drop(providers: [NSItemProvider], at location: CGPoint, in geometry: GeometryProxy) -> Bool {
        var found = providers.loadObjects(offType: URL.self) { url in
            autoZoom = true
            viewModel.setBackground(.url(url.imageURL), undoManager: undoManager)
        }
        
        if !found {
            found = providers.loadObjects(offType: UIImage.self) { image in
                if let data = image.jpegData(compressionQuality: 1) {
                    autoZoom = true
                    viewModel.setBackground(.imageData(data), undoManager: undoManager)
                }
            }
        }
        
        if !found {
            found = providers.loadObjects(offType: String.self) { string in
                if let emoji = string.first, emoji.isEmoji {
                    viewModel.addEmoji(String(emoji),
                                       at: convertToEmojiCoordinates(location, in: geometry),
                                       size: emojiDefaultFontSize / zoomScale,
                                       undoManager: undoManager)
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
    
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView(viewModel: EmojiArtDocument())
    }
}
