//
//  ILCalendar.h
//  iLog Demo Program
//
//  Created by Ross Bower on 3/23/10.
//  Copyright 2010 Ross Bower. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface ILCalendar : NSObject {
	NSString *calID;
	NSDate *calStartDate;
	NSInteger periodLength;
}

@property (retain) NSString *calID;
@property (retain) NSDate *startDate;
@property NSInteger periodLength;
@property (readonly) NSDate *calStartDate;

-(id)periodForDate:(NSDate *)date;
-(id)initWithCalID:(NSString *)_calID;
-(id)periodForID:(NSInteger )pid;

@end
