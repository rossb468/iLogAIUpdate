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

@property (strong) IBOutlet NSMenu *statusMenu;
@property (strong) NSStatusItem *statusItem;
@property (strong) IBOutlet NSButton *preferenceButton;
@property NSInteger lastArraySize;
@property (strong) IBOutlet ILPreferencesPanelController *prefPanelController;
@property (strong) IBOutlet NSTableView *primaryTableView;
@property (strong) IBOutlet ILCalendarListController *calListController;
@property (strong) IBOutlet NSPanel *window;

-(void)calendarListChanged:(NSNotification *)notification;
-(IBAction)openPreferenceSheet:(id)sender;
-(void)updateWindowSize:(NSInteger)changeAmount;

@end
