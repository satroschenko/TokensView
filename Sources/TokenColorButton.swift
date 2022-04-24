//
//  TokenColorButton.swift
//  TokensView
//
//  Created by Sergey Atroschenko on 18.04.22.
//  Copyright © 2022 TokensView. All rights reserved.
//

import Cocoa

public protocol TokenColorButtonDelegate: AnyObject {
    func stateChanged(_ button: TokenColorButton, selected: Bool)
}

public class TokenColorButton: NSButton {
    
    public weak var delegate: TokenColorButtonDelegate?
    public let color: NSColor
    
    private let borderColor = NSColor(hexString: "#F3F3F3")
    private var isMouseOver: Bool = false
    
    init(color: NSColor) {
        self.color = color
        super.init(frame: .zero)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)
        NSGraphicsContext.current?.saveGraphicsState()
        let hightlighted = isMouseOver || state == .on
        
        if hightlighted {
            let borderRect = NSInsetRect(dirtyRect, 1, 1)
            let borderPath = NSBezierPath(ovalIn: borderRect)
            self.borderColor.setFill()
            borderPath.fill()
        }
        
        let innerRect = NSInsetRect(dirtyRect, 3, 3)
        let innerPath = NSBezierPath(ovalIn: innerRect)
        self.color.setFill()
        innerPath.fill()
        
        if hightlighted {
            NSImage(named: "tick_icon")?.draw(in: NSInsetRect(innerRect, 2, 2))
        }
                
        NSGraphicsContext.current?.restoreGraphicsState()
    }
    
    public func didAddedToSuperview() {
        addTrakingArea()
    }
    
    public override func mouseEntered(with event: NSEvent) {
        super.mouseEntered(with: event)
        isMouseOver = true
        needsDisplay = true
    }
    
    public override func mouseExited(with event: NSEvent) {
        super.mouseExited(with: event)
        isMouseOver = false
        needsDisplay = true
    }
    
    @objc func click() {
        needsDisplay = true
        delegate?.stateChanged(self, selected: self.state == .on)
    }
}

private extension TokenColorButton {
    
    func setupUI() {
        self.title = ""
        self.isBordered = false
        self.setButtonType(.toggle)
        self.contentTintColor = NSColor.white
        self.action = #selector(click)
        self.target = self
    }
    
    func addTrakingArea() {
        let trakingArea = NSTrackingArea(rect: self.bounds,
                                         options: [.mouseEnteredAndExited, .activeAlways, .inVisibleRect],
                                         owner: self,
                                         userInfo: nil)
        self.addTrackingArea(trakingArea)
    }
}

