//
//  PaletteManagerView.swift
//  EmojiArt
//
//  Created by Tan Tan on 7/9/22.
//

import SwiftUI

struct PaletteManagerView: View {
    @EnvironmentObject var store: PaletteStore
    @State private var editMode: EditMode = .inactive
    
    var body: some View {
        NavigationView {
            List {
                ForEach(store.palettes) { palette in
                    NavigationLink(destination: PaletteEditor(palette: $store.palettes[palette])) {
                        VStack(alignment: .leading) {
                            Text(palette.name).font(editMode == .active ? .largeTitle : .caption)
                            Text(palette.emojis)
                        }
                    }
                }
                .onDelete { indexSet in
                    store.palettes.remove(atOffsets: indexSet)
                }
                .onMove { indexSet, newOffset in
                    store.palettes.move(fromOffsets: indexSet, toOffset: newOffset)
                }
            }
            .toolbar(content: {
                EditButton()
            })
            .navigationTitle("Manage Palletes")
            .navigationBarTitleDisplayMode(.inline)
            .environment(\.editMode, $editMode)
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
