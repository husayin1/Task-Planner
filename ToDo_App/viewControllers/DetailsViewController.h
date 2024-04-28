//
//  DetailsViewController.h
//  ToDo_App
//
//  Created by husayn on 02/04/2024.
//

#import <UIKit/UIKit.h>
#import "Task.h"
NS_ASSUME_NONNULL_BEGIN
@interface DetailsViewController : UIViewController
//@property Task *taskDetailed;
-(void) setUpScreen:(Task*) screenTask :(int) index;
-(void) setScreenIndex:(int) idx;
@end

NS_ASSUME_NONNULL_END
