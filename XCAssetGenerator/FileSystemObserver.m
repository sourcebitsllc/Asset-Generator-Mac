//
//  FileSystemObserver.m
//  XCAssetGenerator
//
//  Created by Bader on 10/10/14.
//  Copyright (c) 2014 Pranav Shah. All rights reserved.
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
@property FSEventStreamRef fileStream;
//@property
@end

@implementation FileSystemObserver

#pragma mark - TODO:
-(id)init {
    self = [super init];
    if (self == nil)
        return nil;
    
    _pathsToObserve = [[NSMutableArray alloc] init];
    _observers = [[NSMutableDictionary alloc] init];
    
    return self;
}

- (void)addObserverForPath:(NSString *)path fileObserver:(FileObserverCallback)fileBlock directoryObserver:(DirectoryObserverCallback)directoryBlock {
    
    
    FSEventStreamContext context = { 0, (__bridge void *)self, NULL, NULL, NULL };
    
    if (self.fileStream != NULL)
        [self invalidateStream:self.fileStream];
    
    if (![self.pathsToObserve containsObject:path]) {
        [self.pathsToObserve addObject:path];
    }
    // Add the new observers to the existing observers
    //    NSMutableArray *callbacks = [self.observers objectForKey:path];
    //    [callbacks addObject:@{ @"file": fileBlock, @"directory": directoryBlock }];
    
    [self.observers setValue:@{ kFileObserverKey: fileBlock, kDirectoryObserverKey: directoryBlock } forKey:path];
    
    self.fileStream = FSEventStreamCreate(NULL,
                                          &fs_callback,
                                          &context,
                                          (__bridge CFArrayRef)self.pathsToObserve,
                                          kFSEventStreamEventIdSinceNow,
                                          (CFAbsoluteTime)0.2,
                                          //                                          kFSEventStreamCreateFlagNone);
                                          kFSEventStreamCreateFlagFileEvents);
    
    // start the stream on the main event loop
    FSEventStreamScheduleWithRunLoop(self.fileStream,
                                     CFRunLoopGetCurrent(),
                                     kCFRunLoopDefaultMode);
    FSEventStreamStart(self.fileStream);
    //    NSLog(@"%u",self.fileStream);
    
}

- (void)removeObserverForPath:(NSString *)path {
    [self.observers removeObjectForKey:path];
}

- (void)removeAllObservers {
    [self.pathsToObserve removeAllObjects];
    [self.observers removeAllObjects];
    [self invalidateStream:self.fileStream];
}

- (void)invalidateStream:(FSEventStreamRef)ref {
    FSEventStreamStop(ref);
    FSEventStreamUnscheduleFromRunLoop(ref,
                                       CFRunLoopGetCurrent(),
                                       kCFRunLoopDefaultMode);
    FSEventStreamInvalidate(ref);
    FSEventStreamRelease(ref);
}


- (void)fileChangedForPath:(NSString *)path operation:(FileSystemOperation)operation {
    
    // General concept: Get all the entries for said path, (which is an array of dicitonaries containing all the callbacks.
    // Then, enumate every dicitonary and trigger the appropriate callback
    NSDictionary *observersForPath = [self.observers objectForKey:path];
    FileObserverCallback callback = [observersForPath objectForKey:kFileObserverKey];
    if (callback)
        callback(operation);
}

- (void)directoryChangedForPath:(NSString *)path operation:(FileSystemOperation)operation {
    
    // General concept: Get all the entries for said path, (which is an array of dicitonaries containing all the callbacks.
    // Then, enumate every dicitonary and trigger the appropriate callback
    NSDictionary *observersForPath = [self.observers objectForKey:path];
    FileObserverCallback callback = [observersForPath objectForKey:kDirectoryObserverKey];
    if (callback)
        callback(operation);
}



- (void)dealloc {
    FSEventStreamStop(self.fileStream);
    FSEventStreamUnscheduleFromRunLoop(self.fileStream,
                                       CFRunLoopGetCurrent(),
                                       kCFRunLoopDefaultMode);
    FSEventStreamInvalidate(self.fileStream);
    FSEventStreamRelease(self.fileStream);
}
@end


// TODO: Determine what to do with the callback. Seems like its gonna be a trial-and-error thing.
void
fs_callback(ConstFSEventStreamRef ref, void * data, size_t events, void * paths, const FSEventStreamEventFlags flags[], const FSEventStreamEventId ids[]) {
    NSLog(@"Listening");
    //   self()()()() = (__bridge self.class *?)userData;
    size_t	i;
    char ** _paths	= paths;
    NSLog(@"number of events = %zu", events);
    //    NSString * newName = [NSString stringWithFormat:@"%s", paths[0]];
    
    //    NSLog(@"STAT: %u",fileStat);
    
    NSString * newName = [NSString stringWithFormat:@"%s", _paths[0]];
    for (i = 0; i < events; ++i) {
        if (flags[i] & kFSEventStreamEventFlagItemRemoved) {
            NSLog(@"%zu: Item removed:", i);
        }
        if (flags[i] & kFSEventStreamEventFlagItemRenamed) {
            NSLog(@"%zu: Item renamed: %@", i, newName);
        }
        if (flags[i] & kFSEventStreamEventFlagItemCreated) {
            NSLog(@"%zu: Item created: %@", i, newName);
        }
    }
    
}