//
//  QRCodeScreen.m
//  PunchhAdminHelper
//
//  Created by Narendra Verma on 4/3/15.
//  Copyright (c) 2015 Narendra Verma. All rights reserved.
//

#import "QRCodeScreen.h"
#import <WebKit/WebKit.h>

@interface QRCodeScreen () <NSTextFieldDelegate>{
    __weak IBOutlet NSTextField *lblValue;
    __weak IBOutlet WebView *web;
}
- (IBAction)btnRefreshTapped:(id)sender;
@end

@implementation QRCodeScreen

- (void)viewDidLoad {
    [super viewDidLoad];
    [lblValue setStringValue:[self getIPWithNSHost]];
    [lblValue setDelegate:self];
    [self openLink];
}

-(NSString *) getIPWithNSHost{
    NSArray *addresses = [[NSHost currentHost] addresses];
    for (NSString *anAddress in addresses) {
        if (![anAddress hasPrefix:@"127"] && [[anAddress componentsSeparatedByString:@"."] count] == 4) {
            return [NSString stringWithFormat:@"http://%@:3000/api/v1",anAddress];
        }
    }
    return @"IPv4 address not available";
}

- (void) openLink {
    NSString *urlText = @"http://chart.apis.google.com/chart?cht=qr&chs=300x300&chl=";
    urlText = [urlText stringByAppendingString:lblValue.stringValue];
    NSString *encodedString = (NSString *)CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(NULL,(CFStringRef)urlText,NULL,(CFStringRef)@"!*'();@+$,%#[]",kCFStringEncodingUTF8));
    [[web mainFrame] loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:encodedString]]];
}

- (void)textDidEndEditing:(NSNotification *)notification {
    NSLog(@"End");
}

- (BOOL)textShouldBeginEditing:(NSText *)textObject {
    return YES;
}

- (IBAction)btnRefreshTapped:(id)sender {
    [self openLink];
}

- (NSDragOperation)draggingEntered:(id)sender {
    //(Invoked when the dragged image enters destination bounds or frame)
    return NSDragOperationGeneric;
}

- (BOOL)prepareForDragOperation:(id)sender {
    //(Invoked when the image is released)
    return YES;
}

- (void)concludeDragOperation:(id)sender {
    //(Invoked after the released image has been removed from the screen)
}
@end
