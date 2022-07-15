//
//  CustomView.swift
//  View
//
//  Created by 翁黄格 on 2022/1/5.
//

import Foundation
import AppKit

final class CustomView: NSView {
    
    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    //返回true坐标原点从左上角开始，默认为左下角
    override var isFlipped: Bool {
        get {
            return true
        }
    }
    
    //draw view
    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)
        //设置颜色
        NSColor.blue.setFill()
        let frame = self.bounds
        let path = NSBezierPath()
        path.appendRoundedRect(frame, xRadius: 20, yRadius: 20)
        path.fill()
        configLayer()
    }
    
    //点击事件
    override func mouseDown(with event: NSEvent) {
        let point = self.convert(event.locationInWindow, to: nil)
        NSLog("window point \(event.locationInWindow)")
        NSLog("view point: \(point)")
    }
    
    //通过layer设置背景、边框、远角等属性
    func configLayer() {
        self.wantsLayer = true
        self.layer?.backgroundColor = NSColor.red.cgColor
        self.layer?.borderWidth = 2
        self.layer?.cornerRadius = 10
    }
    
    //视图截屏
    func saveSelfAsImage() {
        let image = NSImage(data: self.dataWithPDF(inside: self.bounds))
        let imageDate = image!.tiffRepresentation
        let fileManage = FileManager.default
        
        let path = "/Users/wenghuangge/Documents/myCapture.png"
        fileManage.createFile(atPath: path, contents: imageDate, attributes: nil)
        
        let fileURL = URL(fileURLWithPath: path)
        //通过finder选中图片
        NSWorkspace.shared.activateFileViewerSelecting([fileURL]);
    }

    
}

