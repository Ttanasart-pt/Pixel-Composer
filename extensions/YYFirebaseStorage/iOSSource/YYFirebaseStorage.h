
#import <FirebaseCore/FirebaseCore.h>
#import <FirebaseStorage/FirebaseStorage-Swift.h>

@interface YYFirebaseStorage : NSObject

- (double)SDKFirebaseStorage_Cancel:(double)ind;
- (double)SDKFirebaseStorage_Download:(NSString *)localPath firebasePath:(NSString *)firebasePath bucket:(NSString *)bucket;
- (double)SDKFirebaseStorage_Upload:(NSString *)localPath firebasePath:(NSString *)firebasePath bucket:(NSString *)bucket;
- (double)SDKFirebaseStorage_Delete:(NSString *)firebasePath bucket:(NSString *)bucket;
- (double)SDKFirebaseStorage_GetURL:(NSString *)firebasePath bucket:(NSString *)bucket;
- (double)SDKFirebaseStorage_List:(NSString *)firebasePath maxResults:(double)maxResults pageToken:(NSString *)pageToken bucket:(NSString *)bucket;
- (double)SDKFirebaseStorage_ListAll:(NSString *)firebasePath bucket:(NSString *)bucket;

@end