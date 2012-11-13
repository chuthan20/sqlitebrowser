//
//  Document.h
//  SQLiteBrowser
//
//  Created by Archuthan Vijayaratnam on 2012-10-27.
//  Copyright (c) 2012 Archuthan Vijayaratnam. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface Document : NSDocument <NSApplicationDelegate, NSTableViewDataSource, NSTableViewDelegate, NSOutlineViewDataSource, NSOutlineViewDelegate>
@property (weak) IBOutlet NSView *docView;

@property (weak) IBOutlet NSSearchField *stmtQueryField;

@property (weak) IBOutlet NSTextField *stmtField;
@property (weak) IBOutlet NSTextField *pagingTextField;
@property (weak) IBOutlet NSStepper *pagingStepper;
@property (weak) IBOutlet NSOutlineView *leftOutlineView;
@property (weak) IBOutlet NSTableView *mainTable;

@end
