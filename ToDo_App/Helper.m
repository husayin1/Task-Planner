//
//  Helper.m
//  ToDo_App
//
//  Created by husayn on 03/04/2024.
//

#import "Helper.h"
#import "Task.h"
#import <Foundation/Foundation.h>
@implementation Helper
static Helper* _helperSingleton = nil;
static NSUserDefaults *userDefaults =nil;
+(Helper*) getInstance{
    @synchronized ([Helper class]) {
        if(!_helperSingleton){
            _helperSingleton = [[self alloc]init];
            userDefaults = [NSUserDefaults standardUserDefaults];
        }
    }
    return _helperSingleton;
}
//put in UD
-(void) writeArrayOfTasksToUserDefaults:(NSString *)key withArray:(NSArray *)newArr{
    NSData* archiveData = [NSKeyedArchiver archivedDataWithRootObject:newArr requiringSecureCoding:YES error:nil];
    [userDefaults setObject:archiveData forKey:key];
}
//get from UD
- (NSArray *)readArrayOfTasksFromUserDefaults:(NSString *)key{
    NSArray *myArr;
    NSData *savedData = [userDefaults objectForKey:key];
    myArr = [NSKeyedUnarchiver unarchivedArrayOfObjectsOfClass:[Task class] fromData:savedData error:nil];
    
    if(myArr==nil){
        myArr= [NSMutableArray new];
    }
    return myArr;
}
@end
