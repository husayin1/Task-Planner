//
//  TaskViewController.m
//  ToDo_App
//
//  Created by husayn on 02/04/2024.
//

#import "TaskViewController.h"
#import "Task.h"
#import <UserNotifications/UserNotifications.h>
#import "Helper.h"
@interface TaskViewController ()
@property (weak, nonatomic) IBOutlet UITextField *taskNameTF;
@property (weak, nonatomic) IBOutlet UITextField *taskDescriptionTF;
@property (weak, nonatomic) IBOutlet UISegmentedControl *prioritySC;
@property (weak, nonatomic) IBOutlet UISegmentedControl *statusSC;
@property (weak, nonatomic) IBOutlet UIDatePicker *datePicker;
@property (weak, nonatomic) IBOutlet UISwitch *switchAlert;
@property bool isOpen;
@property NSDate *dateOfNotif;
@property Task *alertTask;
@property NSArray *todoList;
@property Helper* helper;

@end

@implementation TaskViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _datePicker.minimumDate = [NSDate date];
    _dateOfNotif = [NSDate date];
    _helper = [Helper getInstance];
    _alertTask = [Task new];
}

- (IBAction)forNotifc:(UIDatePicker *)sender {
    _dateOfNotif = _datePicker.date;
    NSLog(@"@%",_datePicker);
}


- (IBAction)insertTask:(id)sender {
    Task *t = [Task new];
    if(
       ![[_taskNameTF.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] isEqual:@""]
       &&
       ![[_taskDescriptionTF.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] isEqual:@""]){
           t.taskName = _taskNameTF.text;
           t.taskDescription = _taskDescriptionTF.text;
           t.prioritize = (int)_prioritySC.selectedSegmentIndex;
           t.status = (int)_statusSC.selectedSegmentIndex;
           t.taskDate = _datePicker.date;
           NSString * key = @"todolist";
           
           _todoList = [_helper readArrayOfTasksFromUserDefaults:key];
           NSMutableArray *temp = [NSMutableArray arrayWithArray:_todoList];
           [temp addObject: t];
           _todoList = [NSArray arrayWithArray:temp];
           [_helper writeArrayOfTasksToUserDefaults:key withArray:self->_todoList];
           printf("size of array todo is %ld",_todoList.count);
           printf("Add Task Controller : \n");
           printf("Inserted Task name is %s\n",[t.taskName UTF8String]);
           printf("Inserted Task Description is %s\n",[t.taskDescription UTF8String]);
           [self.navigationController popViewControllerAnimated:YES];
       }else{
           UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Empty Fields" message:@"Please Fill Task Name And Description" preferredStyle:UIAlertControllerStyleAlert];
           UIAlertAction *ok = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil];
           [alert addAction:ok];
           [self presentViewController:alert animated:YES completion:^{
               printf("The data is not filled \n");
           }];
       }
    _alertTask = t;
    if(_isOpen){
        [self notifyClicked];
    }
}

- (void)viewWillAppear:(BOOL)animated{
    [_statusSC removeSegmentAtIndex:2 animated:YES];
    [_statusSC removeSegmentAtIndex:1 animated:YES];
}


-(void) notifyClicked{
    [[UNUserNotificationCenter currentNotificationCenter] requestAuthorizationWithOptions:(UNAuthorizationOptionAlert | UNAuthorizationOptionBadge | UNAuthorizationOptionSound) completionHandler:^(BOOL success, NSError * _Nullable error) {
           if (success) {
               [self scheduleTest];
           } else if (error != nil) {
               NSLog(@"Error occurred");
           }
       }];
   }

   - (void)scheduleTest {
       UNMutableNotificationContent *content = [[UNMutableNotificationContent alloc] init];
       content.title = _alertTask.taskName;
       content.sound = [UNNotificationSound defaultSound];
       content.body = _alertTask.taskDescription;
       
       NSDate *targetDate = [_dateOfNotif dateByAddingTimeInterval:10];
       NSDateComponents *components = [[NSCalendar currentCalendar] components:NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay | NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitSecond fromDate:targetDate];
       UNCalendarNotificationTrigger *trigger = [UNCalendarNotificationTrigger triggerWithDateMatchingComponents:components repeats:NO];

       UNNotificationRequest *request = [UNNotificationRequest requestWithIdentifier:@"some_long_id" content:content trigger:trigger];
       [[UNUserNotificationCenter currentNotificationCenter] addNotificationRequest:request withCompletionHandler:^(NSError * _Nullable error) {
           if (error != nil) {
               NSLog(@"Something went wrong");
           }
       }];   }
- (IBAction)alertSwitch:(id)sender {
    if([sender isOn]){
        printf("Alert is On\n");
        _isOpen = YES;
        [self notifyClicked];
    }else{
        _isOpen = NO;
        printf("Alert is Off\n");
    }
}


@end
