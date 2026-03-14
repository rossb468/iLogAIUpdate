//
//  iLogAppDelegate.m
//  iLog
//
//  Created by Ross Bower on 3/24/10.
//  Copyright 2010 Ross Bower. All rights reserved.
//
// Updated for Xcode 26.3 / macOS 15: Deprecated APIs removed, property synthesis modernized.
// NOTE: ARC (Automatic Reference Counting) should be enabled for this project.
// Modernized for EventKit and macOS 15+ compatibility.

#import "iLogAppDelegate.h"
#import <EventKit/EventKit.h>
#import "ILCalendarListController.h"

@interface iLogAppDelegate ()
@property (strong, nonatomic) EKEventStore *eventStore;
@end

@implementation iLogAppDelegate
@synthesize calListController = calListController;
@synthesize lastArraySize = lastArraySize;
@synthesize preferenceButton = preferenceButton;
@synthesize prefPanelController = prefPanelController;
@synthesize primaryTableView = primaryTableView;
@synthesize statusItem = statusItem;
@synthesize statusMenu = statusMenu;
@synthesize window = window;

- (void)awakeFromNib {
	// Defer status item creation to applicationDidFinishLaunching to avoid auxiliary scene issues.
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    // Ensure the app runs as a foreground app with a Dock icon and menu bar
    [NSApp setActivationPolicy:NSApplicationActivationPolicyRegular];
    [NSApp activateIgnoringOtherApps:YES];
    
    // Create status item after activation using modern button API
    statusItem = [[NSStatusBar systemStatusBar] statusItemWithLength:NSVariableStatusItemLength];
    if (statusItem.button) {
        statusItem.button.title = @"iLog";
    }
    statusItem.menu = statusMenu;

    self.eventStore = [[EKEventStore alloc] init];
    void (^handleAccess)(BOOL, NSError *) = ^(BOOL granted, NSError * _Nullable error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (granted) {
                [self showMainWindow];
                if ([self->calListController respondsToSelector:@selector(loadCalendarsFromEventStore:)]) {
                    [self->calListController loadCalendarsFromEventStore:self.eventStore];
                }
            } else {
                NSAlert *alert = [[NSAlert alloc] init];
                [alert setMessageText:@"Calendar access not granted. The app cannot function without access to your calendars."];
                [alert addButtonWithTitle:@"OK"]; 
                [alert runModal];
                [NSApp terminate:self];
            }
        });
    };
    if (@available(macOS 14.0, *)) {
        [self.eventStore requestFullAccessToEventsWithCompletion:handleAccess];
    } else {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
        [self.eventStore requestAccessToEntityType:EKEntityTypeEvent completion:handleAccess];
#pragma clang diagnostic pop
    }
}

- (void)showMainWindow {
    // Bring the app to the front
    [NSApp activateIgnoringOtherApps:YES];

    if (!window) {
        // Create a simple fallback window if the nib didn't provide one
        NSPanel *fallback = [[NSPanel alloc] initWithContentRect:NSMakeRect(0, 0, 520, 360)
                                                       styleMask:(NSWindowStyleMaskTitled | NSWindowStyleMaskClosable | NSWindowStyleMaskResizable)
                                                         backing:NSBackingStoreBuffered
                                                           defer:NO];
        [fallback setTitle:@"iLog"]; 
        window = fallback; // assign to ivar; under ARC ivars are strong
    }

    [window setFloatingPanel:YES];
    [window setCollectionBehavior:NSWindowCollectionBehaviorCanJoinAllSpaces];
    [window center];
    [window makeKeyAndOrderFront:self];
}

-(void)calendarListChanged:(NSNotification *)notification {
}

-(void)updateWindowSize:(NSInteger)changeAmount {
	NSRect currentFrame = [window frame];
	currentFrame.size.height += changeAmount;
	currentFrame.origin.y -= changeAmount;
	[window setFrame:currentFrame display:YES animate:YES];
}

-(IBAction)openPreferenceSheet:(id)sender {
	[prefPanelController setCalController:[calListController selectedCalendar]];
	[prefPanelController showCustomSheet:[sender window]];
}

- (void)saveCalendarPreferences {
    id calID = nil;
    NSDate *startDate = nil;
    NSInteger periodLength = 0;
    if ([calListController respondsToSelector:@selector(selectedCalendar)]) {
        id selectedCal = [calListController selectedCalendar];
        if ([selectedCal respondsToSelector:@selector(calID)]) {
            calID = [selectedCal calID];
        }
        if ([selectedCal respondsToSelector:@selector(startDate)]) {
            startDate = [selectedCal startDate];
        }
        if ([selectedCal respondsToSelector:@selector(periodLength)]) {
            periodLength = (NSInteger)[selectedCal periodLength];
        }
    }
    if (!calID) { return; }
    NSDictionary *prefsDict = @{ @"calID": calID,
                                 @"calStartDate": startDate ?: [NSDate date],
                                 @"periodLength": @(periodLength) };
    [[NSUserDefaults standardUserDefaults] setObject:prefsDict forKey:calID];
}

-(void)loadCalendarPreferences {
    id calID = nil;
    if ([calListController respondsToSelector:@selector(selectedCalendar)]) {
        id selectedCal = [calListController selectedCalendar];
        if ([selectedCal respondsToSelector:@selector(calID)]) {
            calID = [selectedCal calID];
        }
    }
    if (!calID) { return; }
    NSDictionary *prefsDict = [[NSUserDefaults standardUserDefaults] objectForKey:calID];
    if (prefsDict && [calListController respondsToSelector:@selector(selectedCalendar)]) {
        id selectedCal = [calListController selectedCalendar];
        id startDate = prefsDict[@"calStartDate"];
        NSNumber *period = prefsDict[@"periodLength"];
        if ([selectedCal respondsToSelector:@selector(setStartDate:)]) {
            if ([startDate isKindOfClass:[NSDate class]]) {
                [selectedCal setStartDate:startDate];
            }
        }
        if ([selectedCal respondsToSelector:@selector(setPeriodLength:)]) {
            if ([period isKindOfClass:[NSNumber class]]) {
                [selectedCal setPeriodLength:[period integerValue]];
            }
        }
    }
}

@end

