//
//  MainViewController.m
//  AuthorityOfCameraAndPhoto_OC
//
//  Created by CHLMA2015 on 2017/6/28.
//  Copyright © 2017年 MACHUNLEI. All rights reserved.
//

#import "MainViewController.h"

@import AVFoundation;
@import Photos;
@import AVFoundation;
@import AssetsLibrary;
@interface MainViewController ()<UIImagePickerControllerDelegate,UINavigationControllerDelegate>

@end

@implementation MainViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = @"相机照片授权";
    [self configUI];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)configUI {
    UIButton *cameraBtn = [UIButton buttonWithType:UIButtonTypeSystem];
    [cameraBtn setTitle:@"原始的摄像头授权" forState:UIControlStateNormal];
    [cameraBtn addTarget:self action:@selector(cameraBtnPressed:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:cameraBtn];
    [cameraBtn setFrame:CGRectMake(10, 100, self.view.frame.size.width - 20, 30)];
    
    UIButton *photoBtn = [UIButton buttonWithType:UIButtonTypeSystem];
    [photoBtn setTitle:@"原始的相册授权" forState:UIControlStateNormal];
    [photoBtn addTarget:self action:@selector(photoBtnPressed:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:photoBtn];
    [photoBtn setFrame:CGRectMake(10, 150, self.view.frame.size.width - 20, 30)];
    
    UIButton *optimalCameraBtn = [UIButton buttonWithType:UIButtonTypeSystem];
    [optimalCameraBtn setTitle:@"优化的摄像头授权" forState:UIControlStateNormal];
    [optimalCameraBtn addTarget:self action:@selector(optimalCameraBtnPressed:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:optimalCameraBtn];
    [optimalCameraBtn setFrame:CGRectMake(10, 200, self.view.frame.size.width - 20, 30)];
    
    UIButton *optimalPhotoBtn = [UIButton buttonWithType:UIButtonTypeSystem];
    [optimalPhotoBtn setTitle:@"优化的相册授权" forState:UIControlStateNormal];
    [optimalPhotoBtn addTarget:self action:@selector(optimalPhotoBtnPressed:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:optimalPhotoBtn];
    [optimalPhotoBtn setFrame:CGRectMake(10, 250, self.view.frame.size.width - 20, 30)];
}

- (void)cameraBtnPressed:(id)sender {
    // 首先查看当前设备是否支持拍照
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera])
    {
        [self presentToImagePickerController:UIImagePickerControllerSourceTypeCamera];
    }else{
        [self showAlertController:@"提示" message:@"当前设备不支持拍照"];
    }
}

- (void)photoBtnPressed:(id)sender {
    // 首先查看当前设备是否支持相册
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary])
    {
        [self presentToImagePickerController:UIImagePickerControllerSourceTypePhotoLibrary];
    }else{
        [self showAlertController:@"提示" message:@"当前设备不支持相册"];
    }
}

- (void)optimalCameraBtnPressed:(id)sender {
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera])
    {
        // 应用第一次申请权限调用这里
        if ([self isCameraNotDetermined])
        {
            [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo completionHandler:^(BOOL granted) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    if (granted)
                    {
                        // 用户授权
                        [self presentToImagePickerController:UIImagePickerControllerSourceTypeCamera];
                    }
                    else
                    {
                        // 用户拒绝授权
                        NSLog(@"用户拒绝授权");
                    }
                });
            }];
        }
        // 用户已经拒绝访问摄像头
        else if ([self isCameraDenied])
        {
            [self showAlertController:@"提示" message:@"拒绝访问摄像头，可去设置隐私里开启"];
        }
        // 用户允许访问摄像头
        else
        {
            [self presentToImagePickerController:UIImagePickerControllerSourceTypeCamera];
        }
    }
    else
    {
        // 当前设备不支持摄像头，比如模拟器
        [self showAlertController:@"提示" message:@"当前设备不支持拍照"];
    }
}

- (void)optimalPhotoBtnPressed:(id)sender
{
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary])
    {
        // 第一次安装App，还未确定权限，调用这里
        if ([self isPhotoAlbumNotDetermined])
        {
            if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0)
            {
                // 该API从iOS8.0开始支持
                // 系统弹出授权对话框
                [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        if (status == PHAuthorizationStatusRestricted || status == PHAuthorizationStatusDenied)
                        {
                            // 用户拒绝，跳转到自定义提示页面
                            NSLog(@"用户拒绝授权");
                        }
                        else if (status == PHAuthorizationStatusAuthorized)
                        {
                            // 用户授权，弹出相册对话框
                            [self presentToImagePickerController:UIImagePickerControllerSourceTypePhotoLibrary];
                        }
                    });
                }];
            }
            else
            {
                // 以上requestAuthorization接口只支持8.0以上，如果App支持7.0及以下，就只能调用这里。
                [self presentToImagePickerController:UIImagePickerControllerSourceTypePhotoLibrary];
            }
        }
        else if ([self isPhotoAlbumDenied])
        {
            // 如果已经拒绝，则弹出对话框
            [self showAlertController:@"提示" message:@"拒绝访问相册，可去设置隐私里开启"];
        }
        else
        {
            // 已经授权，跳转到相册页面
            [self presentToImagePickerController:UIImagePickerControllerSourceTypePhotoLibrary];
        }
    }
    else
    {
        // 当前设备不支持打开相册
        [self showAlertController:@"提示" message:@"当前设备不支持相册"];
    }
}

- (void)presentToImagePickerController:(UIImagePickerControllerSourceType)type {
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    picker.delegate = self;
    picker.allowsEditing = YES;
    picker.sourceType = type;
    [self presentViewController:picker animated:YES completion:nil];
}

- (void)showAlertController:(NSString *)title message:(NSString *)message {
    UIAlertController *ac = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
    [ac addAction:[UIAlertAction actionWithTitle:@"我知道了" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        
    }]];
    [self presentViewController:ac animated:YES completion:nil];
}

- (BOOL)isCameraDenied {
    AVAuthorizationStatus author = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
    if (author == AVAuthorizationStatusRestricted || author == AVAuthorizationStatusDenied)
    {
        return YES;
    }
    return NO;
}

- (BOOL)isCameraNotDetermined {
    AVAuthorizationStatus author = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
    if (author == AVAuthorizationStatusNotDetermined)
    {
        return YES;
    }
    return NO;
}

- (BOOL)isPhotoAlbumDenied {
//    ALAuthorizationStatus author = [ALAssetsLibrary authorizationStatus];
//    if (author == ALAuthorizationStatusRestricted || author == ALAuthorizationStatusDenied)
//    {
//        return YES;
//    }
    PHAuthorizationStatus author = [PHPhotoLibrary authorizationStatus];
    if (author == PHAuthorizationStatusRestricted || author == PHAuthorizationStatusDenied) {
        return YES;
    }
    return NO;
}

- (BOOL)isPhotoAlbumNotDetermined {
//    ALAuthorizationStatus author = [ALAssetsLibrary authorizationStatus];
//    if (author == ALAuthorizationStatusNotDetermined)
//    {
//        return YES;
//    }
    PHAuthorizationStatus author = [PHPhotoLibrary authorizationStatus];
    if (author == PHAuthorizationStatusNotDetermined) {
        return YES;
    }
    return NO;
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
