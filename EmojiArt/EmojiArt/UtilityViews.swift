//
//  UtilityViews.swift
//  EmojiArt
//
//  Created by Tan Tan on 7/1/22.
//

import Foundation
import SwiftUI

struct OptionalImage: View {
    var uiImage: UIImage?
    
    var body: some View {
        if let image = uiImage {
            Image(uiImage: image)
        }
    }
}
