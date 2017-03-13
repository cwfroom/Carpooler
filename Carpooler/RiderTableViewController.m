//
//  RiderTableViewController.m
//  Carpooler
//
//  Created by Loli on 12/9/16.
//  Copyright © 2016 Wenfei Cao. All rights reserved.
//

#import "RiderTableViewController.h"
#import "DataConnect.h"
#import "DetailViewController.h"
@import Firebase;

@interface RiderTableViewController () <UITableViewDelegate>
@property (strong, nonatomic) DataConnect* dc;
@property (strong, nonatomic) FIRDatabaseReference *dbRef;
@property NSInteger selectedIndex;
@property (strong, nonatomic) Rider* selectedRider;

@end

@implementation RiderTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.tableView.delegate = self;
    
    self.dc = [DataConnect sharedModel];
    self.navigationItem.title = [self.dc getSessionName];
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    self.dbRef = [[FIRDatabase database] reference];
    NSString* sessionID = [NSString stringWithFormat:@"%d",[self.dc getSessionID]];
    [[self.dbRef child:sessionID] observeEventType:FIRDataEventTypeValue withBlock:^(FIRDataSnapshot * _Nonnull snapshot) {
        for (FIRDataSnapshot* child in snapshot.children){
            if (![child.key  isEqual: kSessionNameKey]){
                Rider* rider = [[Rider alloc] init];
                rider.name = child.key;
                rider.x = child.value[kCoordXKey];
                rider.y = child.value[kCoordYKey];
                rider.image = child.value[kImageKey];
                rider.memo = child.value[kMemoKey];
                
                [self.dc updateRemoteRider:rider];
            }
        }
        [self.tableView reloadData];
    }];

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [[self.dc getRemoteRiders] count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"riderCell" forIndexPath:indexPath];
    
    cell.textLabel.text = [[[self.dc getRemoteRiders]objectAtIndex:indexPath.row] name];
    
    return cell;
}

- (void) tableView: (UITableView *) tableView didSelectRowAtIndexPath: (NSIndexPath *) indexPath {
    self.selectedIndex = indexPath.row;
    self.selectedRider = [[self.dc getRemoteRiders]objectAtIndex:self.selectedIndex];
    [self performSegueWithIdentifier:@"riderViewSegue" sender:self];
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"riderViewSegue"]){
        DetailViewController* vc =  [segue destinationViewController];
        [vc setDriverMode:YES];
        [vc setRider:self.selectedRider];
    }
}



@end
