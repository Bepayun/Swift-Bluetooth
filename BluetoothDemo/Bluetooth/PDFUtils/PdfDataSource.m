//
//  PdfDataSource.m
//  BluetoothDemo
//
//  Created by apple on 2021/12/1.
//

#import "PdfDataSource.h"
#import <UIKit/UIKit.h>

@implementation PdfDataSource {
    CGPDFDocumentRef _PDFDocRef;
}

+ (instancetype)createWithFileUrl:(NSURL *)url {
    PdfDataSource *dataSource = [[PdfDataSource alloc] init];
    dataSource.fileURL = url;
    return dataSource;
}

- (void)setFileURL:(NSURL *)fileURL {
    _fileURL = fileURL;
    
    _PDFDocRef = CGPDFDocumentCreateWithURL((__bridge CFURLRef)fileURL);
    
    self.pageCount = CGPDFDocumentGetNumberOfPages(_PDFDocRef);
}

- (CGSize)getPageSizeByRef:(CGPDFPageRef) _PDFPageRef {
    NSInteger _pageAngle;
    
    CGFloat _pageWidth;
    CGFloat _pageHeight;
    
    CGFloat _pageOffsetX;
    CGFloat _pageOffsetY;
    
    
    CGPDFPageRetain(_PDFPageRef); // Retain the PDF page
    
    CGRect cropBoxRect = CGPDFPageGetBoxRect(_PDFPageRef, kCGPDFCropBox);
    CGRect mediaBoxRect = CGPDFPageGetBoxRect(_PDFPageRef, kCGPDFMediaBox);
    CGRect effectiveRect = CGRectIntersection(cropBoxRect, mediaBoxRect);
    
    _pageAngle = CGPDFPageGetRotationAngle(_PDFPageRef); // Angle
    NSLog(@"pagew--%f-pageh--%f",effectiveRect.size.width,effectiveRect.size.height);
    NSLog(@"pageAngle--%ld",(long)_pageAngle);
    switch (_pageAngle) // Page rotation angle (in degrees)
    {
        default: // Default case
        case 0: case 180: // 0 and 180 degrees
        {
            _pageWidth = effectiveRect.size.width;
            _pageHeight = effectiveRect.size.height;
            _pageOffsetX = effectiveRect.origin.x;
            _pageOffsetY = effectiveRect.origin.y;
            break;
        }
            
        case 90: case 270: // 90 and 270 degrees
        {
            _pageWidth = effectiveRect.size.height;
            _pageHeight = effectiveRect.size.width;
            _pageOffsetX = effectiveRect.origin.y;
            _pageOffsetY = effectiveRect.origin.x;
            break;
        }
    }
    
//    NSInteger page_w = _pageWidth; // Integer width
//    NSInteger page_h = _pageHeight; // Integer height

//    NSLog(@"pagew--%f-pageh--%f",_pageWidth,_pageHeight);
//    if (page_w % 2) page_w--; if (page_h % 2) page_h--; // Even
    return CGSizeMake(_pageWidth, _pageHeight);
//    return CGSizeMake(page_w, page_h); // View size
}

- (CGSize)getPageSize:(NSInteger)page {
    CGPDFPageRef _PDFPageRef = CGPDFDocumentGetPage(_PDFDocRef, page); // Get page
    
    return [self getPageSizeByRef:_PDFPageRef];
}
- (void)drawLayer:(CGContextRef)context page:(NSInteger)page {
    CGPDFPageRef _PDFPageRef = CGPDFDocumentGetPage(_PDFDocRef, page); // Get page
    
    CGSize pageSize = [self getPageSizeByRef:_PDFPageRef];
    NSLog(@"pagesize--%f-pagesize--%f",pageSize.width,pageSize.height);
//    UIScreen *screen = [UIScreen mainScreen];

//    CGContextSetRGBFillColor(context, 1.0f, 1.0f, 1.0f, 1.0f); // White
//    CGContextFillRect(context, CGContextGetClipBoundingBox(context)); // Fill

    CGContextTranslateCTM(context, 0.0f, pageSize.height);
    CGContextScaleCTM(context, 1.0f, -1.0f);

    CGContextConcatCTM(context, CGPDFPageGetDrawingTransform(_PDFPageRef, kCGPDFCropBox, CGRectMake(0, 0, pageSize.width, pageSize.height) , 0, true));
    
    CGContextDrawPDFPage(context, _PDFPageRef); // Render the PDF page into the context
    
}

@end


