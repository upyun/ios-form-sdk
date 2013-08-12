//
//  ViewController.m
//  upyundemo
//
//  Created by andy yao on 12-6-14.
//  Copyright (c) 2012年 upyun.com. All rights reserved.
//

#import "ViewController.h"
#import "UpYun.h"

@interface ViewController ()
@property (weak, nonatomic) IBOutlet UIImageView *image;
@property (weak, nonatomic) IBOutlet UIProgressView *pv;
@end

@implementation ViewController
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
    uy.successBlocker = ^(id data)
    {
        UIAlertView * alert = [[UIAlertView alloc]initWithTitle:@"" message:@"上传成功" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil];
        [alert show];
        NSLog(@"%@",data);
    };
    uy.failBlocker = ^(NSError * error)
    {
        NSString *message = [error.userInfo objectForKey:@"message"];
        UIAlertView * alert = [[UIAlertView alloc]initWithTitle:@"" message:message delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil];
        [alert show];
    };
    uy.progressBlocker = ^(CGFloat percent,long long requestDidSendBytes)
    {
        [_pv setProgress:percent];
    };
    NSString* resourcePath = [[NSBundle mainBundle] resourcePath];
    
    NSString* filePath = [resourcePath stringByAppendingPathComponent:@"FileTest.file"];
    UIImage * image = [UIImage imageNamed:@"image.jpg"];
    NSData * fileData = [NSData dataWithContentsOfFile:filePath];
    /**
     *	@brief	根据 文件路径 上传并由 服务器 生成savekey
     *    saveKeyByServerType可用值:
     *
     *    SaveKeyByServerWithTime
     *    SaveKeyByServerWithMD5
     *    SaveKeyByServerWithRandom
     *    SaveKeyByServerWithFileName
     */
    [uy uploadFile:filePath saveKeyByServerType:SaveKeyByServerWithTime];
    
    /**
     *	@brief	根据 UIImage 上传并由 服务器 生成savekey
     *    saveKeyByServerType可用值:
     *
     *    SaveKeyByServerWithTime
     *    SaveKeyByServerWithMD5
     *    SaveKeyByServerWithRandom
     */
    [uy uploadFile:image saveKeyByServerType:SaveKeyByServerWithTime];
    
    /**
     *	@brief	根据 NSDate 上传并由服 务器生 成savekey
     *    saveKeyByServerType可用值:
     *
     *    SaveKeyByServerWithTime
     *    SaveKeyByServerWithMD5
     *    SaveKeyByServerWithRandom
     */
    [uy uploadFile:fileData saveKeyByServerType:SaveKeyByServerWithTime];
    
    
    /**
     *	@brief	根据 文件路径 上传并由  开发者 成savekey
     */
    [uy uploadFile:filePath customSaveKey:[self getSaveKey]];
    
    /**
     *	@brief	根据 UIImage 上传并由 开发者 生成savekey
     */
    [uy uploadFile:image customSaveKey:[self getSaveKey]];
    
    /**
     *	@brief	根据 NSDate 上传并由 开发者 生成savekey
     */
    [uy uploadFile:fileData customSaveKey:[self getSaveKey]];
}

-(NSString * )getSaveKey {
    NSDate *d = [NSDate date];
    return [NSString stringWithFormat:@"/%d/%d/%.0f.jpg",[self getYear:d],[self getMonth:d],[[NSDate date] timeIntervalSince1970]];
}

- (int)getYear:(NSDate *) date{
    NSDateFormatter *formatter =[[NSDateFormatter alloc] init];
    [formatter setTimeStyle:NSDateFormatterMediumStyle];
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSInteger unitFlags = NSYearCalendarUnit;
    NSDateComponents *comps = [calendar components:unitFlags fromDate:date];
    int year=[comps year];
    return year;
}

- (int)getMonth:(NSDate *) date{
    NSDateFormatter *formatter =[[NSDateFormatter alloc] init];
    [formatter setTimeStyle:NSDateFormatterMediumStyle];
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSInteger unitFlags = NSMonthCalendarUnit;
    NSDateComponents *comps = [calendar components:unitFlags fromDate:date];
    int month = [comps month];
    return month;
}



@end
