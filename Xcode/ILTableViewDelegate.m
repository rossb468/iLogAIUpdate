//
//  CustomTableView.m
//o
//  Created by Ross Bower on 3/17/10.
//  Copyright 2010 Drexel University. All rights reserved.
//

#import "ILTableViewDelegate.h"

@implementation TableViewDelegate


-(void)mouseDown:(NSEvent *)theEvent {

}

-(void)mouseDragged:(NSEvent *)theEvent {
	NSPoint windowOrigin;
    NSWindow *window = [self window];
	
    windowOrigin = [window frame].origin;
	
    [window setFrameOrigin:NSMakePoint(windowOrigin.x + [theEvent deltaX], windowOrigin.y - [theEvent deltaY])];
}

@end
