//
//  FileSystemObserver.h
//  XCAssetGenerator
//
//  Created by Bader on 7/1/15.
//  Copyright (c) 2015 Bader Alabdulrazzaq. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol FileSystemObserverDelegate <NSObject>
@required
- (void)FileSystemDirectoryDeleted:(NSString *)path;
- (void)FileSystemDirectory:(NSString *)oldPath renamedTo:(NSString *)newPath;
- (void)FileSystemDirectoryError:(NSError *)error;
- (void)FileSystemDirectoryContentChanged:(NSString *)root;

@end


@interface FileSystemObserver : NSObject

@property FSEventStreamRef rootStream;
@property FSEventStreamRef contentStream;
@property BOOL ignoreHiddenItems;

- (void)addObserver:(id<FileSystemObserverDelegate>)observer forFileSystemPath:(NSString *)path ignoreContents:(BOOL)ignore;

- (void)addObserver:(id<FileSystemObserverDelegate>)observer forFileSystemPaths:(NSArray *)paths ignoreContents:(BOOL)ignore;

- (void)replacePathForObserversFrom:(NSString *)originalPath To:(NSString *)newPath;
- (void)removeObserverForPath:(NSString *)path;
- (void)removeObserverForPath:(NSString *)path restartStream:(BOOL)restart;
- (void)removeAllObservers;
- (void)stopStream;

@end
