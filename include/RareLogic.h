//  Created by Alejandro Isaza on 11-08-12.
//  Copyright 2011 Preterra Corp. All rights reserved.

#import <Foundation/Foundation.h>
#import "RareLogicEvent.h"

#define RARELOGIC_NETWORK_WIFI 1
#define RARELOGIC_NETWORK_WIRELESS 2
#define RARELOGIC_NETWORK_ANY RARELOGIC_NETWORK_WIFI | RARELOGIC_NETWORK_WIRELESS

@class RareLogicService;

@interface RareLogic : NSObject {
	int _queueDepth;
	int _network;
	NSString* _profile;
	NSString* _uuid;
	NSMutableArray* _queue;
	NSThread* _thread;
}

@property (nonatomic, copy) NSString* profile;
@property (nonatomic, retain) NSString* uuid;
@property (nonatomic, assign) int queueDepth;

+ (id)sharedInstance;
+ (id)sharedInstanceWithProfile:(NSString*)profile;

- (void)record:(RareLogicEvent*)event;

@end
