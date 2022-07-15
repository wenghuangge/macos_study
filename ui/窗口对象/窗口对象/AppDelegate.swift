//
//  AppDelegate.swift
//  窗口对象
//
//  Created by 翁黄格 on 2022/1/3.
//

import Cocoa
import AppKit

@main
class AppDelegate: NSObject, NSApplicationDelegate {

    @IBOutlet var window: NSWindow!
    
    //模态窗口,只有这个窗口可以接收和响应用户操作,关闭后才能进行其它操作，不能选择其它窗口
    @IBOutlet weak var modelWindow: NSWindow!
    
    //自定义窗口创建
    var myWindow: NSWindow!
    
    //session窗口 可以选中其它窗口，但是不能进行其它窗口
    var sessionCode : NSApplication.ModalSession?
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        // Insert code here to initialize your application
        
        //关闭窗口的时候调用close函数
        NotificationCenter.default.addObserver(self, selector: #selector(self.windowClose(_:)), name: NSWindow.willCloseNotification, object: nil)
        
        //修改背景颜色
        self.setWindowBkColor()
        
        //添加按钮在标题栏
        self.addBUttonTotitleBar()
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
        //结束notifaction
        NotificationCenter.default.removeObserver(self)
    }

    //最后一个窗口关闭结束
    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        return true
    }
    
    //显示模态窗口
    @IBAction func showModelWindow(_ sender: NSButton) {
        NSApplication.shared.runModal(for: self.modelWindow);
    }
    
    //关闭窗口
    @objc func windowClose(_ aNotification: Notification)  {
        //关闭session窗口
        if let sessionCode = sessionCode {
            NSApplication.shared.endModalSession(sessionCode)
            self.sessionCode = nil
        }
        
        if let window = aNotification.object as? NSWindow {
            //停止模态窗口
            if self.modelWindow == window {
                NSApplication.shared.stopModal()
            }
            if window == self.window {
                NSApp.terminate(self)
            }
        }
    }
    
    //创建窗口
    @IBAction func createWindow(_ sender: Any) {
        let frame = CGRect(x: 0, y: 0, width: 400, height: 280)
        let style: NSWindow.StyleMask = [NSWindow.StyleMask.titled, NSWindow.StyleMask.titled, NSWindow.StyleMask.closable, NSWindow.StyleMask.resizable]
        
        //创建Window
        myWindow = NSWindow(contentRect: frame, styleMask: style, backing: .buffered, defer: false)
        
        myWindow.title = "New Create Window"
        //显示Window
        myWindow.makeKeyAndOrderFront(self)
        //居中
        myWindow.center()
    }
    
    func setWindowBkColor() {
        self.window.backgroundColor = NSColor.green
    }
    
    func addBUttonTotitleBar() {
        let titleView = self.window.standardWindowButton(.closeButton)?.superview
        let button = NSButton()
        let x = (self.window.contentView?.frame.size.width)! - 100
        let frame = CGRect(x: x, y: 0, width: 80, height: 24)
        button.frame = frame
        button.title = "Register"
        button.bezelStyle = .rounded
        titleView?.addSubview(button)
    }
    
    @IBAction func showSessionWindow(_ sender: NSButton) {
        sessionCode = NSApplication.shared.beginModalSession(for: self.modelWindow)
    }
}

