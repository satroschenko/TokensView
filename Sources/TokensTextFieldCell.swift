//
//  TokensTextFieldCell.swift
//  TokensView
//
//  Created by Sergey Atroschenko on 18.04.22.
//  Copyright © 2022 TokensView. All rights reserved.
//

import Cocoa

class TokensTextFieldCell: NSTextFieldCell {
    
    private var textStorage: NSTextStorage?
    private var initialWidth: CGFloat = 280
    private var latestSize: CGSize = .zero
    
    init() {
        super.init(textCell: "")
        self.allowsEditingTextAttributes = true
        self.wraps = true
    }
    
    required init(coder: NSCoder) {
        super.init(coder: coder)
        self.allowsEditingTextAttributes = true
        self.wraps = true
    }
    
    public override func setUpFieldEditorAttributes(_ textObj: NSText) -> NSText {
        super.setUpFieldEditorAttributes(textObj)
        initialWidth = self.controlView?.bounds.width ?? initialWidth
        guard let textView = super.setUpFieldEditorAttributes(textObj) as? NSTextView else { return textObj }
        let layoutManager = textView.textContainer?.layoutManager
        self.textStorage = layoutManager?.textStorage
        return textView
    }
    
    override func endEditing(_ textObj: NSText) {
        super.endEditing(textObj)
        self.textStorage = nil
    }
    
    override func cellSize(forBounds rect: NSRect) -> NSSize {
        guard let textStorage = textStorage else { return latestSize }
        let textSize = textStorage.mutableString.size(withAttributes: [.font:  defaultFont()])
        let range = NSRange(location: 0, length: textStorage.length)
        
        var currentWidth: CGFloat = 0.0
        var currentHeight: CGFloat = textSize.height + 4
        
        textStorage.enumerateAttribute(.attachment, in: range) { object, range, _ in
            if let attachment = object as? NSTextAttachment {
                let attachmentSize = attachment.attachmentCell?.cellSize() ?? .zero
                if currentWidth + attachmentSize.width > initialWidth {
                    currentWidth = (attachmentSize.width + 2)
                    currentHeight += (attachmentSize.height + 2)
                } else {
                    currentWidth += (attachmentSize.width + 2)
                }
            }
        }
        
        if currentWidth + textSize.width > initialWidth {
            currentWidth = textSize.width
            currentHeight += textSize.height
        } else {
            currentWidth += textSize.width
        }
        currentWidth = initialWidth
        currentHeight = max(currentHeight, 20)
        
        latestSize = NSSize(width: currentWidth, height: currentHeight)
        return latestSize
    }
    
    func removeAllTextExceptTokens() {
        
        guard let storage = textStorage else { return }
        let text = storage.string
        storage.beginEditing()
        for char in text {
            if "\(char)" == TokenUtils.replacementSymbol { continue }
            let range = storage.mutableString.range(of: "\(char)")
            if range.location != NSNotFound {
                storage.replaceCharacters(in: range, with: "")
            }
        }
        storage.endEditing()
    }
    
    func addAtachment(_ attachment: NSTextAttachment) {
        guard let storage = textStorage else { return }
        let newString = NSMutableAttributedString(attachment: attachment)
        newString.addAttributes([
            .font: defaultFont(),
            .foregroundColor: NSColor.textColor
        ], range: NSRange(location: 0, length: newString.length))
        storage.beginEditing()
        storage.append(newString)
        storage.endEditing()
    }
    
    func existingTokens() -> Set<Token> {
        guard let storage = textStorage else { return [] }
        let range = NSRange(location: 0, length: storage.length)
        var result = Set<Token>()
        storage.enumerateAttribute(.attachment, in: range) { object, range, _ in
            if let attachment = object as? NSTextAttachment, let cell = attachment.attachmentCell as? TokenAttachmentCell {
                result.insert(cell.token)
            }
        }
        return result
    }
    
    private func defaultFont() -> NSFont {
        return (self.controlView as? NSTextField)?.font ?? TokenUtils.defaultFont()
    }
}

