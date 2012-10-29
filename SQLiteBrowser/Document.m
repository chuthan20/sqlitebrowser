//
//  Document.m
//  SQLiteBrowser
//
//  Created by Archuthan Vijayaratnam on 2012-10-27.
//  Copyright (c) 2012 Archuthan Vijayaratnam. All rights reserved.
//

#import "Document.h"
#import "sqlite3.h"


@interface Document ()
{
    NSMutableArray *arrayOfData;
    NSMutableArray *leftData;
    
    NSString *databaseFileName;
    
    NSMutableArray *leftOutline;
}

@end

@implementation Document

- (id)init
{
    self = [super init];
    if (self) {
        // Add your subclass-specific initialization here.
    }
    return self;
}

- (NSString *)windowNibName
{
    // Override returning the nib file name of the document
    // If you need to use a subclass of NSWindowController or if your document supports multiple NSWindowControllers, you should remove this method and override -makeWindowControllers instead.
    return @"Document";
}

- (void)windowControllerDidLoadNib:(NSWindowController *)aController
{
    [super windowControllerDidLoadNib:aController];
    // Add any code here that needs to be executed once the windowController has loaded the document's window.
    
    arrayOfData = [NSMutableArray array];
    leftData = [NSMutableArray array];
    
    leftOutline = [NSMutableArray array];
    
//    databaseFileName = nil;
    
    
    self.pagingStepper.maxValue = 0.f;
    self.pagingStepper.minValue = 0.f;

    if (databaseFileName)
    {
        [self loadBtnClicked:nil];
    }
}

+ (BOOL)autosavesInPlace
{
    return YES;
}

- (NSData *)dataOfType:(NSString *)typeName error:(NSError **)outError
{
    // Insert code here to write your document to data of the specified type. If outError != NULL, ensure that you create and set an appropriate error when returning nil.
    // You can also choose to override -fileWrapperOfType:error:, -writeToURL:ofType:error:, or -writeToURL:ofType:forSaveOperation:originalContentsURL:error: instead.
    NSException *exception = [NSException exceptionWithName:@"UnimplementedMethod" reason:[NSString stringWithFormat:@"%@ is unimplemented", NSStringFromSelector(_cmd)] userInfo:nil];
    @throw exception;
    return nil;
}

- (BOOL)readFromURL:(NSURL *)url ofType:(NSString *)typeName error:(NSError *__autoreleasing *)outError
{
    NSLog(@"%@", url.path);
    databaseFileName = url.path;
    return YES;
}

//- (BOOL)readFromData:(NSData *)data ofType:(NSString *)typeName error:(NSError **)outError
//{
//    NSLog(@"%@", typeName);
//    
//    // Insert code here to read your document from the given data of the specified type. If outError != NULL, ensure that you create and set an appropriate error when returning NO.
//    // You can also choose to override -readFromFileWrapper:ofType:error: or -readFromURL:ofType:error: instead.
//    // If you override either of these, you should also override -isEntireFileLoaded to return NO if the contents are lazily loaded.
////    NSException *exception = [NSException exceptionWithName:@"UnimplementedMethod" reason:[NSString stringWithFormat:@"%@ is unimplemented", NSStringFromSelector(_cmd)] userInfo:nil];
////    @throw exception;
//    return YES;
//}



- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView {
    if ([tableView isEqualTo:self.mainTable])
        return arrayOfData.count;
    return 0;
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
    
    if ([tableView isEqualTo:self.mainTable])
    {
        result.stringValue = [[arrayOfData objectAtIndex:row] objectForKey:tableColumn.identifier];
        
    }
    
    // return the result.
    return result;
    
}

- (IBAction)loadBtnClicked:(id)sender
{
    [self loadAndDisplayTable:[NSString stringWithFormat:@"SELECT rowid,* FROM %@", @"sqlite_master"]];
    [self loadAndDisplayLeftTable];
}
- (IBAction)executeBtnClicked:(id)sender {
    NSString *stmt = self.stmtField.stringValue;
    
    [self loadAndDisplayTable:stmt];
    
}

- (IBAction)pagingStepperClicked:(NSStepper *)sender {
    [self.pagingTextField setIntValue:sender.intValue];
    
//    if ([_leftTableView isRowSelected:_leftTableView.selectedRow])
//    {
//        NSLog(@"%@", [leftData objectAtIndex:_leftTableView.selectedRow]);
//        [self loadAndDisplayTable:[NSString stringWithFormat:@"SELECT rowid,* FROM %@ LIMIT 15 OFFSET %d", [leftData objectAtIndex:_leftTableView.selectedRow], sender.intValue * 15]];
//    }
}


- (void) loadAndDisplayLeftTable
{
    [leftData removeAllObjects];
    
    [leftData addObject:@"sqlite_master"];
    sqlite3_stmt    *statement;
    sqlite3 *fdb;
    NSString *databasePath = databaseFileName;
    
    [[NSFileManager defaultManager] fileExistsAtPath:databasePath] ? NSLog(@"File Exists") : NSLog(@"File DOES NOT Exists");
    
    const char *dbpath = [databasePath UTF8String];
    
    
    int ret = sqlite3_open(dbpath, &fdb);
    if (ret == SQLITE_OK)
    {
        NSString *query = @"SELECT tbl_name, type FROM sqlite_master";
        if (sqlite3_prepare_v2(fdb, [query UTF8String], -1, &statement, NULL) == SQLITE_OK)
        {
            
            NSMutableArray *tbls = [NSMutableArray array];
            NSMutableArray *views = [NSMutableArray array];
            NSMutableArray *indices = [NSMutableArray array];
            
            while (sqlite3_step(statement) == SQLITE_ROW)
            {
                const char *cname =  (const char *) sqlite3_column_text(statement, 0);
                if (cname == NULL)
                {
                    cname = "nil";
                }
                NSString *name = [NSString stringWithUTF8String:cname];

                const char *ctype =  (const char *) sqlite3_column_text(statement, 1);
                if (ctype == NULL)
                {
                    ctype = "nil";
                }
                NSString *type = [[NSString stringWithUTF8String:ctype] lowercaseString];
                
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
                
                NSLog(@" %@ %@", name, type);
                [leftData addObject:name];
                
            }
            [leftOutline addObject:tbls];
            [leftOutline addObject:views];
            [leftOutline addObject:indices];
            
            sqlite3_finalize(statement);
        }
    }
    sqlite3_close(fdb);
//    [_leftOutlineView reloadData];
}

- (int) getCount:(NSString *)queryString
{
    sqlite3_stmt    *statement;
    sqlite3 *fdb;
    NSString *databasePath = databaseFileName;
    
    [[NSFileManager defaultManager] fileExistsAtPath:databasePath] ? NSLog(@"File Exists") : NSLog(@"File DOES NOT Exists");
    
    const char *dbpath = [databasePath UTF8String];
    int numOfRows = -1;
    int ret = sqlite3_open(dbpath, &fdb);
    if (ret == SQLITE_OK)
    {
        NSString *qry = [NSString stringWithFormat:@"select count(*) from %@", queryString];
        if (sqlite3_prepare_v2(fdb, [qry UTF8String], -1, &statement, NULL) == SQLITE_OK)
        {
            while (sqlite3_step(statement) == SQLITE_ROW)
            {
                numOfRows = sqlite3_column_int(statement, 0);
                NSLog(@"%@ = %d", queryString, numOfRows);
            }
            sqlite3_finalize(statement);
        }
    }
    sqlite3_close(fdb);
    return numOfRows;
}

- (void) loadAndDisplayTable:(NSString *)tableName
{
    if (!tableName)
        return;
    for (int x= (int)self.mainTable.tableColumns.count-1; x>= 0; x--)
    {
        NSTableColumn *obj = [[self.mainTable tableColumns] objectAtIndex:x];
        [self.mainTable removeTableColumn:obj];
    }
    
    [arrayOfData removeAllObjects];
    [self.mainTable reloadData];
    sqlite3_stmt    *statement;
    sqlite3 *fdb;
    NSString *databasePath = databaseFileName;
    
    [[NSFileManager defaultManager] fileExistsAtPath:databasePath] ? NSLog(@"File Exists") : NSLog(@"File DOES NOT Exists");
    
    const char *dbpath = [databasePath UTF8String];
    
    
    int ret = sqlite3_open(dbpath, &fdb);
    if (ret == SQLITE_OK)
    {
        NSString *query = tableName;
        if (sqlite3_prepare_v2(fdb, [query UTF8String], -1, &statement, NULL) == SQLITE_OK)
        {
            for(int i=1; i<sqlite3_column_count(statement); i++)
            {
                NSLog(@"%@", [NSString stringWithUTF8String:sqlite3_column_name(statement, i)]);
                NSTableColumn *col1 = [[NSTableColumn alloc] initWithIdentifier:[NSString stringWithFormat:@"%d", i]];
                
                
                [[col1 headerCell] setStringValue:[NSString stringWithUTF8String:sqlite3_column_name(statement, i)]];
                [self.mainTable addTableColumn:col1];
            }
            
            while (sqlite3_step(statement) == SQLITE_ROW)
            {
                NSMutableDictionary *data = [NSMutableDictionary dictionary];
                for(int i=0; i<sqlite3_column_count(statement); i++)
                {
                    [data setObject:[self getValue:statement index:i] forKey:[NSString stringWithFormat:@"%d", i]];
                }
                [arrayOfData addObject:data];
            }
            sqlite3_finalize(statement);
        }
    }
    sqlite3_close(fdb);
    [self.mainTable reloadData];
    
    [self.pagingTextField setIntValue:self.pagingStepper.intValue];

}



- (id) getValue:(sqlite3_stmt *)stmt index:(int)ind
{
    const char *ctype = sqlite3_column_decltype(stmt, ind);
    if (ctype == NULL)
        return @"nil";
    
    NSString *type = [[NSString stringWithUTF8String:ctype] lowercaseString];
    if ([type isEqualToString:@"text"])
    {
        const char *cname =  (const char *) sqlite3_column_text(stmt, ind);
        if (cname == NULL)
            return @"null";
        NSString *name = [NSString stringWithUTF8String:cname];
        return name;
    }
    else if ([type isEqualToString:@"integer"])
    {
        int num = sqlite3_column_int(stmt, ind);
        return [NSString stringWithFormat:@"%d", num];
    }
    return @"nil";
}

- (NSInteger)outlineView:(NSOutlineView *)outlineView numberOfChildrenOfItem:(id)item {
    if(item == nil)  return leftOutline.count;
    
    if ([item isEqualToString:@"Tables"])
    {
        return [[leftOutline objectAtIndex:0] count];
    }
    else if ([item isEqualToString:@"View"])
    {
        return [[leftOutline objectAtIndex:1] count];
    }
    else if ([item isEqualToString:@"Indices"])
    {
        return [[leftOutline objectAtIndex:2] count];
    }
    return 0;
}

- (BOOL)outlineView:(NSOutlineView *)outlineView isItemExpandable:(id)item {
    if ([item isEqualToString:@"Tables"])
    {
        return YES;
    }
    else if ([item isEqualToString:@"View"])
    {
        return YES;
    }
    else if ([item isEqualToString:@"Indices"])
    {
        return YES;
    }

    return NO;
}

- (id)outlineView:(NSOutlineView *)outlineView child:(NSInteger)index ofItem:(id)item {
    if (item == nil)
    {
        if (index == 0)
        {
            return @"Tables";
        }
        else if (index == 1)
        {
            return @"View";
        }
        else if (index == 2)
        {
            return @"Indices";
        }
    }
    else
    {
        if ([item isEqualToString:@"Tables"])
        {
            return [[leftOutline objectAtIndex:0] objectAtIndex:index];
        }
        else if ([item isEqualToString:@"View"])
        {
            return [[leftOutline objectAtIndex:1] objectAtIndex:index];
        }
        else if ([item isEqualToString:@"Indices"])
        {
            return [[leftOutline objectAtIndex:2] objectAtIndex:index];
        }
    }
    
    return (item == nil) ? [leftOutline objectAtIndex:index] : [[leftOutline objectAtIndex:[leftOutline indexOfObject:item]] objectAtIndex:index];
}

- (id)outlineView:(NSOutlineView *)outlineView objectValueForTableColumn:(NSTableColumn *)tableColumn byItem:(id)item {
    return (item == nil) ?  @"dddaaa" : item;
}

- (void)outlineViewSelectionDidChange:(NSNotification *)notification
{
    NSOutlineView *ov = notification.object;
    NSString *item = [ov itemAtRow:ov.selectedRow];
    NSString *parent = [ov parentForItem:item];
    
    if ([parent isEqualToString:@"Tables"])
    {
        [self loadAndDisplayTable:[NSString stringWithFormat:@"SELECT rowid,* FROM %@  LIMIT 15 OFFSET 0", item]];
    }
}

- (IBAction)addBtnClicked:(id)sender {
    
}

- (IBAction)removeBtnClicked:(id)sender {
    
    NSOutlineView *ov = self.leftOutlineView;
    NSString *item = [ov itemAtRow:ov.selectedRow];
//    NSString *parent = [ov parentForItem:item];
    
    NSLog(@"%@", [arrayOfData objectAtIndex:self.mainTable.selectedRow]);
    
    NSMutableDictionary *dict = [arrayOfData objectAtIndex:self.mainTable.selectedRow];
    int rowNum = [[dict objectForKey:@"0"] intValue];

    sqlite3 *fdb;
    NSString *databasePath = databaseFileName;
    
    [[NSFileManager defaultManager] fileExistsAtPath:databasePath] ? NSLog(@"File Exists") : NSLog(@"File DOES NOT Exists");
    
    const char *dbpath = [databasePath UTF8String];
    int ret = sqlite3_open(dbpath, &fdb);
    if (ret == SQLITE_OK)
    {
        char *errMsg;

        NSString *qry = [NSString stringWithFormat:@"DELETE FROM %@ WHERE rowid = %d", item, rowNum];
        if (sqlite3_exec(fdb, [qry UTF8String], NULL, NULL, &errMsg) == SQLITE_OK)
        {
            [arrayOfData removeObject:dict];
            [self.mainTable reloadData];
            NSLog(@"SUCCESSFULLY REMOVED");
        }
    }
    sqlite3_close(fdb);
}
@end
