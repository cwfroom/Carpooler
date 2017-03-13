//
//  SuccessViewController.m
//  Carpooler
//
//  Created by Loli on 12/5/16.
//  Copyright © 2016 Wenfei Cao. All rights reserved.
//

#import "SuccessViewController.h"
#import "MapViewController.h"
#import "DataConnect.h"

@interface SuccessViewController ()
@property (weak, nonatomic) IBOutlet UILabel *sessionIDLabel;
@property (strong, nonatomic) DataConnect* dc;
@end

@implementation SuccessViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.navigationItem.hidesBackButton = true;
    self.dc = [DataConnect sharedModel];
    
    self.sessionIDLabel.text = [NSString stringWithFormat:@"Session ID : %d", self.dc.getSessionID];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void) setSessionID : (int) id{
    self.sessionIDLabel.text = [NSString stringWithFormat:@"Session ID : %d", id];
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"driverMap"]){
        MapViewController* vc =  [segue destinationViewController];
        [vc setDriver:YES];
    }
}


@end
