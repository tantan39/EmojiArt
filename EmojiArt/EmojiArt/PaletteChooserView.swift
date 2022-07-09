//
//  PaletteChooserView.swift
//  EmojiArt
//
//  Created by Tan Tan on 7/8/22.
//

import SwiftUI


struct PaletteChooserView: View {
    let emojiDefaultFontSize: CGFloat = 40
    
    var body: some View {
            ScrollingEmojisView(emojis: testEmoji)
                .font(.system(size: emojiDefaultFontSize))
    }
    
    var testEmoji = "😀😆😜🤒🤕🤧💀☠️👻😈👹👺🐞🪲🕷🐶🐼🐸🍄☘️🌻🍏🍎🍉🥝🌭🍔🍕🍞🍼🍺🍾⏱🔌💡🕯"
}

struct PaletteChooserView_Previews: PreviewProvider {
    static var previews: some View {
        PaletteChooserView()
    }
}
