//
//  ILCalendarList.h
//  iLog
//
//  Created by Ross Bower on 3/25/10.
//  Copyright 2010 Ross Bower. All rights reserved.
// Updated for Xcode 26.3 / macOS 15: CalendarStore APIs removed, migration in progress to EventKit.
// NOTE: ARC (Automatic Reference Counting) should be enabled for this project.
// NOTE: Implementation now uses EventKit APIs instead of CalendarStore.
// All calendar management is now performed using EventKit; see implementation for details.

#import <Cocoa/Cocoa.h>
#import <EventKit/EventKit.h>
#import "ILCalController.h"
#import "ILPeriod.h"

@interface ILCalendarListController : NSObject <NSTableViewDataSource> {
	NSTableView *calendarTableView;
	ILCalController *selectedCalendar; 
	NSMutableArray *calArray;
	NSNumber *selectedTableRow;
}

@property (retain) NSMutableArray *calArray;
@property (retain) IBOutlet NSTableView *calendarTableView;
@property (retain) ILCalController *selectedCalendar;

-(id)tableView:(NSTableView *)aTableView objectValueForTableColumn:(NSTableColumn *)aTableColumn row:(NSInteger)rowIndex;
-(NSInteger)numberOfRowsInTableView:(NSTableView *)aTableView;
-(void)tableView:(NSTableView*)tableView willDisplayCell:(id)cell forTableColumn:(NSTableColumn*)tableColumn row:(NSInteger)rowIndex;
-(void)tableView:(NSTableView *)tableView didClickTableColumn:(NSTableColumn *)tableColumn;

-(void)calendarListChanged:(NSNotification *)notification;
-(IBAction)setPeriodForSelectedCalendar:(id)sender;
-(IBAction)updateSelectedCalendar:(id)sender;
-(IBAction)periodSelectorChanged:(id)sender;
-(IBAction)setPeriodLengthForSelectedCalendar:(id)sender;
-(void)loadCalendarsFromEventStore:(EKEventStore *)store;
-(void)addCalendar:(NSString *)calendarIdentifier;
-(void)removeCalendar:(NSString *)calendarIdentifier;

@end
