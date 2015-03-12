//
//  FileSystemObserver.h
//  FSEventSwiftTest
//
//  Created by Bader on 10/10/14.
//  Copyright (c) 2014 Bader. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol FileSystemObserverDelegate <NSObject>

// Created
@optional
- (void)FileSystemDirectoryCreated:(NSString *)path;

@required
- (void)FileSystemDirectoryDeleted:(NSString *)path;
- (void)FileSystemDirectory:(NSString *)oldPath renamedTo:(NSString *)newPath;
- (void)FileSystemDirectoryError:(NSError *)error;
// Deleted

//Bamboozled

// Failures
//  - InitializationFailedAsPathDoesnotExist
//  - UnknownOperationForUnresolvedPath
@end


@interface FileSystemObserver : NSObject

- (void)addObserver:(id<FileSystemObserverDelegate>)observer forFileSystemPath:(NSString *)path;
- (void)replacePathForObserversFrom:(NSString *)originalPath To:(NSString *)newPath;
/*
    Description:
        Remove the path and continue observing the other paths.
*/
- (void)removeObserverForPath:(NSString *)path;
- (void)removeObserverForPath:(NSString *)path restartStream:(BOOL)restart;
- (void)removeAllObservers;
- (void)stopStream;

// Debug
-(void)debugPathsBeingObserved;

@end
