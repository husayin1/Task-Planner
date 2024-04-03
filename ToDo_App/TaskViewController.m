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
@property Task *alertTask;
//@property NSUserDefaults * userDefauls;
//@property NSData *savedData;
@property NSArray *todoList;
@property Helper* helper;

@end

@implementation TaskViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    _datePicker.minimumDate = [NSDate date];
    _helper = [Helper getInstance];
    _alertTask = [Task new];
//    _userDefauls =[NSUserDefaults standardUserDefaults];
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
           
//           _savedData = [_userDefauls objectForKey:key];
//           _todoList = (NSArray*) [NSKeyedUnarchiver unarchivedArrayOfObjectsOfClass:[Task class] fromData:_savedData error:nil];
           _todoList = [_helper readArrayOfTasksFromUserDefaults:key];
           NSMutableArray *temp = [NSMutableArray arrayWithArray:_todoList];
           [temp addObject: t];
           _todoList = [NSArray arrayWithArray:temp];
//           NSData *archiveData = [NSKeyedArchiver archivedDataWithRootObject:_todoList requiringSecureCoding:YES error:nil];
//           [_userDefauls setObject:archiveData forKey:key];
           [_helper writeArrayOfTasksToUserDefaults:key withArray:self->_todoList];
           
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
//    [_taskDelegate insertTask:t];
    if(_isOpen){
        [self notifyClicked];
    }
}

- (void)viewWillAppear:(BOOL)animated{
    [_statusSC removeSegmentAtIndex:2 animated:YES];
    [_statusSC removeSegmentAtIndex:1 animated:YES];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

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
//       NSDate *currentDate = [NSDate date];// Get the current date
//       currentDate = (NSDate*)_alertTask.taskDate;
//       NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init]; // Create a date formatter
//       [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"]; // Set the date format

//       NSString *dateString = [dateFormatter stringFromDate:currentDate]; // Format the date to string

//       NSLog(@"Current Date: %@", dateString); // Print the formatted date

//       NSDate *targetDate = [[_datePicker.date] dateByAddingTimeInterval:10];
       NSDate *targetDate = _datePicker.date;
       NSDateComponents *dateComponents = [[NSCalendar currentCalendar] components:(NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay | NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitSecond) fromDate:targetDate];

       UNCalendarNotificationTrigger *trigger = [UNCalendarNotificationTrigger triggerWithDateMatchingComponents:dateComponents repeats:NO];

       UNNotificationRequest *request = [UNNotificationRequest requestWithIdentifier:@"some_long_id" content:content trigger:trigger];
       [[UNUserNotificationCenter currentNotificationCenter] addNotificationRequest:request withCompletionHandler:^(NSError * _Nullable error) {
           if (error != nil) {
               NSLog(@"Something went wrong");
           }
       }];
   }
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
