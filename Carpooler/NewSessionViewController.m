//
//  NewSessionViewController.m
//  Carpooler
//
//  Created by Loli on 12/5/16.
//  Copyright © 2016 Wenfei Cao. All rights reserved.
//

#import "NewSessionViewController.h"
#import "DataConnect.h"
#import "SuccessViewController.h"
@interface NewSessionViewController () <UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet UITextField *sessionNameField;
@property (weak, nonatomic) IBOutlet UIButton *createButton;
@property (strong, nonatomic) DataConnect* dc;

@property int sessionID;
@end

@implementation NewSessionViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _dc = [DataConnect sharedModel];
    self.sessionNameField.delegate = self;
    [self.sessionNameField becomeFirstResponder];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    
    NSString* str = [self.sessionNameField.text stringByReplacingCharactersInRange:range withString:string];
    
    if (str.length > 0){
        self.createButton.enabled = YES;
    }else{
        self.createButton.enabled = NO;
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
- (IBAction)createSession:(id)sender {
    self.sessionID = [self.dc createNewSession:self.sessionNameField.text];
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"createSuccess"]){
        SuccessViewController* vc =  [segue destinationViewController];
        [vc setSessionID:self.sessionID];
    }
    }
- (IBAction)keyboardDismiss:(id)sender {
    [self.sessionNameField resignFirstResponder];
}


@end
