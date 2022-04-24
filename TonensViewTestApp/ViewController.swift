//
//  ViewController.swift
//  TonensViewTestApp
//
//  Created by Sergey Atroschenko on 20.04.22.
//  Copyright © 2022 TokensView. All rights reserved.
//

import Cocoa
import TokensView

class TableItem {
    let title: String
    var tokens = [Token]()
    
    init(title: String) {
        self.title = title
    }
}

class ViewController: NSViewController {
    
    var items = [TableItem]()

    @IBOutlet weak var splitView: NSSplitView!
    @IBOutlet weak var tableView: NSTableView!
    @IBOutlet weak var stackView: NSStackView!
    
    private var tokensPopover: NSPopover?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let appDelegate = NSApplication.shared.delegate as! AppDelegate
        appDelegate.viewController = self
        
        fillTable()
        updateToolbarButtonState()
        
        tableView.dataSource = self
        tableView.delegate = self
    }
    
    func toolBarButtonClicked(_ sender: NSButton) {
        
        if let popover = tokensPopover {
            popover.performClose(self)
            tokensPopover = nil
            
        } else {
            tokensPopover = NSPopover()
            tokensPopover?.delegate = self
            tokensPopover?.behavior = .transient
            let controller = TokensViewController()
            controller.dataSource = self
            controller.delegate = self
            // Set this property to allow popover change its size dinamically.
            controller.popover = tokensPopover
            tokensPopover?.contentViewController = controller
            tokensPopover?.show(relativeTo: sender.frame, of: sender, preferredEdge: NSRectEdge.maxY)
        }
    }
    
    private func fillTable() {
        items = [
            TableItem(title: "The first item"),
            TableItem(title: "The second item"),
            TableItem(title: "Another one item"),
            TableItem(title: "The next item"),
            TableItem(title: "The last item"),
        ]
    }
    
    private func updateToolbarButtonState() {
        let selection = tableView.selectedRow
        let appDelegate = NSApplication.shared.delegate as! AppDelegate
        appDelegate.windowController?.setToolbarItemEnabled(selection >= 0)
    }
}

extension ViewController: NSTableViewDataSource {
    
    func numberOfRows(in tableView: NSTableView) -> Int {
        return items.count
    }
}

extension ViewController: NSPopoverDelegate {
    
    func popoverWillClose(_ notification: Notification) {
        tokensPopover = nil
    }
}

extension ViewController: NSTableViewDelegate {
    
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        
        let identifier = NSUserInterfaceItemIdentifier(rawValue: "tokens")
        var cell = tableView.makeView(withIdentifier: identifier, owner: self) as? NSTextField
        if cell == nil {
            cell = NSTextField()
            cell?.identifier = identifier
            cell?.isEditable = false
            cell?.isSelectable = false
        }
        
        cell?.stringValue = items[row].title
        return cell
    }
    
    func tableViewSelectionDidChange(_ notification: Notification) {
        updateToolbarButtonState()
        let selection = tableView.selectedRow
        guard selection >= 0 else {
            showTokens(tokens: [])
            return
        }
        let item = items[selection]
        showTokens(tokens: item.tokens)
    }
    
    func showTokens(tokens: [Token]) {
        let subviews = stackView.arrangedSubviews
        subviews.forEach({$0.removeFromSuperview()})
        
        tokens.compactMap({viewForToken(token:$0)}).forEach({stackView.addArrangedSubview($0)})
    }
    
    func viewForToken(token: Token) -> NSView {
        let label = NSTextField(labelWithString: token.title)
        label.textColor = .white
        label.drawsBackground = true
        label.backgroundColor = NSColor(hexString: token.hexString)
        return label
    }
}


extension ViewController: TokensViewDataSource {
    func availableTokensFor(tokensView: TokensView) -> Set<Token> {
        var set = Set<Token>()
        set.insert(Token(title: "Suggested Token #1", hexString: "#c67c00"))
        set.insert(Token(title: "Suggested Token #2", hexString: "#FF0000"))
        set.insert(Token(title: "Suggested Token #3", hexString: "#00FF40"))
        set.insert(Token(title: "Suggested Token #4", hexString: "#0000FF"))
        
        return set
    }
    
    func initialTokensFor(tokensView: TokensView) -> Set<Token> {
        let selection = tableView.selectedRow
        guard selection >= 0 else { return [] }
        var set = Set<Token>()
        let item = items[selection]
        item.tokens.forEach({set.insert($0)})
        return set
    }
}


extension ViewController: TokensViewDelegate {
    func tokenView(_ tokenView: TokensView, tokensChahged tokens: Set<Token>) {
        let selection = tableView.selectedRow
        guard selection >= 0 else { return }
        let item = items[selection]
        item.tokens.removeAll()
        item.tokens.append(contentsOf: tokens)
        showTokens(tokens: item.tokens)
    }
}
