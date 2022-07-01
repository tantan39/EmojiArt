//
//  Background.swift
//  EmojiArt
//
//  Created by Tan Tan on 6/27/22.
//

import Foundation

extension EmojiArtModel {
    enum Background: Equatable {
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
