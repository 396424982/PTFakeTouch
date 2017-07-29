//
//  HJFakeMetaTouch.h
//  HJFakeTouch
//
//  Created by PugaTang on 16/4/20.
//  Copyright © 2016年 PugaTang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface PTFakeMetaTouch : NSObject
/**
 *  Fake a touch event 构造一个触屏基础操作
 *
 *  @param pointId 触屏操作的序列号
 *  @param point   操作的目的位置
 *  @param phase   操作的类别
 *
 *  @return pointId 返回操作的序列号
 */
+ (NSInteger)fakeTouchId:(NSInteger)pointId AtPoint:(CGPoint)point inWindow:(UIWindow *)window withTouchPhase:(UITouchPhase)phase;
/**
 *  Get a not used pointId 获取一个没有使用过的触屏序列号
 *
 *  @return pointId 返回序列号
 */
+ (NSInteger)getAvailablePointId;

/*
 
 [PTFakeMetaTouch fakeTouchId:[PTFakeMetaTouch getAvailablePointId] AtPoint:[delegate()->m_appViewControllerMgr getPointX:100 Y: 300] withTouchPhase:0];
 [PTFakeTouch fakeTouchId:pointId AtPoint:CGPointMake(100,100) withTouchPhase:UITouchPhaseEnded]
 */
@end
