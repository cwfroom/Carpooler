//
//  DetailViewController.h
//  Carpooler
//
//  Created by Loli on 12/9/16.
//  Copyright © 2016 Wenfei Cao. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DataConnect.h"
@interface DetailViewController : UIViewController <UITextViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate>
-(void) setDriverMode : (BOOL) driverMode;
-(void) setRider : (Rider*) rider;

@end
