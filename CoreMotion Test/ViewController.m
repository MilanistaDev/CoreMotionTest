//
//  ViewController.m
//  CoreMotion Test
//
//  Created by 麻生 拓弥 on 2015/02/14.
//  Copyright (c) 2015年 麻生 拓弥. All rights reserved.
//

#import "ViewController.h"
#import <CoreMotion/CoreMotion.h> // 追加

@interface ViewController ()
@property (nonatomic, retain) CMMotionManager *motion;
@property (nonatomic, retain) CMMotionActivityManager *activity;
@property (nonatomic, retain) CMStepCounter *stepCounter;
@property (nonatomic, retain) CMPedometer *pedometer;
@property (nonatomic, retain) CMAltimeter *altitude;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
}

// iOS 8 での ViewAlertController のエラー回避(複数表示できないのは今後の課題)
-(void)viewDidAppear:(BOOL)animated {
    
    // 周波数:データを取得する頻度(Hz) T = 1/f(s)
    int frequency = 10; // 1 秒に 10 回
    
    // インスタンス生成(加速度，ジャイロ)
    self.motion = [[CMMotionManager alloc] init];
    // インスタンス生成(状態取得)
    self.activity = [[CMMotionActivityManager alloc] init];
    // インスタンス生成(歩数取得)
    self.stepCounter = [[CMStepCounter alloc] init];
    
    
    // iOS 7.0 以前共通
    // 加速度取得関数に 10 Hz を渡す
    [self getCMAccelerometerData:frequency];
    
    // ジャイロ取得関数に 10 Hz を渡す
    [self getCMGyroData:frequency];
    
    
    // ここから iOS 7.0 以降(今回は設定で iOS 7 以上にしているので場合分け不必要)
    // 状態取得関数を呼ぶ
    [self getMotionActivity];
    
    // 歩数取得関数を呼ぶ(iOS 7 と iOS 8 で異なる手法なので場合分け)
    float iOSVersion = [[[UIDevice currentDevice] systemVersion] floatValue];
    NSLog(@"iOS %f", iOSVersion);
    if(iOSVersion < 8.0) {
        // iOS 8.0 未満の処理
        [self getStep_iOS7];
        
        // iOS 7 で高度計は非対応
        _floorPlusLabel.text = @"Not supported";
        _floorDownLabel.text = @"Not supported";
        _altitudeLabel.text = @"Not supported";
        _pressureLabel.text = @"Not supported";
        
    } else {
        // iOS 8.0 以降の処理
        // 歩数，距離，階段上り下りの数
        [self getStep_iOS8];
        
        // 気圧，高度も iOS 8 以降でかつ iPhone 6 以降が必要なのでここに書いとく
        // 気圧，高度取得関数を呼ぶ
        [self getAltitude];
    }
}

// 加速度取得関数
- (void)getCMAccelerometerData:(int)frequency
{
    
    // 加速度センサが使用可能かを確認
    if (self.motion.accelerometerAvailable) {
        // 更新間隔の指定
        self.motion.accelerometerUpdateInterval = 1 / frequency;  // 秒
        // ハンドラ
        CMAccelerometerHandler handler = ^(CMAccelerometerData *data, NSError *error) {
            
            // 取得値を各ラベルにリアルタイム表示
            self.acc_xLabel.text = [NSString stringWithFormat:@"%lf", data.acceleration.x];
            self.acc_yLabel.text = [NSString stringWithFormat:@"%lf", data.acceleration.y];
            self.acc_zLabel.text = [NSString stringWithFormat:@"%lf", data.acceleration.z];
            
        };
        // センサの利用開始
        [self.motion startAccelerometerUpdatesToQueue:[NSOperationQueue currentQueue] withHandler:handler];
        
    } else {
        
        _acc_xLabel.text = @"Not supported";
        _acc_yLabel.text = @"Not supported";
        _acc_zLabel.text = @"Not supported";
    }
}

// ジャイロ取得関数
- (void)getCMGyroData:(int)frequency
{
    // ジャイロセンサの有無を確認
    if (self.motion.gyroAvailable) {
        // 更新間隔の指定
        self.motion.gyroUpdateInterval = 1 / frequency;  // 秒
        // ハンドラ
        CMGyroHandler handler = ^(CMGyroData *data, NSError *error) {
            
            // 取得値を各ラベルにリアルタイム表示
            self.gyro_xLabel.text = [NSString stringWithFormat:@"%lf", data.rotationRate.x];
            self.gyro_yLabel.text = [NSString stringWithFormat:@"%lf", data.rotationRate.y];
            self.gyro_zLabel.text = [NSString stringWithFormat:@"%lf", data.rotationRate.z];
            
        };
        // センサーの利用開始
        [self.motion startGyroUpdatesToQueue:[NSOperationQueue currentQueue] withHandler:handler];
        
    } else {
        
        _gyro_xLabel.text = @"Not supported";
        _gyro_yLabel.text = @"Not supported";
        _gyro_zLabel.text = @"Not supported";
    }
}


// 状態取得関数
-(void)getMotionActivity
{
    // 状態取得対象外のアラート処理(M7, M8 チップ非対応)
    if (![CMMotionActivityManager isActivityAvailable]) {
        
        float iOSVersion = [[[UIDevice currentDevice] systemVersion] floatValue];
        NSLog(@"iOS %f", iOSVersion);
        if(iOSVersion >= 8.0) {
            
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Not supported"
                                                                           message:@"Your device doesn't support CMMotionActivity."
                                                                    preferredStyle:UIAlertControllerStyleAlert];
        
            [alert addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            
            }]];
            [self presentViewController:alert animated:YES completion:nil];
            
        } else {
            
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil
                                                        message:@"Your device doesn't support CMMotionActivity."
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
            [alert show];
        
        }
        
        _confidenceLabel.text = @"Not supported";
        _motion_activityLabel.text = @"Not supported";
        _automotiveLabel.text = @"Not supported";
        _cyclingLabel.text = @"Not supported";
        
    // 状態取得可能の場合
    } else {
        
        [_activity startActivityUpdatesToQueue:[NSOperationQueue mainQueue]
                                   withHandler:^(CMMotionActivity *activity) {
                                       
            // 状態が更新されるたびにリアルタイムでラベル更新
            // 精度
            switch (activity.confidence) {
                case CMMotionActivityConfidenceLow:
                    self.confidenceLabel.text = @"Low";
                    break;
                case CMMotionActivityConfidenceMedium:
                    self.confidenceLabel.text = @"Medium";
                    break;
                case CMMotionActivityConfidenceHigh:
                    self.confidenceLabel.text = @"High";
                    break;
                default:
                    self.confidenceLabel.text = @"Error";
                    break;
            }
                                    
            // 状態を調べる(各値 YES or NO)
            BOOL value_stationary = activity.stationary;
            BOOL value_walking = activity.walking;
            BOOL value_running = activity.running;
            BOOL value_unknown = activity.unknown;
            BOOL value_cycling = activity.cycling; // iOS 8 and later
            BOOL value_automotive = activity.automotive;
                                    
            float iOSVersion = [[[UIDevice currentDevice] systemVersion] floatValue];
            if(iOSVersion < 8.0) {
                                           
                _cyclingLabel.text = @"Not supported";
                                           
            } else {
                                           
                // 自転車で移動中?(YES or NO) iOS 8.0 以降なのでこの処理
                if (value_cycling == YES) {
                    self.cyclingLabel.text = @"YES";
                } else {
                    self.cyclingLabel.text = @"NO";
                }
            }
                                    
            // 交通機関で移動中?(YES or NO)
            if (value_automotive == YES) {
                self.automotiveLabel.text = @"YES";
            } else {
                self.automotiveLabel.text = @"NO";
            }
                                       
            // 静止，歩行，走行，不明は両立しそうにない？
            if (value_stationary == YES) {
                self.motion_activityLabel.text = @"Stationary";
            }
            if (value_walking == YES) {
                self.motion_activityLabel.text = @"Walking";
            }
            if (value_running == YES) {
                self.motion_activityLabel.text = @"Running";
            }
            if (value_unknown == YES) {
                self.motion_activityLabel.text = @"Unknown";
            }
        }];
    }
}

// 歩数(iOS 7)
-(void)getStep_iOS7
{
    
    // 歩数取得対象外のアラート処理(M7, M8 チップ非対応)
    if (![CMStepCounter isStepCountingAvailable]) {
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil
                                                        message:@"Your device doesn't support CMStepCounter."
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert show];
        _stepLabel.text = @"Not supported";
        _weeklystepsLabel.text = @"Not supported";
        
    // 歩数取得可能の場合
    } else {
        
        [_stepCounter startStepCountingUpdatesToQueue:[NSOperationQueue mainQueue]
                                             updateOn:1
                                          withHandler:^(NSInteger numberOfSteps, NSDate *timestamp, NSError *error) {
                                              
            // 歩数が更新されるたびにリアルタイムでラベル更新
            self.stepLabel.text = [NSString stringWithFormat:@"%ld", (long)numberOfSteps];
                                              
        }];
        
        // 1週間分の歩数(時間の取り方が正確じゃない気がする)
        NSDate *now_date = [NSDate new]; // 現在時刻
        NSDate *oneweekago_date = [NSDate dateWithTimeIntervalSinceNow:-7*24*60*60]; // 1週間前
        
        [_stepCounter queryStepCountStartingFrom:oneweekago_date to:now_date
                                         toQueue:[NSOperationQueue mainQueue]
                                     withHandler:^(NSInteger numberOfSteps, NSError *error) {
            // 1 週間分を表示させる
            self.weeklystepsLabel.text = [NSString stringWithFormat:@"%ld", (long)numberOfSteps];
        }];
    }
    // 距離は iOS 8からなのでサポートせず
    _distanceLabel.text = @"Not supported";
    _weeklydistanceLabel.text = @"Not supported";
}


// 歩数，距離(iOS 8)
- (void)getStep_iOS8
{
    
    // 歩数取得対象外のアラート処理(M7, M8 チップ非対応)
    // iOS 8 では CMStepCounter が Deprecated なので CMPedometer を使う
    if (!([CMPedometer isStepCountingAvailable] && [CMPedometer isDistanceAvailable])) {
        
        // アラート表示処理
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Not supported"
                                                                       message:@"Your device doesn't support CMPedometer."
                                                                preferredStyle:UIAlertControllerStyleAlert];
        
        [alert addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            
        }]];
        
        [self presentViewController:alert animated:YES completion:nil];
        
        _stepLabel.text = @"Not supported";
        _weeklystepsLabel.text = @"Not supported";
        _distanceLabel.text = @"Not supported";
        _weeklydistanceLabel.text = @"Not supported";
        
    // 歩数取得可能の場合
    } else {
        // インスタンス生成
        self.pedometer = [[CMPedometer alloc] init];

        [self.pedometer startPedometerUpdatesFromDate:[NSDate date]
                                      withHandler:^(CMPedometerData *pedometerData, NSError *error) {
            // step数の取得
            NSNumber *step = pedometerData.numberOfSteps;
            self.stepLabel.text = [NSString stringWithFormat:@"%@", step];
            
            // 距離
            NSNumber *distance = pedometerData.distance;
            double distance_f = [distance doubleValue];
            self.distanceLabel.text = [NSString stringWithFormat:@"%.2f [m]", distance_f];
        
        }];
        
        // 1週間分の歩数(時間の取り方が正確じゃない気がする)
        NSDate *oneweekago_date = [NSDate dateWithTimeIntervalSinceNow:-7*24*60*60]; // 1週間前
        
        [self.pedometer queryPedometerDataFromDate:oneweekago_date
                                            toDate:[NSDate date]
                                       withHandler:^(CMPedometerData *pedometerData, NSError *error) {
            // 1週間の step 数の取得
            NSNumber *step_week = pedometerData.numberOfSteps;
            self.weeklystepsLabel.text = [NSString stringWithFormat:@"%@", step_week];
                
            // 1週間の移動距離
            NSNumber *distance_week = pedometerData.distance;
            double distance_week_f = [distance_week doubleValue];
            self.weeklydistanceLabel.text = [NSString stringWithFormat:@"%.2f [m]", distance_week_f];

        }];
    }
    
    // 階段の昇り降りは iPhone 6 以上なので別で書いておく
    if (!([CMPedometer  isFloorCountingAvailable])) {
    
        // アラート表示処理
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Not supported"
                                                                       message:@"Your device doesn't support FloorCounting."
                                                                preferredStyle:UIAlertControllerStyleAlert];
        
        [alert addAction:[UIAlertAction actionWithTitle:@"OK"
                                                  style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            
        }]];
        
        [self presentViewController:alert animated:YES completion:nil];
        
        _floorPlusLabel.text = @"Not supported";
        _floorDownLabel.text = @"Not supported";
        
    } else {
        
        // インスタンス生成
        self.pedometer = [[CMPedometer alloc] init];
        
        [self.pedometer startPedometerUpdatesFromDate:[NSDate date]
                                          withHandler:^(CMPedometerData *pedometerData, NSError *error) {
            
            // 階段の昇降数
            NSNumber *floorsAscended = pedometerData.floorsAscended;
            NSNumber *floorsDescended = pedometerData.floorsDescended;
                
            self.floorPlusLabel.text = [NSString stringWithFormat:@"%@", floorsAscended];
            self.floorDownLabel.text = [NSString stringWithFormat:@"%@", floorsDescended];
            
        }];
    }
}

// 気圧，高度取得関数(iOS 8)
-(void)getAltitude
{
    
    // 気圧，高度取得対象外のアラート処理(M8 チップ非対応)
    if (![CMAltimeter isRelativeAltitudeAvailable]) {
        
        //アラート表示
        UIAlertController *alerts = [UIAlertController alertControllerWithTitle:@"Not supported"
                                                                        message:@"Your device doesn't support CMAltimeter."
                                                                 preferredStyle:UIAlertControllerStyleAlert];
        
        [alerts addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            
        }]];
        
        [self presentViewController:alerts animated:YES completion:nil];
        
        _altitudeLabel.text = @"Not supported";
        _pressureLabel.text = @"Not supported";
        
    // 気圧，高度取得可能の場合
    } else {
        
        // インスタンス生成
        self.altitude = [[CMAltimeter alloc] init];
        
        [_altitude startRelativeAltitudeUpdatesToQueue:[NSOperationQueue mainQueue]
                                           withHandler:^(CMAltitudeData *altitudeData, NSError *error) {
            
            // 高度が更新されるたびにリアルタイムでラベル更新
            // relativeAltitude なのでそんなに大きな値はでない？マイナスもありうる。
            NSNumber *altitude_value = altitudeData.relativeAltitude;
            double altitude_f = [altitude_value doubleValue];
            self.altitudeLabel.text = [NSString stringWithFormat:@"%.2f [m]", altitude_f];
            
            // 気圧が更新されるたびにリアルタイムでラベル更新
            // 得られるのは kPa だそう。*10 して見慣れた hPa にする
            NSNumber *pressure_value = altitudeData.pressure;
            double pressure_f = [pressure_value doubleValue];
            self.pressureLabel.text = [NSString stringWithFormat:@"%.2f [hPa]", pressure_f*10];
            
        }];
    }
}

// Stop ボタンを押して計測停止(再開の処理は割愛)
- (IBAction)stop_measurement:(id)sender {
    
    // すべてのデータ取得を停止
    [_motion stopAccelerometerUpdates];
    [_motion stopGyroUpdates];
    [_activity stopActivityUpdates];
    [_stepCounter stopStepCountingUpdates];
    [self.pedometer stopPedometerUpdates];
    [_altitude stopRelativeAltitudeUpdates];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
