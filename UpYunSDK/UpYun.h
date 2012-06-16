//
//  UpYun.h
//  upyundemo
//
//  Created by andy yao on 12-6-14.
//  Copyright (c) 2012年 upyun.com. All rights reserved.
//

//￼￼￼￼￼￼￼￼￼￼￼￼￼￼￼￼￼￼￼￼￼￼￼￼￼￼￼￼￼￼￼￼￼￼￼￼￼￼￼￼￼￼￼￼￼￼￼￼￼￼￼￼￼￼￼￼￼￼￼￼￼￼￼￼￼￼￼￼￼￼￼￼￼￼￼￼￼￼￼￼￼￼￼￼￼￼￼￼￼￼￼￼￼￼￼￼￼￼￼￼￼￼￼￼￼￼￼￼￼￼￼￼￼￼￼￼￼￼￼￼￼￼￼￼￼￼￼￼￼￼￼￼￼￼￼￼￼￼￼￼￼￼￼￼￼￼￼￼￼￼￼￼￼￼￼￼￼￼￼￼￼￼￼￼￼￼￼￼￼￼￼￼￼￼￼￼￼￼￼￼￼￼￼￼￼￼功能介绍:
//表单 API上传功能是专门为需要让客户网站的用户可直接上传到又拍云存储的功能。
//表单 API功能支持用户端(浏览器、客户端软件、手机 APP等)直接上传文件到云存储,而不需要通过客户服务器进行中转。
//一、浏览器POST到服务器内容:
//1、policy ￼ ￼ ￼ [policy内容base64值(无换行)] 2、signature ￼ ￼ md5(policy+&+表单API验证密匙) 3、file
//4、POST的目标URL ￼ http://v0.api.upyun.com/空间名/
//￼￼￼￼￼二、policy内容组成:
//1、文件 KEY命名规则:save-key[必须]
//如:/filepath/filename KEY中可使用命名变量:
//(1)、绝对值: 用户自定义字符
//(2)、时间类: {year}{mon}{day}{hour}{min}{sec}
//(3)、md5类: {filemd5} ￼ ￼ ￼ ￼ ￼ 文件内容md5值
//(4)、随机类: {random}{random32} ￼ ￼ 可选16及32位随机字符及数字 (5)、后缀类: {suffix}{.suffix} ￼ ￼ 上传文件的原始后缀
//安全提示: 如果你的应用一次授权只允许上传1个文件,save-key请使用绝对值, 如果你的应用一次授权在过期时间内允许上传多个文件,save-key可使用一些命名变量。
//2、过期时间:expiration(UNIXTIME)[必须](当前上传授权的过期时间)
//3、空间名: bucket ￼ ￼ [必须](用户在又拍云存储的空间名)
//4、跳转url: return-url [可选](当上传完成后,跳转到该URL)
//5、异步url: notify-url [可选](当上传完成后,云存储服务端主动把结果POST到该URL,为保障你的空间安全,建议启用异步回调)
//6、文件大小范围:content-length-range ￼ 单位:Bytes [可选]
//7、图片宽度范围:image-width-range ￼ ￼ 单位:像素 [可选] 图片高度范围:image-height-range ￼ ￼ 单位:像素 [可选]
//￼￼￼￼￼￼￼￼￼￼￼￼￼￼￼￼￼￼￼￼￼￼￼￼￼￼￼￼￼￼￼￼￼￼￼￼￼￼￼￼￼￼￼￼￼￼￼￼￼￼￼￼￼￼￼￼￼￼￼￼￼￼￼￼￼￼￼￼￼￼￼￼￼￼￼￼￼￼￼￼￼￼￼￼￼￼￼￼￼￼￼￼￼￼￼￼￼￼￼￼￼￼￼￼￼￼￼￼￼￼￼￼￼￼￼￼￼￼￼￼￼￼￼￼￼￼￼￼￼￼￼￼￼￼
//￼￼￼￼￼￼￼￼8、指定文件类型:Content-Type
//[可选](指定上传该文件后存储在云存储系统上的文件类型,一般系统通过扩展名自动识别)
//￼￼￼￼￼￼￼9、允许文件类型:allow-file-type ￼ ￼ ￼ jpg,jpeg,gif,png ￼ ￼ [可选](根据上传的文件名后缀进行判断)
//￼￼￼￼￼￼10、例: <?php
//$policydoc=array( "bucket"
//                   =>"demobucket",
//                   =>1323152967, =>"/{year}/{mon}/{random}{.suffix}", =>"jpg,jpeg,gif,png",
//                   =>"http://localhost/form-test/return.php", ///回调地址 ￼ ￼ =>"http://localhost/form-test/notify.php" ///异步回调地址 ￼ ￼
//                   ￼￼￼￼￼￼￼￼￼￼￼￼￼￼￼￼￼￼￼￼￼￼￼￼￼￼￼￼￼￼￼￼￼￼￼￼￼￼￼￼￼￼￼￼￼￼￼￼￼"expiration"
//                   "save-key"
//                   "allow-file-type" "content-length-range" ￼ =>"0,102400",
//                   ///空间名
//                   ///该次授权过期时间 ///命名规则,/2011/12/随机.扩展名 ///仅允许上传图片 ///文件在100K以下
//                   ￼￼￼￼￼￼￼￼￼￼￼￼￼￼￼￼￼￼￼￼￼￼￼￼￼￼￼￼￼￼￼￼￼￼￼￼￼￼￼￼￼￼￼￼￼￼￼￼￼￼￼￼￼￼￼￼"return-url" "notify-url"
//                   ￼￼￼￼￼￼￼￼￼￼￼￼￼￼￼);
//￼￼￼￼￼￼￼￼￼///json编码后格式为(注意不带换行):
///* {"bucket":"demobucket","expiration":1323152967,"save-key":"\/{year}\/{mon}\/{random}{.suffix}",
// "allow-file-type":"jpg,jpeg,gif,png","content-length-range":"0,102400", "return-url":"http:\/\/localhost\/form-test\/return.php", "notify-url":"http:\/\/localhost\/form-test\/notify.php"}
// */
//$policy=base64_encode(json_encode($policydoc)); ￼ ￼ ￼ ￼ ￼ ///注意 base64编码后的 policy
//￼￼￼￼￼￼￼￼￼￼￼￼￼￼￼￼￼￼￼￼￼￼￼￼￼￼￼￼￼￼￼￼￼￼￼￼￼￼￼￼￼￼￼
//￼￼￼￼字符串中不包含换行符!
//￼￼￼￼￼￼￼￼￼三、signature签名
//组成:md5(policy+'&'+表单API验证密匙)
/////表单 API功能的密匙(请访问又拍云管理后台的空间管理页面获取)
//一个标准的授权上传如下: <formaction="http://v0.api.upyun.com/空间名/"method="post"enctype="multipart/form-data"> <inputtype="hidden"name="policy" value="eyJidWNrZXQiOiJkZW1vIiwidXNlcm5hbWUiOiJ1c2VybmFtZSIsImV4cGlyYXRpb24iOjEzMjMxNTM5MDUsInNhdmUta2V5IjoiXC97 eWVhcn1cL3ttb259XC97cmFuZG9tfXsuc3VmZml4fSIsImFsbG93LWZpbGUtdHlwZSI6ImpwZyxqcGVnLGdpZixwbmciLCJjb250ZW50LWxlbmd 0aC1yYW5nZSI6IjAsMTAyNDAwIiwicmV0dXJuLXVybCI6Imh0dHA6XC9cL2xvY2FsaG9zdFwvZm9ybS10ZXN0XC9yZXR1cm4ucGhwIiwibm90aW Z5LXVybCI6Imh0dHA6XC9cL2xvY2FsaG9zdFwvZm9ybS10ZXN0XC9ub3RpZnkucGhwIn0="> <inputtype="hidden"name="signature"value="cf3e1ce231e15a9e3a42ff688074a628">
//<inputtype="file"name="file">
//<inputtype="submit">
//</form>
//四、回调规则
//当该次上传完成时,如有设置 return-url则自动使用 GET模式跳转回用户指定的URL。如:
//http://localhost/form-test/return.php?code=503&message=%E6%8E%88%E6%9D%83%E5%B7%B2%E8%BF%87%E6%9C%9F&url=%2F201 1%2F12%2Ffd0e30047f81fa95.bz2&time=1332129461&non-sign=b11cb84538e884d63e14e52d35a7bd21 回调地址中包括:code、message、url和sign(或non-sign) 四个参数(如是图片空间,额外增加:image-width、image-height、image-frames和image-type四个参数,但不
//用于加密签名)。
//￼￼￼￼￼￼￼￼￼￼￼￼￼￼￼￼￼￼￼￼￼￼￼￼￼￼￼￼￼￼￼￼￼￼￼￼￼￼￼￼￼￼￼￼￼￼￼￼￼￼￼￼￼￼￼￼￼￼￼￼￼￼￼￼￼￼￼￼￼￼￼￼￼￼￼￼￼￼￼￼￼￼￼￼￼￼￼￼￼￼￼￼￼￼￼￼￼￼￼￼￼￼￼￼￼￼￼￼￼￼￼￼￼￼￼￼￼
//其中sign(或non-sign)是根据 code、message、url进行加密签名而成
//￼
//如:md5("{$_GET['code']}&{$_GET['message']}&{$_GET['url']}&{$_GET['time']}&".表单API验证密匙)==$_GET['sign']
//￼
//￼￼
//对于部分系统错误,因未取得操作员信息,会返回 non-sign的签名。此时需特殊处理为:
//￼￼
//md5("{$_GET['code']}&{$_GET['message']}&{$_GET['url']}&{$_GET['time']}&")==$_GET['non-sign']
//￼
//￼￼
//对于有设置 notify-url异步回调的情况,又拍云存储服务端还将通过 POST方式把上传结果回调到用户所指定的 URL。如:
//￼￼
//POSThttp://localhost/form-test/notify.php
//￼￼￼￼
//￼code=503&message=%E6%8E%88%E6%9D%83%E5%B7%B2%E8%BF%87%E6%9C%9F&url=%2F2011%2F12%2Ffd0e30047f81fa95.bz2&time=133 2129461&non-sign=b11cb84538e884d63e14e52d35a7bd21
//￼￼￼￼￼￼￼
//￼
//￼￼
//其签名规则与上面的GET模式一致:)
//￼
//￼
//如不设置 return-url将在又拍云存储接受完上传操作后,把结果信息输出在 body中。
//￼￼￼
#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#define API_DOMAIN @"http://v0.api.upyun.com/"

#define ERROR_DOMAIN @"upyun.com"

@class UpYun;

@protocol UpYunDelegate <NSObject>

@optional

- (void)upYun:(UpYun *)upYun requestDidSucceedWithResult:(id)result;

- (void)upYun:(UpYun *)upYun requestDidFailWithError:(NSError *)error;

- (void)upYunReceivedResponseHeaders:(id)responseHeaders;

// 返回上传进度
- (void)upYun:(UpYun *)upYun requestDidSendBytes:(long long)bytes progress:(float)progress;

@end

@interface UpYun : NSObject {
    NSString *bucket;
    
    NSTimeInterval expiresIn;
    
    NSString *returnUrl;
    
    NSString *notifyUrl;
    
    NSString *contentType;
    
    NSString *allowFileType;
    
    float contentMinLength;
    
    float contentMaxLength;
    
    float imageMinWidth;
    
    float imageMaxWidth;
    
    float imageMinHeight;
    
    float imageMaxHeight;
    
    NSString *passcode;
    
    id<UpYunDelegate> delegate;
}

@property (nonatomic, retain) NSString *bucket;

@property (nonatomic, assign) NSTimeInterval expiresIn;

@property (nonatomic, retain) NSString *returnUrl;

@property (nonatomic, retain) NSString *notifyUrl;

@property (nonatomic, retain) NSString *contentType;

@property (nonatomic, retain) NSString *allowFileType;

@property (nonatomic, assign) float contentMinLength;

@property (nonatomic, assign) float contentMaxLength;

@property (nonatomic, assign) float imageMinWidth;

@property (nonatomic, assign) float imageMaxWidth;

@property (nonatomic, assign) float imageMinHeight;

@property (nonatomic, assign) float imageMaxHeight;

@property (nonatomic, retain) NSString *passcode;

@property (nonatomic, assign) id<UpYunDelegate> delegate;

- (void) uploadImage:(UIImage *)image savekey:(NSString *)savekey;

- (void) uploadImagePath:(NSString *)path savekey:(NSString *)savekey;

- (void) uploadImageData:(NSData *)data savekey:(NSString *)savekey;
@end
