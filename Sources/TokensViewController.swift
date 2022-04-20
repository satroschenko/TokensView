//
//  TokensViewController.swift
//  TokensView
//
//  Created by Sergey Atroschenko on 18.04.22.
//  Copyright © 2022 TokensView. All rights reserved.
//

import Cocoa

public class TokensViewController: NSViewController {
    
    public weak var dataSource: TokensViewDataSource?
    
    // Set this property to allow popover change size dinamically.
    public weak var popover: NSPopover?
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    override init(nibName nibNameOrNil: NSNib.Name?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    convenience init() {
        self.init(nibName: nil, bundle: nil)
    }
    
    public override func loadView() {
        let tokenView = TokensView()
        tokenView.dataSource = self
        tokenView.delegate = self
        self.view = tokenView
    }
    
    public override func viewWillAppear() {
        super.viewWillAppear()
        (self.view as? TokensView)?.willShowView()
    }
    
    public override func viewDidAppear() {
        super.viewDidAppear()
        (self.view as? TokensView)?.didShowView()
    }
}

extension TokensViewController: TokensViewDelegate {
    public func contentSizeChangedFor(tokensView: TokensView) {
        let size = self.view.fittingSize
        NSAnimationContext.runAnimationGroup { _ in
            popover?.contentSize = size
        }
    }
}


extension TokensViewController: TokensViewDataSource {
    
    public func colorListFor(tokensView: TokensView) -> [NSColor]? {
        return dataSource?.colorListFor(tokensView: tokensView)
    }
    
    public func titleFor(tokensView: TokensView) -> String? {
        return dataSource?.titleFor(tokensView: tokensView)
    }
    
    public func availableTokensFor(tokensView: TokensView) -> Set<Token> {
        return dataSource?.availableTokensFor(tokensView: tokensView) ?? Set()
    }
    
    public func initialTokensFor(tokensView: TokensView) -> Set<Token> {
        return dataSource?.initialTokensFor(tokensView: tokensView) ?? Set()
    }
}

