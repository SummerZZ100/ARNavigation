//
//  NavigationModel.swift
//  ARNavigatioin
//
//  Created by Zhang xiaosong on 2018/5/15.
//  Copyright © 2018年 Zhang xiaosong. All rights reserved.
//

import UIKit

enum CompassPoint {
    case north
    case south
    case east
    case west
}

class NavigationModel: NSObject {
    var directionToHead: CompassPoint!//方向
    var westDD: Float!//以西方为准，相对于正西方向的偏转（因为世界坐标系匹配真实东南西北方向后，X轴正方向指向西）
    var wRice: Float! //行走米数
    
    init(directionToHead: CompassPoint ,westDD: Float ,wRice: Float) {
        super.init()
        self.directionToHead = directionToHead
        self.westDD = westDD
        self.wRice = wRice
    }
    
}
