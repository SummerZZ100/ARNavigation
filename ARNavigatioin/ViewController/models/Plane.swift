//
//  Plane.swift
//  ARNavigatioin
//
//  Created by Zhang xiaosong on 2018/4/20.
//  Copyright © 2018年 Zhang xiaosong. All rights reserved.
//

import UIKit
import SceneKit
import ARKit

class Plane: SCNNode {
    
    var anchor: ARPlaneAnchor! //锚点
    var planeGeometry: SCNPlane! //平面几何体

    //    MARK: - 初始化
    init(withAnchor anchor:ARPlaneAnchor) {
        super.init()
        
        self.anchor = anchor
        self.planeGeometry = SCNPlane(width: CGFloat(anchor.extent.x), height: CGFloat(anchor.extent.z))
        
        let material = SCNMaterial()//材质
        let image = UIImage(named: "vertical.png")
        material.diffuse.contents = image
        material.lightingModel = .physicallyBased
        self.planeGeometry.materials = [material]
        
        let planeNode = SCNNode(geometry: self.planeGeometry)//节点
        planeNode.position = SCNVector3Make(anchor.center.x,0,anchor.center.z)
        
        // SceneKit 里的平面默认是垂直的，所以需要旋转90度来匹配 ARKit 中的平面
        planeNode.transform = SCNMatrix4MakeRotation(Float(-.pi/2.0), 1.0, 0.0, 0.0)
        
        setTextureScale()
        addChildNode(planeNode)
        
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
//    更新节点位置
    func update(anchor: ARPlaneAnchor) {
        // 随着用户移动，平面 plane 的 范围 extend 和 位置 location 可能会更新。
        // 需要更新 3D 几何体来匹配 plane 的新参数。
        planeGeometry.width = CGFloat(anchor.extent.x)
        planeGeometry.height = CGFloat(anchor.extent.z)
        
        // plane 刚创建时中心点 center 为 0,0,0，node transform 包含了变换参数。
        // plane 更新后变换没变 但 center 更新了，所以需要更新 3D 几何体的位置
        
        position = SCNVector3Make(anchor.center.x, 0, anchor.center.z)
        
        setTextureScale()
        
    }
    
//    平铺
    private func setTextureScale () {
        let width = self.planeGeometry.width
        let height = self.planeGeometry.height
        
        // 平面的宽度/高度 width/height 更新时，我希望 tron grid material 覆盖整个平面，不断重复纹理。
        // 但如果网格小于 1 个单位，我不希望纹理挤在一起，所以这种情况下通过缩放更新纹理坐标并裁剪纹理
        
        let material = planeGeometry.materials.first
        material?.diffuse.contentsTransform = SCNMatrix4MakeScale(Float(width), Float(height), 1)
        material?.diffuse.wrapS = .repeat
        material?.diffuse.wrapT = .repeat
        
    }
    
    
}
