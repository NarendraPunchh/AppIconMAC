//
//  AppDelegate.m
//  PunchhAdminMac
//
//  Created by Narendra Verma on 4/7/15.
//  Copyright (c) 2015 Narendra Verma. All rights reserved.
//

#import "AppDelegate.h"
#import "QRCodeScreen.h"
@interface AppDelegate ()
@property (strong, nonatomic) QRCodeScreen * screen;
@property (weak) IBOutlet NSWindow *window;
@end

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
//    self.screen = [[QRCodeScreen alloc] initWithNibName:@"QRCodeScreen"
//                                                 bundle:nil];
//    [self.screen.view setFrame:NSRectToCGRect(CGRectMake(0, -10, self.window.frame.size.width, self.window.frame.size.height))];
//    [self.window.contentView addSubview:self.screen.view];
}

- (void)applicationWillTerminate:(NSNotification *)aNotification {
    // Insert code here to tear down your application
}

@end
