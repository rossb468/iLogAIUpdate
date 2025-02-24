//
//  iLogAppDelegate.h
//  iLog
//
//  Created by Ross Bower on 3/24/10.
//  Copyright 2010 Ross Bower. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "ILPeriod.h"
#import "ILCalendar.h"
#import "ILCalController.h"
#import "ILCalendarListController.h"
#import "ILPreferencesPanelController.h"

@interface iLogAppDelegate : NSObject <NSApplicationDelegate> {
    NSPanel *window;
	ILCalendarListController *calListController;
	NSTableView *primaryTableView;
	NSPanel *preferencesPanel;
	ILPreferencesPanelController *prefPanelController;
	NSInteger lastArraySize;
	NSButton *preferenceButton;
	
	NSStatusItem *statusItem;
	NSMenu *statusMenu;
}

@property (assign) IBOutlet NSMenu *statusMenu;
@property (assign) NSStatusItem *statusItem;
@property (assign) IBOutlet NSButton *preferenceButton;
@property NSInteger lastArraySize;
@property (assign) IBOutlet ILPreferencesPanelController *prefPanelController;
@property (assign) IBOutlet NSTableView *primaryTableView;
@property (assign) IBOutlet ILCalendarListController *calListController;
@property (assign) IBOutlet NSPanel *window;

-(void)calendarListChanged:(NSNotification *)notification;
-(IBAction)openPreferenceSheet:(id)sender;
-(void)updateWindowSize:(NSInteger)changeAmount;

@end
