//  Created by Alejandro Isaza on 11-08-12.
//  Copyright 2011 Preterra Corp. All rights reserved.

#import "RlEvent.h"
#import "RareLogic.h"
#import "SBJson.h"

@interface RlEvent ()

- (NSString*)getAttributeName:(NSString*)attrFamily andName:(NSString*)attrName;

@end

@implementation RlEvent

- (id)init {
	self = [super init];
	if (!self)
		return nil;
	
    _attributes = [[NSMutableDictionary alloc] init];
	return self;
}

- (void)dealloc {
	[_attributes release];
	[super dealloc];
}

- (NSDictionary*)attributes {
	return _attributes;
}

- (NSObject*)get:(NSString*)attrFamily andName:(NSString*)attrName {
	return [_attributes objectForKey:[self getAttributeName:attrFamily andName:attrName]];
}

- (void)set:(NSString *)attrFamily andName:(NSString *)attrName withStringValue:(NSString *)value {
	[_attributes setObject:value forKey:[self getAttributeName:attrFamily andName:attrName]];
}

- (void)set:(NSString *)attrFamily andName:(NSString *)attrName withNumberValue:(NSNumber *)value {
	[_attributes setObject:value forKey:[self getAttributeName:attrFamily andName:attrName]];
}

- (void)set:(NSString *)attrFamily andName:(NSString *)attrName withIntValue:(int)value {
	NSNumber* number = [NSNumber numberWithInt:value];
	[self set:attrFamily andName:attrName withNumberValue:number];
}

- (void)set:(NSString *)attrFamily andName:(NSString *)attrName withDoubleValue:(double)value {
	NSNumber* number = [NSNumber numberWithDouble:value];
	[self set:attrFamily andName:attrName withNumberValue:number];
}

- (NSString*)getAttributeName:(NSString*)attrFamily andName:(NSString*)attrName {
    return [NSString stringWithFormat: @"%@.%@", attrFamily, attrName];
}

- (void)record {
    [[RareLogic sharedInstance]record: self];
}

- (id)proxyForJson {
    return _attributes;
}

#pragma mark NSCoding

- (id)initWithCoder:(NSCoder*)decoder {
	self = [super init];
	if (!self)
		return nil;
	
	_attributes = [[decoder decodeObjectForKey:@"attributes"] retain];
	return self;
}

- (void)encodeWithCoder:(NSCoder*)encoder {
	[encoder encodeObject:_attributes forKey:@"attributes"];
}

#pragma mark NSCopying

- (id)copyWithZone:(NSZone*)zone {
	RlEvent* copy = [[RlEvent allocWithZone:zone] init];
	[copy->_attributes release];
	copy->_attributes = [_attributes mutableCopyWithZone:zone];
	return copy;
}

@end
