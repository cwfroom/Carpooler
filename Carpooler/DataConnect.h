//
//  DataConnect.h
//  Carpooler
//
//  Created by Loli on 12/5/16.
//  Copyright © 2016 Wenfei Cao. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Rider.h"
static NSString* const kSessionNameKey = @"sessionName";
static NSString* const kCoordXKey = @"coordX";
static NSString* const kCoordYKey = @"coordY";
static NSString* const kImageKey = @"image";
static NSString* const kMemoKey = @"memo";

@interface DataConnect : NSObject
+ (instancetype) sharedModel;
- (int) createNewSession : (NSString*) sessionName;
- (void) joinSession : (int) sessionID sessionName: (NSString*) sessionName;
- (Rider*) getLocalRider;
- (void) createLocalRider;
- (void) updateLocalRider;
- (void) updateRemoteRider: (Rider*) rider;
- (NSArray*) getRemoteRiders;
- (int) getSessionID;
- (NSString*) getSessionName;

@end
