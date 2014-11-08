//
//  FileSystemObserver.m
//  FSEventSwiftTest
//
//  Created by Bader on 10/10/14.
//  Copyright (c) 2014 Bader. All rights reserved.
//

// ISSUES:
// 1 - If you change the observable path, we wont observe it anymore. Example, if we observe ~/Downloads/Test and you rename it ~/Downloads/Test1 -> we will not observe it until you rename it back to the original.

#import "FileSystemObserver.h"

void fs_callback(ConstFSEventStreamRef ref, void * data, size_t events, void * paths, const FSEventStreamEventFlags flags[], const FSEventStreamEventId ids[]);

NSString * const kFileObserverKey = @"FileObserverKey";
NSString * const kDirectoryObserverKey = @"DirectoryObserverKey";

@interface FileSystemObserver ()
@property (nonatomic, strong) NSMutableArray *pathsToObserve;
@property (nonatomic, strong) NSMutableDictionary *observers;
@property (nonatomic, strong) NSMutableDictionary *pathFileDescriptors;
@property FSEventStreamRef fileStream;

@end

@implementation FileSystemObserver

#pragma mark - Initialization
- (id)init
{
    self = [super init];
    if (self == nil)
        return nil;
    
    _pathsToObserve = [[NSMutableArray alloc] init];
    _observers = [[NSMutableDictionary alloc] init];
    _pathFileDescriptors = [[NSMutableDictionary alloc] init];
    
    return self;
}

- (void)dealloc
{
    _observers = nil;
    _pathsToObserve = nil;
    
    if (self.fileStream == NULL) return;
    
    FSEventStreamStop(self.fileStream);
    FSEventStreamUnscheduleFromRunLoop(self.fileStream,
                                       CFRunLoopGetCurrent(),
                                       kCFRunLoopDefaultMode);
    FSEventStreamInvalidate(self.fileStream);
    FSEventStreamRelease(self.fileStream);
    
    
    //    _fileStream = nil;
}

#pragma MARK - Observers Management

- (void)addObserverForPath:(NSString *)path handler:(FileSystemObserverBlock)directoryBlock
{
    const char *cStringPath = [path cStringUsingEncoding:NSASCIIStringEncoding];
    int fd = open(cStringPath, 0);
    
    if (fd == -1) {
        directoryBlock(FileSystemDirectoryInitializationFailedAsPathDoesNotExist, @"", @"");
        return ;
    }
    
    if (self.fileStream != NULL) {
        
        [self invalidateStream:self.fileStream];
    }
    
    if (![self.pathsToObserve containsObject:path]) {
        [self.pathsToObserve addObject:path];
    }
    
    [self.pathFileDescriptors setObject:@(fd) forKey:path];
    
    
    [self.observers setValue:@{ kDirectoryObserverKey: directoryBlock } forKey:path];
    
    
    [self createStream];
    
}


- (void)removeObserverForPath:(NSString *)path
{
    [self removeObserverForPath:path restartStream:YES];
}

- (void)removeObserverForPath:(NSString *)path restartStream:(BOOL)restart
{
    [self.observers removeObjectForKey:path];
    [self.pathsToObserve removeObject:path];
    [self.pathFileDescriptors removeObjectForKey:path];
    
    if (restart)
        [self restartStream];
}

- (void)removeAllObservers
{
    [self.pathsToObserve removeAllObjects];
    [self.observers removeAllObjects];
    [self.pathFileDescriptors removeAllObjects];
    [self invalidateStream:self.fileStream];
}


#pragma MARK - Stream Managements


- (void)createStream
{
    FSEventStreamContext context = { 0, (__bridge void *)self, NULL, NULL, NULL };

    self.fileStream = FSEventStreamCreate(NULL,
                                          &fs_callback,
                                          &context,
                                          (__bridge CFArrayRef)self.pathsToObserve,
                                          kFSEventStreamEventIdSinceNow,
                                          (CFAbsoluteTime)0.2,
                                          //                                          kFSEventStreamCreateFlagNone);
                                          kFSEventStreamCreateFlagWatchRoot);
    
    // start the stream on the main event loop
    FSEventStreamScheduleWithRunLoop(self.fileStream,
                                     CFRunLoopGetCurrent(),
                                     kCFRunLoopDefaultMode);
    FSEventStreamStart(self.fileStream);
    
}

- (void)restartStream
{
    if (self.fileStream != NULL)
        [self invalidateStream:self.fileStream];
    //    [self createStream];
}

- (void)stopStream
{
    [self invalidateStream:self.fileStream];
}

- (void)invalidateStream:(FSEventStreamRef)ref
{
    if (ref == NULL) return;
    
    FSEventStreamStop(ref);
    FSEventStreamUnscheduleFromRunLoop(ref, CFRunLoopGetCurrent(), kCFRunLoopDefaultMode);
    FSEventStreamInvalidate(ref);
    FSEventStreamRelease(ref);
}

// Returns the main directory that we are observing -- given a subpath
- (NSString *)observedPathForSubdirectory:(NSString *)subpath
{
    __block NSString *matchingPath = nil;
    [self.pathsToObserve enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
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


- (void)replacePathForObserversFrom:(NSString *)originalPath To:(NSString *)newPath
{
    NSDictionary *observersOfOriginalPath = [self.observers objectForKey:originalPath];
    if (observersOfOriginalPath != nil) {
        [self removeObserverForPath:originalPath restartStream:NO];
        [self addObserverForPath:newPath handler:[observersOfOriginalPath[kDirectoryObserverKey] copy]];
    }
}


// TODO: Determine what to do with the callback. Seems like its gonna be a trial-and-error thing.
void
fs_callback(ConstFSEventStreamRef ref, void * data, size_t events, void * paths, const FSEventStreamEventFlags flags[], const FSEventStreamEventId ids[])
{
    FileSystemObserver *theObserver = (__bridge FileSystemObserver *)data;
    size_t	i;
    char ** _paths	= paths;
    NSString *path = [NSString stringWithFormat:@"%s", _paths[0]];
    NSArray *pathsBeingObserved = (__bridge NSArray *)(FSEventStreamCopyPathsBeingWatched(ref));
    
    for (i = 0; i < events; ++i) {
        
        if (flags[i] & kFSEventStreamEventFlagRootChanged) {
            
            //            NSString *thePath   = [theObserver observedPathForSubdirectory:path];
            NSString *thePath = [theObserver parentDirectoryForSubdirectory:path fromDirectories:pathsBeingObserved];
            int descriptor = ((NSNumber *)theObserver.pathFileDescriptors[thePath]).intValue;
            char filePath[PATH_MAX];
            
            FileSystemObserverBlock block = [[theObserver.observers objectForKey:thePath] objectForKey:kDirectoryObserverKey];
            
            if (block) {
                
                if (fcntl(descriptor, F_GETPATH, filePath) != -1)
                {
                    NSString *newPath = [NSString stringWithUTF8String:filePath];
                    BOOL isTrashed = [newPath containsString:@"/.Trash"];
                    
                    if (isTrashed)
                        block(FileSystemDirectoryDeleted, path, newPath);
                    else
                        block(FileSystemDirectoryRenamed, path, newPath);
                    
                } else {
                    // Cannot resolve the proper filde. Now what? BRAAAAAAPBUBUBUBUBPBRAAAAP *gun shots*
                    block(FileSystemDirectoryUnknownOperationForUnresolvedPath, path, @"");
                }
                
            }
        }
        
        //        if (flags[i] & kFSEventStreamEventFlagItemRenamed) {}
        
        //        if (flags[i] & kFSEventStreamEventFlagItemRemoved) {}
        
        //        if (flags[i] & kFSEventStreamEventFlagItemCreated) {}
        
        //        if (flags[i] & kFSEventStreamEventFlagItemIsDir) {}
        
        //        if (flags[i] & kFSEventStreamEventFlagItemIsFile) {}
        
    } // End Events loop
    
    
    
}
@end