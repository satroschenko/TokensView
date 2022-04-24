//
//  WindowController.swift
//  TonensViewTestApp
//
//  Created by Siarhei Atroshchanka on 20.04.22.
//  Copyright © 2022 TokensView. All rights reserved.
//

import Cocoa

class WindowController: NSWindowController {
    
   
    @IBOutlet weak var toolbarItem: NSToolbarItem!
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        let appDelegate = NSApplication.shared.delegate as! AppDelegate
        appDelegate.windowController = self
    }

    func setToolbarItemEnabled(_ enabled: Bool) {
        toolbarItem.isEnabled = enabled
    }
    
    @IBAction func toolBarButtonClicked(_ sender: NSButton) {
        let appDelegate = NSApplication.shared.delegate as! AppDelegate
        appDelegate.viewController?.toolBarButtonClicked(sender)
    }
}
