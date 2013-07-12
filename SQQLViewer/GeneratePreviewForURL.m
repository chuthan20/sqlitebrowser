#include <CoreFoundation/CoreFoundation.h>
#include <CoreServices/CoreServices.h>
#include <QuickLook/QuickLook.h>
#import <Cocoa/Cocoa.h>
#import <sqlite3.h>


#define CSS_STYLE "\
<style>                                 \
table                            \
{                                     \
    border-collapse:collapse;         \
}                                           \
table, td, th                                   \
{                                           \
    border:1px solid black;                     \
}                                                   \
</style>"


OSStatus GeneratePreviewForURL(void *thisInterface, QLPreviewRequestRef preview, CFURLRef url, CFStringRef contentTypeUTI, CFDictionaryRef options);
void CancelPreviewGeneration(void *thisInterface, QLPreviewRequestRef preview);

/* -----------------------------------------------------------------------------
   Generate a preview for file

   This function's job is to create preview for designated file
   ----------------------------------------------------------------------------- */

OSStatus GeneratePreviewForURL(void *thisInterface, QLPreviewRequestRef preview, CFURLRef url, CFStringRef contentTypeUTI, CFDictionaryRef options)
{
    // To complete your generator please implement the function GeneratePreviewForURL in GeneratePreviewForURL.c
    
    NSURL *nsurl = (__bridge NSURL *)url;
    
    
    sqlite3_stmt    *statement;
    sqlite3 *fdb;
    NSString *databasePath = nsurl.path;
    
    [[NSFileManager defaultManager] fileExistsAtPath:databasePath] ? NSLog(@"File Exists") : NSLog(@"File DOES NOT Exists");
    
    const char *dbpath = [databasePath UTF8String];
    
    NSMutableArray *keys = [[NSMutableArray alloc] init];
    NSMutableArray *data = [[NSMutableArray alloc] init];
    
    int ret = sqlite3_open(dbpath, &fdb);
    if (ret == SQLITE_OK)
    {
        NSString *query = @"SELECT tbl_name, type FROM sqlite_master";
        if (sqlite3_prepare_v2(fdb, [query UTF8String], -1, &statement, NULL) == SQLITE_OK)
        {
            int count = sqlite3_column_count(statement);
            for(int i=0; i<count; i++)
            {
                const char *name = sqlite3_column_name(statement, i);
                [keys addObject:[[NSString alloc] initWithFormat:@"%s", name]];
            }
            
            while (sqlite3_step(statement) == SQLITE_ROW)
            {
                NSMutableArray *row = [[NSMutableArray alloc] init];
                for(int i=0; i<count; i++)
                {
                    row[i] = [[NSString alloc] initWithFormat:@"%s", (char *)sqlite3_column_text(statement, i)];
                }
                [data addObject:row];
            }
            sqlite3_finalize(statement);
        }
    }
    sqlite3_close(fdb);


    NSMutableString *html = [[NSMutableString alloc] init];
    [html appendString:@"<html><head>"CSS_STYLE"</head><body><table>"];
    
    [html appendString:@"<tr>"];
    for (NSString *str in keys)
    {
        [html appendFormat:@"<th>%@</th>", str];
    }
    [html appendString:@"</tr>"];

    
    for (NSArray *row in data)
    {
        [html appendString:@"<tr>"];
        for (NSArray *cell in row)
        {
            [html appendFormat:@"<td>%@</td>", cell];
        }
        [html appendString:@"</tr>"];
    }

    
    [html appendString:@"</table></body></html>"];
    
    

    
    CFDictionaryRef properties = (__bridge CFDictionaryRef)[NSDictionary dictionary];
    QLPreviewRequestSetDataRepresentation(preview,
                                          (__bridge CFDataRef)[html dataUsingEncoding:NSUTF8StringEncoding],
                                          kUTTypeHTML,
                                          properties
                                          );

    return noErr;
}

void CancelPreviewGeneration(void *thisInterface, QLPreviewRequestRef preview)
{
    printf("AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA");

    // Implement only if supported
}
