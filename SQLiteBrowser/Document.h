//
//  Document.h
//  SQLiteBrowser
//
//  Created by Archuthan Vijayaratnam on 2012-10-27.
//  Copyright (c) 2012 Archuthan Vijayaratnam. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface Document : NSDocument <NSApplicationDelegate, NSTableViewDataSource, NSTableViewDelegate, NSOutlineViewDataSource, NSOutlineViewDelegate, NSTextViewDelegate>
{
    NSMutableArray *recentSearches;
    NSMutableArray *arrayOfData;
    
    NSString *databaseFileName;
    
    NSMutableArray *leftOutline;
    
    NSString *lastTableToBeClicked;
    int rowIdOfLastItemClicked;
    
    
    NSArray *sideTableTitles;
    
    
    
	BOOL					completePosting;
    BOOL					commandHandling;
}
@property (weak) IBOutlet NSView *docView;

@property (strong) IBOutlet NSTextView *stmtQueryField;

@property (weak) IBOutlet NSTextField *pagingTextField;
@property (weak) IBOutlet NSStepper *pagingStepper;
@property (weak) IBOutlet NSOutlineView *leftOutlineView;
@property (weak) IBOutlet NSTableView *mainTable;

@end
