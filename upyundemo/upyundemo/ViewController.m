//
//  ViewController.m
//  upyundemo
//
//  Created by andy yao on 12-6-14.
//  Copyright (c) 2012年 upyun.com. All rights reserved.
//

#import "ViewController.h"
#import "UpYun.h"

/**
 *	@brief 空间名（必填项）
 */
#error 必填项
#define BUCKET @""

/**
 *	@brief	表单API功能密钥 （必填项）
 */
#error 必填项 
#define PASSCODE @""

/**
 *	@brief	当前上传授权的过期时间，单位为“秒” （必填项，较大文件需要较长时间)
 */
//#error 必填项
#define EXPIRES_IN 600
@interface ViewController ()

@end

@implementation ViewController
@synthesize image,pv;
- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
    } else {
        return YES;
    }
}

- (IBAction)uploadImage:(id)sender {
    UpYun *uy = [[UpYun alloc] init];
    uy.delegate = self;
    uy.expiresIn = EXPIRES_IN;
    uy.bucket = BUCKET;
    uy.passcode = PASSCODE;
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    uy.params = params;
    
    
    /**
     *	@brief	上传方式1: 通过文件路径上传
     */
    NSString* resourcePath = [[NSBundle mainBundle] resourcePath];
    NSString* img = [resourcePath stringByAppendingPathComponent:@"image.jpg"];
    [uy uploadImagePath:img savekey:[self getSaveKey]];
    
    /**
     *	@brief	上传方式2: 通过文件数据上传
     *  (该方式搭配“allow-file-type”参数使用时可能会上传失败)
     */
//    [uy uploadImageData:UIImageJPEGRepresentation([UIImage imageWithContentsOfFile:img], 1.0) savekey:[self getSaveKey]];
}

/**
 *	@brief	拼装saveKey
 *
 *	@return	saveKey
 */
-(NSString * )getSaveKey {
    
    /**
     *	@brief	方式1 由开发者生成saveKey
     */
    NSDate *d = [NSDate date];
    return [NSString stringWithFormat:@"/%d/%d/%.0f.jpg",[self getYear:d],[self getMonth:d],[[NSDate date] timeIntervalSince1970]];
    
    /**
     *	@brief	方式2 由服务器生成saveKey
     */
//    return [NSString stringWithFormat:@"/{year}/{mon}/{filename}{.suffix}"];
    
    /**
     *	@brief	更多方式 参阅 http://wiki.upyun.com/index.php?title=Policy_%E5%86%85%E5%AE%B9%E8%AF%A6%E8%A7%A3
     */
}

- (int)getYear:(NSDate *) date{
    NSDateFormatter *formatter =[[[NSDateFormatter alloc] init] autorelease];
    [formatter setTimeStyle:NSDateFormatterMediumStyle];
    NSCalendar *calendar = [[[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar] autorelease];
    NSInteger unitFlags = NSYearCalendarUnit;
    NSDateComponents *comps = [calendar components:unitFlags fromDate:date];
    int year=[comps year];
    return year;
}

- (int)getMonth:(NSDate *) date{
    NSDateFormatter *formatter =[[[NSDateFormatter alloc] init] autorelease];
    [formatter setTimeStyle:NSDateFormatterMediumStyle];
    NSCalendar *calendar = [[[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar] autorelease];
    NSInteger unitFlags = NSMonthCalendarUnit;
    NSDateComponents *comps = [calendar components:unitFlags fromDate:date];
    int month = [comps month];
    return month;
}


- (void)upYun:(UpYun *)upYun requestDidFailWithError:(NSError *)error {
    NSLog(@"%@",error);
    NSString *string = [error.userInfo objectForKey:@"message"];
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:string 
                                                    message:nil 
                                                   delegate:nil 
                                          cancelButtonTitle:@"关闭" 
                                          otherButtonTitles:nil, nil];
    [alert show];
    [alert release];
}

- (void)upYun:(UpYun *)upYun requestDidSendBytes:(long long)bytes progress:(float)progress {
    [self.pv setProgress:progress];
}

- (void)upYun:(UpYun *)upYun requestDidSucceedWithResult:(id)result {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"上传成功" 
                                                    message:nil 
                                                   delegate:nil 
                                          cancelButtonTitle:@"关闭" 
                                          otherButtonTitles:nil, nil];
    [alert show];
    [alert release];
}

- (void)upYunReceivedResponseHeaders:(id)responseHeaders {
    
}


@end
