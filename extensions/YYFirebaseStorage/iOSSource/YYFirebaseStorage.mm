#import "YYFirebaseStorage.h"
#import "FirebaseUtils.h"

// Error Codes
static const double kFirebaseStorageSuccess = 0.0;
static const double kFirebaseStorageErrorNotFound = -1.0;

@interface YYFirebaseStorage ()

@property (nonatomic, strong) NSMutableDictionary<NSNumber *, FIRStorageObservableTask<FIRStorageTaskManagement> *> *taskMap;
@property (nonatomic, strong) NSMutableDictionary<NSNumber *, NSNumber *> *lastProgressUpdateTime;

- (NSNumber *)getListenerInd;
- (NSString *)listOfReferencesToJSON:(NSArray<FIRStorageReference *> *)list; 
- (void)sendStorageEvent:(NSString *)eventType listener:(NSNumber*)listener path:(NSString *)path localPath:(NSString *)localPath success:(BOOL)success additionalData:(NSDictionary *)additionalData;
- (void)throttleProgressUpdate:(NSNumber*)asyncId eventType:(NSString *)eventType path:(NSString *)path localPath:(NSString *)localPath transferred:(int64_t)transferred total:(int64_t)total;

@end

@implementation YYFirebaseStorage

- (id)init {
    self = [super init];
    if (self) {
        // Initialize dictionaries
        self.taskMap = [[NSMutableDictionary alloc] init];
        self.lastProgressUpdateTime = [[NSMutableDictionary alloc] init];
    }
    return self;
}

- (double)SDKFirebaseStorage_Cancel:(double)ind {
    NSNumber *asyncId = @((long)ind); // Convert double to long
    FIRStorageObservableTask<FIRStorageTaskManagement> * task = self.taskMap[asyncId];
    if (task) {
        [task cancel];
        [task removeAllObservers];
        [self.taskMap removeObjectForKey:asyncId];
        [self.lastProgressUpdateTime removeObjectForKey:asyncId];
        return kFirebaseStorageSuccess;
    }
    return kFirebaseStorageErrorNotFound;
}

- (double)SDKFirebaseStorage_Download:(NSString *)localPath firebasePath:(NSString *)firebasePath bucket:(NSString *)bucket {
    NSNumber *asyncId = [self getListenerInd];
    
    // Get the Application Support directory path
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSApplicationSupportDirectory, NSUserDomainMask, YES);
    NSString *appSupportDirectory = [paths firstObject];
    
    // Ensure the directory exists
    NSError *error = nil;
    [[NSFileManager defaultManager] createDirectoryAtPath:appSupportDirectory withIntermediateDirectories:YES attributes:nil error:&error];
    if (error) {
        NSString *errorMessage = [NSString stringWithFormat:@"Error creating Application Support directory: %@", error.localizedDescription];
        NSDictionary *data = @{@"error": errorMessage};
        [self sendStorageEvent:@"FirebaseStorage_Download" listener:asyncId path:firebasePath localPath:localPath success:NO additionalData:data];
        return [asyncId doubleValue];
    }
    
    NSString *localFilePath = [appSupportDirectory stringByAppendingPathComponent:localPath];
    
    FIRStorageReference *ref = [[[FIRStorage storage] reference] child:firebasePath];
    NSURL *localURL = [NSURL fileURLWithPath:localFilePath];
    FIRStorageDownloadTask *downloadTask = [ref writeToFile:localURL];
    
    // Store the task in taskMap
    self.taskMap[asyncId] = downloadTask;
    self.lastProgressUpdateTime[asyncId] = @(0);
    
    [downloadTask observeStatus:FIRStorageTaskStatusSuccess handler:^(FIRStorageTaskSnapshot *snapshot) {
        [self.taskMap removeObjectForKey:asyncId];
        [self.lastProgressUpdateTime removeObjectForKey:asyncId];
        [self sendStorageEvent:@"FirebaseStorage_Download" listener:asyncId path:firebasePath localPath:localPath success:YES additionalData:nil];
    }];
    
    [downloadTask observeStatus:FIRStorageTaskStatusFailure handler:^(FIRStorageTaskSnapshot *snapshot) {
        [self.taskMap removeObjectForKey:asyncId];
        [self.lastProgressUpdateTime removeObjectForKey:asyncId];
        NSDictionary *data = snapshot.error ? @{@"error": snapshot.error.localizedDescription} : nil;
        [self sendStorageEvent:@"FirebaseStorage_Download" listener:asyncId path:firebasePath localPath:localPath success:NO additionalData:data];
    }];
    
    [downloadTask observeStatus:FIRStorageTaskStatusProgress handler:^(FIRStorageTaskSnapshot *snapshot) {
        [self throttleProgressUpdate:asyncId eventType:@"FirebaseStorage_Download" path:firebasePath localPath:localPath transferred:snapshot.progress.completedUnitCount total:snapshot.progress.totalUnitCount];
    }];
    
    return [asyncId doubleValue];
}

- (double)SDKFirebaseStorage_Upload:(NSString *)localPath firebasePath:(NSString *)firebasePath bucket:(NSString *)bucket {
    NSNumber *asyncId = [self getListenerInd];
    
    // Get the Application Support directory path
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSApplicationSupportDirectory, NSUserDomainMask, YES);
    NSString *appSupportDirectory = [paths firstObject];
    
    // Ensure the directory exists
    NSError *error = nil;
    [[NSFileManager defaultManager] createDirectoryAtPath:appSupportDirectory withIntermediateDirectories:YES attributes:nil error:&error];
    if (error) {
        NSString *errorMessage = [NSString stringWithFormat:@"Error creating Application Support directory: %@", error.localizedDescription];
        NSDictionary *data = @{@"error": errorMessage};
        [self sendStorageEvent:@"FirebaseStorage_Upload" listener:asyncId path:firebasePath localPath:localPath success:NO additionalData:data];
        return [asyncId doubleValue];
    }
    
    NSString *localFilePath = [appSupportDirectory stringByAppendingPathComponent:localPath];
    
    // Check if the local file exists
    if (![[NSFileManager defaultManager] fileExistsAtPath:localFilePath]) {
        NSDictionary *data = @{@"error": @"Local file does not exist"};
        [self sendStorageEvent:@"FirebaseStorage_Upload" listener:asyncId path:firebasePath localPath:localPath success:NO additionalData:data];
        return [asyncId doubleValue];
    }
    
    NSURL *localFile = [NSURL fileURLWithPath:localFilePath];
    FIRStorageReference *ref = [[[FIRStorage storage] reference] child:firebasePath];
    FIRStorageUploadTask *uploadTask = [ref putFile:localFile metadata:nil];
    
    // Store the task in taskMap
    self.taskMap[asyncId] = uploadTask;
    self.lastProgressUpdateTime[asyncId] = @(0);
    
    [uploadTask observeStatus:FIRStorageTaskStatusSuccess handler:^(FIRStorageTaskSnapshot *snapshot) {
        [self.taskMap removeObjectForKey:asyncId];
        [self.lastProgressUpdateTime removeObjectForKey:asyncId];
        [self sendStorageEvent:@"FirebaseStorage_Upload" listener:asyncId path:firebasePath localPath:localPath success:YES additionalData:nil];
    }];
    
    [uploadTask observeStatus:FIRStorageTaskStatusFailure handler:^(FIRStorageTaskSnapshot *snapshot) {
        [self.taskMap removeObjectForKey:asyncId];
        [self.lastProgressUpdateTime removeObjectForKey:asyncId];
        NSDictionary *data = snapshot.error ? @{@"error": snapshot.error.localizedDescription} : nil;
        [self sendStorageEvent:@"FirebaseStorage_Upload" listener:asyncId path:firebasePath localPath:localPath success:NO additionalData:data];
    }];
    
    [uploadTask observeStatus:FIRStorageTaskStatusProgress handler:^(FIRStorageTaskSnapshot *snapshot) {
        [self throttleProgressUpdate:asyncId eventType:@"FirebaseStorage_Upload" path:firebasePath localPath:localPath transferred:snapshot.progress.completedUnitCount total:snapshot.progress.totalUnitCount];
    }];
    
    return [asyncId doubleValue];
}

- (double)SDKFirebaseStorage_Delete:(NSString *)firebasePath bucket:(NSString *)bucket {
    NSNumber *asyncId = [self getListenerInd];
    FIRStorageReference *ref = [[[FIRStorage storage] reference] child:firebasePath];
    [ref deleteWithCompletion:^(NSError *error) {
        NSDictionary *data = error ? @{@"error": error.localizedDescription} : nil;
        BOOL success = (error == nil);
        [self sendStorageEvent:@"FirebaseStorage_Delete" listener:asyncId path:firebasePath localPath:nil success:success additionalData:data];
    }];
    return [asyncId doubleValue];
}

- (double)SDKFirebaseStorage_GetURL:(NSString *)firebasePath bucket:(NSString *)bucket {
    NSNumber *asyncId = [self getListenerInd];
    FIRStorageReference *ref = [[[FIRStorage storage] reference] child:firebasePath];
    [ref downloadURLWithCompletion:^(NSURL *URL, NSError *error) {
        NSMutableDictionary *data = [NSMutableDictionary dictionary];
        BOOL success = (error == nil);
        if (success) {
            data[@"value"] = URL.absoluteString;
        } else {
            data[@"error"] = error.localizedDescription;
        }
        [self sendStorageEvent:@"FirebaseStorage_GetURL" listener:asyncId path:firebasePath localPath:nil success:success additionalData:data];
    }];
    return [asyncId doubleValue];
}

- (double)SDKFirebaseStorage_List:(NSString *)firebasePath maxResults:(double)maxResults pageToken:(NSString *)pageToken bucket:(NSString *)bucket {
    NSNumber *asyncId = [self getListenerInd];
    FIRStorageReference *ref = [[[FIRStorage storage] reference] child:firebasePath];
    
    void (^completion)(FIRStorageListResult *result, NSError *error) = ^(FIRStorageListResult *result, NSError *error) {
        NSMutableDictionary *data = [NSMutableDictionary dictionary];
        BOOL success = (error == nil);
        if (success) {
            data[@"pageToken"] = result.pageToken ?: @"";
            data[@"files"] = [self listOfReferencesToJSON:result.items];
            data[@"folders"] = [self listOfReferencesToJSON:result.prefixes];
        } else {
            data[@"error"] = error.localizedDescription;
        }
        [self sendStorageEvent:@"FirebaseStorage_List" listener:asyncId path:firebasePath localPath:nil success:success additionalData:data];
    };
    
    int64_t maxResultsInt64 = (int64_t)maxResults;
    if (pageToken.length == 0) {
        [ref listWithMaxResults:maxResultsInt64 completion:completion];
    } else {
        [ref listWithMaxResults:maxResultsInt64 pageToken:pageToken completion:completion];
    }
    
    return [asyncId doubleValue];
}

- (double)SDKFirebaseStorage_ListAll:(NSString *)firebasePath bucket:(NSString *)bucket {
    NSNumber *asyncId = [self getListenerInd];
    FIRStorageReference *ref = [[[FIRStorage storage] reference] child:firebasePath];
    [ref listAllWithCompletion:^(FIRStorageListResult *result, NSError *error) {
        NSMutableDictionary *data = [NSMutableDictionary dictionary];
        BOOL success = (error == nil);
        if (success) {
            data[@"files"] = [self listOfReferencesToJSON:result.items];
            data[@"folders"] = [self listOfReferencesToJSON:result.prefixes];
        } else {
            data[@"error"] = error.localizedDescription;
        }
        [self sendStorageEvent:@"FirebaseStorage_ListAll" listener:asyncId path:firebasePath localPath:nil success:success additionalData:data];
    }];
    return [asyncId doubleValue];
}

#pragma mark - Helper Methods

- (NSNumber *)getListenerInd {
    return @([[FirebaseUtils sharedInstance] getNextAsyncId]);
}

- (NSString *)listOfReferencesToJSON:(NSArray<FIRStorageReference *> *)list {
    NSMutableArray *mutList = [NSMutableArray array];
    for (FIRStorageReference *ref in list) {
        [mutList addObject:ref.fullPath];
    }
    NSError *error = nil;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:mutList options:0 error:&error];
    if (!error) {
        return [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    } else {
        return @"[]";
    }
}

- (void)sendStorageEvent:(NSString *)eventType listener:(NSNumber*)listener path:(NSString *)path localPath:(NSString *)localPath success:(BOOL)success additionalData:(NSDictionary *)additionalData {
    NSMutableDictionary *data = [[NSMutableDictionary alloc] init];
    [data setObject:listener forKey:@"listener"];
    [data setObject:path forKey:@"path"];
    if (localPath) {
        [data setObject:localPath forKey:@"localPath"];
    }
    [data setObject:@(success) forKey:@"success"];

    if (additionalData) {
        [data setValuesForKeysWithDictionary:additionalData];
    }

    [FirebaseUtils sendSocialAsyncEvent:eventType data:data];
}

- (void)throttleProgressUpdate:(NSNumber*)asyncId eventType:(NSString *)eventType path:(NSString *)path localPath:(NSString *)localPath transferred:(int64_t)transferred total:(int64_t)total {
    static const NSTimeInterval MIN_PROGRESS_UPDATE_INTERVAL = 0.5; // 500ms
    NSTimeInterval currentTime = [[NSDate date] timeIntervalSince1970];
    NSTimeInterval lastUpdateTime = [self.lastProgressUpdateTime[asyncId] doubleValue];
    if (currentTime - lastUpdateTime >= MIN_PROGRESS_UPDATE_INTERVAL) {
        self.lastProgressUpdateTime[asyncId] = @(currentTime);
        NSDictionary *data = @{
            @"transferred": @(transferred),
            @"total": @(total)
        };
        [self sendStorageEvent:eventType listener:asyncId path:path localPath:localPath success:YES additionalData:data];
    }
}

@end
