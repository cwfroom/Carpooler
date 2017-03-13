//
//  Rider.h
//  Carpooler
//
//  Created by Loli on 12/8/16.
//  Copyright © 2016 Wenfei Cao. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Rider : NSObject
@property (strong, nonatomic) NSString* name;
@property (strong, nonatomic) NSString* image;
@property (strong, nonatomic) NSString* memo;
@property (strong, nonatomic) NSNumber* x;
@property (strong, nonatomic) NSNumber* y;
- (BOOL) isEqual:(Rider*) other;
- (void) assign:(Rider*) other;

@end
