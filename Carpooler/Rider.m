//
//  Rider.m
//  Carpooler
//
//  Created by Loli on 12/8/16.
//  Copyright © 2016 Wenfei Cao. All rights reserved.
//

#import "Rider.h"
@interface Rider()
@end

@implementation Rider
- (instancetype)init{
    self = [super init];
    if (self){
        self.name = @"";
        self.image = @"";
        self.memo = @"";
        self.x = [NSNumber numberWithDouble:0];
        self.y = [NSNumber numberWithDouble:0];
    }
    return self;
}

- (BOOL) isEqual:(Rider *)other{
    if ([self.name isEqual:other.name] &&
        [self.image isEqual:other.image] &&
        [self.memo isEqual:other.memo]&&
        self.x == other.x &&
        self.y == other.y){
        return YES;
    }else{
        return NO;
    }
}
-(void) assign:(Rider *)other{
    self.name = other.name;
    self.image = other.image;
    self.memo = other.memo;
    self.x = other.x;
    self.y = other.y;
}

@end
