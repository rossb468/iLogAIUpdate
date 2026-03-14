//
//  ILPeriod.m
//  iLog Demo Program
//
//  Created by Ross Bower on 3/23/10.
//  Copyright 2010 Ross Bower. All rights reserved.
//
// Updated for Xcode 26.3 / macOS 15: EventKit migration complete. ARC is enabled. Period logic is EventKit compatible.
//

#import "ILPeriod.h"

@implementation ILPeriod

@synthesize startDate = periodStartDate;
@synthesize endDate = periodEndDate;

-(id)init {
	return [self initWithCalendar:nil];
}

// Returns a formatted string representing the period's date range.
// Format defaults to "MMMM dd". Optionally includes the periodID.
-(NSString *)description {
	return [self descriptionWithFormat:@"MMMM dd" printID:FALSE];
}

-(id)copyWithZone:(NSZone *)zone {
	return self;
}

// Returns a formatted string for the period's date range using the specified dateFormat.
// If printID is TRUE, includes the periodID in the output string.
-(NSString *)descriptionWithFormat:(NSString *)dateFormat printID:(BOOL)printID {
	NSDateFormatter *outputFormatter = [[NSDateFormatter alloc] init];
	[outputFormatter setDateFormat:dateFormat];
	NSString *startDateString = [outputFormatter stringFromDate:[self startDate]];
	NSString *endDateString = [outputFormatter stringFromDate:[self endDate]];
	if(printID)
		return [NSString stringWithFormat:@"Period %ld: %@ - %@",(long)[self periodID],startDateString,endDateString];
	else
		return [NSString stringWithFormat:@"%@ - %@",startDateString,endDateString];
}

// Designated initializer with an ILCalendar instance.
// Period logic assumes calendar identifiers are EventKit compatible.
-(id)initWithCalendar:(ILCalendar *)calendar {
	if (self = [super init]) {
		calID = [calendar calID];
		calStartDate = [calendar startDate];
		periodLength = [calendar periodLength];
	}
	
	return self;
}

// Calculates the periodID based on the startDate relative to the calendar's startDate and periodLength.
// This method assumes the calendar uses EventKit identifiers and date logic.
-(NSInteger )periodID {
	NSTimeInterval intervalSinceCalStart = [[self startDate] timeIntervalSinceDate:[self calStartDate]];
	NSInteger  pid = (NSInteger )( (float)intervalSinceCalStart/(float)[self periodLength] );
	
	return (NSInteger )pid;
}

@end

