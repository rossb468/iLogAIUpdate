//
//  ILCalController.m
//  iLog Demo Program
//
//  Created by Ross Bower on 3/23/10.
//  Copyright 2010 Ross Bower. All rights reserved.
//

#import "ILCalController.h"


@implementation ILCalController

@synthesize dataModel;
@synthesize currentPeriod;
@synthesize periodArray;

//---Map to dataModel---
-(NSString *)calID {
	return [[self dataModel] calID];
}

-(NSDate *)startDate {
	return [[self dataModel] startDate];
}

-(NSInteger )periodLength {
	return [[self dataModel] periodLength];
}
//---End Map to dataModel---

-(NSString *)calName {
	return [[[CalCalendarStore defaultCalendarStore] calendarWithUID:[self calID]] title];
}

-(void)setCurrentPeriod:(ILPeriod *)_currentPeriod {
	currentPeriod = _currentPeriod;
	[self updatePeriodArray];
	[self dataModelChanged];
}

//---Init Methods---
-(id)init {
	return [self initWithCalID:nil];
}

-(id)initWithName:(NSString *)name {
	for(CalCalendar *aCalendar in [[CalCalendarStore defaultCalendarStore] calendars])
		if([[aCalendar title] isEqual:name])
			return [self initWithCalID:[aCalendar uid]];
	
	return [self init];
}

-(id)initWithCalID:(NSString *)_calID {
	if (self = [super init]) {
		dataModel = [[ILCalendar alloc] initWithCalID:_calID];
		
		[self loadCalendarPreferences];
		
		currentPeriod = [[self dataModel] periodForDate:[NSDate date]];
		[self updatePeriodArray];
		
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(calendarStoreChanged:) name:CalCalendarsChangedExternallyNotification object:[CalCalendarStore defaultCalendarStore]];
	}
	return self;
}
//---End Init Methods---

-(NSNumber *)hoursWorked {
	NSInteger _timeWorked = [[self timeWorkedForPeriodWithDate:[[self currentPeriod] startDate]] integerValue] / HOUR;
	return (NSNumber *)[NSNumber numberWithInteger:_timeWorked];
}

-(void)calendarStoreChanged:(NSNotification *)notification {
	NSArray *updatedRecords = [[notification userInfo] valueForKey:CalUpdatedRecordsKey];
	if (updatedRecords != nil) {
		[self dataModelChanged];
	}
}

-(void)dataModelChanged {
	[self writeCalendarPreferences];
	[[NSNotificationCenter defaultCenter] postNotificationName:@"CalendarUpdatedNotification" object:self];
}

-(void)setCalID:(NSString *)_calID {
	[[self dataModel] setCalID:_calID];
	[self dataModelChanged];
}

-(void)setStartDate:(NSDate *)_startDate {
	[[self dataModel] setStartDate:_startDate];
	[self dataModelChanged];
}

-(void)setPeriodLength:(NSInteger )_periodLength {
	[[self dataModel] setPeriodLength:_periodLength];
	[self setCurrentPeriodForDate:[NSDate date]]; 
	[self dataModelChanged];
}

-(NSNumber *)timeWorkedForPeriodWithDate:(NSDate *)date {
	ILPeriod *thePeriod = [[self dataModel] periodForDate:date];
	
	CalCalendar *representedCalendar = [[CalCalendarStore defaultCalendarStore] calendarWithUID:[self calID]];
	
	NSPredicate *predicate = [CalCalendarStore eventPredicateWithStartDate:[thePeriod startDate] endDate:[thePeriod endDate] calendars:[NSArray arrayWithObject:representedCalendar]];
	NSMutableArray *eventList = [NSMutableArray arrayWithArray:[[CalCalendarStore defaultCalendarStore] eventsWithPredicate:predicate]];
	
	double timeWorked = 0.0;
	for(CalEvent *theEvent in eventList) {
		timeWorked += [[theEvent endDate] timeIntervalSinceDate:[theEvent startDate]];
	}
	
	return (NSNumber *)[NSNumber numberWithDouble:timeWorked];
}

-(void)setCurrentPeriodForDate:(NSDate *)date {
	currentPeriod = [[self dataModel] periodForDate:date];
}

-(void)updatePeriodArray {
	periodArray = [self getPeriodListForDate:[[self currentPeriod] startDate]];
}

-(NSMutableArray *)getPeriodListForDate:(NSDate *)date {
	ILPeriod *_currentPeriod = [[self dataModel] periodForDate:date];
	NSInteger  startID = [_currentPeriod periodID]-8;
	NSInteger  endID = [_currentPeriod periodID]+8;
	
	if(startID < 0)
		startID = 0;
	
	NSMutableArray *_periodArray = [[NSMutableArray alloc] initWithCapacity:endID];
	
	for(int i=startID;i<endID;i++)
		[_periodArray addObject:[[self dataModel] periodForID:i]];
	
	return _periodArray;
}

-(void)writeCalendarPreferences {
	NSArray *keys = [NSArray arrayWithObjects:@"calID", @"calStartDate", @"periodLength", nil];
	NSArray *objects = [NSArray arrayWithObjects:[self calID], [self startDate], [NSNumber numberWithInteger:[self periodLength]], nil];
	NSDictionary *prefsDict = [NSDictionary dictionaryWithObjects:objects forKeys:keys];
	
	[[NSUserDefaults standardUserDefaults] setObject:prefsDict forKey:[self calID]];
}

-(void)loadCalendarPreferences {
	NSDictionary *prefsDict = [[NSUserDefaults standardUserDefaults] objectForKey:[self calID]];
	
	if (prefsDict) {
		[[self dataModel] setCalID:[prefsDict objectForKey:@"calID"]];
		[[self dataModel] setStartDate:[prefsDict objectForKey:@"calStartDate"]];
		[[self dataModel] setPeriodLength:[[prefsDict objectForKey:@"periodLength"] integerValue]];
	}
}

-(NSString *)description {
	return [NSString stringWithFormat:@"%@",[self dataModel]];
}

@end
