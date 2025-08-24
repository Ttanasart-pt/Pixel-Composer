
#import <FirebaseCore/FirebaseCore.h>

#if !defined(__has_include)
  #error "Firebase.h won't import anything if your compiler doesn't support __has_include. Please \
          import the headers individually."
#else

  #if __has_include(<FirebaseFirestore/FirebaseFirestore.h>)
    #import <FirebaseFirestore/FirebaseFirestore.h>
  #endif

#endif  // defined(__has_include)

@interface YYFirebaseFirestore:NSObject
{
    NSMutableDictionary *Firestore_ListenerMap;
    int Firestore_indMap;
}

@end

