//
//  ILPreferencesPanelController.m
//  iLog
//
//  Created by Ross Bower on 3/30/10.
//  Copyright 2010 Ross Bower. All rights reserved.
//

#import "ILPreferencesPanelController.h"

@implementation ILPreferencesPanelController

@synthesize preferencesPanel;
@synthesize calController;
@synthesize calendarNameField;
@synthesize calendarStartDate;
@synthesize periodStartDay;
@synthesize periodLengthNumber;
@synthesize periodLengthUnits;
@synthesize currentPeriodStartDate;

- (void)showCustomSheet: (NSWindow *)_window {
	[[self calendarNameField] setStringValue:[NSString stringWithFormat:@"Preferences for Calendar:  %@",[[self calController] calName]]];
	[self updateDisplayValues];
    [NSApp beginSheet:preferencesPanel modalForWindow:_window modalDelegate: self didEndSelector: @selector(didEndSheet:returnCode:contextInfo:) contextInfo: nil];
}

-(void)updateDisplayValues {
	if([[self periodLengthUnits] indexOfSelectedItem] == 0)
		[[self calController] setPeriodLength:([[self periodLengthNumber] integerValue] * DAY)];
	else if([[self periodLengthUnits] indexOfSelectedItem] == 1)
		[[self calController] setPeriodLength:([[self periodLengthNumber] integerValue] * WEEK)];
	[[self calendarStartDate] setDateValue:[[self calController] startDate]];
	NSDateComponents *dateComps = [[NSCalendar currentCalendar] components:NSWeekdayCalendarUnit fromDate:[[self calController] startDate]];
	[[self periodStartDay] setSelectedSegment:[dateComps weekday]-1];
	[[self periodLengthUnits] selectItemAtIndex:1];
	[[self currentPeriodStartDate] setDateValue:[[[self calController] currentPeriod] startDate]];
	[[self currentPeriodStartDate] setTimeInterval:[[self calController] periodLength]-(1*DAY)];
	NSLog(@"%d",([[self calController] periodLength] % WEEK));
	if(([[self calController] periodLength] % WEEK) != 0) {
		[[self periodLengthNumber] setIntegerValue:([[self calController] periodLength] / DAY)];
		[[self periodLengthUnits] selectItemAtIndex:0];
	}
	else {
		[[self periodLengthNumber] setIntegerValue:([[self calController] periodLength] / WEEK)];
		[[self periodLengthUnits] selectItemAtIndex:1];
	}
}

-(IBAction)setPeriodLengthNumberFromBox:(id)sender {
	if([[self periodLengthUnits] indexOfSelectedItem] == 0)
		[[self calController] setPeriodLength:([[self periodLengthNumber] integerValue] * DAY)];
	else if([[self periodLengthUnits] indexOfSelectedItem] == 1)
		[[self calController] setPeriodLength:([[self periodLengthNumber] integerValue] * WEEK)];
	[self updateDisplayValues];
}

-(IBAction)setStartDay:(id)sender {
	NSDateComponents *dateComps = [[NSCalendar currentCalendar] components:NSWeekdayCalendarUnit fromDate:[[self calController] startDate]];
	NSInteger diff = [sender selectedSegment]-([dateComps weekday]-1);
	NSDate *myDate = [[[self calController] startDate] dateByAddingTimeInterval:(diff * DAY)];
	[[self calController] setStartDate:myDate];
	[self updateDisplayValues];
}

-(IBAction)setStartDate:(id)sender {
	[[self calController] setStartDate:[sender dateValue]];
	[self updateDisplayValues];
}

-(IBAction)setCurrentPeriod:(id)sender {
	[[self calController] setCurrentPeriodForDate:[sender dateValue]];
	[self updateDisplayValues];
}

-(IBAction)closeMyCustomSheet: (id)sender {
	if([[self periodLengthUnits] indexOfSelectedItem] == 0)
		[[self calController] setPeriodLength:([[self periodLengthNumber] integerValue] * DAY)];
	else if([[self periodLengthUnits] indexOfSelectedItem] == 1)
		[[self calController] setPeriodLength:([[self periodLengthNumber] integerValue] * WEEK)];
    [NSApp endSheet:preferencesPanel];
}

-(void)didEndSheet:(NSWindow *)sheet returnCode:(NSInteger)returnCode contextInfo:(void *)contextInfo {
    [sheet orderOut:self];
}

@end
