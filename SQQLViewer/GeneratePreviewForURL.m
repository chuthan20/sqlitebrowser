#include <CoreFoundation/CoreFoundation.h>
#include <CoreServices/CoreServices.h>
#include <QuickLook/QuickLook.h>
#import <Cocoa/Cocoa.h>

OSStatus GeneratePreviewForURL(void *thisInterface, QLPreviewRequestRef preview, CFURLRef url, CFStringRef contentTypeUTI, CFDictionaryRef options);
void CancelPreviewGeneration(void *thisInterface, QLPreviewRequestRef preview);

/* -----------------------------------------------------------------------------
   Generate a preview for file

   This function's job is to create preview for designated file
   ----------------------------------------------------------------------------- */

OSStatus GeneratePreviewForURL(void *thisInterface, QLPreviewRequestRef preview, CFURLRef url, CFStringRef contentTypeUTI, CFDictionaryRef options)
{
    
    printf("AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA");
    // To complete your generator please implement the function GeneratePreviewForURL in GeneratePreviewForURL.c
    
    NSString *html = @"<html><body><h1>THIS IS A HEADER...</h1></body></html>";
    
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
