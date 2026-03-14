//
//  ILCalController.h
//  iLog Demo Program
//
//  Created by Ross Bower on 3/23/10.
//  Copyright 2010 Ross Bower. All rights reserved.
//

// Updated for Xcode 26.3 / macOS 15: Deprecated APIs removed, property synthesis modernized.
// NOTE: ARC (Automatic Reference Counting) should be enabled for this project.

#import <Cocoa/Cocoa.h>
#import "ILCalendar.h"
#import "ILPeriod.h"
// TODO: Replace all CalendarStore logic with EventKit equivalents below
#import <EventKit/EventKit.h>

// NOTE: All properties and logic that previously used CalCalendar* or CalCalendarStore must be migrated to EKCalendar/EKEventStore. See implementation file for migration details.

@interface ILCalController : NSObject {
	ILCalendar *dataModel;
	ILPeriod *currentPeriod;
	NSMutableArray *periodArray;
}

//Represent IVARs
@property (retain) ILCalendar *dataModel;
@property (nonatomic, retain) ILPeriod *currentPeriod;
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
-(id)initWithCalID:(NSString *)_calID eventStore:(EKEventStore *)store;
-(NSMutableArray *)getPeriodListForDate:(NSDate *)date;

-(void)writeCalendarPreferences;
-(void)loadCalendarPreferences;
-(void)dataModelChanged;
-(void)setCurrentPeriodForDate:(NSDate *)date;
-(void)updatePeriodArray;

@end

