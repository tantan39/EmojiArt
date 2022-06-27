//
//  EmojiArtModel.swift
//  EmojiArt
//
//  Created by Tan Tan on 6/27/22.
//

import Foundation

struct EmojiArtModel {
    let background: Background
    let emojis: [Emoji] = []
    
    struct Emoji {
        let text: String
        let x: Double
        let y: Double
    }
    
    enum Background {
        case bank
        case url(URL)
        case imageData(Data)
        
        var url: URL? {
            switch self {
            case .url(let uRL):
                return uRL
            default:
                return nil
            }
        }
        
        var imageData: Data? {
            switch self {
            case .imageData(let data):
                return data
            default:
                return nil
            }
        }
    }
}
