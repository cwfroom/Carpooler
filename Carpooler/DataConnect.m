//
//  DataConnect.m
//  Carpooler
//
//  Created by Loli on 12/5/16.
//  Copyright © 2016 Wenfei Cao. All rights reserved.
//

#import "DataConnect.h"
@import Firebase;

@interface DataConnect()
@property (strong, nonatomic) FIRDatabaseReference *dbRef;

@property int currentSessionID;
@property (strong,nonatomic) NSString* currentSessionName;
@property (strong,nonatomic) Rider* localRider;
@property (strong,nonatomic) NSMutableArray* remoteRiders;
@end

@implementation DataConnect
+ (instancetype) sharedModel{
    static DataConnect* _sharedModel = nil;
    if (_sharedModel == nil){
        _sharedModel = [[self alloc]init];
    }
    return _sharedModel;
    
}


- (instancetype) init{
    self = [super init];
    if (self){
       self.dbRef = [[FIRDatabase database] reference];
    
        self.localRider = [[Rider alloc]init];
        self.remoteRiders = [[NSMutableArray alloc]init];
    }
    return self;
    
}

- (int) createNewSession:(NSString *)sessionName{
    self.currentSessionName = sessionName;
    self.currentSessionID = arc4random() % 9000 + 1000;

    [[self.dbRef child:[NSString stringWithFormat:@"%d",self.currentSessionID]] setValue:@{kSessionNameKey:self.currentSessionName}];
    
    return self.currentSessionID;
}

-(int) getSessionID{
    return self.currentSessionID;
}

- (NSString*) getSessionName{
    return self.currentSessionName;
}

- (void) joinSession:(int)sessionID sessionName:(NSString *)sessionName{
    self.currentSessionID = sessionID;
    self.currentSessionName = sessionName;
}

- (Rider*) getLocalRider{
    return self.localRider;
}

-(void) createLocalRider{
    [[[self.dbRef child:[NSString stringWithFormat:@"%d",self.currentSessionID]]child:self.localRider.name] setValue:@{kCoordXKey: self.localRider.x,
                                                                                                                       kCoordYKey: self.localRider.y,
                                                                                                                       kImageKey: self.localRider.image,
                                                                                                                       kMemoKey: self.localRider.memo}];

}

- (void) updateLocalRider{
    [[[self.dbRef child:[NSString stringWithFormat:@"%d",self.currentSessionID]]child:self.localRider.name] updateChildValues:@{kCoordXKey: self.localRider.x,
                                                                                                                       kCoordYKey: self.localRider.y,
                                                                                                                       kImageKey: self.localRider.image,
                                                                                                                       kMemoKey: self.localRider.memo}];
  }

-(NSArray*) getRemoteRiders{
    return self.remoteRiders;
}

-(void)updateRemoteRider :(Rider*) rider{
    //Try to find and update rider
    BOOL found = NO;
    for (int i = 0;i<self.remoteRiders.count;i++){
        Rider* iter = self.remoteRiders[i];
        if ([iter.name isEqualToString:rider.name]){
            found = YES;
            if (![iter isEqual:rider]){
                [self.remoteRiders replaceObjectAtIndex:i withObject:rider];
            }
        }
    }
    //If not found add to array
    if (!found){
        [self.remoteRiders addObject:rider];
    }
    
}


@end
