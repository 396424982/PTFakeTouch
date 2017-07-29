#import "PTFakeMetaTouch.h"
#import <substrate.h>
#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import <objc/runtime.h>
#import <IOKit/IOKitLib.h>
#import <CoreFoundation/CoreFoundation.h>
#import "UIKeyboardAutomatic.h"
//模拟点击键盘输入字符串是否完成
static int stringInputIsEnd = 1;
@interface CAppViewControllerManager:NSObject
-(void)testClickX:(double)pointx Y:(double)pointy window:(UIWindow*)window;
-(CGPoint)testGetCoordinate:(id)view;
-(id)TestGetUIKBTree:(NSString *)str;
@end
%group myHook

	
    %hook CAppViewControllerManager
    %new
    -(void)touchViewS:(UIView *)view
    {
       CGPoint newPoint = [self testGetCoordinate:view];
       [self testClickX:newPoint.x Y:newPoint.y window:view.window];
    }
   
    	//获取UIKBTree
	%new
	-(id)TestGetUIKBTree:(NSString *)str
	{
		UIKeyboardAutomatic *kb = [%c(UIKeyboard) activeKeyboard];
		if(kb && [kb isActive])
		{
			NSString *keyplaneName = [kb _getCurrentKeyplaneName];
			//如果不是数字专用键盘
			if([keyplaneName rangeOfString:@"iPhone-Simple-Pad_Def"].location == NSNotFound && [keyplaneName rangeOfString:@"iPhone-Complex-Pad_Def"].location == NSNotFound && [keyplaneName rangeOfString:@"iPhone-Portrait-NumberPad_Def"].location == NSNotFound && [keyplaneName rangeOfString:@"iPhone-Portrait-DecimalPad_Def"].location == NSNotFound)
			{
				//小写字母
				NSPredicate *pred1 = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", @"^[a-z]{1}$"];
				//大写字母
				NSPredicate *pred2 = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", @"^[A-Z]{1}$"];
				//数字标点
				NSPredicate *pred3 = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", @"^[0-9\\-/:;()$&@\".,?!']{1}$"];
				
				UIKeyboardImpl *impl = [%c(UIKeyboardImpl) sharedInstance];
				UIKeyboardLayoutStar *lay = [impl _layout];
				if([pred1 evaluateWithObject:str])
				{
					[lay setKeyplaneName:@"small-letters"];
				}
				else if([pred2 evaluateWithObject:str])
				{
					[lay setKeyplaneName:@"capital-letters"];
				}
				else if([pred3 evaluateWithObject:str])
				{
					[lay setKeyplaneName:@"numbers-and-punctuation"];
				}
				else
				{
					[lay setKeyplaneName:@"numbers-and-punctuation-alternate"];
				}
			}
			UIKBTree *KBTree = [kb _keyplaneNamed:[kb _getCurrentKeyplaneName]];
			for(UIKBTree *tree in [KBTree keys])
			{
				if([str isEqualToString:[tree fullRepresentedString]]) return tree;
			}
		}
		return nil;
	}
	
	//字符输入
	%new
	-(void)TestKBInput:(NSString *)str
	{
		
		UIKeyboardAutomatic *kb = [%c(UIKeyboard) activeKeyboard];
		float delay = 1.0;
		if(kb && [kb isActive])
		{
			stringInputIsEnd = 0;
			UIKeyboardImpl *impl = [%c(UIKeyboardImpl) sharedInstance];
			UIKeyboardLayoutStar *lay = [impl _layout];
			UIWindow *win = [[UIApplication sharedApplication] keyWindow];
			//NSLog(@"-----input str %@ -------------------------------",str);
			
			for(int i=0; i<[str length]; i++)
			{
				//NSLog(@"-----input str length %d -----------%f--------------------",i,delay);
				dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delay * NSEC_PER_SEC)),dispatch_get_main_queue(), ^{
					NSString *string2 = [str substringWithRange:NSMakeRange(i,1)];
					NSLog(@"-----input str %@ -------------------------------",string2);
					
					UIKBTree *KBTree = [self TestGetUIKBTree:string2];
					
					if(KBTree)
					{
						CGRect Rect = [[KBTree shape] paddedFrame];
						float x = Rect.origin.x + Rect.size.width * 0.5;
						float y = Rect.origin.y + Rect.size.height * 0.5;
						CGPoint newPoint = [lay convertPoint:CGPointMake(x, y) toView:win];

                        UIView *firstResponder = [win performSelector:@selector(firstResponder)]; 
                        UIView * inputView = MSHookIvar<UIView*>(firstResponder,"_inputAccessoryView");
                        if(inputView)
                        {
                            [self testClickX:newPoint.x Y:newPoint.y window:inputView.window];
						   // NSLog(@"-----input str %@ --------------%f-----%f------------",string2,newPoint.x,newPoint.y);
                        }
                        
					}
				});
				delay = delay + 1.1;
			}
			delay = delay + 1.5;
			dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delay * NSEC_PER_SEC)),dispatch_get_main_queue(), ^{
				//[self fakeTouchPointX:-1 pointY:-1];
				//NSLog(@"-----input end --------------------------");
                stringInputIsEnd = 1;
			});
		} else {
			stringInputIsEnd = 1;
		}
		
	}
	
	%new
	-(int)getStringInputIsEnd
	{
		return stringInputIsEnd;
	}
    %new
    -(void)testClickX:(double)pointx Y:(double)pointy window:(UIWindow*)window
    {
       // NSLog(@"------testClickX---------");
        NSInteger pointId = [PTFakeMetaTouch fakeTouchId:[PTFakeMetaTouch getAvailablePointId] AtPoint:CGPointMake(pointx,pointy) inWindow:window withTouchPhase:UITouchPhaseBegan];
        [PTFakeMetaTouch fakeTouchId:pointId AtPoint:CGPointMake(pointx,pointy) inWindow:window withTouchPhase:UITouchPhaseEnded];
    }
    %new
    -(void)testSlideX:(double)pointx Y:(double)pointy toX:(double)toX toY:(double)toY window:(UIWindow*)window
    {
        NSInteger pointId = [PTFakeMetaTouch fakeTouchId:[PTFakeMetaTouch getAvailablePointId] AtPoint:CGPointMake(pointx,pointy) inWindow:window withTouchPhase:UITouchPhaseBegan];
        [PTFakeMetaTouch fakeTouchId:pointId AtPoint:CGPointMake(toX,toY) inWindow:window withTouchPhase:UITouchPhaseMoved];
        [PTFakeMetaTouch fakeTouchId:pointId AtPoint:CGPointMake(toX,toY) inWindow:window withTouchPhase:UITouchPhaseEnded];
    }
    %new
    -(CGPoint)getPointX:(double)x Y:(double)y
    {
        return CGPointMake(x,y);
    }
    %new
	-(CGPoint)testGetCoordinate:(id)view
	{
		int from;
		int to;
		int randX;
		int randY;
		CGPoint newPoint;
		CGRect Rect = [view frame];
		if(Rect.size.width > 10)
		{
			from = (int)(Rect.size.width*0.4);
			to = (int)(Rect.size.width - Rect.size.width*0.4);
			randX = (to-from) > 5 ? (int)(from + (arc4random() % (to - from + 1))) : (int)(Rect.size.width * 0.5);
		}
		else
		{
			randX = Rect.size.width * 0.5;
		}
		if(Rect.size.height > 10)
		{
			from = (int)(Rect.size.height*0.4);
			to = (int)(Rect.size.height - Rect.size.height*0.4);
			randY = (to-from) > 5 ? (int)(from + (arc4random() % (to - from + 1))) : (int)(Rect.size.height * 0.5);
		}
		else
		{
			randY = Rect.size.height * 0.5;
		}
		float x = Rect.origin.x + randX;
		float y = Rect.origin.y + randY;
		newPoint = [view convertPoint:CGPointMake(x, y) toView:[[UIApplication sharedApplication] keyWindow]];
		return newPoint;
	}
    %end
    %hook ClickStreamMgr
    - (void)recordPage:(id)arg1 withTime:(long long)arg2
    {
        NSLog(@"----------recordPage:%@---time:%lld------------",arg1,arg2);
        %orig;
    }
    - (id)getClickStreamReport
    {
        id re = %orig;
        NSLog(@"----------getClickStreamReport:%@----------",re);
        return re;
    }
    - (id)genRedunDantReport
    {
         id re = %orig;
        NSLog(@"----------genRedunDantReport:%@----------",re);
        return re;
    }
    - (void)insertWithKey:(id)arg1 Value:(id)arg2
    {
        NSLog(@"----------insertWithKey:%@------%@----",arg1,arg2);
        %orig;
    }
    %end
    %hook UIView
    - (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event
    {
        id re = %orig;
        NSLog(@"-----hitTest------%f--%f---%@--%@",point.x,point.y,event,re);
        return re;
    }
    %end
   
%end
%ctor{
    NSLog(@"--------inject fake-----------");
    %init(myHook);
   
}