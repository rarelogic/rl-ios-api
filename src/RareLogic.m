//  Created by Alejandro Isaza on 11-08-12.
//  Copyright 2011 Preterra Corp. All rights reserved.

#import "RareLogic.h"
#import "Reachability.h"
#import "SBJson.h"
#import <UIKit/UIKit.h>

#define FILE_NAME @"RlEvent"
#define RARELOGIC_API_HOST_NAME @"d.rare.io"
#define RARELOGIC_API_PORT 8080
#define VERSION @"1.0"


@interface RareLogic ()
- (void)load;
- (void)save;

- (void)threadStart:(id)arg;
- (void)send;

+ (NSNumber*)getTimestamp;
@end


@implementation RareLogic

@synthesize profile = _profile;
@synthesize uuid = _uuid;

static RareLogic* _instance;

- (id)init {
    if ( _instance == nil ) {
        if ( ( self = [super init] ) ) {
            _queueDepth = 10;
            _network = RARELOGIC_NETWORK_ANY;
            _uuid = [[[UIDevice currentDevice] uniqueIdentifier] retain];
            _queue = [[NSMutableArray alloc] init];
            _thread = [[NSThread alloc] initWithTarget:self selector:@selector(threadStart:) object:nil];
            
            [self load];
            [_thread start];
        }
    }

	return self;
}

- (void)dealloc {
	[_thread cancel];
	[_uuid release];
	[_profile release];
	[_queue release];
	[_thread release];
	[super dealloc];
}

+ (void)initialize {
    if (_instance == nil)
        _instance = [[self alloc] init];
}

+ (id)sharedInstance {
    return _instance;
}

+ (id)sharedInstanceWithProfile:(NSString *)profile {
    _instance.profile = profile;
    
    return _instance;
}

- (void)load {
	NSArray* paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString* path = [[paths objectAtIndex:0] stringByAppendingPathComponent:FILE_NAME];
	
	NSMutableArray* array = [[NSKeyedUnarchiver unarchiveObjectWithFile:path] retain];
	if (array != nil) {
		[_queue release];
		_queue = [array retain];
	}
}

- (void)save {
	NSArray* paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString* path = [[paths objectAtIndex:0] stringByAppendingPathComponent:FILE_NAME];
	
	@synchronized (_queue) {
		BOOL success = [NSKeyedArchiver archiveRootObject:_queue toFile:path];
		if (!success)
			NSLog(@"[RareLogic] Failed to save property sets");
	}
}

- (void)record:(RlEvent*)event {
	RlEvent* copy = [event copy];
    
	[copy set:@"rl" andName:@"mobiletime" withNumberValue: [RareLogic getTimestamp]];
	
	@synchronized (_queue) {
		[_queue addObject:copy];
		if (_queue.count > _queueDepth)
			[_queue removeObjectAtIndex:0];
	}
	[self save];
	
	[copy release];
}

- (int)queueDepth {
	return _queueDepth;
}

- (void)setQueueDepth:(int)depth {
	@synchronized (_queue) {
		_queueDepth = depth;
		while (_queue.count > _queueDepth)
			[_queue removeObjectAtIndex:0];
	}
}

- (void)threadStart:(id)arg {
	NSAutoreleasePool* pool = [[NSAutoreleasePool alloc] init];
	
	Reachability* reachability = [Reachability reachabilityWithHostName:RARELOGIC_API_HOST_NAME];
    
	while (true) {
		NetworkStatus status = [reachability currentReachabilityStatus];
		if ( ( status == NotReachable ) || 
             ( ( _network == RARELOGIC_NETWORK_WIFI ) && ( status != ReachableViaWiFi ) ) ) {
			[NSThread sleepForTimeInterval:1];
		} else {
			if ([_queue count] == 0)
				[NSThread sleepForTimeInterval:0.5];
			else
				[self send];
		}
	}
	[pool release];
}

- (void)send {
	NSAutoreleasePool* pool = [[NSAutoreleasePool alloc] init];
	NSArray* sending = nil;
    
	@synchronized (_queue) {
		if (_queue.count > 0) {
			sending = [_queue copy];
			[_queue removeAllObjects];
		} else {
			return;
        }
	}
	
	UIDevice* device = [UIDevice currentDevice];
	NSString* baseURL = [NSString stringWithFormat:@"http://%@:%d/store", 
                         RARELOGIC_API_HOST_NAME, 
                         RARELOGIC_API_PORT];
	NSString* clientInfo = [[NSString stringWithFormat:@"Mobile(%@; %@; %@)", 
                             [device model], 
                             [device systemName],
							 [device systemVersion]] 
                            stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
	NSString* path = [NSString stringWithFormat: @"%@/%@/%@/?v=%@&t=%qi&c=%@",
					  baseURL, 
                      _profile, 
                      _uuid, 
                      VERSION, 
                      [[RareLogic getTimestamp] longLongValue], 
                      clientInfo];
	NSURL* url = [NSURL URLWithString:path];
	NSString* body = [sending JSONRepresentation];
	NSMutableURLRequest* request = [NSMutableURLRequest requestWithURL:url];
    
	[request setHTTPBody:[body dataUsingEncoding:NSUTF8StringEncoding]];
	[request setHTTPMethod:@"POST"];
	
	NSHTTPURLResponse* response = nil;
	NSError* error = nil;
    
	[NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
    
	if ( [response statusCode] != 300) {
        if ( error != nil ) {
            NSLog(@"[RareLogic] Connection failed: %@", [error localizedDescription]);
        }
		
		@synchronized (_queue) {
			NSArray* new = [_queue copy];
            
			[_queue removeAllObjects];
			[_queue addObjectsFromArray: sending];
			[_queue addObjectsFromArray: new];
            
			while (_queue.count > _queueDepth)
				[_queue removeObjectAtIndex: 0];
            
			[new release];
		}
	}
	
	[sending release];
	[self save];
	[pool release];
}

+ (NSNumber*)getTimestamp {
    NSTimeInterval interval = [NSDate timeIntervalSinceReferenceDate];
    NSDate* now = [NSDate dateWithTimeIntervalSinceReferenceDate: interval];
    NSCalendar* calendar = [[NSCalendar alloc] initWithCalendarIdentifier: NSGregorianCalendar];
    NSUInteger flags =  NSYearCalendarUnit | 
                        NSMonthCalendarUnit | 
                        NSDayCalendarUnit | 
                        NSHourCalendarUnit | 
                        NSMinuteCalendarUnit | 
                        NSSecondCalendarUnit;
    NSDateComponents* components = [calendar components:flags fromDate:now];
    
    long long stamp = 0;
    
    stamp += (long long)[components year]   * 10000000000000;
    stamp += (long long)[components month]  * 100000000000;
    stamp += (long long)[components day]    * 1000000000;
    stamp += (long long)[components hour]   * 10000000;
    stamp += (long long)[components minute] * 100000;
    stamp += (long long)[components second] * 1000;
    stamp += ((long long)((double)interval * 1000)) % 1000;
    
    [calendar release];
    
    return [NSNumber numberWithLongLong: stamp];
}

@end
