//
//  ARNavigationVectorViewController.swift
//  ARNavigatioin
//
//  Created by Zhang xiaosong on 2018/5/28.
//  Copyright © 2018年 Zhang xiaosong. All rights reserved.
//

import UIKit
import CoreLocation
import CoreMotion
import ARKit
import SceneKit

/// vectore导航
class ARNavigationVectorViewController: ARSCNBaseViewController {
    
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
    
    var needResetOrignalWorld = false //是否需要重新设置世界原点
    
    var navControl: DrawNavigation!//导航绘制类
    
    var distinationType: DistinationType!
    
    var locationArray = Array<SCNVector3>()

    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = "AR导航"
        setupMyView()
        
        self.getRecordLocation()
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
            
            let t1_matrix4_T = SCNMatrix4MakeTranslation(0.0, 0.0, 0.0)
            
            let mXY = SCNMatrix4Mult(matrix4_X, r_matrix4_Y)
            let mXYZ = SCNMatrix4Mult(mXY, matrix4_Z)
            let mT = SCNMatrix4Mult(mXYZ, t1_matrix4_T)
            
            gameView.session.setWorldOrigin(relativeTransform: simd_float4x4(mT))
            
            self.goDrawNavigation()
            
        }
    }
    
    /// MARK: - private methods
    
    /// 绘制导航
    private func goDrawNavigation() {
        self.navControl = DrawNavigation(self.gameView)
        
        self.navControl.showNavigation(vectorArray: locationArray)
    }
    
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
    
    /// 识别图片成功
    private func distinguishSuccess() {
        needResetOrignalWorld = true
        deviceMotionSuccess = false
        deviceMotionPush()
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
            distinguishSuccess()
        }
        
    }
    

    /// 获取向量记录
    private func getRecordLocation() {
        let defaults = UserDefaults.standard
        let data = defaults.data(forKey: "RecordLocation")
        let array = NSKeyedUnarchiver.unarchiveObject(with: data!) as! Array<SCNVector3>
//
        for obj in array {
//            if let position = obj as? SCNVector3 {
                locationArray.append(obj)
//            }
        }
        
        print("location array  \(array)")
        
    }

}

// MARK: - CLLocationManagerDelegate

extension ARNavigationVectorViewController: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didUpdateHeading newHeading: CLHeading) {
        //判断当前设备的朝向是否可用
        guard newHeading.headingAccuracy > 0 else {
            return
        }
        
        directioinAngle = -((180 - newHeading.magneticHeading)/180 * .pi)
        
    }
    
}
