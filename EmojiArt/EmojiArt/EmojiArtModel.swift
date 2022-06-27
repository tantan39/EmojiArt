//
//  EmojiArtModel.swift
//  EmojiArt
//
//  Created by Tan Tan on 6/27/22.
//

import Foundation

struct EmojiArtModel {
    let background: Background = .bank
    var emojis: [Emoji] = []
    
    init() {}
    
    private var uniqueEmojiId: Int = 0
    
    mutating func addEmoji(text: String, at location: (x: Int, y: Int), size: Int) {
        uniqueEmojiId += 1
        let emoji = Emoji(text: text, x: location.x, y: location.y, size: size, id: uniqueEmojiId)
        emojis.append(emoji)
    }
    
    struct Emoji: Identifiable {
        let text: String
        let x: Int
        let y: Int
        let size: Int
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
