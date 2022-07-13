//
//  EmojiArtDocument.swift
//  EmojiArt
//
//  Created by Tan Tan on 6/27/22.
//

import SwiftUI
import Combine
import UniformTypeIdentifiers

enum BackgroundFetchStatus: Equatable {
    case fetching
    case idle
    case failed(URL)
}

extension UTType {
    static let emojiart = UTType(exportedAs: "com.tantran.emojiart")
}

class EmojiArtDocument: ReferenceFileDocument {
    static var readableContentTypes: [UTType] = [UTType.emojiart]
    static var writeableContentTypes: [UTType] = [UTType.emojiart]
    
    required init(configuration: ReadConfiguration) throws {
        if let data = configuration.file.regularFileContents {
            emojiArt = try EmojiArtModel(json: data)
        } else {
            throw CocoaError.init(.fileReadCorruptFile)
        }
    }
    
    func snapshot(contentType: UTType) throws -> Data {
        try emojiArt.json()
    }
    
    func fileWrapper(snapshot: Data, configuration: WriteConfiguration) throws -> FileWrapper {
        FileWrapper(regularFileWithContents: snapshot)
    }
        
    @Published private(set) var emojiArt: EmojiArtModel {
        didSet {
            scheduleAutoSave()
            if emojiArt.background != oldValue.background {
                fetchBackgroundImage()
            }
        }
    }
    @Published var backgroundImage: UIImage?
    @Published var backgroundImageFetchStatus: BackgroundFetchStatus = .idle
    private var cancellable: AnyCancellable?
    
    init() {
        if let url = AutoSave.url, let autoSaveEmoji = try? EmojiArtModel(url: url) {
            emojiArt = autoSaveEmoji
            fetchBackgroundImage()
        } else {
            emojiArt = EmojiArtModel()
        }
//        emojiArt.addEmoji(text: "☺️", at: (-200, 100), size: 40)
//        emojiArt.addEmoji(text: "🍎", at: (50, 100), size: 80)
    }
    
    var emojis: [EmojiArtModel.Emoji] {
        emojiArt.emojis
    }
    
    var background: EmojiArtModel.Background {
        emojiArt.background
    }
    
    private struct AutoSave {
        static let fileName = "AutoSaved.EmojiArt"
        static var url: URL? {
            let documentDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first
            return documentDirectory?.appendingPathComponent(fileName)
        }
        static let coalescingInterval = 5.0
    }
    
    private var timer: Timer?
    private func scheduleAutoSave() {
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: AutoSave.coalescingInterval, repeats: false) { _ in
            self.autoSave()
        }
    }
    
    private func autoSave() {
        if let url = AutoSave.url {
            save(url: url)
        }
    }
    
    func save(url: URL) {
        let thisFunction = "\(String(describing: self)).\(#function)"
        do {
            let data: Data = try emojiArt.json()
            print("\(thisFunction) json = \(String(data: data, encoding: .utf8) ?? "")")
            try data.write(to: url)
            print("\(thisFunction) success!")
        } catch let encodingError where encodingError is EncodingError {
            print("\(thisFunction) couldn't encode because \(encodingError.localizedDescription)")
        } catch {
            print("\(thisFunction): \(error)")
        }
    }
    
    // MARK: - Intend(s)
    private func fetchBackgroundImage() {
        backgroundImage = nil
        switch emojiArt.background {
        case .url(let url):
            self.backgroundImageFetchStatus = .fetching
            cancellable?.cancel()
            let session = URLSession.shared
            cancellable = session.dataTaskPublisher(for: url)
                .map { (data, _) in
                    UIImage(data: data)
                }
                .replaceError(with: nil)
                .receive(on: DispatchQueue.main, options: .none)
                .sink { [weak self] image in
                    self?.backgroundImageFetchStatus = image != nil ? .idle : .failed(url)
                    self?.backgroundImage = image
                }
            
//            DispatchQueue.global(qos: .userInitiated).async {
//                let imageData = try? Data(contentsOf: url)
//                DispatchQueue.main.async { [weak self] in
//                    if self?.emojiArt.background == EmojiArtModel.Background.url(url) {
//                        self?.backgroundImageFetchStatus = .idle
//                        if let imageData = imageData {
//                            self?.backgroundImage = UIImage(data: imageData)
//                        }
//                        if self?.backgroundImage == nil {
//                            self?.backgroundImageFetchStatus = .failed(url)
//                        }
//                    }
//                }
//            }
            
        case .imageData(let data):
            self.backgroundImage = UIImage(data: data)
        default:
            break
        }
    }
    
    func setBackground(_ background: EmojiArtModel.Background) {
        emojiArt.background = background
    }
    
    func addEmoji(_ emoji: String, at location: (x: Int, y: Int), size: CGFloat) {
        emojiArt.addEmoji(text: emoji, at: location, size: Int(size))
    }
    
    func moveEmoji(_ emoji: EmojiArtModel.Emoji, by offset: CGSize) {
        if let index = emojiArt.emojis.index(matching: emoji) {
            emojiArt.emojis[index].x += Int(offset.width)
            emojiArt.emojis[index].y += Int(offset.height)
        }
    }
    
    func scaleEmoji(_ emoji: EmojiArtModel.Emoji, by scale: CGFloat) {
        if let index = emojiArt.emojis.index(matching: emoji) {
            emojiArt.emojis[index].size = Int((CGFloat(emojiArt.emojis[index].size) * scale).rounded(.toNearestOrAwayFromZero))
        }
    }
    
}
