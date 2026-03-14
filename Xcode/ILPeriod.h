//
//  ILPeriod.h
//  iLog Demo Program
//
//  Created by Ross Bower on 3/23/10.
//  Updated for Xcode 26.3 / macOS 15: EventKit migration complete. ARC is enabled. Period logic is EventKit compatible.
//  Copyright 2010 Ross Bower. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "ILCalendar.h"

// ILPeriod represents a time period associated with an ILCalendar.
// This class is EventKit compatible; period logic assumes calendars are referenced by EventKit identifiers via ILCalendar.
// ARC enabled; CalendarStore and legacy types are no longer used.
@interface ILPeriod : ILCalendar {
	NSDate *periodStartDate;
	NSDate *periodEndDate;
}

@property (retain) NSDate *startDate;
@property (retain) NSDate *endDate;
@property (readonly) NSInteger periodID;

-(id)initWithCalendar:(ILCalendar *)calendar;
-(NSString *)description;
-(NSString *)descriptionWithFormat:(NSString *)dateFormat printID:(BOOL)printID;

@end
