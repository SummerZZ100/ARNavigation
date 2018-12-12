//
//  ARNavigationViewController.swift
//  ARNavigatioin
//
//  Created by Zhang xiaosong on 2018/5/15.
//  Copyright © 2018年 Zhang xiaosong. All rights reserved.
//

import UIKit
import CoreLocation
import CoreMotion
import ARKit
import SceneKit

enum DistinationType {
    case Car_1
    case Car_2
    case Car_3
}

/// 导航主视图
//识别图像之后，，重新开启ARScence并，设置世界原点
class ARNavigationViewController: ARSCNBaseViewController {

    /// 定位管理器，用于获取真实世界的方向
    var CLManager = CLLocationManager()
    
    /// 标志是否获取真实世界的方向成功
    var directionSuccess = false
    
    /// 标志是否获取手机位姿成功
    var deviceMotionSuccess = false
    
    /// 真实世界中正南方向偏移的弧度
    var directioinAngle: Double!
    
    /// 世界坐标系旋转到正方位的角度（决定于设备的位姿）
    var deviceAngle: Double = 0.0
    
    /// 设备传感管理器
    var deviceMotionManager: CMMotionManager!
    
    var navControl: DrawNavigation!//导航绘制类
    
    var needResetOrignalWorld = false //是否需要重新设置世界原点
    
    var distinationType: DistinationType!
    
    
    /// MARK: - life cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "AR导航"
        setupMyView()
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    
    override func setupSession() {
        if ARWorldTrackingConfiguration.isSupported {
            let worldTracking = ARWorldTrackingConfiguration()
            worldTracking.isLightEstimationEnabled = true
            
            //添加动态图片库
            let image_1 = UIImage(named: "golden_century_1.png")
            let refrenceImage_1 = ARReferenceImage.init((image_1?.cgImage)!, orientation: .up, physicalWidth: 0.3)
            refrenceImage_1.name = "golden_century_1"
            
            let image_2 = UIImage(named: "car_1.jpg")
            let refrenceImage_2 = ARReferenceImage.init((image_2?.cgImage)!, orientation: .up, physicalWidth: 0.3)
            refrenceImage_2.name = "car_1"
            
            let image_3 = UIImage(named: "car_2.jpg")
            let refrenceImage_3 = ARReferenceImage.init((image_3?.cgImage)!, orientation: .up, physicalWidth: 0.3)
            refrenceImage_3.name = "car_2"

            let image_4 = UIImage(named: "car_3.jpg")
            let refrenceImage_4 = ARReferenceImage.init((image_4?.cgImage)!, orientation: .up, physicalWidth: 0.3)
            refrenceImage_4.name = "car_3"
            
            worldTracking.detectionImages = [refrenceImage_1,refrenceImage_2,refrenceImage_3,refrenceImage_4]
            
            sessionConfiguration = worldTracking
        }
        else {
            let orientationTracking = AROrientationTrackingConfiguration()
            sessionConfiguration = orientationTracking
        }
        
        gameView.session.run(sessionConfiguration)
        
    }
    
    /// 重置世界原点
    override func resetOrignalWorld() {
        if needResetOrignalWorld {
            needResetOrignalWorld = false
            
            let matrix4_X = SCNMatrix4MakeRotation(0.0, 1.0, 0.0, 0.0)
            let r_matrix4_Y = SCNMatrix4MakeRotation(Float(deviceAngle + directioinAngle), 0.0, 1.0, 0.0)//设置世界坐标的正方向
            let matrix4_Z = SCNMatrix4MakeRotation(0.0, 0.0, 0.0, 1.0)
            
            let t1_matrix4_T = SCNMatrix4MakeTranslation(0.0, -1.0, 1.0)//重新设置中心点的位置 向下 1.5m 向后 1.0m
            
            let mXY = SCNMatrix4Mult(matrix4_X, r_matrix4_Y)
            let mXYZ = SCNMatrix4Mult(mXY, matrix4_Z)
            let mT = SCNMatrix4Mult(mXYZ, t1_matrix4_T)
            
            gameView.session.setWorldOrigin(relativeTransform: simd_float4x4(mT))
            
            self.goDrawNavigation()
            
        }
    }
    
    
    /// MARK: - private methods
    
    /// 初始化视图
    private func setupMyView() {
        CLManager.delegate = self
        CLManager.startUpdatingHeading()
    }
    
    /// 开启设备位姿检测
    private func deviceMotionPush() {
        if deviceMotionManager == nil {
            deviceMotionManager = CMMotionManager()
            
            deviceMotionManager.deviceMotionUpdateInterval = 0.5
        }
        let queue = OperationQueue()
        deviceMotionManager.startDeviceMotionUpdates(to: queue) { (motion, error) in
            
            //手机位姿
//            print("roll z = \(String(describing: motion?.attitude.roll))  pitch x = \(String(describing: motion?.attitude.pitch))  yaw y = \(String(describing: motion?.attitude.yaw))")
            
            if !self.deviceMotionSuccess {
                self.deviceMotionSuccess = true
                
                self.deviceMotionManager.stopDeviceMotionUpdates()
                let pitch = (motion?.attitude.pitch)! //绕x轴旋转的弧度
                let roll = (motion?.attitude.roll)!  //绕z轴旋转的弧度
                self.calculateDirection(pitch: pitch, roll: roll)
            }
        }
    }
    
    //计算绕Y轴需要选择的角度
    private func calculateDirection(pitch :Double , roll :Double) {
        
        let absPitch = abs(pitch)
        let absRoll = abs(roll)
        
        //第一象限   pitch x = Optional(0.29111783950973613)  yaw y = Optional(0.099599084804281382)  roll z = Optional(-0.33503381207303545)
        if pitch >= 0.0 && roll <= 0.0 {
            if absPitch < absRoll  {//x轴旋转的角度 小于 z轴旋转的角度 以X轴正方向为初始值
                self.deviceAngle = 90 / 180 * .pi - absPitch
            }
            else if absPitch > absRoll {
                //                        self.angle = 0
                self.deviceAngle = absRoll
            }
            else {
                self.deviceAngle = -(45 / 180 * .pi)
            }
            self.changeWorldOrigin()
        }
        else if pitch >= 0.0 && roll >= 0.0 {// 第四象限
            if absPitch < absRoll {//x<z
                self.deviceAngle = -((90 / 180 * .pi) - absPitch)
            }
            else if absPitch > absRoll {// x> z
                self.deviceAngle = -absRoll
            }
            else {
                self.deviceAngle = (45 / 180 * .pi)
            }
            self.changeWorldOrigin()
        }
        
    }
    
    /// 改变AR中世界坐标系的原点坐标轴方向
    private func changeWorldOrigin() {
        
        self.gameView.session.pause()
        self.gameView.session.run(sessionConfiguration, options: .resetTracking)
    
    }
    
    
    /// 绘制导航
    private func goDrawNavigation() {
        
        if distinationType == DistinationType.Car_1 {
            var navArray = Array<NavigationModel>()
            
            let n1 = NavigationModel(directionToHead: .east, westDD: 18.0, wRice: 3.6)
            let n2 = NavigationModel(directionToHead: .east, westDD: 292.0, wRice: 1.6)
            let n3 = NavigationModel(directionToHead: .east, westDD: 18.0, wRice: 20.0)
            let n4 = NavigationModel(directionToHead: .east, westDD: 292.0, wRice: 20.0)
            navArray.append(n1)
            navArray.append(n2)
            navArray.append(n3)
            navArray.append(n4)
            
            self.navControl = DrawNavigation(self.gameView)
            
            self.navControl.showNavigation(navArray: navArray, downRice: 1.5, backRice: 0.0)
        }
        else if distinationType == DistinationType.Car_2 {
            var navArray = Array<NavigationModel>()
            let n1 = NavigationModel(directionToHead: .east, westDD: 18.0, wRice: 3.4)
            let n2 = NavigationModel(directionToHead: .east, westDD: 110.0, wRice: 4.0)
            let n3 = NavigationModel(directionToHead: .east, westDD: 190.0, wRice: 4.0)
            navArray.append(n1)
            navArray.append(n2)
            navArray.append(n3)
            
            self.navControl = DrawNavigation(self.gameView)
            
            self.navControl.showNavigation(navArray: navArray, downRice: 1.5, backRice: 0.0)
        }
        
        
    }
    
    /// 识别图片成功
    private func distinguishSuccess() {
        needResetOrignalWorld = true
        deviceMotionSuccess = false
        deviceMotionPush()
    }
    
    /// 设置导航
    private func setupNavigation() {
        // Y轴：垂直方向，正方向朝上
        // X轴：东西方向，正方向朝西
        // Z轴：南北方向，正方向朝北
        
        //向南，顺时针（偏西 26度）3米
        
        let rootGeometry = SCNBox(width: 0.0, height: 0.0, length: 0.0, chamferRadius: 0.0)
        let rootNode_1 = SCNNode(geometry: rootGeometry)
        rootNode_1.position = SCNVector3Make(0.0, 0.0, 0.0)
        gameView.scene.rootNode.addChildNode(rootNode_1)
        
        let navigationGeometry_1 = SCNBox(width: 3.0, height: 0.001, length: 0.1, chamferRadius: 0.0)
        let material_1 = SCNMaterial()
        let image_1 = UIImage(named: "navigation_right.png")
        material_1.diffuse.contents = image_1
        material_1.lightingModel = .physicallyBased
        navigationGeometry_1.materials = [material_1]
        let navigationNode_1 = SCNNode(geometry: navigationGeometry_1)
        navigationNode_1.position = SCNVector3Make(1.5, 0.0, 0.0)
        rootNode_1.eulerAngles.y = (90 - 60) / 180 * .pi
        rootNode_1.addChildNode(navigationNode_1)
        
        //向东，顺时针 （偏南 60度）4米
        
        let rootNode_2 = SCNNode(geometry: rootGeometry)
        rootNode_2.position = SCNVector3Make(1.5, 0.0, 0.0)
        navigationNode_1.addChildNode(rootNode_2)
        
        let navigationGeometry_2 = SCNBox(width: 4.0, height: 0.001, length: 0.1, chamferRadius: 0.0)
        navigationGeometry_2.materials = [material_1]
        let navigationNode_2 = SCNNode(geometry: navigationGeometry_2)
        navigationNode_2.position = SCNVector3Make(2.0, 0.0, 0.0)
        rootNode_2.eulerAngles.y = (90 + 30) / 180 * .pi
        rootNode_2.addChildNode(navigationNode_2)
        
        
        //向北，顺时针 （偏东 60度） 4米
        
        let rootNode_3 = SCNNode(geometry: rootGeometry)
        rootNode_3.position = SCNVector3Make(2.0, 0.0, 0.0)
        navigationNode_2.addChildNode(rootNode_3)
        
        let navigationGeometry_3 = SCNBox(width: 4.0, height: 0.001, length: 0.1, chamferRadius: 0.0)
        navigationGeometry_3.materials = [material_1]
        let navigationNode_3 = SCNNode(geometry: navigationGeometry_3)
        navigationNode_3.position = SCNVector3Make(2.0, 0.0, 0.0)
        rootNode_3.eulerAngles.y = 90 / 180 * .pi
        rootNode_3.addChildNode(navigationNode_3)
        
    }
    
    /// MARK: - ARSCNViewDelegate
    
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
//        警卫：识别锚点类型是 ARImageAnchor
        guard let imageAnchor = anchor as? ARImageAnchor else {
            return
        }
        
        let refrenceImage = imageAnchor.referenceImage
        
        if refrenceImage.name == "golden_century_1" {
            
            print("golden_century_1")
        }
        else if refrenceImage.name == "car_1" {
            self.distinationType = .Car_1
            print("girl_1")
            distinguishSuccess()
        }
        else if refrenceImage.name == "car_2" {
            self.distinationType = .Car_2
            print("girl_2")
            distinguishSuccess()
        }
        else if refrenceImage.name == "car_3" {
            self.distinationType = .Car_3
            print("girl_3")
        }
        
    }
    

}



// MARK: - CLLocationManagerDelegate

extension ARNavigationViewController: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didUpdateHeading newHeading: CLHeading) {
        //判断当前设备的朝向是否可用
        guard newHeading.headingAccuracy > 0 else {
            return
        }
        
        directioinAngle = -((180 - newHeading.magneticHeading)/180 * .pi)
        
    }
    
}
