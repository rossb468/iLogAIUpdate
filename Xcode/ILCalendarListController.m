//
//  ILCalendarList.m
//  iLog
//
//  Created by Ross Bower on 3/25/10.
//  Copyright 2010 Ross Bower. All rights reserved.
//
// Updated for Xcode 26.3 / macOS 15: CalendarStore APIs removed, migration in progress to EventKit.
// NOTE: ARC (Automatic Reference Counting) should be enabled for this project.

#import "ILCalendarListController.h"
#import <EventKit/EventKit.h>

@interface ILCalendarListController ()
@property (strong, nonatomic) EKEventStore *eventStore;
@end

@implementation ILCalendarListController

@synthesize calArray = calArray;
@synthesize calendarTableView = calendarTableView;
@synthesize selectedCalendar = selectedCalendar;

-(id)init {
    if(self = [super init]) {
        calArray = [[NSMutableArray alloc] init];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(eventStoreChanged:) name:EKEventStoreChangedNotification object:nil];
        // Observe calendar access changes posted by ILCalController as a fallback
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleCalendarAccessChange:) name:@"CalendarAccessGrantedNotification" object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleCalendarAccessChange:) name:@"CalendarAccessDeniedNotification" object:nil];
        
        // Store will be injected later via loadCalendarsFromEventStore:
    }
    
    return self;
}

- (void)loadCalendarsFromEventStore:(EKEventStore *)store {
    self.eventStore = store;
    [self loadCalendarsFromEventKit];
    [calendarTableView reloadData];
}

-(void)loadCalendarsFromEventKit {
    if (!self.eventStore) { return; }

    [calArray removeAllObjects];
    
    EKAuthorizationStatus s = [EKEventStore authorizationStatusForEntityType:EKEntityTypeEvent];
    BOOL isAuthorized = NO;
    if (@available(macOS 14.0, *)) {
        isAuthorized = (s == EKAuthorizationStatusFullAccess);
    } else {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
        isAuthorized = (s == EKAuthorizationStatusAuthorized);
#pragma clang diagnostic pop
    }
    if (!isAuthorized) {
        // Not authorized; leave list empty
        return;
    }
    
    NSArray<EKCalendar *> *allCalendars = [self.eventStore calendarsForEntityType:EKEntityTypeEvent];
    for (EKCalendar *calendar in allCalendars) {
        // Skip "Mail To Do" equivalent if needed; EventKit calendars usually do not have this.
        // For completeness, ignoring calendars with title "Mail To Do"
        if (![calendar.title isEqualToString:@"Mail To Do"]) {
            ILCalController *calController = [[ILCalController alloc] initWithCalID:calendar.calendarIdentifier eventStore:self.eventStore];
            [calArray addObject:calController];
            
            [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(calendarListChanged:) name:@"CalendarUpdatedNotification" object:calController];
        }
    }
}

#pragma mark - Notifications

- (void)handleCalendarAccessChange:(NSNotification *)note {
    [self loadCalendarsFromEventKit];
    [calendarTableView reloadData];
}

-(void)addCalendar:(NSString *)_uid {
    // TODO: Migration to EventKit - Creating calendars is managed via the Calendar app or EKEventStore saveCalendar:error:
    // Currently just reload calendar list to update UI if needed.
    [self calendarListChanged:nil];
}

-(void)removeCalendar:(NSString *)_uid {
    ILCalController *calendarToRemove;
    for(ILCalController *aCalController in [self calArray])
        if([[aCalController calID] isEqual:_uid])
            calendarToRemove = aCalController;
    
    [[self calArray] removeObject:calendarToRemove];
    [self calendarListChanged:nil];
}

-(void)eventStoreChanged:(NSNotification *)notification {
    // Reload calendars from EventKit store when event store changes externally
    [self loadCalendarsFromEventKit];
    [calendarTableView reloadData];
}

-(id)tableView:(NSTableView *)aTableView objectValueForTableColumn:(NSTableColumn *)aTableColumn row:(NSInteger)rowIndex {
    return [[[self calArray] objectAtIndex:rowIndex] valueForKey:[aTableColumn identifier]];  
}

- (NSInteger)numberOfRowsInTableView:(NSTableView *)aTableView {
    return [[self calArray] count];  
}

-(void)tableView:(NSTableView*)tableView willDisplayCell:(id)cell forTableColumn:(NSTableColumn*)tableColumn row:(NSInteger)rowIndex {
    if ([cell respondsToSelector:@selector(setTextColor:)]) {
        [cell setTextColor:[NSColor whiteColor]];
    }
}

-(void)tableView:(NSTableView *)tableView didClickTableColumn:(NSTableColumn *)tableColumn {
    NSLog(@"%@",[tableColumn identifier]);
}

-(void)calendarListChanged:(NSNotification *)notification {
    [calendarTableView reloadData];
    [self updateSelectedCalendar:self];
}

-(IBAction)periodSelectorChanged:(id)sender {
    NSLog(@"periodSelectorChanged");
    [[[self calArray] objectAtIndex:[sender selectedRow]] setCurrentPeriod:[[sender selectedCell] objectValueOfSelectedItem]];
}

-(IBAction)setCurrentPeriodFromDate:(id)sender {
    [selectedCalendar setCurrentPeriod:[[selectedCalendar dataModel] periodForDate:[sender dateValue]]];
}

-(IBAction)setStartDateForSelectedCalendar:(id)sender {
    [selectedCalendar setStartDate:[sender dateValue]];
}

-(IBAction)setPeriodLengthForSelectedCalendar:(id)sender {
    [selectedCalendar setPeriodLength:([sender indexOfSelectedItem] * WEEK)];
}

-(IBAction)updateSelectedCalendar:(id)sender {
    if([calendarTableView selectedRow] == -1)
        selectedCalendar = nil;
    else
        selectedCalendar = [[self calArray] objectAtIndex:[calendarTableView selectedRow]];
}

-(IBAction)setPeriodForSelectedCalendar:(id)sender {
    [selectedCalendar setCurrentPeriodForDate:[sender dateValue]];
}

@end

