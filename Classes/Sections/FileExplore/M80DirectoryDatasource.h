//
//  M80DirectoryDatasource.h
//  M80WifiSync
//
//  Created by amao on 1/12/15.
//  Copyright (c) 2015 www.xiangwangfeng.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface M80FileModel : NSObject
@property (nonatomic,copy)         NSString    *filename;
@property (nonatomic,assign)       BOOL        isDir;
@property (nonatomic,copy)         NSString    *filepath;
- (UIImage *)icon;
@end

@interface M80DirectoryDatasource : NSObject
@property (nonatomic,copy)  NSString    *dir;

+ (instancetype)datasource:(NSString *)dir;
- (NSArray *)files;

- (BOOL)removeFile:(NSString *)filepath;
- (BOOL)createDir:(NSString *)dirName;
@end
