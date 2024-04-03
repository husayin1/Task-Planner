//
//  InsertionDelegate.h
//  ToDo_App
//
//  Created by husayn on 02/04/2024.
//

#import <Foundation/Foundation.h>
#import "Task.h"
NS_ASSUME_NONNULL_BEGIN

@protocol InsertionDelegate <NSObject>
-(void) insertTask:(Task*) task;

@end

NS_ASSUME_NONNULL_END
