//
//  ViewController.h
//  CoreMotion Test
//
//  Created by 麻生 拓弥 on 2015/02/14.
//  Copyright (c) 2015年 麻生 拓弥. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ViewController : UIViewController <UIAlertViewDelegate>

@property (weak, nonatomic) IBOutlet UILabel *acc_xLabel;
@property (weak, nonatomic) IBOutlet UILabel *acc_yLabel;
@property (weak, nonatomic) IBOutlet UILabel *acc_zLabel;

@property (weak, nonatomic) IBOutlet UILabel *gyro_xLabel;
@property (weak, nonatomic) IBOutlet UILabel *gyro_yLabel;
@property (weak, nonatomic) IBOutlet UILabel *gyro_zLabel;


@property (weak, nonatomic) IBOutlet UILabel *confidenceLabel;
@property (weak, nonatomic) IBOutlet UILabel *motion_activityLabel;
@property (weak, nonatomic) IBOutlet UILabel *automotiveLabel;
@property (weak, nonatomic) IBOutlet UILabel *cyclingLabel;

@property (weak, nonatomic) IBOutlet UILabel *stepLabel;
@property (weak, nonatomic) IBOutlet UILabel *weeklystepsLabel;
@property (weak, nonatomic) IBOutlet UILabel *distanceLabel;
@property (weak, nonatomic) IBOutlet UILabel *weeklydistanceLabel;

@property (weak, nonatomic) IBOutlet UILabel *floorPlusLabel;
@property (weak, nonatomic) IBOutlet UILabel *floorDownLabel;
@property (weak, nonatomic) IBOutlet UILabel *altitudeLabel;
@property (weak, nonatomic) IBOutlet UILabel *pressureLabel;

- (IBAction)stop_measurement:(id)sender;


@end

