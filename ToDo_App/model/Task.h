//
//  Task.h
//  ToDo_App
//
//  Created by husayn on 02/04/2024.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface Task : NSObject <NSCoding,NSSecureCoding>
@property NSString *taskName;
@property NSString *taskDescription;
@property int prioritize;
@property int status;
@property NSDate *taskDate;

-(BOOL) isExistTask:(Task*) replaceTask;
@end

NS_ASSUME_NONNULL_END
