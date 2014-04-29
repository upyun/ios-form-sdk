# 又拍云iOS SDK

又拍云存储iOS SDK，基于 [又拍云存储 表单 API接口] (http://wiki.upyun.com/index.php?title=%E8%A1%A8%E5%8D%95API%E6%8E%A5%E5%8F%A3) 开发。
## 使用说明
### 要求
iOS6.0及以上版本，ARC模式
### 参数设置
* **DEFAULT_BUCKET** : 默认空间名（必填项）
* **DEFAULT_PASSCODE** : 默认表单API功能密钥 （必填项）
* **DEFAULT_EXPIRES_IN** : 默认当前上传授权的过期时间，单位为“秒” （必填项，较大文件需要较长时间)

### 初始化UpYun
````
UpYun *uy = [[UpYun alloc] init];
````

### 上传文件
````
uy.successBlocker = ^(id data){
  //TODO
};
uy.failBlocker = ^(NSError * error){
  //TODO
};
uy.progressBlocker = ^(CGFloat percent,long long requestDidSendBytes){
  //TODO
};
[uy uploadFile:'file' saveKey:'saveKey'];
````
##### 参数说明：

#####1、`file` 需要上传的文件
* 可传入类型：
 * `NSData`:   文件数据
 * `NSString`: 本地文件路径
 * `UIImage`:  传入的图片 (*当以此类型传入图片时，都会转成PNG数据，需要其他格式请先转成`NSData`传入 或者 传入文件路径*)

#####2、`saveKey` 要保存到又拍云存储的具体地址
* 可传入类型：
 * `NSString`: 要保存到又拍云存储的具体地址
* 由开发者自己生成saveKey:
  * 比如`/dir/sample.jpg`表示以`sample.jpg`为文件名保存到`/dir`目录下；
  * 若保存路径为`/sample.jpg`，则表示保存到根目录下；
  * **注意`saveKey`的路径必须是以`/`开始的**，下同
* 由开发者传入关键key由服务器生成saveKey:
  * 比如`/{year}/{mon}/{filename}{.suffix}`表示以上传文件完成时服务器年（`{year}`）、月（`{mon}`）最为目录，以传入的文件名（`{filename}`）及后缀（`{.suffix}`）作为文件名保存
  * **特别的** 当参数`file`以`UIImage`、`NSData`类型传入时，`saveKey`不能带有`{filename}`
  * 其他服务器支持的关键key详见 [save-key详细说明](http://wiki.upyun.com/index.php?title=%E8%A1%A8%E5%8D%95API%E6%8E%A5%E5%8F%A3#.E6.B3.A81.EF.BC.9Asave-key.E8.AF.A6.E7.BB.86.E8.AF.B4.E6.98.8E) 

#####3、`successBlocker` 上传成功回调
* 回调中的参数：
 * `data`: 成功后服务器返回的信息

#####4、`failBlocker` 上传失败回调
* 回调中的参数：
 * `error`: 失败后返回的错误信息


#####5、`progressBlocker` 上传进度度回调
* 回调中的参数：
 * `percent`: 上传进度的百分比
 * `requestDidSendBytes`: 已经发送的数据量

### 错误代码
* `-1998`: 参数`file`以`UIImage`、`NSData`类型传入时，`saveKey`带有`{filename}`
* `-1999`: 参数`file`以`UIImage`、`NSData`、`NSString`外的类型传入
* 其他错误代码详见 [表单API错误代码表](http://wiki.upyun.com/index.php?title=%E8%A1%A8%E5%8D%95API%E6%8E%A5%E5%8F%A3#.E8.A1.A8.E5.8D.95API.E9.94.99.E8.AF.AF.E4.BB.A3.E7.A0.81.E8.A1.A8) 
