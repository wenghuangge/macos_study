//
//  AppDelegate.swift
//  View
//
//  Created by 翁黄格 on 2022/1/4.
//

import Cocoa

@main
class AppDelegate: NSObject, NSApplicationDelegate {

    @IBOutlet var window: NSWindow!

    @IBOutlet weak var customView: CustomView!
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        // Insert code here to initialize your application
        let button = NSButton()
        
        let frame = NSRect(x: 2, y: 2, width: 80, height: 18)
        button.frame = frame
        button.title = "Register"
        button.bezelStyle = .rounded
        
        self.customView.addSubview(button)
        self.customView.postsFrameChangedNotifications = true
        
    }
    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }
    
    func registerNotification() {
        NotificationCenter.default.addObserver(self, selector: #selector(self.receiveFrameChangeNotification(_:)), name: NSView.frameDidChangeNotification, object: nil)
    }

    @objc func receiveFrameChangeNotification(_ notification: Notification) {
        NSLog("receiveFrameChangeNotification");
    }
    
    @IBAction func captureAction(_ sender: Any) {
        self.customView.saveSelfAsImage()
    }
}

