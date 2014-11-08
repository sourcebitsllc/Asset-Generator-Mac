//
//  FileSystemObserver.h
//  FSEventSwiftTest
//
//  Created by Bader on 10/10/14.
//  Copyright (c) 2014 Bader. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger, FileSystemOperation) {
    FileSystemDirectoryCreated,
    FileSystemDirectoryDeleted,
    FileSystemDirectoryRenamed,
    FileSystemDirectoryContentChanged,
    FileSystemDirectoryInitializationFailedAsPathDoesNotExist,
    FileSystemDirectoryUnknownOperationForUnresolvedPath
};

typedef void(^FileFileSystemObserverBlock)(FileSystemOperation);
typedef void(^FileSystemObserverBlock)(FileSystemOperation, NSString *, NSString *);

@interface FileSystemObserver : NSObject

- (void)addObserverForPath:(NSString *)path handler:(FileSystemObserverBlock)directoryBlock;
- (void)replacePathForObserversFrom:(NSString *)originalPath To:(NSString *)newPath;
- (NSString *)pathForBlock:(FileSystemObserverBlock)block;
/*
  Description: 
        Remove the path and continue observing the other paths.
 */
- (void)removeObserverForPath:(NSString *)path;
- (void)removeObserverForPath:(NSString *)path restartStream:(BOOL)restart;
- (void)removeAllObservers;
- (void)stopStream;

@end
