## WeChatHookSDK
微信抢红包外挂

## 外挂简介
近几年微信红包很火热，而有些人就利用红包这个载体进行赌博，之前听朋友说这个可以作弊，一时之间来了兴趣想了解一下实现原理就去研究了一下，并写了这个作弊外挂软件。

红包赌博外挂的原理是：微信红包领取完之后是可以查询这个红包的领取记录的，假设A（主号）和B（小号）两个号同时在同一个群里面，A领完红包之后不停查询领取记录，当剩下最后一个包还没领的时候，根据一定的条件判断如果剩余金额合法则通知B领取

## 免责声明
开源是为了共同学习，外挂有风险，请谨慎使用，使用者自行承担后果（例如封号等）。切勿将此外挂进行二次开发出售以非法牟利，笔者对使用本外挂产生的所有问题不负任何责任

## 如何编译
1：需要真机进行release版本编译

2：编译完成之后需要将dylib进行签名：ldid -S libHookSDK.dylib

## 如何安装
1：1部iphone越狱手机，使用pp助手下载越狱版的微信进行微信多开

2：使用pp助手将libHookSDK.dylib以及libHookSDK.plist拷贝到 /Library/MobileSubstrate/DynamicLibraries 目录下

3：登陆主号，登陆之后进入设置 填写群名称白名单，打开 设置为主号 开关

4：登陆小号，登陆之后进入设置 填写群名称白名单

5：之后分别重启登录主号和小号的微信就可以使用了

其中libHookSDK.dylib由前面编译后生成的，libHookSDK.plist文件在源代码Doc目录里面

## 技术实现
1：根据安装在越狱和非越狱手机区分，外挂发布的方式不同

2：安装在越狱上只需要将前面的文件拷贝到指定目录即可，MobileSubstrate框架会自动在app启动的时候加载这dylib。或者编写tweak插件，将编写的插件源添加到Cydia里

3：非越狱需要将dylib动态库添加到app的load commands域里面实现dylib注入到app，之后重签打包即可

4：这里不打算铺开具体实现技术细节，请参考后面的文档

## 参考
1: http://www.swiftyper.com/2016/12/26/wechat-redenvelop-tweak-for-non-jailbroken-iphone/

2: http://www.jianshu.com/p/189afbe3b429

3: https://mp.weixin.qq.com/s?__biz=MzA3NTYzODYzMg==&mid=2653577384&idx=1&sn=b44a9c9651bf09c5bea7e0337031c53c&scene=1&srcid=0730OYrkabYWsw4AFBCJELvS&from=groupmessage&isappinstalled=0#wechat_redirect
