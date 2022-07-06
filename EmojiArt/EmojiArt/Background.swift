//
//  Background.swift
//  EmojiArt
//
//  Created by Tan Tan on 6/27/22.
//

import Foundation

extension EmojiArtModel {
    enum Background: Equatable, Codable {
        case bank
        case url(URL)
        case imageData(Data)
        
        enum CodingKeys: String, CodingKey {
            case url = "theURL"
            case imageData
        }
        
        init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            if let url = try? container.decode(URL.self, forKey: .url) {
                self = .url(url)
            } else if let imageData = try? container.decode(Data.self, forKey: .imageData) {
                self = .imageData(imageData)
            } else {
                self = .bank
            }
        }
        
        func encode(to encoder: Encoder) throws {
            var container = encoder.container(keyedBy: CodingKeys.self)
            switch self {
            case .bank:
                break
            case .url(let uRL):
                try container.encode(uRL, forKey: .url)
            case .imageData(let data):
                try container.encode(data, forKey: .imageData)
            }
        }
        
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
