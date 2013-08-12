//
//  UpYun.m
//  UpYunSDK2.0
//
//  Created by jack zhou on 13-8-6.
//  Copyright (c) 2013年 upyun. All rights reserved.
//

#import "UpYun.h"
#define ERROR_DOMAIN @"upyun.com"
#define DATE_STRING(expiresIn) [NSString stringWithFormat:@"%.0f",[[NSDate date] timeIntervalSince1970] + expiresIn]
#define REQUEST_URL(bucket) [NSURL URLWithString:[NSString stringWithFormat:@"%@%@/",API_DOMAIN,bucket]]
#define CREAT_SAVE_KEY_BY_SERVER_WITH_TIME @"/{year}{mon}{day}{hour}{min}{sec}"
#define CREAT_SAVE_KEY_BY_SERVER_WITH_MD5 @"/{filemd5}"
#define CREAT_SAVE_KEY_BY_SERVER_WITH_RANDOM @"/{random}{random32}"
#define CREAT_SAVE_KEY_BY_SERVER_WITH_FILENAME @"/{year}/{mon}/{filename}{.suffix}"
@implementation UpYun
-(id)init
{
    if (self = [super init]) {
        self.bucket = DEFAULT_BUCKET;
        self.expiresIn = DEFAULT_EXPIRES_IN;
        self.passcode = DEFAULT_PASSCODE;
	}
	return self;
}

-(BOOL)needActionCheckWithData:(id)data
           saveKeyByServerType:(SaveKeyByServerType)saveKeyByServerType
{
    NSString * message = @"<SaveKeyByServerWithFileName>方式产生savekey,只支持file参数为文件path";
    if(([data isKindOfClass:[UIImage class]] && saveKeyByServerType == SaveKeyByServerWithFileName) ||
       ([data isKindOfClass:[NSData class]] && saveKeyByServerType == SaveKeyByServerWithFileName)){
        NSError *err = [NSError errorWithDomain:ERROR_DOMAIN
                                           code:-99999
                                       userInfo:@{@"message":message}];
        if (_failBlocker) {
            _failBlocker(err);
        }
        return NO;
    }
    return YES;
}

- (void) uploadImage:(UIImage *)image savekey:(NSString *)savekey
{
    NSData *imageData = UIImagePNGRepresentation(image);
    [self uploadImageData:imageData savekey:savekey];
}

- (void) uploadImagePath:(NSString *)path savekey:(NSString *)savekey
{
    AFHTTPRequestOperation * operation = [self creatOperationWithSaveKey:savekey
                                                                    data:nil
                                                                filePath:path];
    [operation start];
}
- (void) uploadImageData:(NSData *)data savekey:(NSString *)savekey
{
    AFHTTPRequestOperation * operation = [self creatOperationWithSaveKey:savekey
                                                                    data:data
                                                                filePath:nil];
    [operation start];
}

-(void)uploadFile:(id)file customSaveKey:(NSString *)customSaveKey
{
    if([file isKindOfClass:[UIImage class]]){
        [self uploadImage:file savekey:customSaveKey];
    }else if([file isKindOfClass:[NSData class]]) {
        [self uploadImageData:file savekey:customSaveKey];
    }else if([file isKindOfClass:[NSString class]]) {
        [self uploadImagePath:file savekey:customSaveKey];
    }else {
        NSError *err = [NSError errorWithDomain:ERROR_DOMAIN
                                           code:-99998
                                       userInfo:@{@"message":@"传入参数类型错误"}];
        if (_failBlocker) {
            _failBlocker(err);
        }
    }
}

- (void)uploadFile:(id)file saveKeyByServerType:(SaveKeyByServerType)saveKeyByServerType
{
    if (![self needActionCheckWithData:file saveKeyByServerType:saveKeyByServerType]) {
        return;
    }
    NSString * saveKey;
    switch (saveKeyByServerType) {
        case SaveKeyByServerWithFileName:
            saveKey = CREAT_SAVE_KEY_BY_SERVER_WITH_FILENAME;
            break;
        case SaveKeyByServerWithMD5:
            saveKey = CREAT_SAVE_KEY_BY_SERVER_WITH_MD5;
            break;
        case SaveKeyByServerWithRandom:
            saveKey = CREAT_SAVE_KEY_BY_SERVER_WITH_RANDOM;
            break;
        case SaveKeyByServerWithTime:
            saveKey = CREAT_SAVE_KEY_BY_SERVER_WITH_TIME;
            break;
        default:
            break;
    }
    if([file isKindOfClass:[UIImage class]]){
        [self uploadImage:file savekey:saveKey];
    }else if([file isKindOfClass:[NSData class]]) {
        [self uploadImageData:file savekey:saveKey];
    }else if([file isKindOfClass:[NSString class]]) {
        [self uploadImagePath:file savekey:saveKey];
    }else {
        NSError *err = [NSError errorWithDomain:ERROR_DOMAIN
                                           code:-99998
                                       userInfo:@{@"message":@"传入参数类型错误"}];
        if (_failBlocker) {
            _failBlocker(err);
        }
    }
}

- (NSString *)getPolicyWithSaveKey:(NSString *)savekey {
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    [dic setObject:self.bucket forKey:@"bucket"];
    [dic setObject:DATE_STRING(self.expiresIn) forKey:@"expiration"];
    [dic setObject:savekey forKey:@"save-key"];
    if (self.params) {
        for (NSString *key in self.params.keyEnumerator) {
            [dic setObject:[self.params objectForKey:key] forKey:key];
        }
    }
    NSString *json = [dic JSONString];
    return [json base64EncodedString];
}

- (NSString *)getSignatureWithPolicy:(NSString *)policy
{
    NSString *str = [NSString stringWithFormat:@"%@&%@",policy,self.passcode];
    NSString *signature = [[[str dataUsingEncoding:NSUTF8StringEncoding] MD5HexDigest] lowercaseString];
    return signature;
}

- (id <AFMultipartFormData>)setData:(id <AFMultipartFormData>)formData
                              data:(NSData *)data
                          filePath:(NSString *)filePath
{
    if (data) {
        [formData appendPartWithFileData:data
                                    name:@"file"
                                fileName:@"file"
                                mimeType:@"multipart/form-data"];
        return formData;
    }
    if (filePath) {
        NSURL * url = [NSURL fileURLWithPath:filePath];
        NSString * fileName = [filePath lastPathComponent];
        fileName = (NSString *)CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault,
                                                                       (CFStringRef)fileName,
                                                                       NULL,
                                                                       (CFStringRef)@"!*'();:@&=+$,?%#[]",
                                                                       kCFStringEncodingUTF8));
        NSError * error = [[NSError alloc]init];
        [formData appendPartWithFileURL:url
                                   name:@"file"
                               fileName:fileName
                               mimeType:@"multipart/form-data"
                                  error:&error];
        
        return formData;
    }
    return nil;
}

-(NSMutableURLRequest *)creatRequestWithSaveKey:(NSString *)saveKey
                                           data:(NSData *)data
                                       filePath:(NSString *)filePath
{
    NSString *policy = [self getPolicyWithSaveKey:saveKey];
    NSString *signature = [self getSignatureWithPolicy:policy];
    NSString * httpMethod = @"POST";
    NSDictionary * parameDic = [NSDictionary dictionaryWithObjectsAndKeys:policy,@"policy",
                                signature,@"signature", nil];
    AFHTTPClient *httpClient = [[AFHTTPClient alloc] initWithBaseURL:REQUEST_URL(self.bucket)];
    __block UpYun * blockSelf = self;
    NSMutableURLRequest *request = [httpClient multipartFormRequestWithMethod:httpMethod
                                                                         path:nil
                                                                   parameters:parameDic
                                                    constructingBodyWithBlock:
                                    ^(id <AFMultipartFormData>formData){
                                        [blockSelf setData:formData data:data filePath:filePath];
                                    }];
    [request setHTTPMethod:httpMethod];
    return  request;
}

- (AFHTTPRequestOperation *)creatOperationWithSaveKey:(NSString *)saveKey
                                                data:(NSData *)data
                                            filePath:(NSString *)filePath
{
    NSMutableURLRequest * request = [self creatRequestWithSaveKey:saveKey
                                                             data:data
                                                         filePath:filePath];
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    
    void(^progress)(NSUInteger bytesWritten,
                    long long totalBytesWritten,
                    long long totalBytesExpectedToWrite)=
    ^(NSUInteger bytesWritten,long long totalBytesWritten,long long totalBytesExpectedToWrite)
    {
        CGFloat percent = totalBytesWritten/(float)totalBytesExpectedToWrite;
        if (_progressBlocker) {
            _progressBlocker(percent,totalBytesWritten);
        }
    };
    void(^success)(AFHTTPRequestOperation *operation, id responseObject)=
    ^(AFHTTPRequestOperation *operation, id responseObject)
    {
        NSDictionary * jsonDic = [responseObject objectFromJSONData];
        NSString *message = [jsonDic objectForKey:@"message"];
        if ([@"ok" isEqualToString:message]) {
            if (_successBlocker) {
                _successBlocker(jsonDic);
            }
        } else {
            NSError *err = [NSError errorWithDomain:ERROR_DOMAIN
                                               code:[[jsonDic objectForKey:@"code"] intValue]
                                           userInfo:jsonDic];
            if (_failBlocker) {
                _failBlocker(err);
            }
        }
    };
    
    void(^fail)(AFHTTPRequestOperation * opetation,NSError * error)=
    ^(AFHTTPRequestOperation * opetation,NSError * error)
    {
        if (_failBlocker) {
            _failBlocker(error);
        }
    };
    
    [operation setCompletionBlockWithSuccess:success
                                     failure:fail];
    [operation setUploadProgressBlock:progress];
    return operation;
}

@end
