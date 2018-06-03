# 手把手教你swift项目添加cocos2dx-lua

标签（空格分隔）： iOS

---

>本文所用各版本信息：
Xcode9.2 + swift4版本
cocos2d-x v3.17 [中文官方网站](http://www.cocos.com/?v=CN)

## 集成思路

首先网上给出一个C系的思路，本人未亲测，并且以C调用lua，绕过了cocos2d-x的调用思路，不觉得这种方式很好，所以弃之；

![C语言调用思路][1]

本文思路如图：
![swift->objective-c->c++->lua][2]
首先swift与objective-c的互相调用非常方便，其次oc只需要将.m文件写成.mm就可以在实现中直接调用c++方法，并且c++可以直接绑定lua，这样一来，就实现了，ios系语言写主框架，lua写游戏逻辑，直接通过`ViewController`展现就可以了；并且lua脚本可以像资源添加的方式直接在文件夹中替换，非常方便；基于以上思路，说干就干；

## 首先你需要一个swift项目

新建一个swift语言写的工程，我们默认你已经会用Xcode做这件事了，于是，工程的结构先大致看一下；

![Nothing项目结构][3]

![image_1cf2g61423hj8ks12ngn544ov1g.png-122.4kB][4]

这里是我自己的swift工程，上面的是总结构，下面的是内部工程结构，我们这里只关注一下**bridge**，首先创建一个`CocosViewController`的控制器，这里的控制器可以是OC类型的，也可以使用swift类型的（由于我们需要用OC做桥接文件，所以需要我们创建一个OC的类，我这里自己写了一个单例用来做桥接，所以控制器就无所谓是OC还是swift了），用来呈现我们用cocos2dx-lua展现的游戏页面；在swift工程中添加OC文件会自动生成桥接文件，名字如图；另外还需要注意一点，`CocosViewController`的.m文件要修改成.mm类型，这样就可以在实现中直接调用C++的类了；

创建好后先不要动，我们再来创建一个OC类型的单例，用来进行引擎的初始化操作，以及对lua游戏操作进行封装，我自己命名为`LuaBridge`；
![image_1cf2h2kvq7381eho18ieh5v1s5o1t.png-12kB][5]

```objective-c
#import "LuaBridge.h"
#include "CocosLua.hpp"

@interface LuaBridge()
{
    CocosLua _cocosLua;
}

@end

@implementation LuaBridge

- (instancetype)init
{
    self = [super init];
    if (self) {
        _cocosLua = CocosLua();
        
    }
    return self;
}

static LuaBridge* _bridge = nil;

+ (instancetype)shared {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _bridge = [[LuaBridge alloc] init];
    });
    return _bridge;
}
@end
```

上面出现的`CocosLua`是一个c++的类，在工程中自己创建的；创建它的目的是用来封装cocos2dx-lua的操作，这个类直接被隐藏在`LuaBridge`单例中，在实际应用过程中可能用的不是很多，我们这里出现它只是为了说明本文的类型结构；

```c++
#ifndef CocosLua_hpp
#define CocosLua_hpp

#include <iostream>

class CocosLua {
    
public:
    CocosLua();
    ~CocosLua();
    
public:
    void cocos_lua();
};

#endif /* CocosLua_hpp */
```

## 创建一个cocos2dx-lua项目

首先我们需要去cocos官网上下载cocos2dx源码，链接在本文开始，我自己下载的是v3.17版本，下载的是zip包，解压后如下图：

![image_1cf2mkgfu1m1uk0i13ppv7jieh3h.png-77.4kB][6]

接下来打开终端，我们创建一个lua项目；

![image_1cf2mm4hr2387mi1snp1iv51gtb3u.png-82.5kB][7]

一路cd到我们下载的cocos2dx文件夹下，然后：
```
$ cd tools/cocos2d-console/bin/
```
到上面的这个目录下新建工程，使用下面的命令格式：
```
cocos new <game name> -p <package identifier> -l <language> -d <location>
<game name> 工程名
<package identifier> 包名，bundle id
<language> 所用语言 cpp lua js
<location> 项目创建路径
```
```
$ ./cocos new Nothing-lua -p com.charles.nothing -l lua -d /Users/dizi/Desktop
```
![image_1cf2n16id1lfp13phripbgh13ta4b.png-153.7kB][8]

![image_1cf2n2esh15vo18se12q01i7dih54o.png-29kB][9]

## 整合swift项目与lua项目

如果你做到这一步，那么我们离成功不远了；接下来我们要把lua项目里的资源拷贝到swift项目中，具体跟着我一步一步做；

1. 把lua项目下`frameworks/cocos2d-x`文件夹拖动到swift目录下：
![image_1cf2ni2nnkpq1pmrsbd1iippri55.png-160.2kB][10]
这里说一点，如果工程是用git管理，因为cocos2d-x下文件比较多，而且是cocos2dx代码文件，所以不必要上传，可添加.gitignore文件：
![image_1cf2o45re1ahs1lvjn8mca14be5i.png-16.3kB][11]

2. 把lua项目下`frameworks/runtime-src/Classes`文件夹拖动到swift目录下：
![image_1cf2o6cm9rhe1tj416tl1acf8285v.png-197.8kB][12]

3. 在swift项目目录下新建`Resources`文件夹，将lua项目中的如图三项拷贝进该文件夹下，这样以后lua的所有资源则将全部在该目录下替换，不需要修改工程中其他地方：
![image_1cf2obieh1vrtujma7ucml86d6c.png-112.3kB][13]

4. 将刚刚添加的文件引用到工程项目中：
![image_1cf2ogs2gai2rj01e701jks1q2h79.png-75.4kB][14]
![image_1cf2pbtk51lrv1kek18me1i5brlh8j.png-68.5kB][15]
注意我们的coco2d-x目录并不需要一并引入到工程中，我们不会用到它（不引用它并不说不会用到，不要删掉，不要删掉，不要删掉！！！）；
PS：这里注意蓝色文件夹和黄色文件夹的区别；

## 工程环境配置

接下来到了重头戏，工程环境配置，这个部分我们需要耐心一点，因为有很多路径需要我们自己去找，还要搞清楚几个不同的工程项目配置，我们一步一步来；

1. 引入工程文件，这几个工程文件分别生成cocos-lib以及调拭用.a库，以下依次：
![image_1cf2vge2nmebc02hcgk8k1a199g.png-241.5kB][16]
![image_1cf2vjknh14co12bq15jqahuh0a9t.png-103.2kB][17]
![image_1cf2vl0kf1skll42p86qi11k16aa.png-156.1kB][18]

2. 接下来配置资源库，点击工程TARGETS->Build Phases，在Target Dependencies中添加：
![image_1cf2vs1jffgj8avof61vg11iuaan.png-85.6kB][19]
在Link Binary With Libraries中添加如下支持库，其中lib文件需要打开Add other添加，按shift + command + G，在其中输入`/usr/lib`；
![image_1cf304l9cja61nu71r9h1l8b539b4.png-118.7kB][20]
![image_1cf309lts1b921oan4rhvkd1svebh.png-110.7kB][21]

3. cocos2dx不支持bitcode，在buildsetting中`Enable Bitcode`改为NO；
![image_1cf30d889rs6173d8s411e0i5jbu.png-21.7kB][22]
C++编译器部分：
![image_1cf30ekpb1omd1rj61m56qo1eracb.png-26.4kB][23]

4. `Header Search Paths`中添加：
```
$(inherited)
$(PROJECT_DIR)/cocos2d-x/cocos
$(PROJECT_DIR)/cocos2d-x/external/lua/tolua
$(PROJECT_DIR)/cocos2d-x/external/lua/lua
$(PROJECT_DIR)/cocos2d-x/external/lua
$(PROJECT_DIR)/cocos2d-x/external
$(PROJECT_DIR)/cocos2d-x/Classes
```
![image_1cf30m5opf41hq513ib1eekflbco.png-130.9kB][24]
5. 引入工程配置：
`cocos2d_libs.xcodeproj`工程配置中，确保以下架构都支持；
![image_1cf30qh2sddp1mi95kj89o1725d5.png-52.8kB][25]
`cocos2d_lua_bindings.xcodeproj`工程配置中，确保以下支持平台为iOS；
![image_1cf30sk2o1211j4t88f11lt172dff.png-98.9kB][26]
6. 好了，开始编译你的工程吧！

## 去倒杯水吧，这个过程会很久。。。
![image_1cf31g68atfq3l31v3uf4n1nm6fs.png-8.4kB][27]
Congratulations! 至此，工程已经全部配置完毕，你已经解决一个大Boss了；
今天就到这里吧，之后我们再续如何用swift调用lua [手把手教你swift项目添加cocos2dx-lua(2)](http://)


  [1]: http://static.zybuluo.com/usiege/uevib9k48ouoh5tzfcdsuco2/image_1cf0chaibo2h1okm1gb01n031lna9.png
  [2]: http://static.zybuluo.com/usiege/pbbigdacwd8wt5dfgj5n1dh1/image_1cf0ck09i8q81o3a1edd16k01n42m.png
  [3]: http://static.zybuluo.com/usiege/gaqy8723btnkzhb00sy41cuo/image_1cf2g3usa1ojcb531vik14mcq0d13.png
  [4]: http://static.zybuluo.com/usiege/8ne4u18l390hg8tyb6rirgrh/image_1cf2g61423hj8ks12ngn544ov1g.png
  [5]: http://static.zybuluo.com/usiege/5d9md3gqr7g6mbctjg5xkyj9/image_1cf2h2kvq7381eho18ieh5v1s5o1t.png
  [6]: http://static.zybuluo.com/usiege/jcs6xlchdkv5153hmba0mczo/image_1cf2mkgfu1m1uk0i13ppv7jieh3h.png
  [7]: http://static.zybuluo.com/usiege/6re1nikuq5yi42grr3llcyp2/image_1cf2mm4hr2387mi1snp1iv51gtb3u.png
  [8]: http://static.zybuluo.com/usiege/g32j6k9a6u3k8n8u8bdon702/image_1cf2n16id1lfp13phripbgh13ta4b.png
  [9]: http://static.zybuluo.com/usiege/ekm9ac1ee3lvxobwy2nw0e50/image_1cf2n2esh15vo18se12q01i7dih54o.png
  [10]: http://static.zybuluo.com/usiege/slid6pe7k8nhx6nqcgik1lan/image_1cf2ni2nnkpq1pmrsbd1iippri55.png
  [11]: http://static.zybuluo.com/usiege/a2dz2qu36yco9mctyogm3p2x/image_1cf2o45re1ahs1lvjn8mca14be5i.png
  [12]: http://static.zybuluo.com/usiege/3jj0oybm87eqo5gyf1t4s8nl/image_1cf2o6cm9rhe1tj416tl1acf8285v.png
  [13]: http://static.zybuluo.com/usiege/0jirzqr476njjw7mnn9pa0wc/image_1cf2obieh1vrtujma7ucml86d6c.png
  [14]: http://static.zybuluo.com/usiege/ibrq5jlvye4djt47bz2x8p5b/image_1cf2ogs2gai2rj01e701jks1q2h79.png
  [15]: http://static.zybuluo.com/usiege/wm1ea7a5s5kj4sgmci64atfh/image_1cf2pbtk51lrv1kek18me1i5brlh8j.png
  [16]: http://static.zybuluo.com/usiege/pzv7pmmzyqhfgxprukdom5g2/image_1cf2vge2nmebc02hcgk8k1a199g.png
  [17]: http://static.zybuluo.com/usiege/grjzsjx2vtnbhq1814kzd1m2/image_1cf2vjknh14co12bq15jqahuh0a9t.png
  [18]: http://static.zybuluo.com/usiege/6ph26ry963spcimacjhgmrnc/image_1cf2vl0kf1skll42p86qi11k16aa.png
  [19]: http://static.zybuluo.com/usiege/f24ifjqb73s2qw6kk92ddnmo/image_1cf2vs1jffgj8avof61vg11iuaan.png
  [20]: http://static.zybuluo.com/usiege/v9m64x38qh0k224c0wgot4v2/image_1cf304l9cja61nu71r9h1l8b539b4.png
  [21]: http://static.zybuluo.com/usiege/yvan9ltqx99nggchr66yvkz0/image_1cf309lts1b921oan4rhvkd1svebh.png
  [22]: http://static.zybuluo.com/usiege/fzjz3bofezeaed0u9adg16lf/image_1cf30d889rs6173d8s411e0i5jbu.png
  [23]: http://static.zybuluo.com/usiege/48wj5plpail9zyyz1p4nf23g/image_1cf30ekpb1omd1rj61m56qo1eracb.png
  [24]: http://static.zybuluo.com/usiege/lzykomwd0fpqyrypl5atgg39/image_1cf30m5opf41hq513ib1eekflbco.png
  [25]: http://static.zybuluo.com/usiege/bkt68q28zl1nn42kbivw3xzv/image_1cf30qh2sddp1mi95kj89o1725d5.png
  [26]: http://static.zybuluo.com/usiege/3d0dh82hc2f1izglc03j0e19/image_1cf30sk2o1211j4t88f11lt172dff.png
  [27]: http://static.zybuluo.com/usiege/lrxbyw47jmdpd4tnr8sg9i5t/image_1cf31g68atfq3l31v3uf4n1nm6fs.png