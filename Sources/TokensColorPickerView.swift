//
//  TokensColorPickerView.swift
//  TokensView
//
//  Created by Sergey Atroschenko on 18.04.22.
//  Copyright © 2022 TokensView. All rights reserved.
//

import Cocoa

public protocol TokensColorPickerViewDelegate: AnyObject {
    func creatingNewTokenRequested(with color: NSColor)
}

public class TokensColorPickerView: NSView {
        
    public var selectedIndex: Int = 0
    public weak var delegate: TokensColorPickerViewDelegate?
    
    private var colors: [NSColor] = [NSColor]()
    private var buttons = [TokenColorButton]()
    
    private var defaultColors: [NSColor] = [
        NSColor(hexString: "#d50000"),
        NSColor(hexString: "#4e342e"),
        NSColor(hexString: "#c67c00"),
        NSColor(hexString: "#c7a500"),
        NSColor(hexString: "#009624"),
        NSColor(hexString: "#0088a3"),
        NSColor(hexString: "#2962ff"),
        NSColor(hexString: "#6200ea"),
        NSColor(hexString: "#aa00ff"),
        NSColor(hexString: "#455a64"),
    ]
    
    private var stackView: NSStackView = {
        let stackView = NSStackView()
        stackView.orientation = .horizontal
        stackView.distribution = .equalCentering
        stackView.spacing = 4.0
        
        return stackView
    }()
    
    private var newTokenButton: NSButton = {
        let button = NSButton()
        button.setButtonType(.momentaryPushIn)
        button.bezelColor = NSColor.controlAccentColor
        button.bezelStyle = .rounded
        button.imagePosition = .imageLeading
        button.imageScaling = .scaleProportionallyDown
        button.alignment = .natural
        button.title = "Create new token"
        
        return button
    }()
    
    init() {
        super.init(frame: .zero)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
    }
    
    public func setColors(_ colors: [NSColor]) {
        self.colors = colors
        let subviews = stackView.arrangedSubviews
        subviews.forEach({
            stackView.removeArrangedSubview($0)
            $0.removeFromSuperview()
        })
        let buttons: [TokenColorButton] = self.colors.compactMap({
            let button = TokenColorButton(color: $0)
            button.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                button.widthAnchor.constraint(equalToConstant: 20.0),
                button.heightAnchor.constraint(equalToConstant: 20.0),
            ])
            return button
        })
        self.buttons = buttons
        
        for (index, button) in buttons.enumerated() {
            stackView.addArrangedSubview(button)
            button.delegate = self
            button.didAddedToSuperview()
            button.state = (index == selectedIndex) ? .on : .off
        }
    }
    
    public func selectedColor() -> NSColor {
        guard selectedIndex < buttons.count else { return NSColor.red }
        return buttons[selectedIndex].color
    }
    
    @objc func newTokenButtonClicked() {
        delegate?.creatingNewTokenRequested(with: selectedColor())
    }
    
    public func updateNewTokenButtonTitle(_ title: String) {
        newTokenButton.title = title
    }
}


private extension TokensColorPickerView {
    
    func setupUI() {
        
        stackView.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(stackView)
        
        newTokenButton.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(newTokenButton)
        newTokenButton.target = self
        newTokenButton.action = #selector(newTokenButtonClicked)
        
        NSLayoutConstraint.activate([
            
            newTokenButton.topAnchor.constraint(equalTo: self.topAnchor, constant: 2),
            newTokenButton.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 5),
            newTokenButton.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -5),
            
            stackView.leadingAnchor.constraint(greaterThanOrEqualTo: self.leadingAnchor, constant: 5),
            stackView.trailingAnchor.constraint(lessThanOrEqualTo: self.trailingAnchor, constant: -5),
            stackView.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            stackView.topAnchor.constraint(equalTo: newTokenButton.bottomAnchor, constant: 10),
            stackView.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -5),
        ])
        
        setColors(defaultColors)
    }
    
    func updateButtonsState() {
        for (index, button) in buttons.enumerated() {
            button.state = (index == selectedIndex) ? .on : .off
        }
    }
}


extension TokensColorPickerView: TokenColorButtonDelegate {
    
    public func stateChanged(_ button: TokenColorButton, selected: Bool) {
        self.selectedIndex = buttons.firstIndex(where: {$0 === button}) ?? 0
        updateButtonsState()
    }
}

