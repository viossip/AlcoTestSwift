//
//  TGCameraViewController.m
//  TGCameraViewController
//
//  Created by Bruno Tortato Furtado on 13/09/14.
//  Copyright (c) 2014 Tudo Gostoso Internet. All rights reserved.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.

#import "TGCameraViewController.h"
#import "TGPhotoViewController.h"
#import "TGCameraSlideView.h"
#import "TGTintedButton.h"
#import "MZTimerLabel.h"
#import "CMDeviceMotionDemo.h"
#import "AlcoTestDroid-Swift.h"
#import <CoreLocation/CoreLocation.h>
//#import "HighpassFilter.h"


@import CoreMotion;
#define kUpdateFrequency 60.0
static double timeInterval  =  1.0/kUpdateFrequency;
@interface TGCameraViewController () <UIImagePickerControllerDelegate, UINavigationControllerDelegate, MZTimerLabelDelegate, NSLayoutManagerDelegate, CLLocationManagerDelegate>{
    
    MZTimerLabel *timerExample7;
    NSInteger game_level;
    
    double lastAx[4],lastAy[4],lastAz[4];
    int countX, countY, countZ, accCount;
    double lastVx, lastVy, lastVz, maxV;
    
    double lastV;
    int type;
    double progress;
    
    double timeCount;
    
    bool bFirstTime;
    
    HighpassFilter * filter;
    CMMotionManager * manager;
    
    double distance;
    int time;
    
}



@property (strong, nonatomic) IBOutlet UIView *captureView;
@property (strong, nonatomic) IBOutlet UIImageView *topLeftView;
@property (strong, nonatomic) IBOutlet UIImageView *topRightView;
@property (strong, nonatomic) IBOutlet UIImageView *bottomLeftView;
@property (strong, nonatomic) IBOutlet UIImageView *bottomRightView;
@property (strong, nonatomic) IBOutlet UIView *separatorView;
@property (strong, nonatomic) IBOutlet UIView *actionsView;
@property (strong, nonatomic) IBOutlet TGTintedButton *closeButton;
@property (strong, nonatomic) IBOutlet TGTintedButton *gridButton;
@property (strong, nonatomic) IBOutlet TGTintedButton *toggleButton;
@property (strong, nonatomic) IBOutlet TGTintedButton *shotButton;
@property (strong, nonatomic) IBOutlet TGTintedButton *albumButton;
@property (strong, nonatomic) IBOutlet UIButton *flashButton;
@property (strong, nonatomic) IBOutlet TGCameraSlideView *slideUpView;
@property (strong, nonatomic) IBOutlet TGCameraSlideView *slideDownView;
@property (weak, nonatomic) IBOutlet UILabel *timerExample7;
@property (weak, nonatomic) IBOutlet UIView *vwScopr;
@property (weak, nonatomic) IBOutlet UIImageView *vwEffect;
@property (nonatomic, assign) BOOL paused;



@property (weak, nonatomic) IBOutlet NSLayoutConstraint *topViewHeight;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *toggleButtonWidth;

@property (strong, nonatomic) TGCamera *camera;
@property (nonatomic) BOOL wasLoaded;
@property (nonatomic, strong) UIView * ball;
@property (nonatomic, strong) CMMotionManager * motionManager;

@property (nonatomic, strong) CLLocationManager *locationManager;
@property (nonatomic, strong) CLLocation *currentLocation;


- (IBAction)closeTapped;
- (IBAction)gridTapped;
- (IBAction)flashTapped;
- (IBAction)shotTapped;
- (IBAction)albumTapped;
- (IBAction)toggleTapped;
//- (IBAction)handleTapGesture:(UITapGestureRecognizer *)recognizer;
- (void)deviceOrientationDidChangeNotification;
- (AVCaptureVideoOrientation)videoOrientationForDeviceOrientation:(UIDeviceOrientation)deviceOrientation;
- (void)viewWillDisappearWithCompletion:(void (^)(void))completion;
- (void)initRoundedFatProgressBar;

@end

@protocol managerDelegate  <NSObject>

-(void)doSomthingAndGetThisString: (NSString *)stringText;

@end

@interface Manager : NSObject
@property (nonatomic,strong) id <managerDelegate>delegate;

@end


@implementation TGCameraViewController

float X = 0;
float Y = 0;
float R = 40;

float StableX = 0.004;
float StableY = 0.004;
float RotX = 0.05;
float RotY = 0.05;

float degree = 20;

bool StateX = false;
bool StateY = false;
bool State_RotX = false;
bool State_RotY = false;
bool Horizon = false;
bool State_left = false;
bool State_right = false;
bool State_up = false;
bool State_down = false;
bool State_loose = false;

- (void)initBall
{
    self.ball = [[UIView alloc] initWithFrame:CGRectMake(160, 250, R, R)];
    self.ball.layer.cornerRadius = 20;
    self.ball.backgroundColor = [UIColor redColor];
    [self.view addSubview:self.ball];
}

- (void)updateBallWithRoll:(float)roll Pitch:(float)pitch Yaw:(float)yaw accX:(float)accX accY:(float)accY accZ:(float)accZ
{
    _vwScopr.layer.borderColor = (__bridge CGColorRef _Nullable)(UIColor.whiteColor);
    _vwScopr.layer.borderWidth = 1.0f;
    
    X += 2 * roll;
    Y += 2 * pitch;
    
    X *= 0.8;
    Y *= 0.8;
    
    CGFloat newX = self.ball.frame.origin.x + X;
    CGFloat newY = self.ball.frame.origin.y + Y;
    
    StateX = accX <= StableX && accX >= -StableX;
    StateY = accY <= StableY && accY >= -StableY;
    State_RotX = roll <= RotX && roll >= -RotX;
    State_RotY = pitch <= RotY && pitch >= - RotY;
    
    Horizon = StateX && StateX && State_RotX && State_RotY;
    State_left = accX >= -0.008 && accX <= -StableX && roll <= -State_RotX;
    State_right = accX <= 0.008 && accX >= StableX && roll >= State_RotX;
    State_up = accY >= -0.008 && accY >= -StableY && pitch <= -State_RotY;
    State_down = accY <= 0.008 && accY >= -StableY && pitch >= State_RotY;
    State_loose = (accX > 0.04 && roll < -State_RotX*2) || (roll > State_RotX*2 && accX < -0.04) || (accY > 0.04 && pitch < -State_RotY*2)|| (pitch > State_RotY*2 && accY < -0.04);
    
    newX = fmin(280, fmax(0, newX));
    newY = fmin(527, fmax(64, newY));
    
    
    if(Horizon){
        _vwEffect.image = [UIImage imageNamed:@"normal_whisky.png"];
    }
    else if(!Horizon){
        if(State_left){
            _vwEffect.image = [UIImage imageNamed:@"left_whisky.png"];
        }
        
        if (State_right) {
            _vwEffect.image = [UIImage imageNamed:@"right_whisky.png"];
        }
        
        if(State_up){
            _vwEffect.image = [UIImage imageNamed:@"up_whisky.png"];
        }
        
        if (State_down) {
            _vwEffect.image = [UIImage imageNamed:@"down_whisky.png"];
        }
        
        if(State_loose){
            [self dismissViewControllerAnimated:false completion:^{
                NSString *score = self->_timerExample7.text;
                //    NSInteger *param = &(game_level);
                NSString * str = @"Loose";
                NSString *param = @"";
                if(self->_game_level == 1){
                    param = @"simple";
                }else if(self->_game_level ==  2){
                    param = @"advance";
                }else if(self->_game_level ==  3){
                    param = @"training";
                }
                if (self.delegate != nil) {
                    [self.delegate getScore:score];
                    [self.delegate getString:str];
                    [self.delegate getParam:param];
                }
            }];
        }
    }
    
    CGFloat newR = R + 10 * accZ;
    self.ball.frame = CGRectMake(newX, newY, newR, newR);
}

- (instancetype)init
{
    return [super initWithNibName:NSStringFromClass(self.class) bundle:[NSBundle bundleForClass:self.class]];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setProgress:0.0f animated:YES];
    [self initRoundedFatProgressBar];
    
    lastV = 0;
    time = 0;
    distance = 0;
    bFirstTime = true;
    timeCount = 0;
    
    (void)(lastVx = 0), (void)(lastVy = 0), lastVz = 0;
    accCount = maxV = type = 0;
    
    for (int i = 0; i < 4; ++i){
        lastAx[i] = lastAy[i] = lastAz[i] = 0;
    }
    
    if(distance > 20){
        [self dismissViewControllerAnimated:false completion:nil];
    }
    
    manager = [[CMMotionManager alloc] init];
    manager.accelerometerUpdateInterval = timeInterval;
    manager.gyroUpdateInterval = timeInterval;
    
    filter = [[HighpassFilter alloc] initWithSampleRate:kUpdateFrequency cutoffFrequency:5.0];
    
    [manager startDeviceMotionUpdatesToQueue:[NSOperationQueue currentQueue]
                                 withHandler:^(CMDeviceMotion *data, NSError *error) {
                                     [self outputAccelertion:data];
                                 }];
   
    if (CGRectGetHeight([[UIScreen mainScreen] bounds]) <= 480) {
        _topViewHeight.constant = 0;
    }
    
    NSArray *devices = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
    if (devices.count > 1) {
        if ([[TGCamera getOption:kTGCameraOptionHiddenToggleButton] boolValue] == YES) {
            _toggleButton.hidden = YES;
            _toggleButtonWidth.constant = 0;
        }
    }
    else {
        if ([[TGCamera getOption:kTGCameraOptionHiddenToggleButton] boolValue] == YES) {
            _toggleButton.hidden = YES;
            _toggleButtonWidth.constant = 0;
        }
    }
    
    if ([[TGCamera getOption:kTGCameraOptionHiddenAlbumButton] boolValue] == YES) {
        _albumButton.hidden = YES;
    }
    
    [_albumButton.layer setCornerRadius:10.f];
    [_albumButton.layer setMasksToBounds:YES];
    
    NSBundle *bundle = [NSBundle bundleForClass:self.class];
    [_closeButton setImage:[UIImage imageNamed:@"CameraClose" inBundle:bundle compatibleWithTraitCollection:nil] forState:UIControlStateNormal];
    [_shotButton setImage:[UIImage imageNamed:@"CameraShot" inBundle:bundle compatibleWithTraitCollection:nil] forState:UIControlStateNormal];
    [_albumButton setImage:[UIImage imageNamed:@"CameraRoll" inBundle:bundle compatibleWithTraitCollection:nil] forState:UIControlStateNormal];
    [_gridButton setImage:[UIImage imageNamed:@"CameraGrid" inBundle:bundle compatibleWithTraitCollection:nil] forState:UIControlStateNormal];
    [_toggleButton setImage:[UIImage imageNamed:@"CameraToggle" inBundle:bundle compatibleWithTraitCollection:nil] forState:UIControlStateNormal];
    
    _camera = [TGCamera cameraWithFlashButton:_flashButton];
    
    _captureView.backgroundColor = [UIColor clearColor];
    
    _topLeftView.transform = CGAffineTransformMakeRotation(0);
    _topRightView.transform = CGAffineTransformMakeRotation(M_PI_2);
    _bottomLeftView.transform = CGAffineTransformMakeRotation(-M_PI_2);
    _bottomRightView.transform = CGAffineTransformMakeRotation(M_PI_2*2);
    
    NSLog(@"%i",_game_level);
    if(_game_level == 1){
        timerExample7 = [[MZTimerLabel alloc] initWithLabel:_timerExample7 andTimerType:MZTimerLabelTypeTimer];
        timerExample7.timeFormat = @"mm:ss";
        [timerExample7 setCountDownTime:40];
        timerExample7.delegate = self;
        [timerExample7 start];

    }
    if(_game_level == 2){
        timerExample7 = [[MZTimerLabel alloc] initWithLabel:_timerExample7 andTimerType:MZTimerLabelTypeTimer];
        timerExample7.timeFormat = @"mm:ss";
        [timerExample7 setCountDownTime:20];
        timerExample7.delegate = self;
        [timerExample7 start];
    }
    if(_game_level == 3){
        
        timerExample7 = [[MZTimerLabel alloc] initWithLabel:_timerExample7 andTimerType:MZTimerLabelTypeStopWatch];
        timerExample7.timeFormat = @"HH:mm:ss";
        //[timerExample7 setCountDownTime:20];
        timerExample7.delegate = self;
        [timerExample7 start];//
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [self setProgress:0.0f animated:YES];
    [super viewWillAppear:animated];
    [self initBall];
    [NSTimer scheduledTimerWithTimeInterval:0.01 target:self selector:@selector(updateDeviceMotion) userInfo:nil repeats:YES];
    
    self.motionManager = [[CMMotionManager alloc] init]; self.motionManager.deviceMotionUpdateInterval = 1.0 / 60.0;
    
    [self.motionManager startDeviceMotionUpdatesUsingReferenceFrame: CMAttitudeReferenceFrameXArbitraryCorrectedZVertical];
    
    [super viewWillAppear:animated];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
    selector:@selector(deviceOrientationDidChangeNotification)
    name:UIDeviceOrientationDidChangeNotification object:nil];
    
    _separatorView.hidden = NO;
    
    _actionsView.hidden = YES;
    
    _topLeftView.hidden =
    _topRightView.hidden =
    _bottomLeftView.hidden =
    _bottomRightView.hidden = YES;
    
    _gridButton.enabled =
    _toggleButton.enabled =
    _shotButton.enabled =
    _albumButton.enabled =
    _flashButton.enabled = NO;
    
    [_camera startRunning];
}

- (void)viewDidAppear:(BOOL)animated
{
    [self setProgress:0.0f animated:YES];
    [super viewDidAppear:animated];
    [self deviceOrientationDidChangeNotification];
    _separatorView.hidden = YES;
    [TGCameraSlideView hideSlideUpView:_slideUpView slideDownView:_slideDownView atView:_captureView completion:^{
        _topLeftView.hidden =
        _topRightView.hidden =
        _bottomLeftView.hidden =
        _bottomRightView.hidden = NO;
        
        _actionsView.hidden = NO;
        
        _gridButton.enabled =
        _toggleButton.enabled =
        _shotButton.enabled =
        _albumButton.enabled =
        _flashButton.enabled = YES;
    }];
    
    if (_wasLoaded == NO) {
        _wasLoaded = YES;
        [_camera insertSublayerWithCaptureView:_captureView atRootView:self.view];
    }
}

- (void)viewDidUnload
{
    self.progressBarRoundedFat = nil;
    [super viewDidUnload];
}

-(void)updateDeviceMotion
{
    CMDeviceMotion *deviceMotion = self.motionManager.deviceMotion;
    if(deviceMotion == nil)
    {
        return;
    }
    
    CMAttitude *attitude = deviceMotion.attitude;
    CMAcceleration userAcceleration = deviceMotion.userAcceleration;
    
    float roll = attitude.roll;
    
    float pitch = attitude.pitch;
    
    float yaw = attitude.yaw;
    
    float accX = userAcceleration.x;
    
    float accY = userAcceleration.y;
    
    float accZ = userAcceleration.z;
    
    [self updateBallWithRoll:roll Pitch:pitch Yaw:yaw accX:accX accY:accY accZ:accZ];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [_camera stopRunning];
    [super viewDidDisappear:animated];
    
    if(self.motionManager != nil){
        [self.motionManager stopDeviceMotionUpdates];
        self.motionManager = nil;
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (BOOL)prefersStatusBarHidden
{
    return YES;
}

#pragma mark -
#pragma mark - UIImagePickerControllerDelegate

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    UIImage *photo = [TGAlbum imageWithMediaInfo:info];
    TGPhotoViewController *viewController = [TGPhotoViewController newWithDelegate:_delegate photo:photo];
    [viewController setAlbumPhoto:YES];
    [self.navigationController pushViewController:viewController animated:NO];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark -
#pragma mark - Actions

- (IBAction)closeTapped
{
    if ([_delegate respondsToSelector:@selector(cameraDidCancel)]) {
        [_delegate cameraDidCancel];
    }
}

- (IBAction)gridTapped
{
    [_camera disPlayGridView];
}

- (IBAction)flashTapped
{
    [_camera changeFlashModeWithButton:_flashButton];
}

- (IBAction)shotTapped
{
#if !TARGET_IPHONE_SIMULATOR
    _shotButton.enabled =
    _albumButton.enabled = NO;
    
    UIDeviceOrientation deviceOrientation = [[UIDevice currentDevice] orientation];
    AVCaptureVideoOrientation videoOrientation = [self videoOrientationForDeviceOrientation:deviceOrientation];
    
    dispatch_group_t group = dispatch_group_create();
    __block UIImage *photo;
    
    dispatch_group_enter(group);
    [self viewWillDisappearWithCompletion:^{
        dispatch_group_leave(group);
    }];
    
    dispatch_group_enter(group);
    [_camera takePhotoWithCaptureView:_captureView videoOrientation:videoOrientation cropSize:_captureView.frame.size completion:^(UIImage *_photo) {
        photo = _photo;
        dispatch_group_leave(group);
    }];
    
    dispatch_group_notify(group, dispatch_get_main_queue(), ^{
        TGPhotoViewController *viewController = [TGPhotoViewController newWithDelegate:_delegate photo:photo];
        [self.navigationController pushViewController:viewController animated:YES];
    });
#endif
}

- (IBAction)albumTapped
{
    _shotButton.enabled =
    _albumButton.enabled = NO;
    
    [self viewWillDisappearWithCompletion:^{
        UIImagePickerController *pickerController = [TGAlbum imagePickerControllerWithDelegate:self];
        pickerController.popoverPresentationController.sourceView = self.albumButton;
        [self presentViewController:pickerController animated:YES completion:nil];
    }];
}

- (IBAction)toggleTapped
{
    [_camera toogleWithFlashButton:_flashButton];
}


#pragma mark -
#pragma mark - Private methods

- (void)deviceOrientationDidChangeNotification
{
    UIDeviceOrientation orientation = [UIDevice.currentDevice orientation];
    NSInteger degress;
    
    switch (orientation) {
        case UIDeviceOrientationFaceUp:
        case UIDeviceOrientationPortrait:
        case UIDeviceOrientationUnknown:
            degress = 0;
            break;
            
        case UIDeviceOrientationLandscapeLeft:
            degress = 90;
            break;
            
        case UIDeviceOrientationFaceDown:
        case UIDeviceOrientationPortraitUpsideDown:
            degress = 180;
            break;
            
        case UIDeviceOrientationLandscapeRight:
            degress = 270;
            break;
    }
    
    CGFloat radians = degress * M_PI / 180;
    CGAffineTransform transform = CGAffineTransformMakeRotation(radians);
    
    [UIView animateWithDuration:.5f animations:^{
        _gridButton.transform =
        _toggleButton.transform =
        _albumButton.transform =
        _flashButton.transform = transform;
    }];
}

- (AVCaptureVideoOrientation)videoOrientationForDeviceOrientation:(UIDeviceOrientation)deviceOrientation
{
    AVCaptureVideoOrientation result = (AVCaptureVideoOrientation) deviceOrientation;
    
    switch (deviceOrientation) {
        case UIDeviceOrientationLandscapeLeft:
            result = AVCaptureVideoOrientationLandscapeRight;
            break;
            
        case UIDeviceOrientationLandscapeRight:
            result = AVCaptureVideoOrientationLandscapeLeft;
            break;
            
        default:
            break;
    }
    return result;
}

- (void)viewWillDisappearWithCompletion:(void (^)(void))completion
{
    _actionsView.hidden = YES;

    [TGCameraSlideView showSlideUpView:_slideUpView slideDownView:_slideDownView atView:_captureView completion:^{
        completion();
    }];
}

-(void)timerLabel:(MZTimerLabel*)timerLabel finshedCountDownTimerWithTime:(NSTimeInterval)countTime{
//    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
//    GameResultViewController *resultVC = [storyboard instantiateViewControllerWithIdentifier:@"resultVC"];
//    resultVC.game_State = @"Success";
//    [self presentViewController:resultVC animated:NO completion:nil];
    NSString *score = @"";
    NSString *param = @"";
    if(_game_level == 1){
        param = @"simple";
        score = @"40";
    }else if(_game_level ==  2){
        param = @"advance";
        score = @"20";
    }else if(_game_level ==  3){
        param = @"training";
    }
    NSString * str = @"";
    if (distance < 20) {
        str = @"Loose";
    } else {
        str = @"Success";
    }
    
    
    NSLog(@"Complete %f", self->distance);
//    NSString *distance = [NSString stringWithFormat:@"%@", distance];
    
    [self dismissViewControllerAnimated:false completion:^{
        
        if (self.delegate != nil) {
            [self.delegate getScore:score];
            [self.delegate getParam:param];
//            [self.delegate getDistance:distance];
            [self.delegate getString:str];
//            NSLog(str);
        }
    }];
}

- (void)outputAccelertion:(CMDeviceMotion*)data
{
    maxV = 0;
    CMAcceleration acc = [data userAcceleration];
    CMAcceleration gacc = [data gravity];
    acc.x += gacc.x, acc.y += gacc.y, acc.z += gacc.z;
    CMRotationMatrix rot = [data attitude].rotationMatrix;
    CMAcceleration accRef;
    
    //first correct the direction
    accRef.x = acc.x*rot.m11 + acc.y*rot.m12 + acc.z*rot.m13;
    accRef.y = acc.x*rot.m21 + acc.y*rot.m22 + acc.z*rot.m23;
    accRef.z = acc.x*rot.m31 + acc.y*rot.m32 + acc.z*rot.m33;
    
    //filter the data
    [filter addAcceleration:accRef];
    
    //add threshold
    accRef.x = (fabs(filter.x) < 0.01) ? 0 : filter.x;
    accRef.y = (fabs(filter.y) < 0.01) ? 0 : filter.y;
    accRef.z = (fabs(filter.z) < 0.01) ? 0 : filter.z;
    
    //we use simpson 3/8 integration method here
    accCount = (accCount+1)%4;
    
    lastAx[accCount] = accRef.x, lastAy[accCount] = accRef.y, lastAz[accCount] = accRef.z;
    
    if (accCount == 3){
        lastVx += (lastAx[0]+lastAx[1]*3+lastAx[2]*3+lastAx[3]) * 0.125 * timeInterval * 3;
        lastVy += (lastAy[0]+lastAy[1]*3+lastAy[2]*3+lastAy[3]) * 0.125 * timeInterval * 3;
        lastVz += (lastAz[0]+lastAz[1]*3+lastAz[2]*3+lastAz[3]) * 0.125 * timeInterval * 3;
    }
    
    //add a fake force
    //(when acc is zero for a continuous time, we should assume that velocity is zero)
    if (accRef.x == 0) countX++; else countX = 0;
    if (accRef.y == 0) countY++; else countY = 0;
    if (accRef.z == 0) countZ++; else countZ = 0;
    if (countX == 10){
        countX = 0;
        lastVx = 0;
    }
    if (countY == 10){
        countY = 0;
        lastVy = 0;
    }
    if (countZ == 10){
        countZ = 0;
        lastVz = 0;
    }

    double vx = lastVx * 9.8, vy = lastVy * 9.8, vz = lastVz * 9.8;
    lastV = sqrt(vx * vx + vy * vy + vz * vz);
    
    if (lastV == 0 && bFirstTime) {
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            while (self->distance <= 20) {
                usleep(200000);
                [self calculDistance];
            }
            
            dispatch_async(dispatch_get_main_queue(), ^{
                NSLog(@"Finished Dispatch");
                
                NSTimeInterval timeCounted = [self->timerExample7 getTimeCounted];
                
                NSString *countedTime = [NSString stringWithFormat:@"%.1f",timeCounted];
                
                [self dismissViewControllerAnimated:false completion:^{
                    //    NSInteger *param = &(game_level);
                    NSString * str = @"Success";
                    
                    NSString *param = @"";
                    if(self->_game_level == 1){
                        param = @"simple";
                    }else if(self->_game_level ==  2){
                        param = @"advance";
                    }else if(self->_game_level ==  3){
                        param = @"training";
                    }
                    
                    if (self.delegate != nil) {
                        [self.delegate getScore:countedTime];
                        [self.delegate getString:str];
                        [self.delegate getParam:param];
                        //            NSLog(str);
                    }
                }];
            });
        });
        bFirstTime = false;
    }
    
    if (fabs(maxV) < fabs(lastV)){
        maxV = lastV;
    }
//    NSLog(@"lastV;;;;%.2f m/s",lastV);
//    NSLog(@"X-%f/ Y-%f/  Z-%f",accRef.x, accRef.y, accRef.z);
//    NSLog(@"%.2f MAXZ",maxV);
}

-(void) valueChanged:(int)n{
    type = n;
}

-(void)calculDistance {
    
    timeCount += 0.2;
    
    if (timeCount < 2)
        return;
    
    distance += lastV ;
    progress = distance / 20 ;
    dispatch_async(dispatch_get_main_queue(), ^{
        [self setProgress:self->progress animated:YES];
        });
//    NSLog(@" Speed;  %lf  Distance;;; %lf", lastV, progress);
}
- (void)setProgress:(CGFloat)progress animated:(BOOL)animated
{
    [_progressBarRoundedFat setProgress:progress animated:animated];
}
- (void)initRoundedFatProgressBar
{
    NSArray *tintColors = @[[UIColor colorWithRed:33/255.0f green:180/255.0f blue:162/255.0f alpha:1.0f],
                            [UIColor colorWithRed:3/255.0f green:137/255.0f blue:166/255.0f alpha:1.0f],
                            [UIColor colorWithRed:91/255.0f green:63/255.0f blue:150/255.0f alpha:1.0f],
                            [UIColor colorWithRed:87/255.0f green:26/255.0f blue:70/255.0f alpha:1.0f],
                            [UIColor colorWithRed:126/255.0f green:26/255.0f blue:36/255.0f alpha:1.0f],
                            [UIColor colorWithRed:149/255.0f green:37/255.0f blue:36/255.0f alpha:1.0f],
                            [UIColor colorWithRed:228/255.0f green:69/255.0f blue:39/255.0f alpha:1.0f],
                            [UIColor colorWithRed:245/255.0f green:166/255.0f blue:35/255.0f alpha:1.0f],
                            [UIColor colorWithRed:165/255.0f green:202/255.0f blue:60/255.0f alpha:1.0f],
                            [UIColor colorWithRed:202/255.0f green:217/255.0f blue:54/255.0f alpha:1.0f],
                            [UIColor colorWithRed:111/255.0f green:188/255.0f blue:84/255.0f alpha:1.0f]];
    
    _progressBarRoundedFat.progressTintColors       = tintColors;
    _progressBarRoundedFat.stripesOrientation       = YLProgressBarStripesOrientationLeft;
    _progressBarRoundedFat.indicatorTextDisplayMode = YLProgressBarIndicatorTextDisplayModeProgress;
    _progressBarRoundedFat.indicatorTextLabel.font  = [UIFont fontWithName:@"Arial-BoldMT" size:20];
    _progressBarRoundedFat.progressStretch          = NO;
}

@end
