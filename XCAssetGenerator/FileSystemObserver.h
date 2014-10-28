//
//  FileSystemObserver.h
//  XCAssetGenerator
//
//  Created by Bader on 10/10/14.
//  Copyright (c) 2014 Pranav Shah. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger, FileSystemOperation) {
    FileSystemCreation,
    FileSystemDeletion,
    FileSystemRename,
};

typedef void(^FileObserverCallback)(FileSystemOperation);
typedef void(^DirectoryObserverCallback)(FileSystemOperation);

@interface FileSystemObserver : NSObject

- (void)addObserverForPath:(NSString *)path fileObserver:(FileObserverCallback)fileBlock directoryObserver:(DirectoryObserverCallback)directoryBlock;

- (void)removeObserverForPath:(NSString *)path;
- (void)removeAllObservers;

@end
