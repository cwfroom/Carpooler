//
//  DetailViewController.m
//  Carpooler
//
//  Created by Loli on 12/9/16.
//  Copyright © 2016 Wenfei Cao. All rights reserved.
//

#import "DetailViewController.h"
#import "DataConnect.h"
#import <MediaPlayer/MediaPlayer.h>
#import <MobileCoreServices/UTCoreTypes.h>
#import <QuartzCore/QuartzCore.h>
@import FirebaseStorage;
@interface DetailViewController () <UITextViewDelegate,UIImagePickerControllerDelegate, UINavigationControllerDelegate>
@property BOOL mDriverMode;
@property BOOL mImageSet;
//@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UIButton *imageButton;
@property (weak, nonatomic) IBOutlet UITextView *memoView;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *saveButton;
@property (strong, nonatomic) DataConnect* dc;
@property (strong, nonatomic) Rider* mRider;
@property (strong, nonatomic) FIRStorage* storage;
@property (strong, nonatomic) FIRStorageReference* storageRef;

@property (copy, nonatomic) NSString *lastChosenMediaType;
@end

@implementation DetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.memoView.delegate = self;
    self.dc = [DataConnect sharedModel];
    self.storage = [FIRStorage storage];
    self.storageRef = [self.storage referenceForURL:@"gs://carpooler-f60a2.appspot.com"];
    
    [[self.memoView layer] setBorderColor:[[UIColor grayColor] CGColor]];
    [[self.memoView layer] setBorderWidth:2.3];
    [[self.memoView layer] setCornerRadius:15];
}

-(void)viewDidAppear:(BOOL)animated{
    self.navigationItem.title = self.mRider.name;
    self.memoView.text = self.mRider.memo;
    
    
    if (self.mDriverMode){
        self.saveButton.title = @"";
        self.memoView.editable = NO;
        
        if (![self.mRider.image isEqualToString:@""]){
            //Download and set image
            FIRStorageReference *imageRef = [self.storageRef child:[self.mRider image]];
            [imageRef dataWithMaxSize:1024 * 1024 completion:^(NSData *data, NSError *error){
                if (error != nil) {
                    NSLog(@"Download Error %@",error);
                } else {
                    UIImage *riderImage = [UIImage imageWithData:data];
                    [self.imageButton setImage:[self shrinkImage:riderImage
                                                          toSize:self.imageButton.bounds.size]  forState:UIControlStateNormal];
                }
            }];
        }

    }else{
        if ([[[self.dc getLocalRider]image]isEqualToString:@""]){
            self.mImageSet = NO;
        }else{
            self.mImageSet = YES;
            //Download and set image
            FIRStorageReference *imageRef = [self.storageRef child:[[self.dc getLocalRider] image]];
            [imageRef dataWithMaxSize:1024 * 1024 completion:^(NSData *data, NSError *error){
                if (error != nil) {
                    NSLog(@"Download Error %@",error);
                } else {
                    UIImage *riderImage = [UIImage imageWithData:data];
                    [self.imageButton setImage:[self shrinkImage:riderImage
                                                          toSize:self.imageButton.bounds.size]  forState:UIControlStateNormal];
                }
            }];
        }
        
        self.saveButton.title = @"Save";
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void) setDriverMode:(BOOL)driverMode{
    self.mDriverMode = driverMode;
}

-(void) setRider : (Rider*) rider{
    self.mRider = rider;
}


- (void)textViewDidChange:(UITextView *)textView{
    if (self.memoView.hasText){
        self.saveButton.enabled = YES;
    }else{
        self.saveButton.enabled = NO;
    }
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    UITouch *touch = [[event allTouches] anyObject];
    if (![[touch view] isKindOfClass:[UITextField class]] && ![[touch view] isKindOfClass:[UITextView class]]) {
        [self.view endEditing:YES];
    }
    [super touchesBegan:touches withEvent:event];
}

- (IBAction)saveButtonTouch:(id)sender {
    [[self.dc getLocalRider] setMemo:self.memoView.text];
    [self.dc updateLocalRider];
    [self performSegueWithIdentifier:@"backToMapSegue" sender:self];
}

- (void)pickMediaFromSource:(UIImagePickerControllerSourceType)sourceType
{
    NSArray *mediaTypes = [UIImagePickerController
                           availableMediaTypesForSourceType:sourceType];
    if ([UIImagePickerController
         isSourceTypeAvailable:sourceType] && [mediaTypes count] > 0) {
        NSArray *mediaTypes = [UIImagePickerController
                               availableMediaTypesForSourceType:sourceType];
        UIImagePickerController *picker = [[UIImagePickerController alloc] init];
        picker.mediaTypes = mediaTypes;
        picker.delegate = self;
        picker.allowsEditing = YES;
        picker.sourceType = sourceType;
        [self presentViewController:picker animated:YES completion:NULL];
    }
}

- (void)imagePickerController:(UIImagePickerController *)picker
didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    self.lastChosenMediaType = info[UIImagePickerControllerMediaType];
    if ([self.lastChosenMediaType isEqual:(NSString *)kUTTypeImage]) {
        UIImage *chosenImage = info[UIImagePickerControllerEditedImage];
        UIImage* smallImage = [self shrinkImage:chosenImage
                                         toSize:self.imageButton.bounds.size];
        
        [self.imageButton setImage:smallImage forState:UIControlStateNormal];
        
        //Upload Image
        NSData* imageData = UIImageJPEGRepresentation(smallImage,1.0);
        NSString* fileName = [NSString stringWithFormat:@"%@-%@.jpg",[self.dc getSessionName],[[self.dc getLocalRider] name]];
        [[self.dc getLocalRider] setImage:fileName];
        [self.dc updateLocalRider];
        
        FIRStorageReference* imageRef = [self.storageRef child:fileName];
        [imageRef putData:imageData metadata:nil completion:^(FIRStorageMetadata *metadata, NSError *error){
            if (error != nil){
                NSLog(@"Error");
            }
        }];
        
    } else if ([self.lastChosenMediaType isEqual:(NSString *)kUTTypeMovie]) {
        
    }
    self.mImageSet = YES;
    
    [picker dismissViewControllerAnimated:YES completion:NULL];
}

- (UIImage *)shrinkImage:(UIImage *)original toSize:(CGSize)size
{
    UIGraphicsBeginImageContextWithOptions(size, YES, 0);
    
    CGFloat originalAspect = original.size.width / original.size.height;
    CGFloat targetAspect = size.width / size.height;
    CGRect targetRect;
    
    if (originalAspect > targetAspect) {
        // original is wider than target
        targetRect.size.width = size.width;
        targetRect.size.height = size.height * targetAspect / originalAspect;
        targetRect.origin.x = 0;
        targetRect.origin.y = (size.height - targetRect.size.height) * 0.5;
    } else if (originalAspect < targetAspect) {
        // original is narrower than target
        targetRect.size.width = size.width * originalAspect / targetAspect;
        targetRect.size.height = size.height;
        targetRect.origin.x = (size.width - targetRect.size.width) * 0.5;
        targetRect.origin.y = 0;
    } else {
        // original and target have same aspect ratio
        targetRect = CGRectMake(0, 0, size.width, size.height);
    }
    
    [original drawInRect:targetRect];
    UIImage *final = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return final;
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [picker dismissViewControllerAnimated:YES completion:NULL];
}
- (IBAction)imageButtonTouch:(id)sender {
    //Show alert for taking a picture or choosing from library
    if (!self.mDriverMode){
        UIAlertController* alertController = [UIAlertController alertControllerWithTitle:@"Upload Image" message:nil preferredStyle:UIAlertControllerStyleActionSheet];
        
        BOOL haveCamera = YES;
        if (![UIImagePickerController isSourceTypeAvailable:
              UIImagePickerControllerSourceTypeCamera])
        {
            haveCamera = NO;
        }
        
        UIAlertAction* takePhotoAction = [UIAlertAction actionWithTitle:@"Take Photo" style:UIAlertActionStyleDefault handler:^(UIAlertAction* action){
            [self pickMediaFromSource:UIImagePickerControllerSourceTypeCamera];
        }];
        
        UIAlertAction* pickPhotoAction = [UIAlertAction actionWithTitle:@"Choose Photo" style:UIAlertActionStyleDefault handler:^(UIAlertAction* action){
            [self pickMediaFromSource:UIImagePickerControllerSourceTypePhotoLibrary];
        }];
        
        UIAlertAction *cancelAction = [UIAlertAction
                                       actionWithTitle:@"Cancel"
                                       style:UIAlertActionStyleCancel
                                       handler:^(UIAlertAction *action) {}];
        
        [alertController addAction:cancelAction];
        if (haveCamera){
            [alertController addAction:takePhotoAction];
        }
        [alertController addAction:pickPhotoAction];
        [self presentViewController:alertController animated:YES completion:nil];
    }
    
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
