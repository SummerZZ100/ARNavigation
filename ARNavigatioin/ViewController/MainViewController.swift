//
//  MainViewController.swift
//  ARNavigatioin
//
//  Created by Zhang xiaosong on 2018/5/24.
//  Copyright © 2018年 Zhang xiaosong. All rights reserved.
//

import UIKit

class MainViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = "AR导航";
        // Do any additional setup after loading the view.
        
//        let navBtn = UIButton(frame: CGRect(x: 50.0, y: 100.0, width: self.view.frame.size.width - 100.0, height: 50.0))
//        self.view.addSubview(navBtn)
//        navBtn.setTitle("根据方向加载导航", for: .normal)
//        navBtn.setTitleColor(UIColor.blue, for: .normal)
//
//        navBtn.addTarget(self, action: #selector(navClick), for: .touchUpInside)
//
//        let arrowBtn = UIButton(frame: CGRect(x: 50.0, y: 200.0, width: self.view.frame.size.width - 100.0, height: 50.0))
//        self.view.addSubview(arrowBtn)
//        arrowBtn.setTitle("箭头导航", for: .normal)
//        arrowBtn.setTitleColor(UIColor.blue, for: .normal)
//
//        arrowBtn.addTarget(self, action: #selector(arrowClick), for: .touchUpInside)
        
        let logoImage = UIImageView(frame: CGRect(x: (self.view.frame.size.width - 90.0)/2, y: 150.0, width: 90.0, height: 90.0))
        logoImage.image = UIImage(named: "golden_century_4")
        self.view.addSubview(logoImage)
        
        let recordLocationBtn = UIButton(frame: CGRect(x: 50.0, y: 280.0, width: self.view.frame.size.width - 100.0, height: 50.0))
        self.view.addSubview(recordLocationBtn)
        recordLocationBtn.setTitle("记录采集导航信息", for: .normal)
        recordLocationBtn.setTitleColor(UIColor.blue, for: .normal)
        recordLocationBtn.addTarget(self, action: #selector(recordLocation), for: .touchUpInside)
        
        
        let showRecordVectorBtn = UIButton(frame: CGRect(x: 50.0, y: 350.0, width: self.view.frame.size.width - 100.0, height: 50.0))
        self.view.addSubview(showRecordVectorBtn)
        showRecordVectorBtn.setTitle("展示采集到的导航", for: .normal)
        showRecordVectorBtn.setTitleColor(UIColor.blue, for: .normal)
        showRecordVectorBtn.addTarget(self, action: #selector(showRecordVector), for: .touchUpInside)
        
        
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @objc func showRecordVector() {
        let recordVector = ARNavigationVectorViewController()
        self.navigationController?.pushViewController(recordVector, animated: true)
    }

     @objc func navClick() {
        let navController = ARNavigationViewController()
        self.navigationController?.pushViewController(navController, animated: true)
    }
    
    @objc func arrowClick() {
        let arrowController = ArrowViewController()
        self.navigationController?.pushViewController(arrowController, animated: true)
    }
    
    @objc func recordLocation() {
        let recordLocationController = RecordLocationViewController()
        self.navigationController?.pushViewController(recordLocationController, animated: true)
    }

}
