#import "PdfPreviewerPlugin.h"

static NSString* const kDirectory = @"PDFPreviewer";
static NSString* const kOutputBaseName = @"page";
static NSString* const kFilePath = @"file:///";

@implementation PdfPreviewerPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  FlutterMethodChannel* channel = [FlutterMethodChannel
      methodChannelWithName:@"pdf_previewer"
            binaryMessenger:[registrar messenger]];
  PdfPreviewerPlugin* instance = [[PdfPreviewerPlugin alloc] init];
  [registrar addMethodCallDelegate:instance channel:channel];
 [PdfPreviewerPlugin clearCache];
  
}

+ (void)clearCache{
    
     dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
         
         NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
         NSString *documentsDirectory = [paths objectAtIndex:0];
         NSString *filePathAndDirectory = [documentsDirectory stringByAppendingPathComponent:kDirectory];
         NSError *error;
         
         BOOL fileExists = [[NSFileManager defaultManager] fileExistsAtPath:filePathAndDirectory];
         
         if (fileExists && ![[NSFileManager defaultManager] removeItemAtPath:filePathAndDirectory error:&error]){
             NSLog(@"PDFPreviewer: Error while removing the cache: %@", error);
         }else{
             NSLog(@"PDFPreviewer: Cache removed with success.");
         }
     });
}
    
    


- (void)handleMethodCall:(FlutterMethodCall*)call result:(FlutterResult)result {
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        if ([@"getPagePreview" isEqualToString:call.method]) {
            
            size_t pageNumber = (size_t)[call.arguments[@"pageNumber"] intValue];
            NSString * filePath = call.arguments[@"filePath"];
            
            result([self getPDFPreview:filePath ofPage:pageNumber isTheLastPage: NO]);
        } else if([@"getLastPagePreview" isEqualToString:call.method]){
            NSString * filePath = call.arguments[@"filePath"];
            
            result([self getPDFPreview:filePath ofPage:0 isTheLastPage: YES]);
        }else {
            result(FlutterMethodNotImplemented);
        }
        
    });
}


-(NSString*)getPDFPreview:(NSString *)url ofPage:(size_t)pageNumber isTheLastPage:(BOOL)isOnLastPage
{
    NSURL * sourcePDFUrl;
    
    if([url containsString:kFilePath]){
        sourcePDFUrl = [NSURL URLWithString:url];
    }else{
        sourcePDFUrl = [NSURL URLWithString:[kFilePath stringByAppendingString:url]];
    }
    
    
    CGPDFDocumentRef SourcePDFDocument = CGPDFDocumentCreateWithURL((__bridge CFURLRef)sourcePDFUrl);
    size_t numberOfPages = CGPDFDocumentGetNumberOfPages(SourcePDFDocument);
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *filePathAndDirectory = [documentsDirectory stringByAppendingPathComponent:kDirectory];
    NSError *error;
    
    
    if (![[NSFileManager defaultManager] createDirectoryAtPath:filePathAndDirectory
                                   withIntermediateDirectories:YES
                                                    attributes:nil
                                                         error:&error])
    {
        NSLog(@"Create directory error: %@", error);
        return nil;
    }
    
    if(isOnLastPage){
        pageNumber = numberOfPages;
    }
    
    
    CGPDFPageRef SourcePDFPage = CGPDFDocumentGetPage(SourcePDFDocument, pageNumber);
    // CoreGraphics: MUST retain the Page-Refernce manually
    CGPDFPageRetain(SourcePDFPage);
    NSString *relativeOutputFilePath = [NSString stringWithFormat:@"%@/%@%d.png", kDirectory, kOutputBaseName, (int)pageNumber];
    NSString *imageFilePath = [documentsDirectory stringByAppendingPathComponent:relativeOutputFilePath];
    CGRect sourceRect = CGPDFPageGetBoxRect(SourcePDFPage, kCGPDFMediaBox);
    UIGraphicsBeginPDFContextToFile(imageFilePath, sourceRect, nil);
    UIGraphicsBeginImageContext(CGSizeMake(sourceRect.size.width,sourceRect.size.height));
    CGContextRef currentContext = UIGraphicsGetCurrentContext();
    CGContextTranslateCTM(currentContext, 0.0, sourceRect.size.height); //596,842 //640×960,
    CGContextScaleCTM(currentContext, 1.0, -1.0);
    CGContextDrawPDFPage (currentContext, SourcePDFPage); // draws the page in the graphics context
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    [UIImagePNGRepresentation(image) writeToFile: imageFilePath atomically:YES];
    
    return imageFilePath;
    
    
}

@end
