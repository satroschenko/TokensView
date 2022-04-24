//
//  TokensView.swift
//  TokensView
//
//  Created by Sergey Atroschenko on 18.04.22.
//  Copyright © 2022 TokensView. All rights reserved.
//

import Cocoa

public protocol TokensViewDataSource: AnyObject {
    // Optional method.
    // Return list of colors for tokens.
    // If method returns `nil` or `empty` array - the default list will be used.
    func colorListFor(tokensView: TokensView) -> [NSColor]?
    
    // Optional method.
    // Return title for `TokensView`
    // If method returns `nil` - the default value will be used.
    func titleFor(tokensView: TokensView) -> String?
    
    // Return list of existing tokens to show suggested list.
    // This method calls multiple times.
    func availableTokensFor(tokensView: TokensView) -> Set<Token>
    
    // Return list of initial tokens to prefill text field.
    func initialTokensFor(tokensView: TokensView) -> Set<Token>
}

public protocol TokensViewDelegate: AnyObject {
    func tokenView(_ tokenView: TokensView, tokensChahged tokens: Set<Token>)
}

public protocol TokensViewSizeDelegate: AnyObject {
    func contentSizeChangedFor(tokensView: TokensView)
}

extension TokensViewDataSource {
    // Default implementation.
    public func colorListFor(tokensView: TokensView) -> [NSColor]? { return nil }
    public func titleFor(tokensView: TokensView) -> String? { return nil }
}

extension TokensViewSizeDelegate {
    // Default implementation.
    func contentSizeChangedFor(tokensView: TokensView) {}
}

public class TokensView: NSView {
    
    enum State {
        case initial
        case newToken
        case existingToken
    }
    
    private var state: State = .initial { didSet { updateViewsVisibility() } }
    
    public weak var dataSource: TokensViewDataSource?
    public weak var delegate: TokensViewDelegate?
    
    public weak var sizeDelegate: TokensViewSizeDelegate?    
    
    public var titleLabel: NSTextField = {
        let textField = NSTextField()
        textField.isEditable = false
        textField.drawsBackground = false
        textField.alignment = .center
        textField.isBezeled = false
        textField.isSelectable = false
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.stringValue = "Assing Tags to ..."
        if #available(macOS 11.0, *) {
            textField.font = NSFont.preferredFont(forTextStyle: .headline)
        } else {
            textField.font = NSFont.systemFont(ofSize: 14)
        }
        
        return textField
    }()
    
    public var colorPickerView: TokensColorPickerView = {
        let view = TokensColorPickerView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    public var tokensListView: TokensListView = {
        let view = TokensListView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    public var textField: TokensTextField = {
        let textField = TokensTextField()
        textField.isEditable = true
        textField.font = TokenUtils.defaultFont()
        textField.stringValue = ""
        textField.translatesAutoresizingMaskIntoConstraints = false
        
        return textField
    }()
    
    public var contentView: NSView = {
        let view = NSView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    public override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        setupUI()
    }
    
    public required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
    }
    
    public func willShowView() {
        if let colors = dataSource?.colorListFor(tokensView: self), colors.count > 0 {
            colorPickerView.setColors(colors)
        }
        
        if let title = dataSource?.titleFor(tokensView: self) {
            titleLabel.stringValue = title
        }
        
        if let tokens = dataSource?.availableTokensFor(tokensView: self) {
            tokensListView.setTokens(tokens.subtracting(textField.existingTokens()))
        }
    }
    
    public func didShowView() {
        if let initialTokens = dataSource?.initialTokensFor(tokensView: self) {
            initialTokens.forEach({textField.addTokenRequested($0)})
        }
    }
}


private extension TokensView {
    
    func setupUI() {
        self.addSubview(titleLabel)
        self.addSubview(textField)
        self.addSubview(contentView)
        
        textField.tokensDelegate = self
        colorPickerView.delegate = self
        tokensListView.delegate = self
                
        NSLayoutConstraint.activate([
            self.widthAnchor.constraint(greaterThanOrEqualToConstant: 300.0),
                        
            titleLabel.topAnchor.constraint(equalTo: self.topAnchor, constant: 5),
            titleLabel.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 10),
            titleLabel.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -10),
            
            textField.topAnchor.constraint(equalTo: self.titleLabel.bottomAnchor, constant: 5),
            textField.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 10),
            textField.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -10),
            
            contentView.topAnchor.constraint(equalTo: self.textField.bottomAnchor, constant: 15),
            contentView.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 10),
            contentView.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -10),
            contentView.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -10),
        ])
        
        updateViewsVisibility()
    }
    
    func updateViewsVisibility() {
        
        colorPickerView.removeFromSuperview()
        tokensListView.removeFromSuperview()
        
        switch state {
        case .initial:
            addViewToContent(tokensListView)
        case .newToken:
            addViewToContent(colorPickerView)
        case .existingToken:
            addViewToContent(tokensListView)
        }
        sizeDelegate?.contentSizeChangedFor(tokensView: self)
    }
    
    func addViewToContent(_ view: NSView) {
        contentView.addSubview(view)
        NSLayoutConstraint.activate([
            view.topAnchor.constraint(equalTo: contentView.topAnchor),
            view.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            view.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            view.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
        ])
    }
}

extension TokensView: TokensTextFieldDelegate {
    
    public func tokensTextField(_ textField: TokensTextField, textChanged text: String, tokens: Set<Token>) {
        
        let allTokens = dataSource?.availableTokensFor(tokensView: self) ?? Set()
        let name = text.trimmingCharacters(in: .whitespacesAndNewlines)
        colorPickerView.updateNewTokenButtonTitle("Create new token: `\(name)`")
        if let existingToken = allTokens.first(where: {$0.title == name}) {
            self.state = .existingToken
            tokensListView.setTokens(Set(arrayLiteral: existingToken))
            sizeDelegate?.contentSizeChangedFor(tokensView: self)
        
        } else {
            self.state = text.isEmpty ? .initial : .newToken
            tokensListView.setTokens(allTokens.subtracting(tokens))
        }
    }
    
    public func tokenFor(title: String) -> Token? {
        let colorString = colorPickerView.selectedColor().toHexString()
        return Token(title: title, hexString: colorString)
    }
    
    public func tokensTextField(_ textField: TokensTextField, tokensChanged tokens: Set<Token>) {
        delegate?.tokenView(self, tokensChahged: tokens)
    }
}

extension TokensView: TokensColorPickerViewDelegate {
    public func creatingNewTokenRequested(with color: NSColor) {
        textField.newTokenRequested()
    }
}

extension TokensView: TokensListViewDelegate {
    public func tokenClicked(tokensView: TokensListView, token: Token) {
        textField.addTokenRequested(token)
        sizeDelegate?.contentSizeChangedFor(tokensView: self)
    }
}

