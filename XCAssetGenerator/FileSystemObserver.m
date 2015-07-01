//
//  FileSystemObserver.m
//  FSEventSwiftTest
//
//  Created by Bader on 10/10/14.
//  Copyright (c) 2014 Bader. All rights reserved.
//

/*
    <<>><<>><<>><<>><<>> Sunset this whole mess in Swift 2.0 <<>><<>><<>><<>><<>>
*/

#import "FileSystemObserver.h"

static void fs_callback(ConstFSEventStreamRef ref, void * data, size_t events, void * paths, const FSEventStreamEventFlags flags[], const FSEventStreamEventId ids[]);


@interface FileSystemObserver ()
@property (nonatomic, strong) NSMutableDictionary *observers; // dictionary of paths: Array
@property (nonatomic, strong) NSMutableDictionary *pathFileDescriptors;
@property (nonatomic, strong) NSMutableArray *rootsToObserve;
@property (nonatomic, strong) NSMutableArray *contentsToObserve;
@end

@implementation FileSystemObserver

#pragma mark - Initialization
- (id)init
{
    self = [super init];
    if (self == nil)
        return nil;
    
//    _pathsToObserve = [[NSMutableArray alloc] init];
    _observers = [[NSMutableDictionary alloc] init];
    _pathFileDescriptors = [[NSMutableDictionary alloc] init];
    
    _ignoreHiddenItems = YES;
    _rootsToObserve = [[NSMutableArray alloc] init];
    _contentsToObserve = [[NSMutableArray alloc] init];
    return self;
}

- (void)dealloc
{
    _observers = nil;
    _pathFileDescriptors = nil;
    _rootsToObserve = nil;
    _contentsToObserve = nil;
    
    if (self.rootStream == NULL && self.contentStream == NULL) return;
    
    FSEventStreamStop(self.rootStream);
    FSEventStreamUnscheduleFromRunLoop(self.rootStream,
                                       CFRunLoopGetCurrent(),
                                       kCFRunLoopDefaultMode);
    FSEventStreamInvalidate(self.rootStream);
    FSEventStreamRelease(self.rootStream);
    
    FSEventStreamStop(self.contentStream);
    FSEventStreamUnscheduleFromRunLoop(self.contentStream,
                                       CFRunLoopGetCurrent(),
                                       kCFRunLoopDefaultMode);
    FSEventStreamInvalidate(self.contentStream);
    FSEventStreamRelease(self.contentStream);


}

#pragma MARK - Observers Management

- (void)addObserver:(id<FileSystemObserverDelegate>)observer forFileSystemPaths:(NSArray *)paths ignoreContents:(BOOL)ignore
{
    [paths enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        [self addObserver:observer forFileSystemPath:obj ignoreContents:ignore];
    }];
}
     
- (void)addObserver:(id<FileSystemObserverDelegate>)observer forFileSystemPath:(NSString *)path ignoreContents:(BOOL)ignore
{
    const char *cStringPath = [path cStringUsingEncoding:NSASCIIStringEncoding];
    int fd = open(cStringPath, 0);
    
    if (fd == -1) {
        // Initialization failed error.
        [observer FileSystemDirectoryError:nil];
        return ;
    }
    
    if (!ignore && self.contentStream != NULL)
        [self invalidateContentStream];
    
    if (self.rootStream != NULL)
        [self invalidateStream];
    
    
    if (!ignore && ![self.contentsToObserve containsObject:path])
        [self.contentsToObserve addObject:path];
    
    if (![self.rootsToObserve containsObject:path]) {
        [self.rootsToObserve addObject:path];
    }
    
    [self.pathFileDescriptors setObject:@(fd) forKey:path];
    [self.observers setValue:@[observer] forKey:path];
    
    [self createStream];
}

- (void)removeObserverForPath:(NSString *)path
{
    [self removeObserverForPath:path restartStream:YES];
}

- (void)removeObserverForPath:(NSString *)path restartStream:(BOOL)restart
{
    [self.observers removeObjectForKey:path];
    [self.rootsToObserve removeObject:path];
    [self.contentsToObserve removeObject:path];
    [self.pathFileDescriptors removeObjectForKey:path];
    
    if (restart)
        [self restartStream];
}

- (void)removeAllObservers
{
    [self.rootsToObserve removeAllObjects];
    [self.contentsToObserve removeAllObjects];
    [self.observers removeAllObjects];
    [self.pathFileDescriptors removeAllObjects];
//    [self invalidateStream];
}

#pragma MARK - Stream Managements


- (void)createStream
{
    FSEventStreamContext context = { 0, (__bridge void *)self, NULL, NULL, NULL };
    
    self.rootStream = FSEventStreamCreate(nil,
                                          &fs_callback,
                                          &context,
                                          (__bridge CFArrayRef)self.rootsToObserve,
                                          kFSEventStreamEventIdSinceNow,
                                          (CFAbsoluteTime)0.2,
                                          kFSEventStreamCreateFlagWatchRoot);
    
    if (self.rootStream != NULL) {
        // start the stream on the main event loop IFF stream was successfully created.
        FSEventStreamScheduleWithRunLoop(self.rootStream,
                                         CFRunLoopGetCurrent(),
                                         kCFRunLoopDefaultMode);
        FSEventStreamStart(self.rootStream);
        
    }
    
    FSEventStreamContext context2 = { 0, (__bridge void *)self, NULL, NULL, NULL };
    if (self.contentsToObserve.count) {
        self.contentStream = FSEventStreamCreate(NULL,
                                              &fs_callback,
                                              &context2,
                                              (__bridge CFArrayRef)self.contentsToObserve,
                                              kFSEventStreamEventIdSinceNow,
                                              (CFAbsoluteTime)0.2,
                                              kFSEventStreamCreateFlagFileEvents);
        
        if (self.contentStream != NULL) {
            // start the stream on the main event loop IFF stream was successfully created.
            FSEventStreamScheduleWithRunLoop(self.contentStream,
                                             CFRunLoopGetCurrent(),
                                             kCFRunLoopDefaultMode);
            FSEventStreamStart(self.contentStream);
        }
    }
    
}

         
- (void)restartStream
{

    if (self.rootStream != nil)
        [self invalidateStream];
    if (self.contentStream != nil)
        [self invalidateStream];
    
    [self createStream];
}

- (void)stopStream
{
    [self invalidateStream];
}

- (void)invalidateContentStream
{
    // TODO:
    if (self.contentStream == NULL) return;
    
    FSEventStreamStop(self.contentStream);
    FSEventStreamUnscheduleFromRunLoop(self.contentStream, CFRunLoopGetCurrent(), kCFRunLoopDefaultMode);
    FSEventStreamInvalidate(self.contentStream);
    FSEventStreamRelease(self.contentStream);
    
    self.contentStream = NULL;
}

-(void)invalidateStream
{
    if (self.rootStream == NULL) return;
    
    FSEventStreamStop(self.rootStream);
    FSEventStreamUnscheduleFromRunLoop(self.rootStream, CFRunLoopGetCurrent(), kCFRunLoopDefaultMode);
    FSEventStreamInvalidate(self.rootStream);
    FSEventStreamRelease(self.rootStream);
    
    self.rootStream = NULL;
    
    [self invalidateContentStream];
}


// Returns the main directory that we are observing -- given a subpath
- (NSString *)observedPathForSubdirectory:(NSString *)subpath
{
    __block NSString *matchingPath = nil;
    [self.rootsToObserve enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        if ([subpath containsString:obj]) {
            matchingPath = obj;
            *stop = YES;
        }
    }];
    return matchingPath;
}

- (NSString *)parentDirectoryForSubdirectory:(NSString *)sub fromDirectories:(NSArray *)directories
{
    __block NSString *matchingPath = nil;
    [directories enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        if ([sub containsString:obj]) {
            matchingPath = obj;
            *stop = YES;
        }
    }];
    
    return matchingPath;
    
}

//-(void)debugPathsBeingObserved
//{
//    NSArray *pathsBeingObserved = (__bridge NSArray *)(FSEventStreamCopyPathsBeingWatched(self.fileStream));
//    NSLog(@"%@",pathsBeingObserved);
//}

- (void)replacePathForObserversFrom:(NSString *)originalPath To:(NSString *)newPath
{
    NSArray *observersOfOriginalPath = [self.observers objectForKey:originalPath];
    BOOL ignore = [self.contentsToObserve containsObject:originalPath] ? NO : YES;
    if (observersOfOriginalPath != nil) {
        [self removeObserverForPath:originalPath restartStream:NO];
        [observersOfOriginalPath enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            [self addObserver:obj forFileSystemPath:newPath ignoreContents:ignore];
        }];
        
    }
}

BOOL isHidden(NSString *path)
{
    NSArray *components = path.pathComponents;
    __block BOOL isHidden = NO;
    [components enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        if ([obj hasPrefix:@"."]) {
            isHidden = YES;
            *stop = YES;
        }
    }];
    return isHidden;
}

static void
fs_callback(ConstFSEventStreamRef ref, void * data, size_t events, void * paths, const FSEventStreamEventFlags flags[], const FSEventStreamEventId ids[])
{
    FileSystemObserver *theObserver = (__bridge FileSystemObserver *)data;
    size_t	i;
    char ** _paths	= paths;
    NSString *path = [NSString stringWithFormat:@"%s", _paths[0]];
    NSArray *pathsBeingObserved = (__bridge NSArray *)(FSEventStreamCopyPathsBeingWatched(ref));
    BOOL contentChanged = NO;
    
    for (i = 0; i < events; ++i) {
        
        if ( ref == theObserver.contentStream && (flags[i] & kFSEventStreamEventFlagItemRenamed || flags[i]  & kFSEventStreamEventFlagItemRemoved || flags[i] & kFSEventStreamEventFlagItemCreated)) {
            // Ignore the TEMP file that we create.
            if (theObserver.ignoreHiddenItems) {
                // if (!isHidden(path)) // Sometimes .DS_Store eats copy events. So check everything until we find a better way.
                    contentChanged = YES;
         
            } else {
                contentChanged = YES;
            }
        }
        
        if (flags[i] & kFSEventStreamEventFlagRootChanged) {
            NSString *thePath = [theObserver parentDirectoryForSubdirectory:path
                                                            fromDirectories:pathsBeingObserved];

            int descriptor = ((NSNumber *)theObserver.pathFileDescriptors[thePath]).intValue;
            char filePath[PATH_MAX];
            NSArray *observers = [theObserver.observers objectForKey:thePath];
            if (observers) {
                // Resolve the path using its filde.
                if (fcntl(descriptor, F_GETPATH, filePath) != -1)
                {
                    NSString *newPath = [NSString stringWithUTF8String:filePath];
                    BOOL isTrashed = [newPath containsString:@"/.Trash"];
                    BOOL isOldPathEqualToNewPath = [path isEqualToString:newPath]; // This can happen when we "rm".
                    // No other notifications are sent except a rename with non-changed filename
                    
                    if (isOldPathEqualToNewPath || isTrashed) {
                        [observers enumerateObjectsUsingBlock:^(id observer, NSUInteger idx, BOOL *stop) {
                            [observer FileSystemDirectoryDeleted:path];
                        }];
                    }
      
                    else {
                        [observers enumerateObjectsUsingBlock:^(id observer, NSUInteger idx, BOOL *stop) {
                            [observer FileSystemDirectory:path renamedTo:newPath];
                        }];
                    }
                } else {
                    // Cannot resolve the proper filde. Jump ship.
                    [observers enumerateObjectsUsingBlock:^(id observer, NSUInteger idx, BOOL *stop) {
                        [observer FileSystemDirectoryError:nil];
                    }];
                }
                
            }
        }
        
    } // End Events loop
    
    // Notify the observers if content changed.
    if (contentChanged) {
        NSString *thePath = [theObserver parentDirectoryForSubdirectory:path
                                                        fromDirectories:pathsBeingObserved];
        NSArray *observers = [theObserver.observers objectForKey:thePath];
        [observers enumerateObjectsUsingBlock:^(id observer, NSUInteger idx, BOOL *stop) {
            [observer FileSystemDirectoryContentChanged:thePath];
        }];
    }
    
    
    
}
@end