//
//  VectorNavNode.swift
//  ARNavigatioin
//
//  Created by Zhang xiaosong on 2018/5/30.
//  Copyright © 2018年 Zhang xiaosong. All rights reserved.
//

import UIKit
import ARKit

struct VectorNav {
    var vector: SCNVector3!//当前节点相对于父节点的向量
    var node: SCNNode!//当前节点的导航
    var orignalVector: SCNVector3! //当前节点所使用的原始数据
}
