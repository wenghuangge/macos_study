//
//  DisableVerticalScrollView.swift
//  ScollView
//
//  Created by 翁黄格 on 2022/7/15.
//

import Cocoa

class DisableVerticalScrollView: NSScrollView {
    //鼠标移动
    override func scrollWheel(with event: NSEvent) {
        let f = abs(event.deltaY)
        if event.deltaX == 0.0 && f >= 0.01 {
            return
        } else {
            super.scrollWheel(with: event);
        }
    }
}
