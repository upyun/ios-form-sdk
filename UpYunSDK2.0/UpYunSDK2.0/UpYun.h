//
//  UpYun.h
//  UpYunSDK2.0
//
//  Created by jack zhou on 13-8-6.
//  Copyright (c) 2013年 upyun. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "JSONKit.h"
#import "Base64.h"
#import "NSData+MD5Digest.h"
#import "AFNetworking.h"

/**
 *	@brief 默认空间名（必填项），可在init之后修改bucket的值来更改
 */

#error 必填项
#define DEFAULT_BUCKET @""

/**
 *	@brief	默认表单API功能密钥 （必填项），可在init之后修改passcode的值来更改
 */
#error 必填项
#define DEFAULT_PASSCODE @""

/**
 *	@brief	默认当前上传授权的过期时间，单位为“秒” （必填项，较大文件需要较长时间)，可在init之后修改expiresIn的值来更改
 */
//#error 必填项
#define DEFAULT_EXPIRES_IN 600

#define API_DOMAIN @"http://v0.api.upyun.com/"

typedef void(^SUCCESS_BLOCK)(id result);
typedef void(^FAIL_BLOCK)(NSError * error);
typedef void(^PROGRESS_BLOCK)(CGFloat percent,long long requestDidSendBytes);

typedef enum
{
    SaveKeyByServerWithTime,//   由 服务器 根据时间 生成savekey
    SaveKeyByServerWithMD5,//    由 服务器 根据上传文件MD5值 生成savekey
    SaveKeyByServerWithRandom,// 由 服务器 生成随机值 生成savekey
    SaveKeyByServerWithFileName//由 服务器 根据文件名 生成savekey
}SaveKeyByServerType;

@interface UpYun : NSObject

@property (nonatomic, copy) NSString *bucket;

@property (nonatomic, unsafe_unretained) NSTimeInterval expiresIn;

@property (nonatomic, copy) NSMutableDictionary *params;

@property (nonatomic, copy) NSString *passcode;

@property (nonatomic, copy) SUCCESS_BLOCK   successBlocker;

@property (nonatomic, copy) FAIL_BLOCK      failBlocker;

@property (nonatomic, copy) PROGRESS_BLOCK  progressBlocker;

@property (nonatomic, unsafe_unretained)SaveKeyByServerType autoSaveKeyType;

/**********************/
/**以下新增接口 建议使用**/
/**
 *	@brief	上传文件
 *
 *	@param 	file 	文件信息 可用值：UIImage、NSData、NSString(文件路径)
 *
 *  @tag    当传入 file 类型 为UIImage或者NSData时 SaveKeyByServerType 中的 SaveKeyByServerWithFileName不可用
 *
 *	@param 	saveKeyByServerType 	由服务器生成savekey的方式
 */
-(void)uploadFile:(id)file saveKeyByServerType:(SaveKeyByServerType)saveKeyByServerType;

/**
 *	@brief	上传文件
 *
 *	@param 	file 	文件信息 可用值：UIImage、NSData、NSString(文件路径)
 *	@param 	customSaveKey 	由开发者自定义的saveKey
 */
-(void)uploadFile:(id)file customSaveKey:(NSString *)customSaveKey;

/**以上新增接口 建议使用**/
/**********************/              


/**
 *	@brief	上传图片接口
 *
 *	@param 	image 	图片
 *	@param 	savekey 	savekey
 */
- (void) uploadImage:(UIImage *)image savekey:(NSString *)savekey;

/**
 *	@brief	上传图片接口
 *
 *	@param 	path 	图片path
 *	@param 	savekey 	savekey
 */
- (void) uploadImagePath:(NSString *)path savekey:(NSString *)savekey;


/**
 *	@brief	上传图片接口
 *
 *	@param 	data 	图片data
 *	@param 	savekey 	savekey
 */
- (void) uploadImageData:(NSData *)data savekey:(NSString *)savekey;

@end
