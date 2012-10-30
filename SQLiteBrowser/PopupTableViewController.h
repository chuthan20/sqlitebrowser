//
//  PopupTableViewController.h
//  SQLiteBrowser
//
//  Created by Archuthan Vijayaratnam on 2012-10-30.
//  Copyright (c) 2012 Archuthan Vijayaratnam. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class ATPopupWindow;
@interface PopupTableViewController : NSViewController <NSTableViewDelegate, NSTableViewDataSource> 
@property IBOutlet NSTableView *tableList;

@end
