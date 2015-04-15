//
//  DragDropView.m
//  PunchhAdminMac
//
//  Created by Narendra Verma on 4/7/15.
//  Copyright (c) 2015 Narendra Verma. All rights reserved.
//

#import "DragDropView.h"
#import "IconClass.h"
#import "AppDelegate.h"

@interface DragDropView() {
    BOOL highlight;
    NSDictionary * dictOther;
    NSString * pathContenJsonFile;
    NSMutableArray * mArrIcons;
}
@end

@implementation DragDropView

- (id)initWithFrame:(NSRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        [self registerForDraggedTypes:[NSArray arrayWithObject:NSFilenamesPboardType]];
    }
    return self;
}

- (id) initWithCoder:(NSCoder *)coder {
    if ([super initWithCoder:coder]) {
        [self registerForDraggedTypes:[NSArray arrayWithObject:NSFilenamesPboardType]];
    }
    return self;
}

- (NSDragOperation)draggingEntered:(id <NSDraggingInfo>)sender{
    highlight=YES;
    [self setNeedsDisplay: YES];
    return NSDragOperationGeneric;
}

- (void)draggingExited:(id <NSDraggingInfo>)sender{
    highlight=NO;
    [self setNeedsDisplay: YES];
}

- (BOOL)prepareForDragOperation:(id <NSDraggingInfo>)sender {
    highlight=NO;
    [self setNeedsDisplay: YES];
    return YES;
}

- (BOOL)performDragOperation:(id < NSDraggingInfo >)sender {
    return YES;
}

- (void)concludeDragOperation:(id <NSDraggingInfo>)sender{
    [self filterImageAsseetsFolder:[[sender draggingPasteboard] propertyListForType:NSFilenamesPboardType]];
}

- (NSString *) getNewPath:(NSArray *)components {
    //need to find the main folder
    NSString * path = (NSString *)components.lastObject;
    return path;
}

- (void) filterImageAsseetsFolder:(NSArray *)arr {
    if ([arr.lastObject rangeOfString:@".png"].length || [arr.lastObject rangeOfString:@".jpg"].length) {
        NSImage * image = [[NSImage alloc] initWithContentsOfFile:arr.lastObject];
        [self setImage:image];
        AppDelegate *appDelegate = (AppDelegate *)[NSApp delegate];
        appDelegate.image = image;
    } else {
        NSString * pathImageAsset;
        NSFileManager * fileManager = [NSFileManager defaultManager];
        for (NSString * path in [fileManager subpathsOfDirectoryAtPath:[self getNewPath:arr] error:nil]) {
            if ([path rangeOfString:@"AppIcon.appiconset" options:NSCaseInsensitiveSearch].length) {
                if (![path rangeOfString:@".json"].length && ![path rangeOfString:@".DS_Store"].length) {
                    pathImageAsset = path;
                } else if ([path rangeOfString:@".json"].length) {
                    //Create app icons for the content.jsonfile
                    NSString * filePath = [NSString stringWithFormat:@"%@/%@",arr.lastObject,path];
                    pathContenJsonFile = filePath;
                    [self creatAppIconsWithTextData:[NSData dataWithContentsOfFile:filePath]];

                }
            }
        }
        [self createAppIconsWithArray:arr
                              andpath:pathImageAsset];
    }
}

- (void) creatAppIconsWithTextData:(NSData *)data {
    NSError *e = nil;
    NSDictionary *jsonArray = [NSJSONSerialization JSONObjectWithData:data
                                                         options:NSJSONReadingMutableContainers
                                                           error:&e];

    if (!jsonArray) {
        NSLog(@"Error parsing JSON: %@", e);
    } else {
        if ([jsonArray valueForKey:@"images"]) {
            NSArray * arrayData = jsonArray[@"images"];
            mArrIcons = [[NSMutableArray alloc] init];
            for (NSDictionary * dict in arrayData) {
                IconClass * value = [IconClass new];
                value.scale = dict[@"scale"];
                value.sizeName = dict[@"size"];
                value.idiom = dict[@"idiom"];
                value.size = [self getSize:value];
                value.fileName = [self getFileNameForIcon:value];
                [mArrIcons addObject:value];
            }
        }
        dictOther = [[NSDictionary alloc] initWithDictionary:[jsonArray valueForKey:@"info"]];
    }
    [self writeDataIntoFile];
}

- (void) writeDataIntoFile {
    NSMutableArray * array = [NSMutableArray array];
    for (IconClass * iconValue in mArrIcons) {
        NSMutableDictionary * dict = [NSMutableDictionary dictionary];
        [dict setValue:iconValue.idiom forKey:@"idiom"];
        [dict setValue:iconValue.sizeName forKey:@"size"];
        [dict setValue:iconValue.scale forKey:@"scale"];
        [dict setValue:iconValue.fileName forKey:@"filename"];
        [array addObject:dict];
    }
    NSMutableDictionary * jsonDict = [NSMutableDictionary dictionary];
    [jsonDict addEntriesFromDictionary:[NSDictionary dictionaryWithObject:dictOther forKey:@"info"]];
    [jsonDict setObject:array forKey:@"images"];
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:jsonDict options:NSJSONWritingPrettyPrinted
                                                         error:nil];
    NSString * dataJson = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    BOOL ok = [dataJson writeToFile:pathContenJsonFile
                         atomically:YES
                           encoding:NSUnicodeStringEncoding
                              error:nil];
}

- (int) getSize:(IconClass *)iconValue {
    return [[iconValue.sizeName substringToIndex:[iconValue.sizeName rangeOfString:@"x"].location] intValue] * [[iconValue.scale substringToIndex:[iconValue.scale rangeOfString:@"x"].location] intValue];
}

- (NSString *) getFileNameForIcon:(IconClass *)iconValue {
    NSString * extination = nil;
    switch ([[iconValue.scale substringToIndex:[iconValue.scale rangeOfString:@"x"].location] intValue]) {
        case 2: extination = @"@2x.png"; break;
        case 3: extination = @"@3x.png"; break;
        default: extination = @".png"; break;
    }
    NSString * initialName = [NSString stringWithFormat:@"appIcon_%@_%@",iconValue.idiom,iconValue.sizeName];
    initialName = [initialName stringByAppendingString:extination];
    return initialName;
}

- (void) createAppIconsWithArray:(NSArray *)arr andpath:(NSString *)path {
    for (IconClass * icon in mArrIcons) {
        [self saveImageAtPath:[(NSString *)arr.lastObject stringByAppendingString:[NSString stringWithFormat:@"/%@/%@",path,icon.fileName]]
                     withSize:icon.size];
    }
}

- (void)saveImageAtPath:(NSString *)path withSize:(int)size{
    AppDelegate *appDelegate = (AppDelegate *)[NSApp delegate];
    NSImage * image = appDelegate.image;
    CGImageRef cgRef = [image CGImageForProposedRect:NULL
                                             context:nil
                                               hints:nil];
    NSBitmapImageRep *newRep = [[NSBitmapImageRep alloc] initWithCGImage:[self resizeCGImage:cgRef
                                                                                     toWidth:size
                                                                                   andHeight:size]];
    NSData *pngData = [newRep representationUsingType:NSPNGFileType properties:nil];
    [pngData writeToFile:path atomically:YES];
}

- (CGImageRef)resizeCGImage:(CGImageRef)image toWidth:(int)width andHeight:(int)height {
    // create context, keeping original image properties
    CGColorSpaceRef colorspace = CGImageGetColorSpace(image);
    CGContextRef context = CGBitmapContextCreate(NULL, width, height,
                                                 CGImageGetBitsPerComponent(image),
                                                 CGImageGetBytesPerRow(image),
                                                 colorspace,
                                                 CGImageGetAlphaInfo(image));
    CGColorSpaceRelease(colorspace);


    if(context == NULL)
        return nil;


    // draw image to context (resizing it)
    CGContextDrawImage(context, CGRectMake(0, 0, width, height), image);
    // extract resulting image from context
    CGImageRef imgRef = CGBitmapContextCreateImage(context);
    CGContextRelease(context);
    
    
    return imgRef;
}

- (void)drawRect:(NSRect)rect{
    [super drawRect:rect];
    if ( highlight ) {
        [[NSColor grayColor] set];
        [NSBezierPath setDefaultLineWidth: 5];
        [NSBezierPath strokeRect: [self bounds]];
    }
}

- (void)pasteboard:(NSPasteboard *)pasteboard item:(NSPasteboardItem *)item provideDataForType:(NSString *)type {
}

- (NSDragOperation)draggingSession:(NSDraggingSession *)session sourceOperationMaskForDraggingContext:(NSDraggingContext)contex {
    return NSDragOperationGeneric;
}
@end
