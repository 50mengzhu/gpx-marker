//
//  NSImage.swift
//  gpx marker
//
//  Created by mica dai on 2024/11/20.
//
#if os(iOS)
import UIKit
typealias PlatformImage = UIImage
#elseif os(macOS)
import AppKit
typealias PlatformImage = NSImage
#endif


#if os(macOS)
import AppKit

extension NSImage {
    func colored(with color: NSColor) -> NSImage {
        let image = self.copy() as! NSImage
        image.lockFocus()
        color.set()
        let rect = NSRect(origin: .zero, size: image.size)
        rect.fill(using: .sourceAtop)
        image.unlockFocus()
        return image
    }
    
    func toUIImage() -> PlatformImage? {
        guard let tiffData = self.tiffRepresentation,
              let bitmap = NSBitmapImageRep(data: tiffData),
              let data = bitmap.representation(using: .png, properties: [:]) else {
            return nil
        }
        return PlatformImage(data: data)
    }
}
#endif
