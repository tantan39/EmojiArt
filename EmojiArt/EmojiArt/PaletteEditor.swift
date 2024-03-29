//
//  PaletteEditor.swift
//  EmojiArt
//
//  Created by Tan Tan on 7/9/22.
//

import SwiftUI

struct PaletteEditor: View {
    @Binding var palette: Palette
    @State private var emojisToAdd: String = ""
    
    var body: some View {
        Form {
            nameSection
            addEmojisSection
            removeEmojisSection
        }
        .frame(minWidth: 300, minHeight: 350)
        .navigationTitle("Edit \(palette.name)")
    }
    
    var nameSection: some View {
        Section(header: Text("Name")) {
            TextField("Name", text: $palette.name)
        }
    }
    
    var addEmojisSection: some View {
        Section(header: Text("Add Emojis")) {
            TextField("", text: $emojisToAdd)
                .onChange(of: emojisToAdd) { emojis in
                    addEmojis(emojis)
                }
        }
    }
    
    var removeEmojisSection: some View {
        Section {
            let emojis = palette.emojis.removeDuplicateCharacters().map { String($0) }
            LazyVGrid (columns: [GridItem(.adaptive(minimum: 40))]) {
                ForEach (emojis, id: \.self) { emoji in
                    Text(emoji)
                        .onTapGesture {
                            withAnimation {
                                palette.emojis.removeAll(where: { String($0) == emoji })
                            }
                        }
                }
            }
            
        } header: {
            Text("Remove Emojis")
        }

    }
    
    private func addEmojis(_ emojis: String) {
        withAnimation {
            palette.emojis = (emojis + palette.emojis)
                .filter({ $0.isEmoji })
                .removeDuplicateCharacters()
        }
    }
}

struct PaletteEditor_Previews: PreviewProvider {
    static var previews: some View {
        PaletteEditor(palette: .constant(PaletteStore(name: "Preview").palette(at: 4)))
            .previewLayout(.fixed(width: 300, height: 350))
    }
}
