//
//  AppDelegate.swift
//  TonensViewTestApp
//
//  Created by Sergey Atroschenko on 20.04.22.
//  Copyright © 2022 TokensView. All rights reserved.
//

import Cocoa

@main
class AppDelegate: NSObject, NSApplicationDelegate {
    
    weak var windowController: WindowController?
    weak var viewController: ViewController?

    func applicationDidFinishLaunching(_ aNotification: Notification) {
    }

    func applicationWillTerminate(_ aNotification: Notification) {
    }

    func applicationSupportsSecureRestorableState(_ app: NSApplication) -> Bool {
        return true
    }


}

