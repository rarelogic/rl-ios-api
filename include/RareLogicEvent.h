//  Created by Alejandro Isaza on 11-08-12.
//  Copyright 2011 Preterra Corp. All rights reserved.

#import <Foundation/Foundation.h>


@interface RareLogicEvent : NSObject <NSCopying, NSCoding> {
	NSMutableDictionary* _attributes;
}

- (NSDictionary*)attributes;

- (NSObject*)get:(NSString*)attrFamily andName:(NSString*)attrName;

- (void)set:(NSString*)attrFamily andName:(NSString*)attrName withStringValue:(NSString*)value;
- (void)set:(NSString*)attrFamily andName:(NSString*)attrName withNumberValue:(NSNumber*)value;
- (void)set:(NSString*)attrFamily andName:(NSString*)attrName withIntValue:(int)value;
- (void)set:(NSString*)attrFamily andName:(NSString*)attrName withDoubleValue:(double)value;

- (void)record;

- (id)proxyForJson;

@end
