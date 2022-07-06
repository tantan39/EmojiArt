//
//  EmojiArtModel.swift
//  EmojiArt
//
//  Created by Tan Tan on 6/27/22.
//

import Foundation

struct EmojiArtModel: Codable {
    var background: Background = .bank
    var emojis: [Emoji] = []
    
    init(json: Data) throws {
        self = try JSONDecoder().decode(EmojiArtModel.self, from: json)
    }
    
    init(url: URL) throws {
        let data = try Data(contentsOf: url)
        try self.init(json: data)
    }
    
    init() {}
    
    private var uniqueEmojiId: Int = 0
    
    mutating func addEmoji(text: String, at location: (x: Int, y: Int), size: Int) {
        uniqueEmojiId += 1
        let emoji = Emoji(text: text, x: location.x, y: location.y, size: size, id: uniqueEmojiId)
        emojis.append(emoji)
    }
    
    func json() throws -> Data {
        return try JSONEncoder().encode(self)
    }
    
    struct Emoji: Identifiable, Codable {
        let text: String
        var x: Int
        var y: Int
        var size: Int
        let id: Int
        
        fileprivate init(text: String, x: Int, y: Int, size: Int, id: Int) {
            self.text = text
            self.x = x
            self.y = y
            self.size = size
            self.id = id
        }
    }
}
