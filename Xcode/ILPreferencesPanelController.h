//
//  ILPreferencesPanelController.h
//  iLog
//
//  Created by Ross Bower on 3/30/10.
//  Copyright 2010 Ross Bower. All rights reserved.
//
// Updated for Xcode 26.3 / macOS 15: Deprecated APIs removed, property synthesis modernized.
// Updated for Xcode 26.3 / macOS 15: EventKit migration complete. ARC is enabled. Calendar interaction uses EventKit only.
// This controller is designed to manage preferences using EventKit calendar access exclusively.

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

@property (nonatomic, strong) IBOutlet NSDatePicker *currentPeriodStartDate;
@property (nonatomic, strong) IBOutlet NSComboBox *periodLengthUnits;
@property (nonatomic, strong) IBOutlet NSTextField *periodLengthNumber;
@property (nonatomic, strong) IBOutlet NSSegmentedControl *periodStartDay;
@property (nonatomic, strong) IBOutlet NSDatePicker *calendarStartDate;
@property (nonatomic, strong) IBOutlet NSTextField *calendarNameField;
@property (nonatomic, strong) IBOutlet NSPanel *preferencesPanel;
@property (nonatomic, strong) IBOutlet ILCalController *calController;

/// Displays the preferences panel as a sheet attached to the specified window.
/// This method uses EventKit-based calendar preferences exclusively.
-(void)showCustomSheet:(NSWindow *)_window;

-(IBAction)closeMyCustomSheet:(id)sender;

-(void)didEndSheet:(NSWindow *)sheet returnCode:(NSInteger)returnCode contextInfo:(void *)contextInfo;

/// Updates the panel display values based on the current EventKit calendar properties.
-(void)updateDisplayValues;

-(IBAction)setPeriodLengthNumberFromBox:(id)sender;
-(IBAction)setStartDate:(id)sender;
-(IBAction)setStartDay:(id)sender;
-(IBAction)setCurrentPeriod:(id)sender;

@end

