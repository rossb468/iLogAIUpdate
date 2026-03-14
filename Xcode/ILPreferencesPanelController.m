//
//  ILPreferencesPanelController.m
//  iLog
//
//  Created by Ross Bower on 3/30/10.
//  Copyright 2010 Ross Bower. All rights reserved.
//

// Updated for Xcode 26.3 / macOS 15: EventKit migration complete. ARC is enabled. Calendar interaction uses EventKit only.

#import "ILPreferencesPanelController.h"

@implementation ILPreferencesPanelController

@synthesize currentPeriodStartDate = currentPeriodStartDate;
@synthesize periodLengthUnits = periodLengthUnits;
@synthesize periodLengthNumber = periodLengthNumber;
@synthesize periodStartDay = periodStartDay;
@synthesize calendarStartDate = calendarStartDate;
@synthesize calendarNameField = calendarNameField;
@synthesize preferencesPanel = preferencesPanel;
@synthesize calController = calController;

- (void)showCustomSheet: (NSWindow *)_window {
	// Update the calendar name label using EventKit-backed calController
	[[self calendarNameField] setStringValue:[NSString stringWithFormat:@"Preferences for Calendar:  %@", [[self calController] calName]]];
	[self updateDisplayValues];
    [_window beginSheet:preferencesPanel completionHandler:^(NSModalResponse returnCode) {
        [self didEndSheet:preferencesPanel returnCode:returnCode contextInfo:nil];
    }];
}

-(void)updateDisplayValues {
	// Update UI controls with values from EventKit-backed calController
	if([[self periodLengthUnits] indexOfSelectedItem] == 0)
		[[self calController] setPeriodLength:([[self periodLengthNumber] integerValue] * DAY)];
	else if([[self periodLengthUnits] indexOfSelectedItem] == 1)
		[[self calController] setPeriodLength:([[self periodLengthNumber] integerValue] * WEEK)];
	
	[[self calendarStartDate] setDateValue:[[self calController] startDate]];
	
	// Retrieve weekday component from EventKit-based startDate
	NSDateComponents *dateComps = [[NSCalendar currentCalendar] components:NSCalendarUnitWeekday fromDate:[[self calController] startDate]];
	
	[[self periodStartDay] setSelectedSegment:[dateComps weekday] - 1];
	
	// Select period length units UI control
	[[self periodLengthUnits] selectItemAtIndex:1];
	
	// Set the current period start date and adjust end date using periodLength
	[[self currentPeriodStartDate] setDateValue:[[[self calController] currentPeriod] startDate]];
	
	// Adjust the currentPeriodStartDate's time interval to the end of the period
	[[self currentPeriodStartDate] setTimeInterval:[[self calController] periodLength] - (1 * DAY)];
	
	NSLog(@"%ld", (long)([[self calController] periodLength] % WEEK));
	
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
	// Update period length in calController based on user input, EventKit-backed
	if([[self periodLengthUnits] indexOfSelectedItem] == 0)
		[[self calController] setPeriodLength:([[self periodLengthNumber] integerValue] * DAY)];
	else if([[self periodLengthUnits] indexOfSelectedItem] == 1)
		[[self calController] setPeriodLength:([[self periodLengthNumber] integerValue] * WEEK)];
	[self updateDisplayValues];
}

-(IBAction)setStartDay:(id)sender {
	// Adjust start date weekday in calController using EventKit APIs
	NSDateComponents *dateComps = [[NSCalendar currentCalendar] components:NSCalendarUnitWeekday fromDate:[[self calController] startDate]];
	NSInteger diff = [sender selectedSegment] - ([dateComps weekday] - 1);
	
	NSDate *myDate = [[[self calController] startDate] dateByAddingTimeInterval:(diff * DAY)];
	[[self calController] setStartDate:myDate];
	[self updateDisplayValues];
}

-(IBAction)setStartDate:(id)sender {
	// Sets the start date in calController via EventKit
	[[self calController] setStartDate:[sender dateValue]];
	[self updateDisplayValues];
}

-(IBAction)setCurrentPeriod:(id)sender {
	// Sets current period in calController for a given date via EventKit
	[[self calController] setCurrentPeriodForDate:[sender dateValue]];
	[self updateDisplayValues];
}

-(IBAction)closeMyCustomSheet: (id)sender {
	// Save any pending period length changes to calController (EventKit-backed)
	if([[self periodLengthUnits] indexOfSelectedItem] == 0)
		[[self calController] setPeriodLength:([[self periodLengthNumber] integerValue] * DAY)];
	else if([[self periodLengthUnits] indexOfSelectedItem] == 1)
		[[self calController] setPeriodLength:([[self periodLengthNumber] integerValue] * WEEK)];
    [preferencesPanel.sheetParent endSheet:preferencesPanel];
}

-(void)didEndSheet:(NSWindow *)sheet returnCode:(NSInteger)returnCode contextInfo:(void *)contextInfo {
    [sheet orderOut:self];
}

@end

