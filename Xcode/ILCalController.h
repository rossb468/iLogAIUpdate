//
//  ILCalController.h
//  iLog Demo Program
//
//  Created by Ross Bower on 3/23/10.
//  Copyright 2010 Ross Bower. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "ILCalendar.h"
#import "ILPeriod.h"
#import <CalendarStore/CalendarStore.h>


@interface ILCalController : NSObject {
	ILCalendar *dataModel;
	ILPeriod *currentPeriod;
	NSMutableArray *periodArray;
}

//Represent IVARs
@property (retain) ILCalendar *dataModel;
@property (retain) ILPeriod *currentPeriod;
@property (retain) NSMutableArray *periodArray;

//Represent dataModel IVARs
@property (retain) NSString *calID;
@property (retain) NSDate *startDate;
@property NSInteger periodLength;

@property (readonly) NSString *calName;
@property (readonly) NSNumber *hoursWorked;

-(NSNumber *)timeWorkedForPeriodWithDate:(NSDate *)date;
-(id)initWithName:(NSString *)name;
-(id)initWithCalID:(NSString *)_calID;
-(NSMutableArray *)getPeriodListForDate:(NSDate *)date;

-(void)writeCalendarPreferences;
-(void)loadCalendarPreferences;
-(void)dataModelChanged;
-(void)setCurrentPeriodForDate:(NSDate *)date;
-(void)updatePeriodArray;

@end
