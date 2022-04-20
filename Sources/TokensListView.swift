//
//  TokensListView.swift
//  TokensView
//
//  Created by Sergey Atroschenko on 18.04.22.
//  Copyright © 2022 TokensView. All rights reserved.
//

import Cocoa

class TokenButton: NSButton {
    var token: Token?
}

public protocol TokensListViewDelegate: AnyObject {
    func tokenClicked(tokensView: TokensListView, token: Token)
}

public class TokensListView: NSView {
    
    private var allTokens = Set<Token>()
    public weak var delegate: TokensListViewDelegate?
    
    public var stackView: NSStackView = {
        let stackView = NSStackView()
        stackView.orientation = .vertical
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.spacing = 2.0
        
        return stackView
    }()
    
    init() {
        super.init(frame: .zero)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
    }
    
    public func setTokens(_ tokens: Set<Token>) {
        self.allTokens = tokens
        updateViews()
    }
    
    @objc func buttonClicked(_ sender: TokenButton) {
        guard let token = sender.token else { return }
        delegate?.tokenClicked(tokensView: self, token: token)
    }
}

private extension TokensListView {
    
    func setupUI() {
                
        self.addSubview(stackView)
        NSLayoutConstraint.activate([
            stackView.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 5),
            stackView.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -5),
            stackView.topAnchor.constraint(equalTo: self.topAnchor, constant: 10),
            stackView.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -5),
        ])
    }
    
    func updateViews() {
        let subviews = stackView.arrangedSubviews
        subviews.forEach({
            stackView.removeArrangedSubview($0)
            $0.removeFromSuperview()
        })
        let buttons: [NSButton] = self.allTokens.sorted(by: {$0.title > $1.title}).compactMap({
            
            let button = self.newButton()
            button.title = $0.title
            button.image = NSColor(hexString: $0.hexString).toCircleImage(size: NSSize(width: 20, height: 20))
            button.token = $0
            return button
        })
        
        for button in buttons {
            stackView.addArrangedSubview(button)
            NSLayoutConstraint.activate([
                button.leadingAnchor.constraint(equalTo: stackView.leadingAnchor),
                button.trailingAnchor.constraint(equalTo: stackView.trailingAnchor),
                button.heightAnchor.constraint(equalToConstant: 20),
            ])
        }
    }
    
    func newButton() -> TokenButton {
        let button = TokenButton()
        button.imagePosition = .imageLeading
        button.alignment = .natural
        button.isBordered = false
        button.setButtonType(.momentaryChange)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.target = self
        button.action = #selector(buttonClicked(_:))
        return button
    }
}
