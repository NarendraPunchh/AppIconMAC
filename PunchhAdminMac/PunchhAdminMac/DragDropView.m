//
//  DragDropView.m
//  PunchhAdminMac
//
//  Created by Narendra Verma on 4/7/15.
//  Copyright (c) 2015 Narendra Verma. All rights reserved.
//

#import "DragDropView.h"
#import "IconClass.h"

@interface DragDropView() {
    BOOL highlight;
    NSArray * icons;
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
    [self creatAppIcons];
    return YES;
//    if ([[[draggedFilenames objectAtIndex:0] pathExtension] isEqual:@"txt"]){
//        return YES;
//    } else {
//        return NO;
//    }
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
    NSString * pathImageAsset;
    NSFileManager * fileManager = [NSFileManager defaultManager];
    for (NSString * path in [fileManager subpathsOfDirectoryAtPath:[self getNewPath:arr] error:nil]) {
        if ([path rangeOfString:@"AppIcon.appiconset" options:NSCaseInsensitiveSearch].length) {
            if (![path rangeOfString:@".json"].length) {
                [self createAppIconsWithArray:arr
                                      andpath:path];
            } else if ([path rangeOfString:@".json"].length) {
                NSString * filePath = [NSString stringWithFormat:@"%@%@",arr.lastObject,path];
                NSData *data = [NSData dataWithContentsOfFile:filePath];
                NSString *textDataFile = [[NSString alloc] initWithData:data
                                                               encoding:NSUTF8StringEncoding];
                NSLog(@"Data : %@",textDataFile);
            }
        }
    }
    [self createAppIconsWithArray:arr
                          andpath:pathImageAsset];
}

- (void) createAppIconsWithArray:(NSArray *)arr andpath:(NSString *)path {
    for (IconClass * icon in icons) {
        [self saveImageAtPath:[(NSString *)arr.lastObject stringByAppendingString:[NSString stringWithFormat:@"/%@/%dx%d.png",path,icon.size,icon.size]]
                     withSize:icon.size];
    }
}

- (void)saveImageAtPath:(NSString *)path withSize:(int)size{
    NSLog(@"%@",path);
    NSImage * image = [NSImage imageNamed:@"7368.jpg"];
    CGImageRef cgRef = [image CGImageForProposedRect:NULL
                                             context:nil
                                               hints:nil];
    NSBitmapImageRep *newRep = [[NSBitmapImageRep alloc] initWithCGImage:[self resizeCGImage:cgRef
                                                                                     toWidth:size
                                                                                   andHeight:size]];
    NSData *pngData = [newRep representationUsingType:NSPNGFileType properties:nil];
    NSLog(@"%@",[pngData writeToFile:path atomically:YES] ? @"Yes" : @"No");
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

- (void) creatAppIcons {
    NSMutableArray * array = [NSMutableArray array];
    NSArray *sizeArray = @[@29,@58,@87,@100,@200];
    for (NSNumber * number in sizeArray) {
        IconClass * icon = [IconClass new];
        icon.size = number.intValue;
        [array addObject:icon];
    }
    icons = [NSArray arrayWithArray:array];
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
