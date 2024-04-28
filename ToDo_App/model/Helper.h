//
//  Helper.h
//  ToDo_App
//
//  Created by husayn on 03/04/2024.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface Helper : NSObject
-(void) writeArrayOfTasksToUserDefaults:(NSString*)key withArray: (NSArray*)newArr;
-(NSArray*) readArrayOfTasksFromUserDefaults:(NSString*)key;
+(Helper*) getInstance ;
@end

NS_ASSUME_NONNULL_END
