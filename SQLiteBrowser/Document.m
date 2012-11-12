//
//  Document.m
//  SQLiteBrowser
//
//  Created by Archuthan Vijayaratnam on 2012-10-27.
//  Copyright (c) 2012 Archuthan Vijayaratnam. All rights reserved.
//

#import "Document.h"
#import "sqlite3.h"

<<<<<<< HEAD
static int kNumOffset = 100;
=======
static int kMaxLimit = 100;
>>>>>>> ba0c7fca09d71ade5e601d2e541feb4af69538cd

@interface Document ()
{
    NSMutableArray *arrayOfData;
    
    NSString *databaseFileName;
    
    NSMutableArray *leftOutline;
    
    NSString *lastTableToBeClicked;
    int rowIdOfLastItemClicked;
    
    
    NSArray *sideTableTitles;
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
    return @"Document";
}

- (void)windowControllerDidLoadNib:(NSWindowController *)aController
{
    [super windowControllerDidLoadNib:aController];
    
    arrayOfData = [NSMutableArray array];

    
    leftOutline = [NSMutableArray array];

    self.pagingStepper.maxValue = 0.f;
    self.pagingStepper.minValue = 0.f;

    if (databaseFileName)
    {
        [self loadBtnClicked:nil];
    }
    
    sideTableTitles = @[@"Table", @"View", @"Index"] ;
}

+ (BOOL)autosavesInPlace
{
    return YES;
}

- (NSData *)dataOfType:(NSString *)typeName error:(NSError **)outError
{
    NSException *exception = [NSException exceptionWithName:@"UnimplementedMethod" reason:[NSString stringWithFormat:@"%@ is unimplemented", NSStringFromSelector(_cmd)] userInfo:nil];
    @throw exception;
    return nil;
}

- (BOOL)readFromURL:(NSURL *)url ofType:(NSString *)typeName error:(NSError *__autoreleasing *)outError
{
    databaseFileName = url.path;
    return YES;
}

- (CGFloat)tableView:(NSTableView *)tableView heightOfRow:(NSInteger)row
{
    return 40;
}

- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView {
    if ([tableView isEqualTo:self.mainTable])
        return arrayOfData.count;
    return 0;
}

- (NSView *)tableView:(NSTableView *)tableView viewForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row {
    NSTextField *result = [tableView makeViewWithIdentifier:@"MyView" owner:self];
    if (result == nil) {
        result = [[NSTextField alloc] initWithFrame:NSMakeRect(0, 0, 200, tableView.rowHeight)];
        [result setBackgroundColor:[NSColor clearColor]];
        [result setBezeled:NO];
        [result setDrawsBackground:NO];
        result.identifier = @"MyView";
    }
//    [result setEditable:YES];
    
    if ([tableView isEqualTo:self.mainTable])
    {
        NSString *strValue = [[arrayOfData objectAtIndex:row] objectForKey:tableColumn.identifier];
        result.stringValue = strValue ? strValue : @"";
        [result setToolTip:[tableColumn.headerCell representedObject]];
    }
    return result;
    
}

- (IBAction)loadBtnClicked:(id)sender
{
    lastTableToBeClicked = @"sqlite_master";
<<<<<<< HEAD
    [self loadAndDisplayTable:lastTableToBeClicked offset:0 limit:kNumOffset];

=======
    [self loadAndDisplayTable:lastTableToBeClicked offset:0 limit:kMaxLimit];
>>>>>>> ba0c7fca09d71ade5e601d2e541feb4af69538cd
    [self loadAndDisplayLeftTable];
}
- (IBAction)executeBtnClicked:(id)sender {
    NSString *stmt = self.stmtField.stringValue;
<<<<<<< HEAD
    
    
//    [self loadAndDisplayTable:stmt];
    
=======
    [self loadAndDisplayTable:stmt offset:0 limit:1];
>>>>>>> ba0c7fca09d71ade5e601d2e541feb4af69538cd
}

- (IBAction)pagingStepperClicked:(NSStepper *)sender {
    [self.pagingTextField setIntValue:sender.intValue];
<<<<<<< HEAD
    
    [self loadAndDisplayTable:lastTableToBeClicked offset:0 limit:kNumOffset];

    
//    if ([_leftTableView isRowSelected:_leftTableView.selectedRow])
//    {
//        NSLog(@"%@", [leftData objectAtIndex:_leftTableView.selectedRow]);
//        [self loadAndDisplayTable:[NSString stringWithFormat:@"SELECT rowid,* FROM %@ LIMIT 15 OFFSET %d", [leftData objectAtIndex:_leftTableView.selectedRow], sender.intValue * 15]];
//    }
=======
    [self loadAndDisplayTable:lastTableToBeClicked offset:kMaxLimit*sender.intValue limit:kMaxLimit];
>>>>>>> ba0c7fca09d71ade5e601d2e541feb4af69538cd
}


- (void) loadAndDisplayLeftTable
{
    
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
<<<<<<< HEAD
        NSString *query = [NSString stringWithFormat:@"SELECT rowid,* FROM %@", tableName];
=======
        NSString *query = [NSString stringWithFormat:@"SELECT * FROM %@ ORDER BY rowid LIMIT %d OFFSET %d", tableName, limit, offset];
        NSLog(@"%@", query);
>>>>>>> ba0c7fca09d71ade5e601d2e541feb4af69538cd
        if (sqlite3_prepare_v2(fdb, [query UTF8String], -1, &statement, NULL) == SQLITE_OK)
        {
            for(int i=0; i<sqlite3_column_count(statement); i++)
            {
                NSTableColumn *col1 = [[NSTableColumn alloc] initWithIdentifier:[NSString stringWithFormat:@"%d", i]];
                sqlite3_column_value(statement, i);
                const char *name = sqlite3_column_name(statement, i);
                const char *type = sqlite3_column_decltype(statement, i);
                
                if (name == NULL)
                    name = "-";
                if (type == NULL)
                    type = "-";

                [[col1 headerCell] setStringValue: [NSString stringWithFormat:@"%@%@",[NSString stringWithUTF8String:name], @""]];//[[NSString stringWithUTF8String:type] uppercaseString]]];
                [[col1 headerCell] setRepresentedObject:[NSString stringWithUTF8String:name]];
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
    const char *cname =  (const char *) sqlite3_column_text(stmt, ind);
    if (cname != NULL)
        return [NSString stringWithUTF8String:cname];
    return @"NULL";
}

- (NSInteger)outlineView:(NSOutlineView *)outlineView numberOfChildrenOfItem:(id)item {
    if(item == nil)  return leftOutline.count;
    return [[leftOutline objectAtIndex:[sideTableTitles indexOfObject:item]] count];
}

- (BOOL)outlineView:(NSOutlineView *)outlineView isItemExpandable:(id)item {
    return [sideTableTitles containsObject:item];
}

- (id)outlineView:(NSOutlineView *)outlineView child:(NSInteger)index ofItem:(id)item {
    if (item == nil)
        return [sideTableTitles objectAtIndex:index];
    else
        return [[leftOutline objectAtIndex:[sideTableTitles indexOfObject:item]] objectAtIndex:index];
}

- (id)outlineView:(NSOutlineView *)outlineView objectValueForTableColumn:(NSTableColumn *)tableColumn byItem:(id)item
{
    return (item == nil) ?  @"dddaaa" : item;
}

- (void)outlineViewSelectionDidChange:(NSNotification *)notification
{
    NSOutlineView *ov = notification.object;
    NSString *item = [ov itemAtRow:ov.selectedRow];
    NSString *parent = [ov parentForItem:item];
    
    if ([parent isEqualToString:[sideTableTitles objectAtIndex:0]])
    {
        lastTableToBeClicked = item;
<<<<<<< HEAD
        [self loadAndDisplayTable: item offset:0 limit:kNumOffset];
    }
}

- (IBAction)addBtnClicked:(id)sender {
    NSLog(@"%@", [arrayOfData lastObject]);
    
    NSMutableDictionary *dictionary = [NSMutableDictionary dictionary];
    [_mainTable.tableColumns enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        NSTableColumn *c = obj;
        NSString *key = [c.headerCell representedObject];
        NSLog(@"key = %@", key);
        [dictionary setObject:[NSNull null] forKey:c.identifier];
    }];
    [arrayOfData addObject:dictionary];
    [_mainTable reloadData];
    
//    [self insert:dictionary intoTable:lastTableToBeClicked];
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
=======
        int totalCount = [self getCount:item];
        self.pagingStepper.maxValue = 1.0 *(totalCount/kMaxLimit);
        [self loadAndDisplayTable:item offset:0 limit:kMaxLimit];
>>>>>>> ba0c7fca09d71ade5e601d2e541feb4af69538cd
    }
}

@end
