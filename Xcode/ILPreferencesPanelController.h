//
//  ILPreferencesPanelController.h
//  iLog
//
//  Created by Ross Bower on 3/30/10.
//  Copyright 2010 Ross Bower. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "ILCalController.h"


@interface ILPreferencesPanelController : NSObject {
	NSPanel *preferencesPanel;
	ILCalController *calController;
	NSTextField *calendarNameField;
	NSDatePicker *calendarStartDate;
	NSDatePicker *currentPeriodStartDate;
	NSSegmentedControl *periodStartDay;
	NSTextField *periodLengthNumber;
	NSComboBox *periodLengthUnits;
}

@property (retain) IBOutlet NSDatePicker *currentPeriodStartDate;
@property (retain) IBOutlet NSComboBox *periodLengthUnits;
@property (retain) IBOutlet NSTextField *periodLengthNumber;
@property (retain) IBOutlet NSSegmentedControl *periodStartDay;
@property (retain) IBOutlet NSDatePicker *calendarStartDate;
@property (retain) IBOutlet NSTextField *calendarNameField;;
@property (retain) IBOutlet NSPanel *preferencesPanel;
@property (retain) IBOutlet ILCalController *calController;

-(void)showCustomSheet: (NSWindow *)_window;
-(IBAction)closeMyCustomSheet: (id)sender;
-(void)didEndSheet:(NSWindow *)sheet returnCode:(NSInteger)returnCode contextInfo:(void *)contextInfo;

-(void)updateDisplayValues;

-(IBAction)setPeriodLengthNumberFromBox:(id)sender;
-(IBAction)setStartDate:(id)sender;
-(IBAction)setStartDay:(id)sender;
-(IBAction)setCurrentPeriod:(id)sender;

@end
