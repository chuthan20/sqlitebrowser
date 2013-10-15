//
//  Document.m
//  SQLiteBrowser
//
//  Created by Archuthan Vijayaratnam on 2012-10-27.
//  Copyright (c) 2012 Archuthan Vijayaratnam. All rights reserved.
//

#import "Document.h"
#include <sqlite3.h>

static int kNumOffset = 100;

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
    recentSearches = [NSMutableArray arrayWithObjects:@"sqlite_master ", @"select ",@"from ",@"where ",@"union ",@"update ",@"delete ",@"drop ",@"table ",@"explain ",@"set ",@"count ",@"order by ",@"limit ",@"offset ",@"rowid ", nil];
    _mainTable.rowHeight = 22;
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
/*
- (BOOL)loadDataRepresentation:(NSData *)data ofType:(NSString *)type
{
    NSError *error;
    NSLog(@"AAAAAAAAAAA %@", error);
    return [self readFromData:data ofType:type error:&error];
}

- (NSString *)uuidString {
    // Returns a UUID
    
    CFUUIDRef uuid = CFUUIDCreate(kCFAllocatorDefault);
    NSString *uuidStr = (__bridge_transfer NSString *)CFUUIDCreateString(kCFAllocatorDefault, uuid);
    CFRelease(uuid);
    
    return uuidStr;
}


- (BOOL)readFromData:(NSData *)data ofType:(NSString *)typeName error:(NSError *__autoreleasing *)outError
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    NSString *cache = [paths objectAtIndex:0] ;
    
    NSString *filepath = [NSString stringWithFormat:@"%@/%@", cache, [self uuidString]];
    
    NSLog(@"BBBBBBBBBB");
    NSLog(@"AAAAAAAAAAA %@, \r%@", cache, filepath);
    
    NSError *error;
    [data writeToFile:filepath options:NSDataWritingWithoutOverwriting error:&error];
    
    NSLog(@"AAAAAAAAAAA %@ %@", cache, error);
    
    return [self readFromURL:[NSURL URLWithString:filepath] ofType:typeName error:NULL];
}
 */

- (BOOL)readFromURL:(NSURL *)url ofType:(NSString *)typeName error:(NSError *__autoreleasing *)outError
{
    databaseFileName = url.path;
    return YES;
}

- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView {
    NSLog(@"%s", __PRETTY_FUNCTION__);
    if (tableView == self.mainTable)
        return arrayOfData.count;
    return 0;
}

- (CGFloat)tableView:(NSTableView *)tableView sizeToFitWidthOfColumn:(NSInteger)column
{
    NSLog(@"%s", __PRETTY_FUNCTION__);
    NSTableColumn *c =  (NSTableColumn *)[tableView.tableColumns objectAtIndex:column];
    CGFloat maxWidth = 0.0f;
    
   NSInteger rows = [tableView numberOfRows];
    NSDictionary *attributes = [NSDictionary dictionaryWithObjectsAndKeys:[NSFont systemFontOfSize:13], NSFontAttributeName, nil];
    for (int i=0; i<rows; i++)
    {
        NSString *strValue = [[arrayOfData objectAtIndex:i] objectForKey:c.identifier];
        NSSize labelSize = [strValue sizeWithAttributes:attributes];
        maxWidth = MAX(labelSize.width + 10, maxWidth);
    }
    return maxWidth;
}

- (id)tableView:(NSTableView *)tableView objectValueForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row
{
    NSLog(@"%s", __PRETTY_FUNCTION__);
   if ([tableView isEqualTo:self.mainTable])
    {
        NSString *strValue = [[arrayOfData objectAtIndex:row] objectForKey:tableColumn.identifier];
        return strValue;
    }
    return nil;
}


- (IBAction)loadBtnClicked:(id)sender
{
    lastTableToBeClicked = @"sqlite_master";
    [self loadAndDisplayTable:lastTableToBeClicked offset:0 limit:kNumOffset];
    [self loadAndDisplayLeftTable];
}

- (IBAction)executeBtnClicked:(id)sender {
    NSString *stmt = self.stmtQueryField.value;
    [recentSearches addObject:stmt];
    [self loadAndDisplayTableWithQuery:stmt];
}

- (IBAction)pagingStepperClicked:(NSStepper *)sender {
    [self.pagingTextField setIntValue:sender.intValue];
    [self loadAndDisplayTable:lastTableToBeClicked offset:0 limit:kNumOffset];
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
            [leftOutline addObject:tbls];
            [leftOutline addObject:views];
            [leftOutline addObject:indices];
            
            sqlite3_finalize(statement);
        }
    }
    sqlite3_close(fdb);
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
    NSLog(@"%@ = %d", queryString, numOfRows);

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
        NSString *query = [NSString stringWithFormat:@"SELECT * FROM %@ ORDER BY rowid LIMIT %d OFFSET %d", tableName, limit, offset];
        NSLog(@"%@", query);
        
        if (sqlite3_prepare_v2(fdb, [query UTF8String], -1, &statement, NULL) == SQLITE_OK)
        {
            int count = sqlite3_column_count(statement);
            for(int i=0; i<count; i++)
            {
                NSTableColumn *col1 = [[NSTableColumn alloc] initWithIdentifier:[NSString stringWithFormat:@"%d", i]];
                const char *name = sqlite3_column_name(statement, i);
                [[col1 headerCell] setStringValue: [NSString stringWithFormat:@"%s", name]];
                [[col1 headerCell] setRepresentedObject:[NSString stringWithUTF8String:name]];
                [self.mainTable addTableColumn:col1];
            }
            
            while (sqlite3_step(statement) == SQLITE_ROW)
            {
                NSMutableDictionary *data = [NSMutableDictionary dictionary];
                for(int i=0; i<count; i++)
                {
                    [data setObject:[self getValue:statement index:i] forKey:[NSString stringWithFormat:@"%d", i]];
                }
                NSLog(@"%@" , data);
                [arrayOfData addObject:data];
            }
            sqlite3_finalize(statement);
        }
    }
    sqlite3_close(fdb);
    
    
    [self.mainTable reloadData];
    
    [self.pagingTextField setIntValue:self.pagingStepper.intValue];
}


- (void) loadAndDisplayTableWithQuery:(NSString *)query
{
    if (!query)
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
//        NSString *query = [NSString stringWithFormat:query];
        NSLog(@"%@", query);
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
    
//    [self.pagingTextField setIntValue:self.pagingStepper.intValue];
}

- (id) getValue:(sqlite3_stmt *)stmt index:(int)ind
{
    const char *cname =  (const char *) sqlite3_column_text(stmt, ind);
    if (cname != NULL)
    {
        NSString *str = [[NSString alloc] initWithUTF8String:cname];
        if (str)
            return str;
        else
        {
            return [NSString stringWithFormat:@"%s", (const char *) sqlite3_column_text(stmt, ind)];
        }
    }
    return @"-";
}

- (NSInteger)outlineView:(NSOutlineView *)outlineView numberOfChildrenOfItem:(id)item {
    NSLog(@"%s %@", __PRETTY_FUNCTION__, item);
    if(item == nil)  return leftOutline.count;
    return [[leftOutline objectAtIndex:[sideTableTitles indexOfObject:item]] count];
}

- (BOOL)outlineView:(NSOutlineView *)outlineView isItemExpandable:(id)item {
    NSLog(@"%s %@ %@", __PRETTY_FUNCTION__, item, [sideTableTitles containsObject:item]? @"YES":@"NO");
    return [sideTableTitles containsObject:item];
}

- (id)outlineView:(NSOutlineView *)outlineView child:(NSInteger)index ofItem:(id)item {
    NSLog(@"%s %@", __PRETTY_FUNCTION__, item);
    if (item == nil)
        return [sideTableTitles objectAtIndex:index];
    else
    {
        NSLog(@"%@" , @"AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA");
        NSLog(@"%@" , [[leftOutline objectAtIndex:[sideTableTitles indexOfObject:item]] objectAtIndex:index]);
        NSLog(@"%@" , @"AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA");

        return [[leftOutline objectAtIndex:[sideTableTitles indexOfObject:item]] objectAtIndex:index];
    }
}

- (id)outlineView:(NSOutlineView *)outlineView objectValueForTableColumn:(NSTableColumn *)tableColumn byItem:(id)item
{
    NSLog(@"%s %@", __PRETTY_FUNCTION__, item);
    return (item == nil) ?  @"" : item;
}

- (void)outlineViewSelectionDidChange:(NSNotification *)notification
{
    NSLog(@"%s", __PRETTY_FUNCTION__);
    NSOutlineView *ov = notification.object;
    NSString *item = [ov itemAtRow:ov.selectedRow];
    NSString *parent = [ov parentForItem:item];
    
    if ([parent isEqualToString:[sideTableTitles objectAtIndex:0]])
    {
        lastTableToBeClicked = item;
        [self loadAndDisplayTable: item offset:0 limit:kNumOffset];
    }
}

- (IBAction)toolbarItemClicked:(NSToolbarItem *)sender {
    NSLog(@"%s %@", __PRETTY_FUNCTION__, sender.label);
    if ([@"execute" isEqualToString:[sender.label lowercaseString]])
    {
        [self executeBtnClicked:nil];
    }
    else if ([@"reset" isEqualToString:[sender.label lowercaseString]])
    {
        [self loadBtnClicked:nil];
    }
}

@end
