//
//  ILCalendarList.m
//  iLog
//
//  Created by Ross Bower on 3/25/10.
//  Copyright 2010 Ross Bower. All rights reserved.
//

#import "ILCalendarListController.h"


@implementation ILCalendarListController

@synthesize calArray;
@synthesize calendarTableView;
@synthesize selectedCalendar;

-(id)init {
	if(self = [super init]) {
		calArray = [[NSMutableArray alloc] init];
		
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(calendarStoreChanged:) name:CalCalendarsChangedExternallyNotification object:[CalCalendarStore defaultCalendarStore]];
	}
	
	return self;
}

-(void)addCalendar:(NSString *)_uid {
	CalCalendar *aCalendar = [[CalCalendarStore defaultCalendarStore] calendarWithUID:_uid];
	if(![[aCalendar title] isEqual:@"Mail To Do"]) {
		[[self calArray] addObject:[[ILCalController alloc] initWithCalID:[aCalendar uid]]];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(calendarListChanged:) name:@"CalendarUpdatedNotification" object:[[self calArray] lastObject]];
	}
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

-(void)calendarStoreChanged:(NSNotification *)notification {
	NSMutableArray *calendarStoreArray = [[NSMutableArray alloc] init];
	for(CalCalendar *aCalendar in [[CalCalendarStore defaultCalendarStore] calendars])
		if(![[aCalendar title] isEqual:@"Mail To Do"])
			[calendarStoreArray addObject:aCalendar];

	if([[notification userInfo] valueForKey:@"CalInsertedRecordsKey"]) {
		NSArray *insertedCalendarList = [NSArray arrayWithArray:[[notification userInfo] valueForKey:@"CalInsertedRecordsKey"]];
		for(NSString *_uid in insertedCalendarList)
			[self addCalendar:_uid];
	}
	if([[notification userInfo] valueForKey:@"CalDeletedRecordsKey"]) {
		NSArray *deletedCalendarList = [NSArray arrayWithArray:[[notification userInfo] valueForKey:@"CalDeletedRecordsKey"]];
		for(NSString *_uid in deletedCalendarList)
			[self removeCalendar:_uid];
	}
}

-(id)tableView:(NSTableView *)aTableView objectValueForTableColumn:(NSTableColumn *)aTableColumn row:(int)rowIndex {
	return [[[self calArray] objectAtIndex:rowIndex] valueForKey:[aTableColumn identifier]];  
}

- (int)numberOfRowsInTableView:(NSTableView *)aTableView {
	return [[self calArray] count];  
}

-(void)tableView:(NSTableView*)tableView willDisplayCell:(id)cell forTableColumn:(NSTableColumn*)tableColumn row:(int)rowIndex {
	[cell setTextColor:[NSColor whiteColor]];
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
