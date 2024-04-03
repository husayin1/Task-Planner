//
//  Task.m
//  ToDo_App
//
//  Created by husayn on 02/04/2024.
//

#import "Task.h"

@implementation Task

- (void)encodeWithCoder:(nonnull NSCoder *)coder {
    [coder encodeObject:_taskName forKey:@"taskName"];
    [coder encodeObject:_taskDescription forKey:@"taskDescription"];
    [coder encodeInt:_prioritize forKey:@"prioritize"];
    [coder encodeInt:_status forKey:@"status"];
    [coder encodeObject:_taskDate forKey:@"date"];
}

- (nullable instancetype)initWithCoder:(nonnull NSCoder *)coder {
    if(self = [super init]){
        _taskName = [coder decodeObjectOfClass:[NSString class] forKey:@"taskName"];
        _taskDescription = [coder decodeObjectOfClass:[NSString class] forKey:@"taskDescription"];
        _prioritize  = [coder decodeIntForKey:@"prioritize"];
        _status  = [coder decodeIntForKey:@"status"];
        _taskDate = [coder decodeObjectOfClass:[NSDate class] forKey:@"date"];
    }
    return self;
}
+(BOOL)supportsSecureCoding{
    return YES;
}
-(BOOL)isExistTask:(Task *)replaceTask{
    bool result=NO;
    if([self.taskName isEqual:replaceTask.taskName]&&[self.taskDescription isEqual:replaceTask.taskDescription] && self.prioritize == replaceTask.prioritize && self.status == replaceTask.status && [self.taskDate isEqualToDate:replaceTask.taskDate]){
        result = YES;
    }
    return result;
}

@end
