//
//  ILCalendarList.h
//  iLog
//
//  Created by Ross Bower on 3/25/10.
//  Copyright 2010 Ross Bower. All rights reserved.
//

#import <Cocoa/Cocoa.h>
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

-(id)tableView:(NSTableView *)aTableView objectValueForTableColumn:(NSTableColumn *)aTableColumn row:(int)rowIndex;
-(int)numberOfRowsInTableView:(NSTableView *)aTableView;
-(void)tableView:(NSTableView*)tableView willDisplayCell:(id)cell forTableColumn:(NSTableColumn*)tableColumn row:(int)rowIndex;
-(void)tableView:(NSTableView *)tableView didClickTableColumn:(NSTableColumn *)tableColumn;


-(void)calendarListChanged:(NSNotification *)notification;
-(IBAction)setPeriodForSelectedCalendar:(id)sender;
-(IBAction)updateSelectedCalendar:(id)sender;
-(IBAction)periodSelectorChanged:(id)sender;
-(IBAction)setPeriodLengthForSelectedCalendar:(id)sender;
-(IBAction)updateSelectedCalendar:(id)sender;
-(void)calendarStoreChanged:(NSNotification *)notification;
-(void)addCalendar:(NSString *)_uid;
-(void)removeCalendar:(NSString *)_uid;


@end
