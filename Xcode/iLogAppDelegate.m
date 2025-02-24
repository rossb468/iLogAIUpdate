//
//  iLogAppDelegate.m
//  iLog
//
//  Created by Ross Bower on 3/24/10.
//  Copyright 2010 Ross Bower. All rights reserved.
//

#import "iLogAppDelegate.h"

@implementation iLogAppDelegate

@synthesize window;
@synthesize calListController;
@synthesize primaryTableView;
@synthesize prefPanelController;
@synthesize lastArraySize;
@synthesize preferenceButton;
@synthesize statusItem;
@synthesize statusMenu;

- (void)awakeFromNib {
	statusItem = [[NSStatusBar systemStatusBar] statusItemWithLength:NSVariableStatusItemLength];
	[statusItem setMenu:statusMenu];
	[statusItem setTitle:@"iLog"];
	//NSImage *statusImage = [[NSImage alloc] initWithContentsOfFile:@"statusImage.png"];
	//[statusItem setImage:statusImage];
	//[statusItem setAlternateImage:<#(NSImage *)image#>];
	[statusItem setHighlightMode:YES];
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
	[window setFloatingPanel:TRUE];
	[window setCollectionBehavior:NSWindowCollectionBehaviorCanJoinAllSpaces];
	[window makeKeyAndOrderFront:self];
	
	for(CalCalendar *aCalendar in [[CalCalendarStore defaultCalendarStore] calendars]) {
		if(![[aCalendar title] isEqual:@"Mail To Do"]) {
			[[calListController calArray] addObject:[[ILCalController alloc] initWithCalID:[aCalendar uid]]];
			[[NSNotificationCenter defaultCenter] addObserver:calListController selector:@selector(calendarListChanged:) name:@"CalendarUpdatedNotification" object:[[calListController calArray] lastObject]];
		}
	}
    
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(calendarListChanged:) name:CalCalendarsChangedExternallyNotification object:[CalCalendarStore defaultCalendarStore]];
	
	[self updateWindowSize:([[calListController calArray] count]-1)*21];
	
	[[calListController calendarTableView] reloadData];
	[calListController setSelectedCalendar:[[calListController calArray] objectAtIndex:0]];
	[self setLastArraySize:[[calListController calArray] count]];
	
	
}

-(void)calendarListChanged:(NSNotification *)notification {
	NSInteger diff = [[calListController calArray] count] - lastArraySize;
	[self setLastArraySize:[[calListController calArray] count]];
	[self updateWindowSize:(21*diff)];
}

-(void)updateWindowSize:(NSInteger)changeAmount {
	NSRect currentFrame = [window frame];
	currentFrame.size.height += changeAmount;
	currentFrame.origin.y -= changeAmount;
	[window setFrame:currentFrame display:TRUE animate:TRUE];
}

-(IBAction)openPreferenceSheet:(id)sender {
	[prefPanelController setCalController:[calListController selectedCalendar]];
	[prefPanelController showCustomSheet:[sender window]];
}

@end
