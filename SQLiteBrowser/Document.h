//
//  Document.h
//  SQLiteBrowser
//
//  Created by Archuthan Vijayaratnam on 2012-10-27.
//  Copyright (c) 2012 Archuthan Vijayaratnam. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface Document : NSDocument <NSApplicationDelegate, NSTableViewDataSource, NSTableViewDelegate, NSOutlineViewDataSource, NSOutlineViewDelegate, NSTextViewDelegate>

@property (strong) IBOutlet NSTextView *stmtQueryField;

@property (weak) IBOutlet NSOutlineView *leftOutlineView;
@property (weak) IBOutlet NSTableView *mainTable;
@property (strong) IBOutlet NSDrawer *consoleDrawer;

@end
