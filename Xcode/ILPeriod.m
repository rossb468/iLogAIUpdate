//
//  ILPeriod.m
//  iLog Demo Program
//
//  Created by Ross Bower on 3/23/10.
//  Copyright 2010 Ross Bower. All rights reserved.
//

#import "ILPeriod.h"

@implementation ILPeriod

@synthesize startDate = periodStartDate;
@synthesize endDate = periodEndDate;

-(id)init {
	return [self initWithCalendar:nil];
}

-(NSString *)description {
	return [self descriptionWithFormat:@"MMMM dd" printID:FALSE];
}

-(id)copyWithZone:(NSZone *)zone {
	return [self retain];
}

-(NSString *)descriptionWithFormat:(NSString *)dateFormat printID:(BOOL)printID {
	NSDateFormatter *outputFormatter = [[NSDateFormatter alloc] init];
	[outputFormatter setDateFormat:dateFormat];
	NSString *startDateString = [outputFormatter stringFromDate:[self startDate]];
	NSString *endDateString = [outputFormatter stringFromDate:[self endDate]];
	if(printID)
		return [NSString stringWithFormat:@"Period %ld: %@ - %@",[self periodID],startDateString,endDateString];
	else
		return [NSString stringWithFormat:@"%@ - %@",startDateString,endDateString];
}

-(id)initWithCalendar:(ILCalendar *)calendar {
	if (self = [super init]) {
		calID = [calendar calID];
		calStartDate = [calendar startDate];
		periodLength = [calendar periodLength];
	}
	
	return self;
}

-(NSInteger )periodID {
	NSTimeInterval intervalSinceCalStart = [[self startDate] timeIntervalSinceDate:[self calStartDate]];
	NSInteger  pid = (NSInteger )( (float)intervalSinceCalStart/(float)[self periodLength] );
	
	return (NSInteger )pid;
}

@end
