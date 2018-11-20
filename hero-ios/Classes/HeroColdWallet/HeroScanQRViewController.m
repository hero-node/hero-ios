//
//  HeroScanQRViewController.m
//  hero-ios
//
//  Created by 李潇 on 2018/11/20.
//

#import <AVFoundation/AVFoundation.h>
#import "HeroScanQRViewController.h"
#import "HeroQRCoder.h"
#import "UIView+Hero.h"


#define TOP (SCREEN_H-220)/2
#define LEFT (SCREEN_W-220)/2

#define kScanRect CGRectMake(LEFT, TOP, 220, 220)

@interface HeroScanQRViewController () <UIImagePickerControllerDelegate>

@property (nonatomic, copy) void(^completion)(NSString *result);

@property (nonatomic) AVCaptureDevice *device;
@property (nonatomic) AVCaptureDeviceInput *input;
@property (nonatomic) AVCaptureMetadataOutput *output;
@property (nonatomic) AVCaptureSession *session;
@property (nonatomic) AVCaptureVideoPreviewLayer *preview;

@property (nonatomic) NSTimer *timer;
@property (nonatomic) UIImageView *line;

@property (nonatomic) UIImagePickerController *picker;

@end

@implementation HeroScanQRViewController {
    int num;
    BOOL upOrDown;
    CAShapeLayer *cropLayer;
}

- (instancetype)initWithCompletion:(void (^)(NSString * _Nonnull))completion {
    if (self = [self init]) {
        self.completion = completion;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = @"扫描二维码";
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"相册" style:UIBarButtonItemStylePlain target:self action:@selector(onAlbumTapped)];
    self.navigationItem.rightBarButtonItem.tintColor = [UIColor whiteColor];
    
    [self setupUI];
}

- (void)onAlbumTapped {
    [self presentViewController:self.picker animated:YES completion:nil];
}

- (void)setupUI {
    NSBundle *bundle = [NSBundle bundleWithURL:[[NSBundle bundleForClass:[self class]] URLForResource:@"hero-ios" withExtension:@"bundle"]];
    
    UIImageView *sacnBorder = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"scanBorder" inBundle:bundle compatibleWithTraitCollection:nil]];
    sacnBorder.frame = kScanRect;
    [self.view addSubview:sacnBorder];
    
    upOrDown = NO;
    num = 0;
    
    _line = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"scanLine" inBundle:bundle compatibleWithTraitCollection:nil]];
    _line.frame = CGRectMake(LEFT, TOP+10, 220, 2);
    [self.view addSubview:_line];
    
    _picker = [[UIImagePickerController alloc] init];
    _picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    _picker.delegate = self;
    
    [self setupCamera];
    [self setCropRect:kScanRect];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    self.timer = [NSTimer scheduledTimerWithTimeInterval:0.02 target:self selector:@selector(timerTrigger) userInfo:nil repeats:YES];
    [self.session startRunning];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    
    [self.session stopRunning];
    [self.timer invalidate];
    self.timer = nil;
}

- (void)timerTrigger {
    if (upOrDown == NO) {
        num ++;
        _line.frame = CGRectMake(LEFT, TOP+10+2*num, 220, 2);
        if (2*num == 200) {
            upOrDown = YES;
        }
    }
    else {
        num --;
        _line.frame = CGRectMake(LEFT, TOP+10+2*num, 220, 2);
        if (num == 0) {
            upOrDown = NO;
        }
    }
}

- (void)setCropRect:(CGRect)cropRect{
    cropLayer = [[CAShapeLayer alloc] init];
    CGMutablePathRef path = CGPathCreateMutable();
    CGPathAddRect(path, nil, cropRect);
    CGPathAddRect(path, nil, self.view.bounds);
    
    [cropLayer setFillRule:kCAFillRuleEvenOdd];
    [cropLayer setPath:path];
    [cropLayer setFillColor:[UIColor blackColor].CGColor];
    [cropLayer setOpacity:0.6];
    
    [cropLayer setNeedsDisplay];
    
    [self.view.layer addSublayer:cropLayer];
}

- (void)setupCamera {
    AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    if (device==nil) {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"提示" message:@"设备没有摄像头" preferredStyle:UIAlertControllerStyleAlert];
        [alert addAction:[UIAlertAction actionWithTitle:@"确认" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            
        }]];
        [self presentViewController:alert animated:YES completion:nil];
        return;
    }
    // Device
    self.device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    
    // Input
    self.input = [AVCaptureDeviceInput deviceInputWithDevice:self.device error:nil];
    
    // Output
    self.output = [[AVCaptureMetadataOutput alloc] init];
    [self.output setMetadataObjectsDelegate:self queue:dispatch_get_main_queue()];
    
    //设置扫描区域
    CGFloat top = TOP/SCREEN_H;
    CGFloat left = LEFT/SCREEN_W;
    CGFloat width = 220/SCREEN_W;
    CGFloat height = 220/SCREEN_H;
    ///top 与 left 互换  width 与 height 互换
    [self.output setRectOfInterest:CGRectMake(top, left, height, width)];
    
    
    // Session
    self.session = [[AVCaptureSession alloc]init];
    [self.session setSessionPreset:AVCaptureSessionPresetHigh];
    if ([self.session canAddInput:self.input])
    {
        [self.session addInput:self.input];
    }
    
    if ([self.session canAddOutput:self.output])
    {
        [self.session addOutput:self.output];
    }
    
    // 条码类型 AVMetadataObjectTypeQRCode
    [self.output setMetadataObjectTypes:[NSArray arrayWithObjects:AVMetadataObjectTypeQRCode, nil]];
    
    // Preview
    self.preview =[AVCaptureVideoPreviewLayer layerWithSession:self.session];
    self.preview.videoGravity = AVLayerVideoGravityResizeAspectFill;
    self.preview.frame =self.view.layer.bounds;
    [self.view.layer insertSublayer:self.preview atIndex:0];
    
    // Start
    [self.session startRunning];
}

#pragma mark AVCaptureMetadataOutputObjectsDelegate
- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputMetadataObjects:(NSArray *)metadataObjects fromConnection:(AVCaptureConnection *)connection {
    NSString *stringValue;
    
    if ([metadataObjects count] >0) {
        //停止扫描
        [self.session stopRunning];
        [self.timer setFireDate:[NSDate distantFuture]];
        
        AVMetadataMachineReadableCodeObject * metadataObject = [metadataObjects objectAtIndex:0];
        stringValue = metadataObject.stringValue;
        NSLog(@"扫描结果：%@",stringValue);
        
        NSArray *arry = metadataObject.corners;
        for (id temp in arry) {
            NSLog(@"%@",temp);
        }
        
        if (self.completion) {
            [self.navigationController popViewControllerAnimated:YES];
            self.completion(stringValue);
        }
        
    } else {
        NSLog(@"无扫描信息");
        return;
    }
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<UIImagePickerControllerInfoKey,id> *)info {
    [self dismissViewControllerAnimated:YES completion:^{
        UIActivityIndicatorView *loading = [[UIActivityIndicatorView alloc] init];
        loading.activityIndicatorViewStyle = UIActivityIndicatorViewStyleWhite;
        loading.center = self.view.center;
        [self.view addSubview:loading];
        [loading startAnimating];
        UIImage *image = info[UIImagePickerControllerOriginalImage];
        NSString *result = [HeroQRCoder readQRCodeFromImage:image];
        [loading stopAnimating];
        [loading removeFromSuperview];
        if (result.length > 0) {
            if (self.completion) {
                self.completion(result);
                [self.navigationController popViewControllerAnimated:YES];
            }
        } else {
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"扫描失败" message:@"无法扫描该图片" preferredStyle:UIAlertControllerStyleAlert];
            [alert addAction:[UIAlertAction actionWithTitle:@"确认" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                
            }]];
            [self presentViewController:alert animated:YES completion:nil];
        }
    }];
    
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
