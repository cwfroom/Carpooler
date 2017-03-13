//
//  JoinSessionViewController.m
//  Carpooler
//
//  Created by Loli on 12/8/16.
//  Copyright © 2016 Wenfei Cao. All rights reserved.
//

#import "JoinSessionViewController.h"
#import "DataConnect.h"
#import "MapViewController.h"


@interface JoinSessionViewController () <UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet UITextField *nameField;
@property (weak, nonatomic) IBOutlet UIButton *okButton;
@property (strong, nonatomic) DataConnect* dc;
@end

@implementation JoinSessionViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.dc = [DataConnect sharedModel];
    self.navigationItem.title = [self.dc getSessionName];
    self.nameField.delegate = self;
    [self.nameField becomeFirstResponder];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    
    NSString* str = [self.nameField.text stringByReplacingCharactersInRange:range withString:string];
    
    if (str.length > 0){
        self.okButton.enabled = YES;
    }else{
        self.okButton.enabled = NO;
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

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"riderMap"]){
        MapViewController* vc =  [segue destinationViewController];
        [[self.dc getLocalRider] setName:self.nameField.text];
        [self.dc createLocalRider];
        [vc setDriver:NO];
    }
}
- (IBAction)keyboardDismiss:(id)sender {
    [self.nameField resignFirstResponder];
}


@end
