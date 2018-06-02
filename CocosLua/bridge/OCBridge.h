//
//  Bridge.h
//  CocosLua
//
//  Created by charles on 2018/6/2.
//  Copyright © 2018年 charles. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "platform/ios/CCEAGLView-ios.h"

@interface OCBridge : NSObject

+ (instancetype)shared;

@property (strong) CCEAGLView* eaglView;
- (void)setupWithFrame:(CGRect)frame;

@end
