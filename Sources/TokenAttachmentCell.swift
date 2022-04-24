//
//  TokenAttachmentCell.swift
//  TokensView
//
//  Created by Sergey Atroschenko on 18.04.22.
//  Copyright © 2022 TokensView. All rights reserved.
//

import Cocoa

public enum TokensDrawingMode {
    case `default`
    case selected

    func strokeColor() -> NSColor {
        switch self {
        case .default:
            return NSColor.controlTextColor
        case .selected:
            return NSColor.alternateSelectedControlTextColor
        }
    }
    
    func fillColor(for token: Token) -> NSColor {
        switch self {
        case .default:
            return NSColor(hexString: token.hexString)
        case .selected:
            return NSColor.selectedControlColor
        }
    }
}

public class TokenAttachmentCell: NSTextAttachmentCell {
    
    private static var attachmentCellMargin: CGFloat = 5.0
    private var drawingMode: TokensDrawingMode = .default
    
    public var token: Token
    
    public init(token: Token) {
        self.token = token
        super.init()
    }
    
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override func cellBaselineOffset() -> NSPoint {
        return NSPoint(x: 0.0, y: self.defaultFont().descender)
    }
    
    private func defaultFont() -> NSFont {
        return self.font ?? TokenUtils.defaultFont()
    }
    
    public override func cellSize() -> NSSize {
        let size = self.stringValue.size(withAttributes: [.font: self.defaultFont()])
        return self.cellSizeFor(titleSize: size)
    }
    
    public override var stringValue: String {
        get {
            return self.token.title
        }
        set {
            self.stringValue = newValue
        }
    }
    
    func cellSizeFor(titleSize: NSSize) -> NSSize {
        let newSize = NSSize(width: titleSize.width + 10, height: titleSize.height)
        let rect = NSRect(origin: .zero, size: newSize)
        return NSIntegralRect(rect).size;
    }

    public override func draw(withFrame cellFrame: NSRect, in controlView: NSView?, characterIndex charIndex: Int, layoutManager: NSLayoutManager) {
        drawingMode = .default
        
        if let textView = controlView as? NSTextView {
            for rangeValue in textView.selectedRanges {
                
                let range = rangeValue.rangeValue;
                if !NSLocationInRange(charIndex, range) { continue }
                if controlView?.window?.isKeyWindow ?? false {
                    self.drawingMode = .selected
                }
            }
        }

        self.drawToken(withFrame: cellFrame, in: controlView)
    }
    
    public override func draw(withFrame cellFrame: NSRect, in controlView: NSView?) {
        self.draw(withFrame: cellFrame,
                  in: controlView,
                  characterIndex: NSNotFound,
                  layoutManager: currentLayoutManager())
    }
    
    public override func drawInterior(withFrame cellFrame: NSRect, in controlView: NSView) {
        self.draw(withFrame: cellFrame,
                  in: controlView,
                  characterIndex: NSNotFound,
                  layoutManager: currentLayoutManager())
        
    }
    
    public func drawToken(withFrame cellFrame: NSRect, in controlView: NSView?) {
        
        NSGraphicsContext.current?.saveGraphicsState()

        let path = self.tokenPath(for: cellFrame)
        path.addClip()
        
        drawingMode.fillColor(for: token).setFill()
        path.fill()
        drawingMode.strokeColor().setStroke()
        path.stroke()

        let titleRect: CGRect = NSInsetRect(cellFrame, 5, 0)
        self.drawTitle(withFrame: titleRect, in: controlView)
        NSGraphicsContext.current?.restoreGraphicsState()
    }

    public func drawTitle(withFrame cellFrame: NSRect, in controlView: NSView?) {
        
        let style = NSMutableParagraphStyle()
        style.lineBreakMode = .byTruncatingTail
        self.stringValue.draw(in: cellFrame, withAttributes: [
            .font: self.defaultFont(),
            .foregroundColor: NSColor.white,
            .paragraphStyle: style
        ])
    }
}


private extension TokenAttachmentCell {
    
    func currentLayoutManager() -> NSLayoutManager {
        let newManager = NSLayoutManager()
        if let view = controlView as? NSTextView {
            return view.layoutManager ?? newManager
        }
        return newManager
    }
    
    func tokenPath(for rect: NSRect) -> NSBezierPath {
        
        let radius: CGFloat = 3
        let innerRect: CGRect = NSInsetRect(rect, 2, 1)
        
        let path = NSBezierPath()
        path.move(to: NSPoint(x: innerRect.minX + radius, y: innerRect.minY))
        path.line(to: NSPoint(x: innerRect.maxX - radius, y: innerRect.minY))
        path.appendArc(withCenter: CGPoint(x: innerRect.maxX - radius, y: innerRect.minY + radius), radius: radius, startAngle: -90, endAngle: 0, clockwise: false)
        path.line(to: NSPoint(x: innerRect.maxX, y: innerRect.maxY - radius))
        path.appendArc(withCenter: CGPoint(x: innerRect.maxX - radius, y: innerRect.maxY - radius), radius: radius, startAngle: 0, endAngle: 90, clockwise: false)
        path.line(to: NSPoint(x: innerRect.minX + radius, y: innerRect.maxY))
        path.appendArc(withCenter: CGPoint(x: innerRect.minX + radius, y: innerRect.maxY - radius), radius: radius, startAngle: 90, endAngle: 180, clockwise: false)
        path.line(to: NSPoint(x: innerRect.minX, y: innerRect.minY + radius))
        path.appendArc(withCenter: CGPoint(x: innerRect.minX + radius, y: innerRect.minY + radius), radius: radius, startAngle: 180, endAngle: 260, clockwise: false)

        path.close()

        path.lineWidth = 1.0
        
        return path
    }
}

