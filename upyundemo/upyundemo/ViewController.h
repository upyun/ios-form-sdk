//
//  ViewController.h
//  upyundemo
//
//  Created by andy yao on 12-6-14.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UpYun.h"

@interface ViewController : UIViewController<UpYunDelegate>

@property (retain, nonatomic) IBOutlet UIImageView *image;

@property (retain, nonatomic) IBOutlet UIProgressView *pv;

- (IBAction)uploadImage:(id)sender;

@end
