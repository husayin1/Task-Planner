//
//  DetailsViewController.m
//  ToDo_App
//
//  Created by husayn on 02/04/2024.
//

#import "DetailsViewController.h"
#import "Task.h"

@interface DetailsViewController ()
@property (weak, nonatomic) IBOutlet UITextField *taskNameTF;
@property (weak, nonatomic) IBOutlet UITextField *taskDescriptionTF;
@property (weak, nonatomic) IBOutlet UISegmentedControl *taskPrioritySC;
@property (weak, nonatomic) IBOutlet UISegmentedControl *taskStatusSC;
@property (weak, nonatomic) IBOutlet UIDatePicker *taskDate;
@property (weak, nonatomic) IBOutlet UIButton *edtButton;

@property NSUserDefaults *userDefaults;
@property NSArray * tasks;
@property NSData *savedData;
@property (nonatomic) int screenIndex;
@property Task * taskScreen;
@property int taskIndex;
@property bool isEditable;
@end

@implementation DetailsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    _userDefaults = [NSUserDefaults standardUserDefaults];
    _savedData = [_userDefaults objectForKey:@"todolist"];
    _tasks = (NSArray*) [NSKeyedUnarchiver unarchivedArrayOfObjectsOfClass:[Task class] fromData:_savedData error:nil];
    _isEditable = NO;
    [self editableFields:NO];
}
-(void)viewWillAppear:(BOOL)animated{
    [self setFields:_taskScreen];
    switch(_screenIndex){
        case 0:
            break;
        case 1:
            [_taskStatusSC setEnabled:NO forSegmentAtIndex:0];
            break;
        case 2:
            [_taskStatusSC removeSegmentAtIndex:1 animated:YES];
            [_taskStatusSC removeSegmentAtIndex:0 animated:YES];
            [_taskNameTF setEnabled:NO];
            [_taskDescriptionTF setEnabled:NO];
            [_taskPrioritySC setEnabled:NO];
            [_taskStatusSC setEnabled:NO];
            [_taskDate setEnabled:NO];
            [_edtButton setHidden:YES];
            break;
        default:
            break;
    }
}

-(void) editableFields:(bool) editable{
    [_taskNameTF setEnabled:editable];
    [_taskDescriptionTF setEnabled:editable];
    [_taskPrioritySC setEnabled:editable];
    [_taskStatusSC setEnabled:editable];
    [_taskDate setEnabled:editable];
}
- (IBAction)editTask:(id)sender {
    _isEditable=!_isEditable;
    if(_isEditable){
        [self editableFields:YES];
        [_edtButton setTitle:@"Save" forState:normal];
    }else{
        [self editableFields:NO];
        [_edtButton setTitle:@"Edit" forState:normal];
    }
    if(![[_taskNameTF.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] isEqual:@""]){
        Task* te = [Task new];
        te.taskName = _taskNameTF.text;
        te.taskDescription = _taskDescriptionTF.text;
        te.status =(int) _taskStatusSC.selectedSegmentIndex;
        te.prioritize = (int)_taskPrioritySC.selectedSegmentIndex;
        te.taskDate = _taskDate.date;
        bool isExist = [_taskScreen isExistTask:te];
        if(!isExist){
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Confirmation" message:@"Are you sure you want to edit the task" preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *yes = [UIAlertAction actionWithTitle:@"YES" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
                NSMutableArray *arr = [NSMutableArray arrayWithArray:self->_tasks];
                [arr replaceObjectAtIndex:self->_taskIndex withObject:te];
                self->_tasks = [NSArray arrayWithArray: arr];
                NSData *archiveData = [NSKeyedArchiver archivedDataWithRootObject:self->_tasks requiringSecureCoding:YES error:nil];
                [self->_userDefaults setObject:archiveData forKey:@"todolist"];
        
                [self.navigationController popViewControllerAnimated:YES];
            }];
            UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"CANCEL" style:UIAlertActionStyleCancel handler:nil];
            
            [alert addAction:yes];
            [alert addAction:cancel];
            [self presentViewController:alert animated:YES completion:nil];
        }
    }else{
        
    }
}
-(void)setUpScreen:(Task *)screenTask :(int)index{
    _taskScreen = screenTask;
    _taskIndex = index;
}
-(void)setScreenIndex:(int)idx{
    _screenIndex = idx;
}
-(void) setFields: (Task*) scrnTask{
    _taskNameTF.text = scrnTask.taskName;
    _taskDescriptionTF.text = scrnTask.taskDescription;
    _taskPrioritySC.selectedSegmentIndex = scrnTask.prioritize;
    _taskStatusSC.selectedSegmentIndex = scrnTask.status;
    _taskDate.date = scrnTask.taskDate;
}


@end
