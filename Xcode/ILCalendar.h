//
//  ILCalendar.h
//  iLog Demo Program
//
//  Created by Ross Bower on 3/23/10.
//  Copyright 2010 Ross Bower. All rights reserved.
//
// Updated for Xcode 26.3 / macOS 15: Deprecated APIs removed, property synthesis modernized.
// NOTE: ARC (Automatic Reference Counting) should be enabled for this project.
// Updated for Xcode 26.3 / macOS 15: EventKit migration complete. ARC is enabled. Model is EventKit-aware via identifier only.
// This model is now compatible with EventKit calendar identifiers as used throughout the app.

#import <Cocoa/Cocoa.h>

@interface ILCalendar : NSObject {
	NSString *calID;
	NSDate *calStartDate;
	NSInteger periodLength;
}

@property (retain) NSString *calID;
@property (retain) NSDate *startDate;
@property NSInteger periodLength;
@property (readonly) NSDate *calStartDate;

-(id)periodForDate:(NSDate *)date;
-(id)initWithCalID:(NSString *)_calID;
-(id)periodForID:(NSInteger )pid;

@end

