//
//  ViewController.swift
//  AuthorityOfCameraAndPhoto
//
//  Created by CHLMA2015 on 2017/6/28.
//  Copyright © 2017年 MACHUNLEI. All rights reserved.
//

import UIKit
import AVFoundation
import AssetsLibrary
import Photos

class ViewController: UIViewController, UIImagePickerControllerDelegate,UINavigationControllerDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        title = "相机照片授权Demo"
        view.backgroundColor = UIColor.white
        self.configUI()
    }

    func configUI() -> Void {
        view.addSubview(cameraBtn)
        view.addSubview(photoBtn)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        cameraBtn.frame = CGRect(x: 20, y: 100, width: view.frame.width -  40, height: 40)
        photoBtn.frame = CGRect(x: 20, y: 160, width: view.frame.width -  40, height: 40)
    }
    
    func optimalCameraBtnPressed(_ sender: UIButton) -> Void {
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.camera) {
            // 应用第一次申请权限调用这里
            if isCameraNotDetermined() {
                AVCaptureDevice.requestAccess(forMediaType: AVMediaTypeVideo, completionHandler: { (granted:Bool) in
                    let main = DispatchQueue.main
                    main.async {
                        
                        if granted {
                            // 用户授权
                            self.presentToImagePickerController(type: UIImagePickerControllerSourceType.camera)
                        }else{
                            // 用户拒绝授权
                            NSLog("%@", "用户拒绝授权")
                        }
                    }
                })
            }
                // 用户已经拒绝访问摄像头
            else if isCameraDenied(){
                self.showAlertController(title: "提示", message: "拒绝访问摄像头，可去设置隐私里开启")
            }
                // 用户允许访问摄像头
            else{
                self.presentToImagePickerController(type: UIImagePickerControllerSourceType.camera)
            }
        }
            // 当前设备不支持摄像头，比如模拟器
        else{
            self.showAlertController(title: "提示", message: "当前设备不支持拍照")
        }
    }
    
    func optimalPhotoBtnPressed(_ sender: UIButton) -> Void {
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.photoLibrary) {
            // 还未确定权限，调用这里
            if isPhotoAlbumNotDetermined() {
                let version:String = UIDevice.current.systemVersion
                let f1:Float = version._bridgeToObjectiveC().floatValue
                if ( f1 >= 8.0) {
                    
                    // 该API从iOS8.0开始支持
                    // 系统弹出授权对话框
                    PHPhotoLibrary.requestAuthorization({ (status:PHAuthorizationStatus ) in
                        if (status == PHAuthorizationStatus.restricted || status == PHAuthorizationStatus.denied){
                            // 用户拒绝
                            NSLog("%@", "用户拒绝授权")
                        }
                        else{
                            // 用户授权，弹出相册对话框
                            self.presentToImagePickerController(type: UIImagePickerControllerSourceType.photoLibrary)
                        }
                    })
                }
            }
                // 如果已经拒绝，则弹出对话框
            else if isPhotoAlbumDenied(){
                self.showAlertController(title: "提示", message: "拒绝访问相册，可去设置隐私里开启")
            }
                // 已经授权，跳转到相册页面
            else{
                self.presentToImagePickerController(type: UIImagePickerControllerSourceType.photoLibrary)
            }
        }
            // 当前设备不支持打开相册
        else{
            self.showAlertController(title: "提示", message: "当前设备不支持相册")
        }
    }
    
    func presentToImagePickerController(type:UIImagePickerControllerSourceType) -> Void {
        
        let picker:UIImagePickerController = UIImagePickerController.init()
        picker.delegate = self
        picker.allowsEditing = true
        picker.sourceType = type
        self.present(picker, animated: true, completion: nil)
    }
    
    func showAlertController(title:NSString, message:NSString) -> Void {
        NSLog(">>>>>     %@ %@", title, message)
    }
    
    func isCameraDenied() -> Bool {
        let author = AVCaptureDevice.authorizationStatus(forMediaType: AVMediaTypeVideo)
        if ( author == AVAuthorizationStatus.restricted || author == AVAuthorizationStatus.denied ){
            return true
        }
        return false
    }
    
    func isCameraNotDetermined() -> Bool {
        let author = AVCaptureDevice.authorizationStatus(forMediaType: AVMediaTypeVideo)
        if author == AVAuthorizationStatus.notDetermined {
            return true
        }
        return false
    }
    
    func isPhotoAlbumDenied() -> Bool {
        //        // 9.0 之前
        //        let author = ALAssetsLibrary.authorizationStatus()
        //        if author == ALAuthorizationStatus.restricted || author == ALAuthorizationStatus.denied {
        //            return true
        //        }
        // 9.0 之后
        let author = PHPhotoLibrary.authorizationStatus()
        if ( author == PHAuthorizationStatus.restricted || author == PHAuthorizationStatus.denied ) {
            return true
        }
        return false
    }
    
    func isPhotoAlbumNotDetermined() -> Bool {
        //        // 9.0 之前
        //        let author = ALAssetsLibrary.authorizationStatus()
        //        if author == ALAuthorizationStatus.notDetermined {
        //            return true
        //        }
        // 9.0 之后
        let author = PHPhotoLibrary.authorizationStatus()
        if author == PHAuthorizationStatus.notDetermined {
            return true
        }
        return false
    }
    
    fileprivate lazy var cameraBtn: UIButton = {
        let cameraBtn = UIButton(type: .custom)
        cameraBtn.setTitle("相机授权", for: UIControlState())
        cameraBtn.setTitleColor(.blue, for: UIControlState())
        cameraBtn.backgroundColor = .yellow
        cameraBtn.addTarget(self, action: #selector(optimalCameraBtnPressed(_:)), for: .touchUpInside)
        
        return cameraBtn
    }()
    
    fileprivate lazy var photoBtn: UIButton = {
        let photoBtn = UIButton(type: .custom)
        photoBtn.setTitle("相册授权", for: UIControlState())
        photoBtn.setTitleColor(.blue, for: UIControlState())
        photoBtn.backgroundColor = .magenta
        photoBtn.addTarget(self, action: #selector(optimalPhotoBtnPressed(_:)), for: .touchUpInside)
        
        return photoBtn
    }()
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

