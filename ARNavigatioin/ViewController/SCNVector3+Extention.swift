//
//  SCNVector3+Extention.swift
//  Distance
//
//  Created by Zhang xiaosong on 2018/4/24.
//  Copyright © 2018年 Zhang xiaosong. All rights reserved.
//

import ARKit

extension SCNVector3: Equatable{

    
//    世界坐标系中4*4矩阵 转为 x y z 坐标（向量）
    static func positionTransform(_ transform: matrix_float4x4) -> SCNVector3 {
        return SCNVector3Make(transform.columns.3.x, transform.columns.3.y, transform.columns.3.z)
    }
    

    /// 计算距离
    ///
    /// - Parameter vector: 目标点
    /// - Returns: 距离 m
    func distance(to vector:SCNVector3) -> Float {
        let distanceX = self.x - vector.x
        let distanceY = self.y - vector.y
        let distanceZ = self.z - vector.z
        
        return sqrt((distanceX * distanceX) + (distanceY * distanceY) + (distanceZ * distanceZ))
        
    }
    
    /// 画线
    ///
    /// - Parameters:
    ///   - vector: 目标点
    ///   - color: 线的颜色
    /// - Returns: 线条
    func line(to vector:SCNVector3, color:UIColor) -> SCNNode {
        
        let indices :[UInt32] = [0,1]//指数
        let source = SCNGeometrySource(vertices: [self,vector])//创建一个几何容器
        
        let element = SCNGeometryElement(indices: indices, primitiveType: .line)//用线的方式来创造一个几何元素（线）
        let geomtry = SCNGeometry(sources: [source], elements: [element])//几何
        geomtry.firstMaterial?.diffuse.contents = color//渲染颜色
        let node = SCNNode(geometry: geomtry)//返回一个节点
        return node
        
    }
    
    // MARK: - Equatable
    
    public static func == (lhs: SCNVector3, rhs: SCNVector3) -> Bool {
        //当左边的与右边的相等
        return (lhs.x == rhs.x) && (lhs.y == rhs.y) && (lhs.z == rhs.z)
    }
    
    
}
