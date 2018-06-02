//
//  Bridge.m
//  CocosLua
//
//  Created by charles on 2018/6/2.
//  Copyright © 2018年 charles. All rights reserved.
//

#import "OCBridge.h"

#include "cocos2d.h"
#include "AppDelegate.h"
#include "BridgeLua.hpp"


@interface OCBridge()
{
    BridgeLua   _cocosLua;
    cocos2d::Application* _app;
}

@end

static AppDelegate* _cocosDelegate = nil;

@implementation OCBridge

static OCBridge* _bridge = nil;
+ (instancetype)shared {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _bridge = [[OCBridge alloc] init];
    });
    return _bridge;
}


- (instancetype)init
{
    self = [super init];
    if (self) {
        //cocos2d initiatial
        _cocosDelegate = new AppDelegate();
        _app = cocos2d::Application::getInstance();

        //
        _cocosLua = BridgeLua();
    }
    return self;
}

- (void)setupWithFrame:(CGRect)frame {
    
    CCEAGLView* eaglView = [CCEAGLView viewWithFrame:frame
                                          pixelFormat:kEAGLColorFormatRGB565
                                          depthFormat:GL_DEPTH24_STENCIL8_OES
                                   preserveBackbuffer:NO
                                           sharegroup:nil
                                        multiSampling:NO
                                      numberOfSamples:0];
    cocos2d::GLView* glview = cocos2d::GLViewImpl::createWithEAGLView((__bridge void*)eaglView);
    cocos2d::Director::getInstance()->setOpenGLView(glview);
    
    cocos2d::Application::getInstance()->run();
    
    self.eaglView = eaglView;
}

@end
