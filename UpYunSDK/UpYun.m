//
//  UpYun.m
//  upyundemo
//
//  Created by andy yao on 12-6-14.
//  Copyright (c) 2012年 upyun.com. All rights reserved.
//

#import "UpYun.h"
#import "WBUtil.h"
#import "SBJson.h"
#import "ASIFormDataRequest.h"

@interface UpYun() {
    long long totalbytes;
}

@end

@implementation UpYun
@synthesize 
bucket,
expiresIn,
returnUrl,
notifyUrl,
contentType,
allowFileType,
contentMinLength,
contentMaxLength,
imageMinWidth,
imageMaxWidth,
imageMinHeight,
imageMaxHeight,
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
    [dic setObject:[NSString stringWithFormat:@"%f",[[NSDate date] timeIntervalSince1970] + self.expiresIn] forKey:@"expiration"];
    [dic setObject:savekey forKey:@"save-key"];
    if (self.allowFileType) {
        [dic setObject:self.allowFileType forKey:@"allow-file-type"];
    }
    if (contentMaxLength > 0 && contentMinLength >= 0 && contentMaxLength >= contentMinLength) {
        [dic setObject:[NSString stringWithFormat:@"%d,%d",contentMinLength,contentMaxLength] forKey:@"content-length-range"];
    }
    if (imageMaxWidth > 0 && imageMinWidth >= 0 && imageMaxWidth >= imageMinWidth) {
        [dic setObject:[NSString stringWithFormat:@"%d,%d",imageMinWidth,imageMaxWidth] forKey:@"image-width-range"];
    }
    if (imageMaxHeight > 0 && imageMinHeight >= 0 && imageMaxHeight >= imageMinHeight) {
        [dic setObject:[NSString stringWithFormat:@"%d,%d",imageMinHeight,imageMaxHeight] forKey:@"image-height-range"];
    }
    if (self.returnUrl) {
        [dic setObject:self.returnUrl forKey:@"return-url"];
    }
    if (self.notifyUrl) {
        [dic setObject:self.notifyUrl forKey:@"notify-url"];
    }
    NSString *json = [dic JSONRepresentation];
    return [json base64EncodedString];
}


- (void)requestFinished:(ASIHTTPRequest *)request {
    SBJsonParser *p = [[SBJsonParser alloc] init];
    NSDictionary *dic = [p objectWithString:request.responseString];
    [p release];
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
