//
//  NoScrollerScrollView.swift
//  ScollView
//
//  Created by 翁黄格 on 2022/7/15.
//

import Cocoa

class NoScrollerScrollView: NSScrollView {

    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)
        // Drawing code here.
    }
    
    override func tile() {
        super.tile()
        var hFrame = self.horizontalScroller?.frame
        hFrame?.size.height = 0
        if let hFrame = hFrame {
            self.horizontalScroller?.frame = hFrame
        }
        
        var vFrame = self.verticalScroller?.frame
        vFrame?.size.width = 0
        if let vFrame = vFrame {
            self.verticalScroller?.frame = vFrame
        }
    }
    
}
