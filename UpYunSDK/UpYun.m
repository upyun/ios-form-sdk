//
//  UpYun.m
//  upyundemo
//
//  Created by andy yao on 12-6-14.
//  Copyright (c) 2012年 upyun.com. All rights reserved.
//

#import "UpYun.h"
#import "WBUtil.h"
#import "ASIFormDataRequest.h"
#import "JSONKit.h"
@interface UpYun() {
    long long totalbytes;
}

@end

@implementation UpYun
@synthesize 
bucket,
expiresIn,
params,
passcode,
delegate;

- (void) uploadImage:(UIImage *)image savekey:(NSString *)savekey {
    NSData *imageData = UIImagePNGRepresentation(image);
    [self uploadImageData:imageData savekey:savekey];
}

- (void) uploadImagePath:(NSString *)path savekey:(NSString *)savekey {

    NSString *policy = [self policy:savekey];
    NSString *str = [NSString stringWithFormat:@"%@&%@",policy,self.passcode];
    NSString *signature = [[str MD5EncodedString] lowercaseString];
    NSLog(@"%@",signature);
    ASIFormDataRequest *adr = [ASIFormDataRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@/",API_DOMAIN,self.bucket]]];
    [adr setPostFormat:ASIMultipartFormDataPostFormat];
    [adr addPostValue:policy forKey:@"policy"];
    [adr addPostValue:signature forKey:@"signature"];
    [adr addFile:path forKey:@"file"];
    [adr setStringEncoding:NSUTF8StringEncoding];
    [adr setDelegate:self];
    [adr setUploadProgressDelegate:self];
    [adr startAsynchronous];
}

- (void) uploadImageData:(NSData *)data savekey:(NSString *)savekey {
    NSString *policy = [self policy:savekey];
    NSString *str = [NSString stringWithFormat:@"%@&%@",policy,self.passcode];
    NSString *signature = [[str MD5EncodedString] lowercaseString];
    ASIFormDataRequest *adr = [ASIFormDataRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@/",API_DOMAIN,self.bucket]]];
    [adr setPostFormat:ASIMultipartFormDataPostFormat];
    [adr addPostValue:policy forKey:@"policy"];
    [adr addPostValue:signature forKey:@"signature"];
    [adr addData:data forKey:@"file"];
    [adr setStringEncoding:NSUTF8StringEncoding];
    [adr setDelegate:self];
    [adr setUploadProgressDelegate:self];
    [adr startAsynchronous];
}

- (NSString *)policy:(NSString *)savekey {
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    [dic setObject:self.bucket forKey:@"bucket"];
    [dic setObject:[NSString stringWithFormat:@"%.0f",[[NSDate date] timeIntervalSince1970] + self.expiresIn] forKey:@"expiration"];
    [dic setObject:savekey forKey:@"save-key"];
    if (self.params) {
        for (NSString *key in self.params.keyEnumerator) {
            [dic setObject:[self.params objectForKey:key] forKey:key];
        }
    }
    NSString *json = [dic JSONString];
    return [json base64EncodedString];
}



- (void)requestFinished:(ASIHTTPRequest *)request {
    NSString * dataString = request.responseString;
    JSONDecoder *jd=[[JSONDecoder alloc] init];
    NSDictionary *dic = [jd objectWithUTF8String:(const unsigned char *)[dataString UTF8String] length:(unsigned int)[dataString length]];
    [jd release];
    NSString *message = [dic objectForKey:@"message"];
    if ([@"ok" isEqualToString:message]) {
        if ([delegate respondsToSelector:@selector(upYun:requestDidSendBytes:progress:)]) {
            [delegate upYun:self requestDidSendBytes:0 progress:1];
        }
        if ([delegate respondsToSelector:@selector(upYun:requestDidSucceedWithResult:)]) {
            [delegate upYun:self requestDidSucceedWithResult:dic];
        }
    } else {
        if ([delegate respondsToSelector:@selector(upYun:requestDidFailWithError:)]) {
            NSError *err = [NSError errorWithDomain:ERROR_DOMAIN code:[[dic objectForKey:@"code"] intValue] userInfo:dic];
            [delegate upYun:self requestDidFailWithError:err];
        }
    }
}

- (void)requestFailed:(ASIHTTPRequest *)request {
    totalbytes = 0;
    if ([delegate respondsToSelector:@selector(upYun:requestDidFailWithError:)]) {
        [delegate upYun:self requestDidFailWithError:request.error];
    }
}

- (void)requestStarted:(ASIHTTPRequest *)request {
    totalbytes = 0;
}

- (void)requestReceivedResponseHeaders:(ASIHTTPRequest *)request {
    if ([delegate respondsToSelector:@selector(upYunReceivedResponseHeaders:)]) {
        [delegate upYunReceivedResponseHeaders:request.responseHeaders];
    }
}

- (void)request:(ASIHTTPRequest *)request incrementUploadSizeBy:(long long)newLength {
    
}

- (void)request:(ASIHTTPRequest *)request didSendBytes:(long long)bytes {
    totalbytes += bytes;
    if ([delegate respondsToSelector:@selector(upYun:requestDidSendBytes:progress:)]) {
        [delegate upYun:self requestDidSendBytes:bytes progress:(float)totalbytes/(float)request.postLength];
    }
}

@end
