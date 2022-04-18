//
//  TokenUtils.swift
//  TokensView
//
//  Created by Sergey Atroschenko on 18.04.22.
//  Copyright © 2022 TokensView. All rights reserved.
//

import Cocoa


public class TokenUtils {
    public static let replacementSymbol = "\u{fffc}"

    public static func defaultFont() -> NSFont {
        if #available(macOS 11.0, *) {
            return NSFont.preferredFont(forTextStyle: .body)
        } else {
            return NSFont.systemFont(ofSize: 12)
        }
    }
}


extension NSColor {

    convenience init(hexString: String) {
        
        var hex: String = hexString
        if hexString.hasPrefix("#") {
            hex = String(hexString.dropFirst())
        }
        
        hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int = UInt64()
        Scanner(string: hex).scanHexInt64(&int)
        let aValue, rValue, gValue, bValue: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (aValue, rValue, gValue, bValue) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (aValue, rValue, gValue, bValue) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (aValue, rValue, gValue, bValue) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (aValue, rValue, gValue, bValue) = (255, 0, 0, 0)
        }
        self.init(red: CGFloat(rValue) / 255, green: CGFloat(gValue) / 255, blue: CGFloat(bValue) / 255, alpha: CGFloat(aValue) / 255)
    }
    
    func toHexString() -> String {
        guard let rgbColor = self.usingColorSpace(.deviceRGB) else { return "" }
        var r: CGFloat = 0
        var g: CGFloat = 0
        var b: CGFloat = 0
        var a: CGFloat = 0
        rgbColor.getRed(&r, green: &g, blue: &b, alpha: &a)
        let rgb: Int = (Int)(r*255)<<16 | (Int)(g*255)<<8 | (Int)(b*255)<<0
        return String(format: "#%06x", rgb)
    }

    func toCircleImage(size: NSSize) -> NSImage {
        let image = NSImage(size: size)
        image.lockFocus()
        let innerRect = NSInsetRect(NSRect(origin: .zero, size: size), 4, 4)
        let path = NSBezierPath(ovalIn: innerRect)
        self.setFill()
        path.fill()
        image.unlockFocus()
        return image
    }
}
