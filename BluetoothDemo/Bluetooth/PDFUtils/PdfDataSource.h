//
//  PdfDataSource.h
//  BluetoothDemo
//
//  Created by apple on 2021/12/1.
//

#import <Foundation/Foundation.h>
#import "DocumentDataSource.h"

@interface PdfDataSource : NSObject <DocumentDataSource>

@property (nonatomic,assign) NSInteger pageCount;
@property (nonatomic,strong) NSURL* fileURL;
@property (nonatomic,strong) NSString* password;

+ (instancetype)createWithFileUrl:(NSURL *)url;

@end
