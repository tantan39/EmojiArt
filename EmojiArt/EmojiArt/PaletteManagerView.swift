//
//  PaletteManagerView.swift
//  EmojiArt
//
//  Created by Tan Tan on 7/9/22.
//

import SwiftUI

struct PaletteManagerView: View {
    @EnvironmentObject var store: PaletteStore
    
    var body: some View {
        NavigationView {
            List {
                ForEach(store.palettes) { palette in
                    NavigationLink(destination: PaletteEditor(palette: $store.palettes[palette])) {
                        VStack(alignment: .leading) {
                            Text(palette.name)
                            Text(palette.emojis)
                        }
                    }
                }
            }
            .navigationTitle("Manage Palletes")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

struct PaletteManagerView_Previews: PreviewProvider {
    static var previews: some View {
        PaletteManagerView()
            .previewDevice("iPhone 13 Pro Max")
            .environmentObject(PaletteStore(name: "Preview"))
    }
}
