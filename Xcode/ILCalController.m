//
//  ILCalController.m
//  iLog Demo Program
//
//  Created by Ross Bower on 3/23/10.
//  Copyright 2010 Ross Bower. All rights reserved.
//

// Updated for Xcode 26.3 / macOS 15: CalendarStore APIs removed, migrated to EventKit.
// NOTE: ARC (Automatic Reference Counting) is enabled for this project.

#import "ILCalController.h"
#import <EventKit/EventKit.h>

@implementation ILCalController {
    EKEventStore *_eventStore;
}

@synthesize dataModel = dataModel;
@synthesize currentPeriod = currentPeriod;
@synthesize periodArray = periodArray;

#pragma mark - Authorization

// Ensures the app has authorization to access calendar events. Calls completion on main queue.
- (void)ensureEventAccessWithCompletion:(void (^)(BOOL granted))completion {
    EKAuthorizationStatus status = [EKEventStore authorizationStatusForEntityType:EKEntityTypeEvent];
    BOOL isAuthorized = NO;
    if (@available(macOS 14.0, *)) {
        isAuthorized = (status == EKAuthorizationStatusFullAccess);
    } else {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
        isAuthorized = (status == EKAuthorizationStatusAuthorized);
#pragma clang diagnostic pop
    }
    if (isAuthorized) {
        if (completion) { dispatch_async(dispatch_get_main_queue(), ^{ completion(YES); }); }
        return;
    }
    if (status == EKAuthorizationStatusNotDetermined) {
        // Request access. EventKit calls back on an arbitrary queue; hop to main for UI updates.
        if (@available(macOS 14.0, *)) {
            [_eventStore requestFullAccessToEventsWithCompletion:^(BOOL granted, NSError * _Nullable error) {
                (void)error;
                if (completion) { dispatch_async(dispatch_get_main_queue(), ^{ completion(granted); }); }
            }];
        } else {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
            [_eventStore requestAccessToEntityType:EKEntityTypeEvent completion:^(BOOL granted, NSError * _Nullable error) {
                (void)error;
                if (completion) { dispatch_async(dispatch_get_main_queue(), ^{ completion(granted); }); }
            }];
#pragma clang diagnostic pop
        }
        return;
    }
    // Denied or restricted
    if (completion) { dispatch_async(dispatch_get_main_queue(), ^{ completion(NO); }); }
}

#pragma mark - Properties

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
    EKCalendar *calendar = [_eventStore calendarWithIdentifier:[self calID]];
    return calendar.title ?: @"(No Calendar)";
}

-(void)setCurrentPeriod:(ILPeriod *)_currentPeriod {
	currentPeriod = _currentPeriod;
	[self updatePeriodArray];
	[self dataModelChanged];
}

#pragma mark - Init Methods

-(void)dealloc {
	[[NSNotificationCenter defaultCenter] removeObserver:self];
}

-(id)init {
	return [self initWithCalID:nil];
}

-(id)initWithName:(NSString *)name {
	// Fetch calendar by name using EKEventStore
	if (!_eventStore) {
		_eventStore = [[EKEventStore alloc] init];
	}
	
	NSArray<EKCalendar *> *calendars = [_eventStore calendarsForEntityType:EKEntityTypeEvent];
	for (EKCalendar *aCalendar in calendars) {
		if ([aCalendar.title isEqualToString:name]) {
			return [self initWithCalID:aCalendar.calendarIdentifier eventStore:_eventStore];
		}
	}
	return [self init];
}

-(id)initWithCalID:(NSString *)_calID {
	return [self initWithCalID:_calID eventStore:nil];
}

-(id)initWithCalID:(NSString *)_calID eventStore:(EKEventStore *)store {
	if (self = [super init]) {
		_eventStore = store ?: [[EKEventStore alloc] init];
		dataModel = [[ILCalendar alloc] initWithCalID:_calID];
		
		[self loadCalendarPreferences];
		
		currentPeriod = [[self dataModel] periodForDate:[NSDate date]];
		[self updatePeriodArray];
		
		// Observe EKEventStoreChangedNotification for calendar changes
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(eventStoreChanged:) name:EKEventStoreChangedNotification object:_eventStore];
	}
	return self;
}

#pragma mark - Business Logic

-(NSNumber *)hoursWorked {
	NSInteger _timeWorked = [[self timeWorkedForPeriodWithDate:[[self currentPeriod] startDate]] integerValue] / HOUR;
	return (NSNumber *)[NSNumber numberWithInteger:_timeWorked];
}

-(void)eventStoreChanged:(NSNotification *)notification {
	// Respond to EventKit store changes by updating data model
	[self dataModelChanged];
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
    if (!thePeriod || ![thePeriod startDate] || ![thePeriod endDate]) {
        return @(0.0);
    }
	
	EKCalendar *representedCalendar = [_eventStore calendarWithIdentifier:[self calID]];
	if (!representedCalendar) {
		return @(0.0);
	}

    EKAuthorizationStatus status = [EKEventStore authorizationStatusForEntityType:EKEntityTypeEvent];
    if (status == EKAuthorizationStatusNotDetermined) {
        [self ensureEventAccessWithCompletion:^(BOOL granted) {
            [[NSNotificationCenter defaultCenter] postNotificationName:(granted ? @"CalendarAccessGrantedNotification" : @"CalendarAccessDeniedNotification") object:self];
        }];
        return @(0.0);
    }
    BOOL isAuthorized = NO;
    if (@available(macOS 14.0, *)) {
        isAuthorized = (status == EKAuthorizationStatusFullAccess);
    } else {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
        isAuthorized = (status == EKAuthorizationStatusAuthorized);
#pragma clang diagnostic pop
    }
    if (!isAuthorized) {
        return @(0.0);
    }

	NSPredicate *predicate = [_eventStore predicateForEventsWithStartDate:[thePeriod startDate] endDate:[thePeriod endDate] calendars:@[representedCalendar]];
	
	NSArray<EKEvent *> *eventList = [_eventStore eventsMatchingPredicate:predicate];
	
	NSTimeInterval timeWorked = 0.0;
	for (EKEvent *theEvent in eventList) {
		timeWorked += [theEvent.endDate timeIntervalSinceDate:theEvent.startDate];
	}
	
	return @(timeWorked);
}

-(void)setCurrentPeriodForDate:(NSDate *)date {
	currentPeriod = [[self dataModel] periodForDate:date];
}

-(void)updatePeriodArray {
    ILPeriod *cp = [self currentPeriod];
    if (cp) {
        periodArray = [self getPeriodListForDate:[cp startDate]];
    } else {
        periodArray = [NSMutableArray array];
    }
}

-(NSMutableArray *)getPeriodListForDate:(NSDate *)date {
    if (!date) {
        return [NSMutableArray array];
    }
    ILPeriod *_currentPeriod = [[self dataModel] periodForDate:date];
    if (!_currentPeriod) {
        return [NSMutableArray array];
    }
    NSInteger startID = [_currentPeriod periodID] - 8;
    NSInteger endID = [_currentPeriod periodID] + 8;

    if (startID < 0) {
        startID = 0;
    }
    if (endID < startID) {
        endID = startID;
    }

    NSMutableArray *_periodArray = [[NSMutableArray alloc] initWithCapacity:(endID - startID)];

    for (NSInteger i = startID; i < endID; i++) {
        ILPeriod *p = [[self dataModel] periodForID:i];
        if (p) {
            [_periodArray addObject:p];
        } else {
            // Skip nil periods to avoid exceptions
            continue;
        }
    }

    return _periodArray;
}

-(void)writeCalendarPreferences {
    NSString *prefsKey = [self calID];
    if (!prefsKey) {
        // If we don't have a calendar identifier yet, skip writing preferences.
        return;
    }
    NSArray *keys = [NSArray arrayWithObjects:@"calID", @"calStartDate", @"periodLength", nil];
    NSArray *objects = [NSArray arrayWithObjects:[self calID], [self startDate], [NSNumber numberWithInteger:[self periodLength]], nil];
    NSDictionary *prefsDict = [NSDictionary dictionaryWithObjects:objects forKeys:keys];

    [[NSUserDefaults standardUserDefaults] setObject:prefsDict forKey:prefsKey];
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

