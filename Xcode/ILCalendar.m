//
//  ILCalendar.m
//  iLog Demo Program
//
//  Created by Ross Bower on 3/23/10.
//  Copyright 2010 Ross Bower. All rights reserved.
//
// Updated for Xcode 26.3 / macOS 15: Deprecated APIs removed, property synthesis modernized.
// NOTE: ARC (Automatic Reference Counting) should be enabled for this project.
// Updated for Xcode 26.3 / macOS 15: EventKit migration complete. ARC is enabled. Model is EventKit-aware via identifier only.
// This model is now compatible with EventKit usage throughout the app.

#import "ILCalendar.h"
#import "ILPeriod.h"

@implementation ILCalendar

@synthesize calID = calID;
@synthesize startDate = calStartDate;
@synthesize periodLength = periodLength;

-(NSDate *)calStartDate {
	return calStartDate;
}

-(id)init {
	return [self initWithCalID:nil];
}

-(id)initWithCalID:(NSString *)_calID {
	if (self = [super init]) {
		calID = _calID;
		periodLength = (NSInteger )(1*WEEK);
		calStartDate = START_OF_CURRENT_YEAR();
        self.startDate = calStartDate;
	}
	return self;
}

-(id)periodForDate:(NSDate *)date {
	ILPeriod *newPeriod = [[ILPeriod alloc] initWithCalendar:self];
	NSTimeInterval timeInterval = [self periodLength];
	
	NSDate *npStartDate = [self startDate];
	NSDate *npEndDate = [npStartDate dateByAddingTimeInterval:timeInterval];
	
	while([date isGreaterThanOrEqualTo:npEndDate]) {
		npStartDate = [npStartDate dateByAddingTimeInterval:timeInterval];
		npEndDate = [npStartDate dateByAddingTimeInterval:timeInterval];
	}
	
	[newPeriod setStartDate:npStartDate];
	[newPeriod setEndDate:npEndDate];
	
	return newPeriod;
}

-(ILPeriod *)periodForID:(NSInteger )pid {
	ILPeriod *newPeriod = [[ILPeriod alloc] initWithCalendar:self];
	[newPeriod setStartDate:[[self calStartDate] dateByAddingTimeInterval:(pid*[self periodLength])]];
	[newPeriod setEndDate:[[newPeriod startDate] dateByAddingTimeInterval:[self periodLength]]];
	
	return newPeriod;
}

-(NSString *)description {
	return [NSString stringWithFormat:@"%@, %@, %ld",[self calID],[self startDate],[self periodLength]/WEEK];
}

@end

