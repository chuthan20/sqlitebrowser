//
//  PopupTableViewController.m
//  SQLiteBrowser
//
//  Created by Archuthan Vijayaratnam on 2012-10-30.
//  Copyright (c) 2012 Archuthan Vijayaratnam. All rights reserved.
//

#import "PopupTableViewController.h"
#import "ATPopupWindow.h"

@interface PopupTableViewController ()
{
    ATPopupWindow *_window;
}
@end

@implementation PopupTableViewController

//- (void)awakeFromNib
//{
//    [super awakeFromNib];
//    [self showPopUpWindow:self.view.frame];
//}

- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView {
    return 10;
}

- (NSView *)tableView:(NSTableView *)tableView viewForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row {
    
        // get an existing cell with the MyView identifier if it exists
    NSTextField *result = [tableView makeViewWithIdentifier:@"MyView" owner:self];
    [result setEditable:NO];
    
        // There is no existing cell to reuse so we will create a new one
    if (result == nil) {
        
            // create the new NSTextField with a frame of the {0,0} with the width of the table
            // note that the height of the frame is not really relevant, the row-height will modify the height
            // the new text field is then returned as an autoreleased object
        result = [[NSTextField alloc] initWithFrame:NSMakeRect(0, 0, 200, 20)];
        [result setBackgroundColor:[NSColor clearColor]];
        [result setBezeled:NO];
        [result setDrawsBackground:NO];
        [result setEditable:NO];
        [result setSelectable:NO];
            // the identifier of the NSTextField instance is set to MyView. This
            // allows it to be re-used
        result.identifier = @"MyView";
    }
    
        // result is now guaranteed to be valid, either as a re-used cell
        // or as a new cell, so set the stringValue of the cell to the
        // nameArray value at row
    
    result.stringValue = @"Oh yEa";
    
        // return the result.
    return result;
    
}
/*
- (void)_createWindowIfNeeded {
    if (_window == nil) {
        NSRect viewFrame = self.view.frame;
            // Create and setup our window
        _window = [[ATPopupWindow alloc] initWithContentRect:viewFrame styleMask:NSBorderlessWindowMask backing:NSBackingStoreBuffered defer:NO];
        [_window setReleasedWhenClosed:NO];
        [_window setLevel:NSPopUpMenuWindowLevel];
        [_window setHasShadow:YES];
        [[_window contentView] addSubview:self.view];
        [_window makeFirstResponder:self.tableList];
        
            // Make the window have a clear color and be non-opaque for our pop-up animation
        [_window setBackgroundColor:[NSColor clearColor]];
        [_window setOpaque:NO];
    }
}


- (void)_windowClosed:(NSNotification *)note {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NSWindowWillCloseNotification object:_window];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NSApplicationDidResignActiveNotification object:nil];
}

- (void)_closeAndSendAction:(BOOL)sendAction {
    [_window close];
}
- (void)_windowShouldClose:(NSNotification *)note {
    [self _closeAndSendAction:NO];
}

- (void) showPopUpWindow: (NSRect) rect
{
    [self _createWindowIfNeeded];
    NSPoint origin = rect.origin;
    NSRect windowFrame = [_window frame];
        // The origin is the lower left; subtract the window's height
    origin.y -= NSHeight(windowFrame);
        // Center the popup window under the rect
    origin.y += floor(NSHeight(rect) / 3.0);
    origin.x -= floor(NSWidth(windowFrame) / 2.0);
    origin.x += floor(NSWidth(rect) / 2.0);
    
    [_window setFrameOrigin:origin];
    [_window popup];
    
        // Add some watches on the window and application
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_windowClosed:) name:NSWindowWillCloseNotification object:_window];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_windowShouldClose:) name:NSApplicationDidResignActiveNotification object:nil];

}

*/
@end
