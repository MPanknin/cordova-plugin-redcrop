#import <Cordova/CDVPlugin.h>
#import "PECropViewController.h"

@interface CTCrop : CDVPlugin <PECropViewControllerDelegate, MsgDelegate>
- (void) cropImage:(CDVInvokedUrlCommand *) command;
@end