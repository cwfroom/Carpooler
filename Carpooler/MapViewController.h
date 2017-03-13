//
//  MapViewController.h
//  Carpooler
//
//  Created by Loli on 12/5/16.
//  Copyright © 2016 Wenfei Cao. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
@import GoogleMaps;

@interface MapViewController : UIViewController <CLLocationManagerDelegate, GMSMapViewDelegate>
-(void) setDriver : (BOOL) driverMode;

@end
