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

#define SUB_SAVE_KEY_SUFFIX @"{.suffix}"
#define SUB_SAVE_KEY_FILENAME @"{filename}"

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

- (void) uploadImage:(UIImage *)image savekey:(NSString *)savekey
{
    if (![self checkSavekey:savekey]) {
        return;
    }
    NSData *imageData = UIImagePNGRepresentation(image);
    [self uploadImageData:imageData savekey:savekey];
}

- (void) uploadImagePath:(NSString *)path savekey:(NSString *)savekey
{
    [self uploadFilePath:path savekey:savekey];
}

- (void) uploadImageData:(NSData *)data savekey:(NSString *)savekey
{
    if (![self checkSavekey:savekey]) {
        return;
    }
    [self uploadFileData:data savekey:savekey];
}

- (void) uploadFilePath:(NSString *)path savekey:(NSString *)savekey
{
    AFHTTPRequestOperation * operation = [self creatOperationWithSaveKey:savekey
                                                                    data:nil
                                                                filePath:path];
    [operation start];
}

- (void) uploadFileData:(NSData *)data savekey:(NSString *)savekey
{
    AFHTTPRequestOperation * operation = [self creatOperationWithSaveKey:savekey
                                                                    data:data
                                                                filePath:nil];
    [operation start];
}

- (BOOL)checkSavekey:(NSString *)string
{
    NSRange rangeSuffix;
    rangeSuffix = [string rangeOfString:SUB_SAVE_KEY_SUFFIX];
    NSRange rangeFileName;
    rangeFileName = [string rangeOfString:SUB_SAVE_KEY_FILENAME];
    if(rangeFileName.location != NSNotFound || rangeSuffix.location != NSNotFound)
    {
        NSString *  message = [NSString stringWithFormat:@"传入file为NSData或者UIImage时,不能使用%@或者%@方式生成savekey",
                               SUB_SAVE_KEY_SUFFIX,SUB_SAVE_KEY_FILENAME];
        NSError *err = [NSError errorWithDomain:ERROR_DOMAIN
                                           code:-1998
                                       userInfo:@{@"message":message}];
        if (_failBlocker) {
            _failBlocker(err);
        }
        return NO;
    }
    return YES;
}

- (void)uploadFile:(id)file saveKey:(NSString *)saveKey
{
    if (![file isKindOfClass:[NSString class]] && ![self checkSavekey:saveKey])//非path传入的需要检查savekey
    {
        return;
    }
    if([file isKindOfClass:[UIImage class]]){
        [self uploadImage:file savekey:saveKey];
    }else if([file isKindOfClass:[NSData class]]) {
        [self uploadFileData:file savekey:saveKey];
    }else if([file isKindOfClass:[NSString class]]) {
        [self uploadFilePath:file savekey:saveKey];
    }else {
        NSError *err = [NSError errorWithDomain:ERROR_DOMAIN
                                           code:-1999
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
