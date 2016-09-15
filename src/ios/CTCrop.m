#import "CTCrop.h"

#define CDV_PHOTO_PREFIX @"cdv_photo_"

@interface CTCrop ()
@property (copy) NSString* callbackId;
@property (assign) NSUInteger quality;
@end

@implementation CTCrop

- (void) cropImage: (CDVInvokedUrlCommand *) command {
    UIImage *image;
    NSString *imagePath = [command.arguments objectAtIndex:0];
    NSDictionary *options = [command.arguments objectAtIndex:1];
    id quality = options[@"quality"] ?: @100;
    
    self.quality = [quality unsignedIntegerValue];
    NSString *filePrefix = @"file://";
    
    if ([imagePath hasPrefix:filePrefix]) {
        imagePath = [imagePath substringFromIndex:[filePrefix length]];
    }
    
    
    if (!(image = [UIImage imageWithContentsOfFile:imagePath])) {
        NSDictionary *err = @{
                              @"message": @"Image doesn't exist",
                              @"code": @"ENOENT"
                              };
        CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsDictionary:err];
        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
        return;
    }

    PECropViewController *cropController = [[PECropViewController alloc] init];
    cropController.delegate = self;
    cropController.msgDelegate = self;

    cropController.image = image;

    // e.g.) Cropping center square
    CGFloat width = image.size.width;
    CGFloat height = image.size.height;

    CGFloat length = MIN(width, height);
    cropController.toolbarHidden = NO;
    cropController.rotationEnabled = NO;

    cropController.keepingCropAspectRatio = YES;
    CGFloat ratio = 9.0f / 16.0f;
    cropController.cropAspectRatio = ratio;
    
    if((height / width) >= ratio)
    {
        cropController.maximumZoomScale = width / 3200.0f;    
    }
    else
    {
        cropController.maximumZoomScale = height / 1800.0f;
    }
    

    // TODO parameterize this
    //cropController.imageCropRect = CGRectMake((width - length) / 2,
                                        //   (height - length) / 2,
                                        //   length,
                                        //   length * ratio);


    cropController.imageCropRect = CGRectMake((width - 3200) / 2, (height - 1800) / 2, 3200, 1800);                                    

    self.callbackId = command.callbackId;
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:cropController];
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        navigationController.modalPresentationStyle = UIModalPresentationFormSheet;
    }
    
    [self.viewController presentViewController:navigationController animated:YES completion:NULL];

    // [self msg2Client:@"redLog('Cropview active');"];

    NSString *msgInput = [NSString stringWithFormat:@"cW = %f; cH = %f; ", width , height];
    // [self msg2Client:msgInput];


    CGSize initSize = cropController.imageCropRect.size;
    NSString *msgRect = [NSString stringWithFormat:@"rWStart = %f; rHStart = %f; ", initSize.width , initSize.height];
    // [self msg2Client:msgRect];    

    CGPoint pos = cropController.imageCropRect.origin;
    NSString *msgPos = [NSString stringWithFormat:@"redLog('Rect Pos: %.2f : %.2f');", pos.x , pos.y];
    // [self msg2Client:msgPos];    

    CGFloat dx = width / initSize.width;
    CGFloat dy = height / initSize.height;

    NSString *msgDelta = [NSString stringWithFormat:@"dtWStart = %f; dtHStart = %f;", dx , dy];
    // [self msg2Client:msgDelta];  
}

#pragma mark - MsgDelegate

-(void) msg2Client:(NSString *)msg {
    [self.commandDelegate evalJs:msg];
}

#pragma mark - PECropViewControllerDelegate

- (void)cropViewController:(PECropViewController *)controller didFinishCroppingImage:(UIImage *)croppedImage {
    [controller dismissViewControllerAnimated:YES completion:nil];
    if (!self.callbackId) return;
    
    NSData *data =  UIImageJPEGRepresentation(croppedImage, (CGFloat) self.quality);
    NSString* filePath = [self tempFilePath:@"jpg"];
    CDVPluginResult *result;
    NSError *err;

    CGSize finalSize = croppedImage.size;
    NSString *msgFinal = [NSString stringWithFormat:@"redLog('Final size: %.f : %.f');", finalSize.width , finalSize.height];
    // [self msg2Client:msgFinal];    

    // NSString *msgPath = [NSString stringWithFormat:@"redLog('Path: %@ ');", filePath];
    // [self msg2Client:msgPath];  

    // save file
    if (![data writeToFile:filePath options:NSAtomicWrite error:&err]) {
        result = [CDVPluginResult resultWithStatus:CDVCommandStatus_IO_EXCEPTION messageAsString:[err localizedDescription]];
    }
    else {
        result = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:[[NSURL fileURLWithPath:filePath] absoluteString]];
    }
    
    [self.commandDelegate sendPluginResult:result callbackId:self.callbackId];
    self.callbackId = nil;
}

- (void)cropViewControllerDidCancel:(PECropViewController *)controller {
    [controller dismissViewControllerAnimated:YES completion:nil];
    NSDictionary *err = @{
                          @"message": @"User cancelled",
                          @"code": @"userCancelled"
                          };
    CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsDictionary:err];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:self.callbackId];
    self.callbackId = nil;
}

#pragma mark - Utilites

- (NSString*)tempFilePath:(NSString*)extension
{
    NSString* docsPath = [NSTemporaryDirectory()stringByStandardizingPath];
    NSFileManager* fileMgr = [[NSFileManager alloc] init]; // recommended by Apple (vs [NSFileManager defaultManager]) to be threadsafe
    NSString* filePath;
    
    // generate unique file name
    int i = 1;
    do {
        filePath = [NSString stringWithFormat:@"%@/%@%03d.%@", docsPath, CDV_PHOTO_PREFIX, i++, extension];
    } while ([fileMgr fileExistsAtPath:filePath]);
    
    return filePath;
}

@end
