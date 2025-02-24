//
//  ILPeriod.h
//  iLog Demo Program
//
//  Created by Ross Bower on 3/23/10.
//  Copyright 2010 Ross Bower. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "ILCalendar.h"

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
