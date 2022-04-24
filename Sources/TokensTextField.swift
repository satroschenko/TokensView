//
//  TokensTextField.swift
//  TokensView
//
//  Created by Sergey Atroschenko on 18.04.22.
//  Copyright © 2022 TokensView. All rights reserved.
//

import Cocoa

public protocol TokensTextFieldDelegate: AnyObject {
    func tokensTextField(_ textField: TokensTextField, textChanged text: String, tokens: Set<Token>)
    func tokenFor(title: String) -> Token?
    func tokensTextField(_ textField: TokensTextField, tokensChanged tokens: Set<Token>)
}

// Default implementation.
extension TokensTextFieldDelegate {
    func tokensTextField(_ textField: TokensTextField, textChanged text: String, tokens: Set<Token>) {}
    func tokenFor(title: String) -> Token? { return nil }
    func tokensTextField(_ textField: TokensTextField, tokensChanged tokens: Set<Token>) {}
}

public class TokensTextField: NSTextField {
        
    weak var tokensDelegate: TokensTextFieldDelegate?
    private var currentTokens = Set<Token>()
    
    init() {
        super.init(frame: .zero)
        configure()
    }
    
    required public init?(coder: NSCoder) {
        super.init(coder: coder)
        configure()
    }
    
    public override var intrinsicContentSize: NSSize {
        let size = sizeThatFits(NSSize(width: self.frame.width, height: CGFloat.greatestFiniteMagnitude))
        return size
    }
    
    public override func textDidChange(_ notification: Notification) {
        super.textDidChange(notification)
        self.invalidateIntrinsicContentSize()
    }
    
    public override class var cellClass: AnyClass? {
        get {
            return TokensTextFieldCell.self
        }
        set {
            super.cellClass = newValue
        }
    }
    
    public func newTokenRequested() {
        addNewTokenFromCurrentText()
    }
    
    public func addTokenRequested(_ token: Token) {
        addNewToken(token)
    }
    
    public func existingTokens() -> Set<Token> {
        return tokenCell()?.existingTokens() ?? []
    }
}


private extension TokensTextField {
    
    func configure() {
        self.delegate = self
        let fieldCell = TokensTextFieldCell()
        self.cell = fieldCell
        self.isBordered = true
        self.textColor = NSColor.textColor
    }
    
    func tokenCell() -> TokensTextFieldCell? {
        return self.cell as? TokensTextFieldCell
    }
    
    func addNewTokenFromCurrentText() {
        let text = currentText()
        guard text.count > 0 else { return }
        guard let token = tokensDelegate?.tokenFor(title: text) else { return }
        
        tokenCell()?.removeAllTextExceptTokens()
        if !existingTokens().contains(token) {

            let attachment = NSTextAttachment(data: nil, ofType: nil)
            
            let newCell =  TokenAttachmentCell(token: token)
            attachment.image?.size = newCell.cellSize()
            attachment.attachmentCell = newCell
            newCell.attachment = attachment
            tokenCell()?.addAtachment(attachment)
        }
        
        currentTokens = existingTokens()
        tokensDelegate?.tokensTextField(self, textChanged: currentText(), tokens: currentTokens)
        tokensDelegate?.tokensTextField(self, tokensChanged: currentTokens)
    }
    
    func addNewToken(_ token: Token) {
        guard !existingTokens().contains(token) else { return }
        let text = currentText()
        if token.title == text {
            addNewTokenFromCurrentText()
            return
        }
        
        let attachment = NSTextAttachment(data: nil, ofType: nil)
        let newCell =  TokenAttachmentCell(token: token)
        attachment.attachmentCell = newCell
        newCell.attachment = attachment
                
        tokenCell()?.removeAllTextExceptTokens()
        tokenCell()?.addAtachment(attachment)

        currentTokens = existingTokens()
        tokensDelegate?.tokensTextField(self, textChanged: currentText(), tokens: currentTokens)
        tokensDelegate?.tokensTextField(self, tokensChanged: currentTokens)
    }
}

extension TokensTextField: NSTextFieldDelegate {
    
    public func controlTextDidChange(_ obj: Notification) {
        tokensDelegate?.tokensTextField(self, textChanged: currentText(), tokens: existingTokens())
        if currentTokens != existingTokens() {
            currentTokens = existingTokens()
            tokensDelegate?.tokensTextField(self, tokensChanged: currentTokens)
        }
    }
    
    public func control(_ control: NSControl, textView: NSTextView, doCommandBy commandSelector: Selector) -> Bool {
        
        if commandSelector == #selector(NSResponder.insertNewline(_:)) {
            addNewTokenFromCurrentText()
            return true
        }
        if commandSelector == #selector(NSResponder.insertTab(_:)) {
            return true
        }
        return false
    }
    
    public func textView(_ textView: NSTextView,
                         clickedOn cell: NSTextAttachmentCellProtocol,
                         in cellFrame: NSRect,
                         at charIndex: Int) {
        textView.setSelectedRange(NSRange(location: charIndex, length: 1))
    }
}

private extension TokensTextField {
    
    func currentText() -> String {
        let text = self.stringValue.replacingOccurrences(of: TokenUtils.replacementSymbol, with: "").trimmingCharacters(in: .whitespacesAndNewlines)
        return text
    }
}
