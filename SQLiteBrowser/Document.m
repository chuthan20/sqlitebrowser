//
//  Document.m
//  SQLiteBrowser
//
//  Created by Archuthan Vijayaratnam on 2012-10-27.
//  Copyright (c) 2012 Archuthan Vijayaratnam. All rights reserved.
//

#import "Document.h"
#include <sqlite3.h>

static int kNumOffset = 5000;

@interface Document ()
{
    NSMutableArray*             _arrayOfData;
    NSMutableArray*             _leftOutline;

    NSArray*                    _sideTableTitles;

    NSString*                   _databaseFileName;
    NSString*                   _lastTableToBeClicked;

    int                         _rowIdOfLastItemClicked;

	BOOL                        _completePosting;
    BOOL                        _commandHandling;
}
@property (unsafe_unretained) IBOutlet NSTextView *console;
@end


@implementation Document

- (NSString *)windowNibName
{
    return NSStringFromClass([self class]);
}

- (void)windowControllerDidLoadNib:(NSWindowController *)aController
{
    [super windowControllerDidLoadNib:aController];
    
    _arrayOfData = [NSMutableArray array];
    _leftOutline = [NSMutableArray array];
    
    if (_databaseFileName != NULL)
    {
        [self loadBtnClicked:nil];
    }
    
    _sideTableTitles = @[@"Table", @"View", @"Index"] ;
    _mainTable.rowHeight = 22;
    [_consoleDrawer open];
}

+ (BOOL)autosavesInPlace
{
    return NO;
}

- (void)canCloseDocumentWithDelegate:(id)delegate shouldCloseSelector:(SEL)shouldCloseSelector contextInfo:(void *)contextInfo
{
    [self updateChangeCount:NSChangeCleared];
    [self close];
}

- (BOOL)readFromURL:(NSURL *)url ofType:(NSString *)typeName error:(NSError *__autoreleasing *)outError
{
    _databaseFileName = url.path;
    return YES;
}

#pragma mark - TableView Datasource & Delegates
- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView
{
    if (tableView == self.mainTable)
        return _arrayOfData.count;
    return 0;
}

- (CGFloat)tableView:(NSTableView *)tableView sizeToFitWidthOfColumn:(NSInteger)column
{
    NSTableColumn *c =  (NSTableColumn *)[tableView.tableColumns objectAtIndex:column];
    NSCell *cell = c.headerCell;
    CGFloat maxWidth = [cell.title sizeWithAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[NSFont systemFontOfSize:13], NSFontAttributeName, nil]].width;
    
    NSInteger rows = [tableView numberOfRows];
    NSDictionary *attributes = [NSDictionary dictionaryWithObjectsAndKeys:[NSFont systemFontOfSize:13], NSFontAttributeName, nil];
    for (int i=0; i<rows; i++)
    {

        NSString *strValue = [[_arrayOfData objectAtIndex:i] objectForKey:c.identifier];
        NSSize labelSize = [strValue sizeWithAttributes:attributes];
        maxWidth = MAX(labelSize.width + 10, maxWidth);
    }
    return maxWidth;
}

- (id)tableView:(NSTableView *)tableView objectValueForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row
{
    if ([tableView isEqualTo:self.mainTable])
    {
        NSString *strValue = [[_arrayOfData objectAtIndex:row] objectForKey:tableColumn.identifier];
        return strValue;
    }
    return nil;
}


- (void) tableView:(NSTableView *)tableView setObjectValue:(id)object forTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row
{

     NSLog(@"%@", [_arrayOfData objectAtIndex:row]);
     NSLog(@"%ld", (long)row);
     NSLog(@"%@", object);
     NSLog(@"%@", tableColumn);
}

#pragma mark - Toolbar button events
- (IBAction)loadBtnClicked:(id)sender
{
    NSLog(@"%s" , __PRETTY_FUNCTION__);
    _lastTableToBeClicked = @"sqlite_master";
    [self loadAndDisplayTable:_lastTableToBeClicked offset:0 limit:kNumOffset];
    [self loadAndDisplayLeftTable];
    
}

- (IBAction)executeBtnClicked:(id)sender
{
    if (self.stmtQueryField.string.length == 0)
        return;

    NSRange range = [self.stmtQueryField selectedRange];
    if (range.length > 0)
    {
        [self loadAndDisplayTableWithQuery:[[self.stmtQueryField string] substringWithRange:range]];
    }
    else
    {
        NSMutableString *query = [NSMutableString string];

        //select the whole line of query (not sqlite syntax aware -- dumb selection)
        NSString *str = [self.stmtQueryField string];

        //copy from from end of the line to current position
        for (int i = (int)range.location; i<str.length; i++)
        {
            if ([str characterAtIndex:i] == '\n')
                break;
            else
                [query appendFormat:@"%c", [str characterAtIndex:i]];
        }

        // copy string from current position to beginning of the line
        for (int i = (int)range.location-1; i >= 0; i--)
        {
            if ([str characterAtIndex:i] == '\n')
                break;

            [query insertString:[NSString stringWithFormat:@"%c", [str characterAtIndex:i]] atIndex:0];

            if (i==0)
                break;
        }
        [self loadAndDisplayTableWithQuery:query];
    }
}


- (IBAction)toolbarItemClicked:(NSToolbarItem *)sender
{
    if ([@"execute" isEqualToString:[sender.label lowercaseString]])
    {
        [self executeBtnClicked:nil];
    }
    else if ([@"reset" isEqualToString:[sender.label lowercaseString]])
    {
        [self loadBtnClicked:nil];
    }
    else if ([@"console" isEqualToString:[sender.label lowercaseString]])
    {
        if (_consoleDrawer.state == NSDrawerClosedState || _consoleDrawer.state == NSDrawerClosingState)
            [_consoleDrawer open];
        else
            [_consoleDrawer close];
    }
}

- (void) addQueryToConsole:(NSString *)query
{
    [_console.textStorage appendAttributedString:[self syntaxHightlightQuery:query]];
}

- (void) addErrorMessageToConsole:(NSString *) query
{
    NSAttributedString *str = [[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@", query] attributes:@{NSForegroundColorAttributeName:[NSColor redColor]}];
    [_console.textStorage appendAttributedString: str];
}

- (NSAttributedString *) syntaxHightlightQuery:(NSString *)query
{
    NSArray *keywords = [NSArray arrayWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"sqlite_syntax" ofType:@"plist"]];

    NSMutableCharacterSet *cs = [NSMutableCharacterSet whitespaceAndNewlineCharacterSet];
//    [cs formUnionWithCharacterSet:[NSCharacterSet characterSetWithCharactersInString:@",()"]];
    NSArray *arr = [query componentsSeparatedByCharactersInSet:cs];

    NSMutableAttributedString *formattedQuery = [[NSMutableAttributedString alloc] initWithString:@"> "];
    for (NSString *str in arr)
    {
        NSAttributedString *k  = nil;
        NSString *cword = [str lowercaseString];
        if ([keywords containsObject:cword])
        {
            k = [[NSAttributedString alloc] initWithString:[str uppercaseString] attributes:@{NSForegroundColorAttributeName:[NSColor colorWithCalibratedRed:0.188 green:0.248 blue:0.979 alpha:1.000]}];
        }
        else
        {
            k = [[NSAttributedString alloc] initWithString:str attributes:@{NSForegroundColorAttributeName:[NSColor colorWithCalibratedRed:0.268 green:0.696 blue:0.761 alpha:1.000]}];

        }
        [formattedQuery appendAttributedString:k];
        [formattedQuery appendAttributedString:[[NSAttributedString alloc] initWithString:@" "]];
    }

    [formattedQuery appendAttributedString:[[NSAttributedString alloc] initWithString:@"\n"]];
    return formattedQuery;

}

- (void) loadAndDisplayLeftTable
{
    sqlite3 *fdb = [self openDatabase];
    if (fdb != NULL)
    {
        NSString *query = @"SELECT tbl_name, type FROM sqlite_master";
        [self addQueryToConsole:[NSString stringWithFormat:@"%@\n", query]];

        sqlite3_stmt    *statement = NULL;
        if (sqlite3_prepare_v2(fdb, [query UTF8String], -1, &statement, NULL) == SQLITE_OK)
        {
            
            NSMutableArray *tbls = [NSMutableArray array];
            NSMutableArray *views = [NSMutableArray array];
            NSMutableArray *indices = [NSMutableArray array];
            
            while (sqlite3_step(statement) == SQLITE_ROW)
            {
                const char *cname =  (const char *) sqlite3_column_text(statement, 0);
                NSString *name = [NSString stringWithFormat:@"%s", cname];
                
                const char *ctype =  (const char *) sqlite3_column_text(statement, 1);
                NSString *type = [[NSString stringWithFormat:@"%s", ctype] lowercaseString];
                
                if ([type isEqualToString:@"view"])
                {
                    [views addObject:name];
                }
                else if ([type isEqualToString:@"table"])
                {
                    [tbls addObject:name];
                }
                else if ([type isEqualToString:@"index"])
                {
                    [indices addObject:name];
                }
            }
            [_leftOutline removeAllObjects];
            [_leftOutline addObject:tbls];
            [_leftOutline addObject:views];
            [_leftOutline addObject:indices];
            sqlite3_finalize(statement);
        }
    }
    sqlite3_close(fdb);
    [_leftOutlineView reloadData];
}

- (int) getCount:(NSString *)queryString
{
    sqlite3 *fdb = [self openDatabase];
    int numOfRows = -1;

    if (fdb != NULL)
    {
        sqlite3_stmt    *statement = NULL;
        NSString *qry = [NSString stringWithFormat:@"select count(*) from %@", queryString];
        [self addQueryToConsole:[NSString stringWithFormat:@"%@\n", queryString]];

        if (sqlite3_prepare_v2(fdb, [qry UTF8String], -1, &statement, NULL) == SQLITE_OK)
        {
            while (sqlite3_step(statement) == SQLITE_ROW)
            {
                numOfRows = sqlite3_column_int(statement, 0);
            }
            sqlite3_finalize(statement);
        }
    }
    sqlite3_close(fdb);
    return numOfRows;
}

- (void) loadAndDisplayTable:(NSString *)tableName offset:(int)offset limit:(int)limit
{
    if (!tableName)
        return;

    NSString *query = [NSString stringWithFormat:@"SELECT * FROM %@ ORDER BY rowid LIMIT %d OFFSET %d", tableName, limit, offset];
    [self loadAndDisplayTableWithQuery:query];
}

- (void) setResultsTableHeadersWithTitle:(sqlite3_stmt *)statement
{
    for(int i=0; i<sqlite3_column_count(statement); i++)
    {
        const char *name = sqlite3_column_name(statement, i);
        NSString *identifier = [[NSString alloc] initWithFormat:@"%s",name];

        NSTableColumn *col1 = [[NSTableColumn alloc] initWithIdentifier:identifier];
        [[col1 headerCell] setStringValue: identifier];
        [[col1 headerCell] setRepresentedObject:identifier];

        [self.mainTable addTableColumn:col1];
    }
}

- (void) setResultsTableBody:(sqlite3_stmt *)statement
{
    while (sqlite3_step(statement) == SQLITE_ROW)
    {
        NSMutableDictionary *data = [NSMutableDictionary dictionary];
        for(int i=0; i<sqlite3_column_count(statement); i++)
        {
            const char *name = sqlite3_column_name(statement, i);
            NSString *identifier = [[NSString alloc] initWithFormat:@"%s",name];
            [data setObject:[self getValue:statement index:i] forKey:identifier];
        }
        [_arrayOfData addObject:data];
    }
}

- (sqlite3 *) openDatabase
{
    sqlite3 *fdb;
    const char *dbpath = [_databaseFileName UTF8String];
    int ret = sqlite3_open(dbpath, &fdb);
    if (ret != SQLITE_OK)
    {
        [self addErrorMessageToConsole:[NSString stringWithFormat:@"%s\n", sqlite3_errmsg(fdb)]];
        sqlite3_close(fdb);
        fdb = NULL;
    }
    return fdb;
}

- (void) loadAndDisplayTableWithQuery:(NSString *)query
{
    [self addQueryToConsole:[NSString stringWithFormat:@"%@\n", query]];
    for (int x= (int)self.mainTable.tableColumns.count-1; x>= 0; x--)
    {
        NSTableColumn *obj = [[self.mainTable tableColumns] objectAtIndex:x];
        [self.mainTable removeTableColumn:obj];
    }
    
    [_arrayOfData removeAllObjects];
    [self.mainTable reloadData];
    
    sqlite3 *fdb = [self openDatabase];
    if (fdb != NULL)
    {
        sqlite3_stmt    *statement = NULL;
        int status = sqlite3_prepare_v2(fdb, [query UTF8String], -1, &statement, NULL);
        if (status == SQLITE_OK)
        {
            [self setResultsTableHeadersWithTitle:statement];
            [self setResultsTableBody:statement];
            sqlite3_finalize(statement);
        }
        else
        {
            [self addErrorMessageToConsole:[NSString stringWithFormat:@"%s\n", sqlite3_errmsg(fdb)]];
        }
    }
    sqlite3_close(fdb);
    [self.mainTable reloadData];
}

- (id) getValue:(sqlite3_stmt *)stmt index:(int)ind
{
    //TODO: should check for type, i.e., blob? then give options for preview... image, audio.. etc
    const char *cname =  (const char *) sqlite3_column_text(stmt, ind);
    return [[NSString alloc] initWithBytes:cname length:strlen(cname) encoding:NSUTF8StringEncoding];
}

#pragma mark - Left outline view Datasource & delegates
- (NSInteger)outlineView:(NSOutlineView *)outlineView numberOfChildrenOfItem:(id)item
{
    if(item == nil)  return _leftOutline.count;
    return [[_leftOutline objectAtIndex:[_sideTableTitles indexOfObject:item]] count];
}

- (BOOL)outlineView:(NSOutlineView *)outlineView isItemExpandable:(id)item
{
    return [_sideTableTitles containsObject:item];
}

- (id)outlineView:(NSOutlineView *)outlineView child:(NSInteger)index ofItem:(id)item
{
    if (item == nil)
        return [_sideTableTitles objectAtIndex:index];
    else
    {
        return [[_leftOutline objectAtIndex:[_sideTableTitles indexOfObject:item]] objectAtIndex:index];
    }
}

- (id)outlineView:(NSOutlineView *)outlineView objectValueForTableColumn:(NSTableColumn *)tableColumn byItem:(id)item
{
    return (item == nil) ?  @"" : item;
}

- (BOOL)outlineView:(NSOutlineView *)outlineView shouldEditTableColumn:(NSTableColumn *)tableColumn item:(id)item
{
    return NO;
}


- (void)outlineViewSelectionDidChange:(NSNotification *)notification
{
    NSOutlineView *ov = notification.object;
    NSString *item = [ov itemAtRow:ov.selectedRow];
    NSString *parent = [ov parentForItem:item];
    
    if (parent != nil && [parent isEqualToString:[_sideTableTitles objectAtIndex:0]])
    {
        _lastTableToBeClicked = item;
        [self loadAndDisplayTable: item offset:0 limit:kNumOffset];
    }
    else if ([@"table" isEqualToString:[item lowercaseString]] || [@"index" isEqualToString:[item lowercaseString]] || [@"view" isEqualToString:[item lowercaseString]])
    {
        [self loadAndDisplayTableWithQuery:[NSString stringWithFormat:@"select * from sqlite_master where type like '%@'", item]];
    }
}

#pragma mark - Query textview
- (BOOL)textView:(NSTextView *)aTextView doCommandBySelector:(SEL)aSelector
{
    if (aSelector == @selector(insertNewline:))
    {
        [self executeBtnClicked:nil];
        return YES;
    }
    else if (aSelector == @selector(insertNewlineIgnoringFieldEditor:))
    {
        [[aTextView textStorage] appendAttributedString:[[NSAttributedString alloc] initWithString:@"\n"]];
        return YES;
    }
    return NO;
}

@end