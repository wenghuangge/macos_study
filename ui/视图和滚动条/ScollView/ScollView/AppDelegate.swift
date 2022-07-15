//
//  AppDelegate.swift
//  ScollView
//
//  Created by 翁黄格 on 2022/2/9.
//

import Cocoa

@main
class AppDelegate: NSObject, NSApplicationDelegate {
    
    var datas = [NSDictionary]()
    @IBOutlet weak var window: NSWindow!
    

    @IBOutlet weak var tableView: NSTableView!
    
    @IBOutlet weak var scrollView: NoScrollerScrollView!
    
    func applicationDidFinishLaunching(_ notification: Notification) {
        //滚动视图
        addScrollView()
        //禁止视图
        addNoScrollerScrollView()
        
        //更新表格数据
        updateDate()
    }
    
    func applicationWillTerminate(_ notification: Notification) {
        
    }
    
    //添加滚动条
    func addScrollView() {
        
        let frame = CGRect(x: 0, y: 0, width: 100, height: 100)
        let myScrollView = NSScrollView(frame: frame)
        //加载图片
        let image = NSImage(named: NSImage.Name("screen.png"))
        //图片视图
        let imageViewFrame = CGRect(x: 0, y: 0, width: (image?.size.width)!, height: (image?.size.height)!)
        let imageView = NSImageView(frame: imageViewFrame)
        //添加图片
        imageView.image = image
        
        //添加图片视图到滚动视图
        myScrollView.hasVerticalRuler = true
        myScrollView.hasHorizontalScroller = true
        myScrollView.documentView = imageView
        
        //添加滑动视图到主视图
        self.window.contentView?.addSubview(myScrollView)
        
        
        //剪切视图滑动到滑动到左下方
        var newScrollOrigin:NSPoint
        let contentView: NSClipView = myScrollView.contentView
        if self.window.contentView!.isFlipped {
            newScrollOrigin = NSPoint(x: 0.0, y: 0.0)
        } else {
            newScrollOrigin = NSPoint(x: 0.0, y: imageView.frame.size.height - contentView.frame.size.height)
        }
        contentView.scroll(to: newScrollOrigin)
        
    }
    
    func addNoScrollerScrollView() {
        let frame = CGRect(x: 210, y: 0, width: 100, height: 100)
        let myScrollerView = DisableVerticalScrollView(frame: frame)
        let image = NSImage(named: NSImage.Name("screen.png"))
        let imageViewFrame = CGRect(x: 0, y: 0, width: (image?.size.width)!, height:  (image?.size.height)!)
        let imageView = NSImageView(frame: imageViewFrame)
        imageView.image = image
        
        myScrollerView.documentView = imageView
        
        self.window.contentView?.addSubview(myScrollerView)
        
        //滚动到顶部位置
        var newScrollOrigin : NSPoint
        let contentView: NSClipView = myScrollerView.contentView
        
        if self.window.contentView!.isFlipped {
            newScrollOrigin = NSPoint(x: 0.0,y: 0.0);
        }
        else{
            newScrollOrigin = NSPoint(x: 0.0,y: imageView.frame.size.height-contentView.frame.size.height);
        }
        contentView.scroll(to: newScrollOrigin)
    }
    
    
    func updateDate() {
        self.datas = [
            ["name":"john", "address":"USA"],
            ["name":"mary", "address":"China"],
            ["name":"park", "address":"Japan"],
            ["name":"Daba", "address":"Russia"]
        ]
        
        self.tableView.reloadData()
    }
}

//绑定table数据
extension AppDelegate:NSTableViewDataSource {
    func numberOfRows(in tableView: NSTableView) -> Int {
        Swift.print("count = ", self.datas.count)
        return self.datas.count
    }
}

extension AppDelegate: NSTableViewDelegate {
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {

            let data = self.datas[row]
            //表格列的标识
            let key = (tableColumn?.identifier)!
            //单元格数据
            let value = data[key]
            
            //根据表格列的标识,创建单元视图
            let view = tableView.makeView(withIdentifier: key, owner: self)
            let subviews = view?.subviews
            if (subviews?.count)!<=0 {
                return nil
            }
            Swift.print("key:rwwValue:", key.rawValue)
            if key.rawValue == "name" || key.rawValue == "address" {
                let textField = subviews?[0] as! NSTextField
                if value != nil {
                    textField.stringValue = value as! String
                }
            }
            
            return view
    }
    
    
    func tableViewSelectionDidChange(_ notification: Notification){
        let tableView = notification.object as! NSTableView
        let row = tableView.selectedRow
        print("selection row \(row)")
    }
}


