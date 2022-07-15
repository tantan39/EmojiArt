//
//  Camera.swift
//  EmojiArt
//
//  Created by Tan Tan on 7/15/22.
//

import Foundation
import SwiftUI

struct Camera: UIViewControllerRepresentable {
    
    typealias UIViewControllerType = UIImagePickerController
    
    var handlePickedImage: (UIImage?) -> Void
    
    static var isAvailable: Bool {
        UIImagePickerController.isSourceTypeAvailable(.camera)
    }
    
    func makeUIViewController(context: Context) -> UIImagePickerController {
        let pickerController = UIImagePickerController()
        pickerController.sourceType = .camera
        pickerController.allowsEditing = true
        pickerController.delegate = context.coordinator
        return pickerController
    }
    
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {
        
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(handlePickedImage: handlePickedImage)
    }
    
    class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        var handlePickedImage: (UIImage?) -> Void
        
        init(handlePickedImage: @escaping (UIImage?) -> Void) {
            self.handlePickedImage = handlePickedImage
        }
        
        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            handlePickedImage(nil)
        }
        
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            let image = info[.editedImage] ?? info[.originalImage]
            handlePickedImage(image as? UIImage)
        }
    }
}
