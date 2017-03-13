//
//  StartViewController.m
//  Carpooler
//
//  Created by Loli on 12/5/16.
//  Copyright © 2016 Wenfei Cao. All rights reserved.
//

#import "StartViewController.h"
#import "DataConnect.h"
#import "MapViewController.h"
@import Firebase;

@interface StartViewController () <UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet UITextField *sessionIDField;
@property (weak, nonatomic) IBOutlet UIButton *joinButton;
@property (weak, nonatomic) IBOutlet UISwitch *driverSwitch;
@property (strong, nonatomic) DataConnect* dc;
@property (strong, nonatomic) FIRDatabaseReference *dbRef;
@end

@implementation StartViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _dc = [DataConnect sharedModel];
    self.sessionIDField.delegate = self;
    self.dbRef = [[FIRDatabase database] reference];
    
    //[self.sessionIDField becomeFirstResponder];
    // Do any additional setup after loading the view.
   
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    
    NSString* str = [self.sessionIDField.text stringByReplacingCharactersInRange:range withString:string];
    
    if (str.length > 0){
        self.joinButton.enabled = YES;
    }else{
        self.joinButton.enabled = NO;
    }
    return YES;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    UITouch *touch = [[event allTouches] anyObject];
    if (![[touch view] isKindOfClass:[UITextField class]] && ![[touch view] isKindOfClass:[UITextView class]]) {
        [self.view endEditing:YES];
    }
    [super touchesBegan:touches withEvent:event];
}

- (IBAction)joinButtonTouch:(id)sender {
    NSString* sessionID = self.sessionIDField.text;
    [[self.dbRef child:sessionID] observeSingleEventOfType:FIRDataEventTypeValue withBlock:^(FIRDataSnapshot * _Nonnull snapshot) {
        
        if ([snapshot hasChildren]){
            //retrive value successfully
            NSString* sessionName = snapshot.value[kSessionNameKey];
            [self.dc joinSession:[sessionID intValue] sessionName:sessionName];
            if (self.driverSwitch.isOn){
                [self performSegueWithIdentifier:@"joinDriverSegue" sender:self];
            }else{
                [self performSegueWithIdentifier:@"joinRiderSegue" sender:self];
            }
            
        }else{
            //display alert for not finding the session
            UIAlertController* alertCotroller = [UIAlertController alertControllerWithTitle:@"Cannot find session" message:@"Check the session ID" preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction* okAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction* action){
                
            }];
            
            [alertCotroller addAction:okAction];
            [self presentViewController:alertCotroller animated:YES completion:nil];
        }
        
    } withCancelBlock:^(NSError * _Nonnull error) {
        NSLog(@"Error when trying to fetch data");
    }];
    
        
    
 
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"joinDriverSegue"]){
        MapViewController* vc =  [segue destinationViewController];
        [vc setDriver:self.driverSwitch.isOn];
    }
    
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
- (IBAction)endEditing:(id)sender {
    [self.sessionIDField resignFirstResponder];
}


@end
