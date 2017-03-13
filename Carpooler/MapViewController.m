//
//  MapViewController.m
//  Carpooler
//
//  Created by Loli on 12/5/16.
//  Copyright © 2016 Wenfei Cao. All rights reserved.
//

#import "MapViewController.h"
#import "DataConnect.h"
#import "DetailViewController.h"
@import Firebase;


@interface MapViewController () <CLLocationManagerDelegate, GMSMapViewDelegate>
@property BOOL mDriverMode;
@property BOOL mLocalMarkSet;
@property (strong, nonatomic) DataConnect* dc;
@property (strong, nonatomic) FIRDatabaseReference *dbRef;
@property (nonatomic,retain) CLLocationManager *locationManager;
@property (strong, nonatomic) GMSMapView* mapView;
@property (strong, nonatomic) GMSMarker* myMarker;
@property (strong, nonatomic) NSMutableArray* remoteMarkers;
@property (strong ,nonatomic) Rider* selectedRider;

@property (weak, nonatomic) IBOutlet UIBarButtonItem *homeLeftButton;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *rightButton;

@end

@implementation MapViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.dc = [DataConnect sharedModel];
    
    
    //Enable locating
    self.locationManager = [[CLLocationManager alloc]init];
    self.locationManager.delegate = self;
    [self.locationManager requestWhenInUseAuthorization];
    
    
    //Initialize map with locating enabled
    GMSCameraPosition *camera = [GMSCameraPosition cameraWithLatitude:0
                                                            longitude:0
                                                                 zoom:1];
    self.mapView = [GMSMapView mapWithFrame:CGRectZero camera:camera];
    
    self.mapView.settings.compassButton = YES;
    self.mapView.myLocationEnabled = YES;

    self.view = self.mapView;
    self.mapView.delegate = self;
    
    
    
}

- (void) viewDidAppear:(BOOL)animated{
    self.navigationItem.title = [self.dc getSessionName];
    
    if (self.mDriverMode){
        [self.rightButton setTitle:@"Riders"];
    }else{
        [self.rightButton setTitle:@"Details"];
    }
    
    if (self.mDriverMode){
        self.remoteMarkers = [[NSMutableArray alloc]init];
    }else{
        self.mLocalMarkSet = NO;
        self.myMarker = [[GMSMarker alloc]init];
        self.myMarker.title = @"Me";
        self.myMarker.map = nil;
    }
    
    //Listen database changes
    if (self.mDriverMode){
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
                }
            }
            [self updateRemoteMarkers];
            
        }];
        
    }

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) setDriver:(BOOL)driverMode{
    self.mDriverMode = driverMode;
}

- (void) locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status{
    if (status == kCLAuthorizationStatusAuthorizedWhenInUse){
        [self.locationManager startUpdatingLocation];
        self.mapView.myLocationEnabled = YES;
        self.mapView.settings.myLocationButton = true;
    }
}

- (void) locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray<CLLocation *> *)locations{
    self.mapView.camera = [GMSCameraPosition cameraWithTarget:[[locations firstObject] coordinate] zoom:15 bearing:0 viewingAngle:0];
    [self.locationManager stopUpdatingLocation];
    
}
- (IBAction)homeButtonTouch:(id)sender {
    [self performSegueWithIdentifier:@"backHomeSegue" sender:self];
    
}

-(void) mapView:(GMSMapView *)mapView didTapAtCoordinate:(CLLocationCoordinate2D)coordinate{
    if (!self.mDriverMode){
        if (!self.mLocalMarkSet){
            //New marker
            [self updateMyMarker:coordinate];
            self.mLocalMarkSet = YES;
        }else{
            UIAlertController* alertCotroller = [UIAlertController alertControllerWithTitle:@"Move marker" message:@"Do you want to update your location?" preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction* okAction = [UIAlertAction actionWithTitle:@"Yes" style:UIAlertActionStyleDefault handler:^(UIAlertAction* action){
                [self updateMyMarker:coordinate];
            }];
            
            UIAlertAction* noAction = [UIAlertAction actionWithTitle:@"No" style:UIAlertActionStyleDefault handler:^(UIAlertAction* action){
                
            }];
            
            [alertCotroller addAction:okAction];
            [alertCotroller addAction:noAction];
            [self presentViewController:alertCotroller animated:YES completion:nil];
            
        }
        
    }
}

-(void) mapView:(GMSMapView *)mapView didLongPressInfoWindowOfMarker:(nonnull GMSMarker *)marker{
    if (self.mDriverMode){
        for (Rider* rider in [self.dc getRemoteRiders]){
            if ([rider.name isEqualToString:marker.title]){
                self.selectedRider = rider;
                [self performSegueWithIdentifier:@"mapToDetailSegue" sender:self];
                break;
            }
        }
    }
    
}

-(void) updateMyMarker: (CLLocationCoordinate2D)coordinate{
    [self.myMarker setPosition:coordinate];
    [[self.dc getLocalRider]setX:[NSNumber numberWithDouble:coordinate.latitude]];
    [[self.dc getLocalRider]setY:[NSNumber numberWithDouble:coordinate.longitude]];
    [self.dc updateLocalRider];
    self.myMarker.map = self.mapView;
    
}

-(void) updateRemoteMarkers{
    for (Rider* rider in [self.dc getRemoteRiders]){
        for (GMSMarker* marker in self.remoteMarkers){
            //If marker exists update
            if ([rider.name isEqualToString:marker.title]){
                CLLocationCoordinate2D coord;
                coord.latitude = [rider.x doubleValue];
                coord.longitude = [rider.y doubleValue];
                [marker setPosition:coord];
            }
        }
        //Marker not found, make a new one
        CLLocationCoordinate2D coord;
        coord.latitude = [rider.x doubleValue];
        coord.longitude = [rider.y doubleValue];
        GMSMarker* marker = [GMSMarker markerWithPosition:coord];
        marker.title = rider.name;
        marker.map = self.mapView;
        [self.remoteMarkers addObject:marker];
    }
    
}

- (IBAction)rightButtonTouch:(id)sender {
    if (self.mDriverMode){
        [self performSegueWithIdentifier:@"riderTableSegue" sender:self];
    }else{
        [self performSegueWithIdentifier:@"riderEditSegue" sender:self];
    }
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"riderEditSegue"]){
        DetailViewController* vc =  [segue destinationViewController];
        [vc setDriverMode:NO];
        [vc setRider:[self.dc getLocalRider]];
    }
    if ([segue.identifier isEqualToString:@"mapToDetailSegue"]){
        DetailViewController* vc =  [segue destinationViewController];
        [vc setDriverMode:YES];
        [vc setRider:self.selectedRider];
    }
    
}


@end
