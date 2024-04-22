//
//  ViewController.m
//  ToDo_App
//
//  Created by husayn on 02/04/2024.
//

#import "ViewController.h"
#import "TaskViewController.h"
#import "Task.h"
#import "DetailsViewController.h"
#import "Helper.h"
@interface ViewController ()
@property (weak, nonatomic) IBOutlet UITableView *tasksTable;
@property (weak, nonatomic) IBOutlet UISearchBar *searchingBar;
@property Helper* helper;
@property NSArray *todoArr;
@property NSArray *tempTodo;
@property bool isSearching;
@property NSMutableArray<Task*> *searchList;
@end

@implementation ViewController
//life cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    _tasksTable.delegate = self;
    _tasksTable.dataSource = self;
    
    _searchingBar.delegate = self;
    _searchingBar.autocapitalizationType = UITextAutocapitalizationTypeNone;
    _isSearching = NO;
    
    _helper = [Helper getInstance];
    _searchList = [NSMutableArray new];
}
//life cycle
-(void)viewWillAppear:(BOOL)animated{
//    _savedData = [_userDefaults objectForKey:@"todolist"];
//    _todoArr = (NSArray*) [NSKeyedUnarchiver unarchivedArrayOfObjectsOfClass:[Task class] fromData:_savedData error:nil];
//    _tempTodo = [self filterToDoArray:_todoArr];
    _todoArr = [_helper readArrayOfTasksFromUserDefaults:@"todolist"];
    _tempTodo = [self filterToDoArray:_todoArr];
    [_tasksTable reloadData];
    if (self->_tempTodo.count == 0) {
        self.tasksTable.hidden = YES;
    }else{
        self.tasksTable.hidden = NO;

    }
}
//button
- (IBAction)addNewTask:(id)sender {
    TaskViewController * taskViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"TaskViewController"];
    [self.navigationController pushViewController:taskViewController animated:YES];
}
//searched list
-(void) searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText{
    _isSearching = YES;
    [_searchList removeAllObjects];
    for(Task * task in _tempTodo){
        if([[task.taskName lowercaseString] containsString:[searchText lowercaseString] ]){
            [_searchList addObject:task];
        }
        [_tasksTable reloadData];
    }
}	
//filtering the array to be todos only
-(NSArray<Task*>*)filterToDoArray:(NSArray<Task*>*)todos{
    NSMutableArray *arr = [NSMutableArray new];
    for(Task* task in todos){
        if(task.status == 0){
            [arr addObject:task];
        }
    }
    return arr;
}
//table view
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath{
    return YES;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 70;
}
//applying cell
- (nonnull UITableViewCell *)tableView:(nonnull UITableView *)tableView cellForRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"TaskCell" forIndexPath: indexPath];
    UIImageView *taskImg = [cell viewWithTag:0];
    UILabel *taskNameLabel = [cell viewWithTag:1];
    UILabel *taskDescriptionLabel = [cell viewWithTag:2];
    if(_isSearching && ![_searchingBar.text isEqual:@""]){
        taskNameLabel.text = [_searchList[indexPath.row] taskName];
        taskDescriptionLabel.text=[_searchList[indexPath.row] taskDescription];
        switch([_searchList[indexPath.row] prioritize]){
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
                taskImg.image=[UIImage imageNamed:@"1"];
                break;
        }
    }else{
        _isSearching = NO;
        [_searchList removeAllObjects];
        taskNameLabel.text = [_tempTodo[indexPath.row] taskName];
        taskDescriptionLabel.text=[_tempTodo[indexPath.row] taskDescription];
        switch([_tempTodo[indexPath.row] prioritize]){
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
                taskImg.image=[UIImage imageNamed:@"1"];
                break;
        }
    }
    return cell;
}
//number of rows
- (NSInteger)tableView:(nonnull UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSInteger count =0;
    if(_isSearching && ![_searchingBar.text isEqual:@""]){
        count = _searchList.count;
    }else{
        count = _tempTodo.count;
    }
    return count;
}
//delete cell
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath{
    if(editingStyle == UITableViewCellEditingStyleDelete){
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Confirm" message:@"Are you sure you want to delete this task" preferredStyle:UIAlertControllerStyleActionSheet];
        UIAlertAction *delete = [UIAlertAction actionWithTitle:@"Delete" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
            NSMutableArray *arr = [NSMutableArray arrayWithArray:self->_todoArr];
            [arr removeObjectAtIndex:[self->_todoArr indexOfObject:[self->_tempTodo objectAtIndex:indexPath.row]]];
            self->_todoArr = [NSArray arrayWithArray:arr];
            self->_tempTodo = [self filterToDoArray:self->_todoArr];
            [self->_helper writeArrayOfTasksToUserDefaults:@"todolist" withArray: self->_todoArr];
            [self->_tasksTable reloadData];
            if (self->_tempTodo.count == 0) {
                self.tasksTable.hidden = YES;
            }
        }];
        UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil];
        [alert addAction:delete];
        [alert addAction:cancel];
        [self presentViewController:alert animated:YES completion:nil];
    }else if(editingStyle==UITableViewCellEditingStyleInsert){
        //create a new instance of the appropriate class, insert it into the array andd add a new row to the table view
    }
}
//for on click
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    DetailsViewController * detailsViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"DetailsViewController"];
    Task* t = _tempTodo[indexPath.row];
    [detailsViewController setUpScreen:t:(int)[_todoArr indexOfObject:t]];
    [detailsViewController setScreenIndex:0];
    [self.navigationController pushViewController:detailsViewController animated:YES];

}

@end
