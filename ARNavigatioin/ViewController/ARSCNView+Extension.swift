//
//  ARSCNView+Extension.swift
//  Distance
//
//  Created by Zhang xiaosong on 2018/4/24.
//  Copyright © 2018年 Zhang xiaosong. All rights reserved.
//

import ARKit

extension ARSCNView {
    
    
    /// 拿到三维坐标
    ///
    /// - Parameter position: 点位置
    /// - Returns: 三维坐标
    func worldVector(with position:CGPoint) -> SCNVector3? {
        
        let results = hitTest(position, types: .featurePoint)//用来搜索ARSession检测到的锚点,还有真实世界的对象而不是view里面的SceneKit里面的内容,假设找内容的话用(option)
        guard let result = results.first else {
            return nil
        }
        
        return SCNVector3.positionTransform(result.worldTransform)
        
    }
    
}
