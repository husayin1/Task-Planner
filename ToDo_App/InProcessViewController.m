//
//  InProcessViewController.m
//  ToDo_App
//
//  Created by husayn on 02/04/2024.
//

#import "InProcessViewController.h"
#import "Task.h"
#import "Helper.h"
#import "DetailsViewController.h"
@interface InProcessViewController ()
@property (weak, nonatomic) IBOutlet UITableView *progressTable;

//@property NSUserDefaults *userDefault;
@property NSArray *allTasks;
@property NSArray<Task*> *inProcessTasks;
@property NSArray *high;
@property NSArray *med;
@property NSArray *low;
//@property NSData *savedData;
@property Helper *helper;
@property bool isSections ;
@property NSArray<NSArray<Task*>*> *temp;
@property UIBarButtonItem *filterButton;
@end

@implementation InProcessViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    _filterButton = [[UIBarButtonItem alloc]initWithTitle:@"Filter" style:UIBarButtonItemStylePlain target:self action:@selector(filterClicked)];
    [self.navigationItem setRightBarButtonItem:_filterButton];
    
//    _userDefault = [NSUserDefaults standardUserDefaults];
    _helper = [Helper getInstance];
    _progressTable.delegate=self;
    _progressTable.dataSource=self;
    _isSections = NO;
}

//filtering the array to be in process
-(NSArray<Task*>*)filterInProcessArray:(NSArray<Task*>*)process{
    NSMutableArray *arr = [NSMutableArray new];
    for(Task* task in process){
        if(task.status == 1){
            [arr addObject:task];
        }
    }
    return arr;
}
//filtering to 3 arrays
-(NSArray*) filterToSectionArray:(NSArray*) todosAr :(int) prio{
    NSMutableArray *arraySec = [NSMutableArray new];
    
    for(Task *task in todosAr){
        if(task.prioritize == prio){
            [arraySec addObject:task];
        }
    }
    return arraySec;
}
- (nonnull UITableViewCell *)tableView:(nonnull UITableView *)tableView cellForRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    UITableViewCell *cell = [_progressTable dequeueReusableCellWithIdentifier:@"ProcessCell" forIndexPath: indexPath];
    UIImageView *taskImg = [cell viewWithTag:0];
    UILabel *taskNameLabel = [cell viewWithTag:1];
    UILabel *taskDescriptionLabel = [cell viewWithTag:2];
    NSString *title ;
    NSString *desc ;
    int cellPrio;
    if(_isSections){
        title = _temp[indexPath.section][indexPath.row].taskName;
        desc = _temp[indexPath.section][indexPath.row].taskDescription;
        cellPrio = _temp[indexPath.section][indexPath.row].prioritize;
    }else{
        title = _inProcessTasks[indexPath.row].taskName;
        desc=_inProcessTasks[indexPath.row].taskDescription;
        cellPrio=_inProcessTasks[indexPath.row].prioritize;
    }
    
    taskNameLabel.text = title;
    taskDescriptionLabel.text=desc;
    switch(cellPrio){
        case 0:
            taskImg.image=[UIImage imageNamed:@"0"];
            break;
        case 1:
            taskImg.image=[UIImage imageNamed:@"1"];
            break;
        case 2:
            taskImg.image=[UIImage imageNamed:@"2"];
            break;
        default:
            break;
    }
    return cell;
}
//delete cell
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath{
    if(editingStyle == UITableViewCellEditingStyleDelete){
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Confirm" message:@"Are you sure you want to delete this task" preferredStyle:UIAlertControllerStyleActionSheet];
        UIAlertAction *delete = [UIAlertAction actionWithTitle:@"Delete" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
            NSMutableArray *arr = [NSMutableArray arrayWithArray:self->_allTasks];
            [arr removeObjectAtIndex:[self->_allTasks indexOfObject:[self->_inProcessTasks objectAtIndex:indexPath.row]]];
            self->_allTasks = [NSArray arrayWithArray:arr];
            self->_inProcessTasks = [self filterInProcessArray:self->_allTasks];
//            NSData * archiveData = [NSKeyedArchiver archivedDataWithRootObject:self->_allTasks requiringSecureCoding:YES error:nil];
//            [self->_userDefault setObject:archiveData forKey:@"todolist"];
            [self->_helper writeArrayOfTasksToUserDefaults:@"todolist" withArray:self->_allTasks];
            [self->_progressTable reloadData];
            [self loadData];
        }];
        UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil];
        [alert addAction:delete];
        [alert addAction:cancel];
        [self presentViewController:alert animated:YES completion:nil];
    }else if(editingStyle==UITableViewCellEditingStyleInsert){
        //create a new instance of the appropriate class, insert it into the array andd add a new row to the table view
    }
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 70;
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    DetailsViewController *detailsViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"DetailsViewController"];
    Task * te;
    if(_isSections){
        te = _temp[indexPath.section][indexPath.row];
    }else{
        te = _inProcessTasks[indexPath.row];
    }
    [detailsViewController setUpScreen:te :(int)[_allTasks indexOfObject:te]];
    [detailsViewController setScreenIndex:1];
    [self.navigationController pushViewController:detailsViewController animated:YES];
}
-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    NSString *title;
    if(_isSections){
        switch(section){
            case 0:
                title=@"High Priority";
                break;
            case 1:
                title=@"Medium Priority";
                break;
            case 2:
                title=@"Low Priority";
                break;
            default:
                title = @"";
                break;
        }
    }else{
        title=@"";
    }
    return title;
}

- (NSInteger)tableView:(nonnull UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSInteger count = 0;
    if(_isSections){
        switch(section){
            case 0:
                count = _high.count;
                break;
            case 1:
                count = _med.count;
                break;
            case 2:
                count = _low.count;
                break;
            default:
                count=0;
                break;
        }
    }else{
        count = _inProcessTasks.count;
    }
    return count;
}
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return _isSections? 3 : 1;
}
-(void) filterClicked{
    _isSections=!_isSections;
    if(_isSections){
        [_filterButton setTitle:@"All"];
    }else{
        [_filterButton setTitle:@"Filter"];
    }
    [self loadData];
}


-(void) loadData{
//    _savedData = [_userDefault objectForKey:@"todolist"];
//    _allTasks = (NSArray*) [NSKeyedUnarchiver unarchivedArrayOfObjectsOfClass:[Task class] fromData:_savedData error:nil];
    _allTasks = [_helper readArrayOfTasksFromUserDefaults:@"todolist"];
    _inProcessTasks = [self filterInProcessArray:_allTasks];
    if(_isSections){
        _high = [self filterToSectionArray:_inProcessTasks:0];
        _med = [self filterToSectionArray:_inProcessTasks:1];
        _low = [self filterToSectionArray:_inProcessTasks:2];
        
        _temp = @[_high,_med,_low];
    }
    [_progressTable reloadData];
}
-(void)viewWillAppear:(BOOL)animated{
    [self loadData];
}

@end
