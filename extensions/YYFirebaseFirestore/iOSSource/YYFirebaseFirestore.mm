
#import "YYFirebaseFirestore.h"
#import <UIKit/UIKit.h>

const int EVENT_OTHER_SOCIAL = 70;
extern int CreateDsMap( int _num, ... );
extern void CreateAsynEventWithDSMap(int dsmapindex, int event_index);
extern UIViewController *g_controller;
extern UIView *g_glView;
extern int g_DeviceWidth;
extern int g_DeviceHeight;

extern "C" void dsMapClear(int _dsMap );
extern "C" int dsMapCreate();
extern "C" void dsMapAddInt(int _dsMap, char* _key, int _value);
extern "C" void dsMapAddDouble(int _dsMap, char* _key, double _value);
extern "C" void dsMapAddString(int _dsMap, char* _key, char* _value);

extern "C" int dsListCreate();
extern "C" void dsListAddInt(int _dsList, int _value);
extern "C" void dsListAddString(int _dsList, char* _value);
extern "C" const char* dsListGetValueString(int _dsList, int _listIdx);
extern "C" double dsListGetValueDouble(int _dsList, int _listIdx);
extern "C" int dsListGetSize(int _dsList);

extern "C" void createSocialAsyncEventWithDSMap(int dsmapindex);

@implementation YYFirebaseFirestore

	-(id) init
	{
		if(self = [super init])
		{
			if(![FIRApp defaultApp])
				[FIRApp configure];
				
			return self;
		}
	}

    -(void) Init
    {
		//Start point of index
		//Autentication 5000
		//storage 6000
		//Firestore 7000
		//RealTime 10000
		Firestore_indMap = 7000;
	
        Firestore_ListenerMap = [[NSMutableDictionary alloc]init];
    }

	-(double) FirebaseFirestore_SDK:(NSString*) fluent_json
	{
        NSDictionary *fluent_obj = [YYFirebaseFirestore json2dic:fluent_json];
        
        NSString *action = [fluent_obj valueForKey:@"_action"];
        double isDocument = [[fluent_obj valueForKey:@"_isDocument"] doubleValue];

		if([action isEqualToString:@"Set"])
		{
			if(isDocument >= 0.5)
				return [self Firebase_Firestore_document_set_:fluent_obj];
			else
				return [self Firebase_Firestore_collection_add_:fluent_obj];
		}
		else if([action isEqualToString:@"Update"])
		{
			if(isDocument >= 0.5)
				return [self Firebase_Firestore_document_update_:fluent_obj];
			else
				NSLog(@"Firestore: You can't update a Collection");
		}
		else if([action isEqualToString:@"Read"])
		{
			if(isDocument >= 0.5)
				return [self Firebase_Firestore_document_get_:fluent_obj];
			else
				return [self Firebase_Firestore_collection_get_:fluent_obj];
		}
		else if([action isEqualToString:@"Listener"])
		{
			if(isDocument >= 0.5)
				return [self Firebase_Firestore_document_listener_:fluent_obj];
			else
				return [self Firebase_Firestore_collection_listener_:fluent_obj];
		}
		else if([action isEqualToString:@"Delete"])
		{
			if(isDocument >= 0.5)
				return [self Firebase_Firestore_document_delete_:fluent_obj];
			else
				NSLog(@"Firestore: You can't delete a Collection");
		}
		else if([action isEqualToString:@"Query"])
		{
			if(isDocument < 0.5)
				return [self Firebase_Firestore_collection_query_:fluent_obj];
			else
				NSLog(@"Firestore:You can Query collecctions");
		}
		else if([action isEqualToString:@"ListenerRemove"])
            [self Firebase_Firestore_listener_remove_:fluent_obj];
        else if([action isEqualToString:@"ListenerRemoveAll"])
            [self Firebase_Firestore_listener_removeAll];
		
		return 0.0;
	}

-(double) Firestore_getListenerInd
{
    Firestore_indMap ++;
    return Firestore_indMap;
}

-(void) Firestore_listenerToMaps:(id<FIRListenerRegistration>) listener ind: (int) ind
{
    [Firestore_ListenerMap setValue:listener forKey:[NSString stringWithFormat:@"%d",ind]];
}

-(NSDictionary*) jsonToDic:(NSString*) json
{
    NSError *jsonError;
    NSData *objectData = [json dataUsingEncoding:NSUTF8StringEncoding];
    NSDictionary *dicValues = [NSJSONSerialization JSONObjectWithData:objectData
                                                               options:NSJSONReadingMutableContainers
                                                                 error:&jsonError];
    return dicValues;
}

-(NSString*) dicToJSON:(NSDictionary*) dic
{
    NSError *err;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dic options:0 error:&err];
    NSString *jsonStr = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    return jsonStr;
}

-(double) Firebase_Firestore_collection_add_:(NSDictionary*)fluent_obj
{
    int listenerInd = [self Firestore_getListenerInd];
    [[[FIRFirestore firestore] collectionWithPath:[fluent_obj valueForKey:@"_path"]] addDocumentWithData:[self jsonToDic:[fluent_obj valueForKey:@"_value"]] completion:^(NSError * _Nullable error)
    {
        int dsMapIndex = dsMapCreate();
        dsMapAddString(dsMapIndex,(char*)"type",(char*)"FirebaseFirestore_Collection_Add");
        dsMapAddString(dsMapIndex,(char*)"path",(char*)[(NSString*)[fluent_obj valueForKey:@"_path"] UTF8String]);
        [self AddStatusToCallback:dsMapIndex error:error];
        dsMapAddDouble(dsMapIndex,(char*)"listener",listenerInd);
        CreateAsynEventWithDSMap(dsMapIndex,EVENT_OTHER_SOCIAL);
    }];
    return listenerInd;
}

-(double) Firebase_Firestore_collection_get_:(NSDictionary*)fluent_obj
{
    int listenerInd = [self Firestore_getListenerInd];
    [[[FIRFirestore firestore] collectionWithPath:[fluent_obj valueForKey:@"_path"]] getDocumentsWithCompletion:^(FIRQuerySnapshot * _Nullable snapshot,
                                 NSError * _Nullable error)
    {
        int dsMapIndex = dsMapCreate();
        dsMapAddString(dsMapIndex,(char*)"type",(char*)"FirebaseFirestore_Collection_Read");
        dsMapAddString(dsMapIndex,(char*)"path",(char*)[(NSString*)[fluent_obj valueForKey:@"_path"] UTF8String]);
        dsMapAddDouble(dsMapIndex,(char*)"listener",listenerInd);
        if(error)
            [self AddStatusToCallback:dsMapIndex error:error];
        else
        {
                dsMapAddDouble(dsMapIndex,(char*)"status",200);
                dsMapAddString(dsMapIndex,(char*)"value",(char*)[[YYFirebaseFirestore FIRQuerySnapshotToJSON:snapshot] UTF8String]);
        }

        CreateAsynEventWithDSMap(dsMapIndex,EVENT_OTHER_SOCIAL);
    }];
    return listenerInd;
}

-(double) Firebase_Firestore_collection_listener_:(NSDictionary*)fluent_obj
{
    int listenerInd = [self Firestore_getListenerInd];
    
    id<FIRListenerRegistration> ID = [[[FIRFirestore firestore] collectionWithPath:[fluent_obj valueForKey:@"_path"]]
    addSnapshotListener:^(FIRQuerySnapshot *snapshot, NSError *error)
    {
        int dsMapIndex = dsMapCreate();
        dsMapAddString(dsMapIndex,(char*)"type",(char*)"FirebaseFirestore_Collection_Listener");
        dsMapAddString(dsMapIndex,(char*)"path",(char*)[(NSString*)[fluent_obj valueForKey:@"_path"] UTF8String]);
        dsMapAddDouble(dsMapIndex,(char*)"listener",listenerInd);
        if(error)
            [self AddStatusToCallback:dsMapIndex error:error];
        else
        {
            dsMapAddDouble(dsMapIndex,(char*)"status",200);
            dsMapAddString(dsMapIndex,(char*)"value",(char*)[[YYFirebaseFirestore FIRQuerySnapshotToJSON:snapshot] UTF8String]);
        }

        CreateAsynEventWithDSMap(dsMapIndex,EVENT_OTHER_SOCIAL);
    }];
    [self Firestore_listenerToMaps:ID ind:listenerInd];
    return listenerInd;
}

-(double) Firebase_Firestore_collection_query_:(NSDictionary*)fluent_obj
{
    int listenerInd = [self Firestore_getListenerInd];
    FIRQuery *query = [[FIRFirestore firestore] collectionWithPath:[fluent_obj valueForKey:@"_path"]];
    
    if([fluent_obj valueForKey:@"_operations"] != [NSNull null])
    {
        NSArray *array = [fluent_obj valueForKey:@"_operations"];
        for(int a = 0 ; a < [array count] ; a ++)
        {
            NSDictionary *dic = array[a];
            NSString* path = [dic valueForKey:@"path"];
            NSString* where_op = [dic valueForKey:@"operation"];
            id value = [dic valueForKey:@"value"];
            if([where_op isEqualToString:@"EQUAL"])
                    query = [query queryWhereField:path isEqualTo:value];
            if([where_op isEqualToString:@"GREATER_THAN_OR_EQUAL"])
                    query = [query queryWhereField:path isGreaterThanOrEqualTo:value];
            if([where_op isEqualToString:@"GREATER_THAN"])
                    query = [query queryWhereField:path isGreaterThan:value];
            if([where_op isEqualToString:@"LESS_THAN_OR_EQUAL"])
                    query = [query queryWhereField:path isLessThanOrEqualTo:value];
            if([where_op isEqualToString:@"LESS_THAN"])
                    query = [query queryWhereField:path isLessThan:value];
        }
    }
    
    if([fluent_obj valueForKey:@"_orderBy_direction"] != [NSNull null])
    if([fluent_obj valueForKey:@"_orderBy_direction"] != [NSNull null] && [fluent_obj valueForKey:@"_orderBy_field"] != [NSNull null])
    {
		if([[fluent_obj valueForKey:@"_orderBy_direction"] isEqualToString:@"ASCENDING"])
			query = [query queryOrderedByField:[fluent_obj valueForKey:@"_orderBy_field"] descending:FALSE];
		if([[fluent_obj valueForKey:@"_orderBy_direction"] isEqualToString:@"DESCENDING"])
			query = [query queryOrderedByField:[fluent_obj valueForKey:@"_orderBy_field"] descending:TRUE];
    }
	else
		query = [query queryOrderedByField:[fluent_obj valueForKey:@"_orderBy_field"]];
	
	if([fluent_obj valueForKey:@"_orderBy_direction"] != [NSNull null])
    
    if([fluent_obj valueForKey:@"_start"] != [NSNull null])
        query = [query queryStartingAtValues:@[[fluent_obj valueForKey:@"_start"]]];
    
    if([fluent_obj valueForKey:@"_end"] != [NSNull null])
        query = [query queryEndingAtValues:@[[fluent_obj valueForKey:@"_start"]]];
    
    if([fluent_obj valueForKey:@"_limit"] != [NSNull null])
        query = [query queryLimitedTo: [[fluent_obj valueForKey:@"_limit"] intValue]];
    
    [query getDocumentsWithCompletion:^(FIRQuerySnapshot * _Nullable snapshot,
                                 NSError * _Nullable error)
    {
        int dsMapIndex = dsMapCreate();
        dsMapAddString(dsMapIndex,(char*)"type",(char*)"FirebaseFirestore_Collection_Query");
        dsMapAddString(dsMapIndex,(char*)"path",(char*)[(NSString*)[fluent_obj valueForKey:@"_path"] UTF8String]);
        dsMapAddDouble(dsMapIndex,(char*)"listener",listenerInd);
        if(error)
            [self AddStatusToCallback:dsMapIndex error:error];
        else
        {
            dsMapAddDouble(dsMapIndex,(char*)"status",200);
            dsMapAddString(dsMapIndex,(char*)"value",(char*)[[YYFirebaseFirestore FIRQuerySnapshotToJSON:snapshot] UTF8String]);
        }
        CreateAsynEventWithDSMap(dsMapIndex,EVENT_OTHER_SOCIAL);
    }];
    return listenerInd;
}


//https://firebase.google.com/docs/reference/android/com/google/firebase/firestore/DocumentReference
-(double) Firebase_Firestore_document_set_:(NSDictionary*)fluent_obj//:(NSString*) jsonPath value: (NSString*) [fluent_obj valueForKey:@"_value"];
{
    int listenerInd = [self Firestore_getListenerInd];
    [[[FIRFirestore firestore] documentWithPath:[fluent_obj valueForKey:@"_path"]] setData:[self jsonToDic:[fluent_obj valueForKey:@"_value"]] completion:^(NSError * _Nullable error)
    {
        int dsMapIndex = dsMapCreate();
        dsMapAddString(dsMapIndex,(char*)"type",(char*)"FirebaseFirestore_Document_Set");
        dsMapAddString(dsMapIndex,(char*)"path",(char*)[(NSString*)[fluent_obj valueForKey:@"_path"] UTF8String]);
        [self AddStatusToCallback:dsMapIndex error:error];
        dsMapAddDouble(dsMapIndex,(char*)"listener",listenerInd);
        CreateAsynEventWithDSMap(dsMapIndex,EVENT_OTHER_SOCIAL);
    }];
    return listenerInd;
}

-(double) Firebase_Firestore_document_update_:(NSDictionary*)fluent_obj//:(NSString*) jsonPath value: (NSString*) [fluent_obj valueForKey:@"_value"];
{
    int listenerInd = [self Firestore_getListenerInd];
    [[[FIRFirestore firestore] documentWithPath:[fluent_obj valueForKey:@"_path"]] updateData:[self jsonToDic:[fluent_obj valueForKey:@"_value"]] completion:^(NSError * _Nullable error)
    {
        int dsMapIndex = dsMapCreate();
        dsMapAddString(dsMapIndex,(char*)"type",(char*)"FirebaseFirestore_Document_Update");
        dsMapAddString(dsMapIndex,(char*)"path",(char*)[(NSString*)[fluent_obj valueForKey:@"_path"] UTF8String]);
        [self AddStatusToCallback:dsMapIndex error:error];
        dsMapAddDouble(dsMapIndex,(char*)"listener",listenerInd);
        CreateAsynEventWithDSMap(dsMapIndex,EVENT_OTHER_SOCIAL);
    }];
    return listenerInd;
}

-(double) Firebase_Firestore_document_get_:(NSDictionary*)fluent_obj//:(NSString*) jsonPath
{
    int listenerInd = [self Firestore_getListenerInd];
    
    [[[FIRFirestore firestore] documentWithPath:[fluent_obj valueForKey:@"_path"]] getDocumentWithCompletion:^(FIRDocumentSnapshot * _Nullable snapshot, NSError * _Nullable error)
    {
        int dsMapIndex = dsMapCreate();
        dsMapAddString(dsMapIndex,(char*)"type",(char*)"FirebaseFirestore_Document_Read");
        dsMapAddString(dsMapIndex,(char*)"path",(char*)[(NSString*)[fluent_obj valueForKey:@"_path"] UTF8String]);
        dsMapAddDouble(dsMapIndex,(char*)"listener",listenerInd);
        if(error)
            [self AddStatusToCallback:dsMapIndex error:error];
        else
        {
            if(![snapshot exists])
            {
                dsMapAddDouble(dsMapIndex,(char*)"status",404);
                dsMapAddString(dsMapIndex,(char*)"errorMessage",(char*)"Some requested document was not found.");
            }
            else
            {
                dsMapAddDouble(dsMapIndex,(char*)"status",200);
                dsMapAddString(dsMapIndex,(char*)"value",(char*)[[YYFirebaseFirestore FIRDocumentSnapshotToJSON:snapshot] UTF8String]);
            }
        }
        CreateAsynEventWithDSMap(dsMapIndex,EVENT_OTHER_SOCIAL);
    }];
    return listenerInd;
}

-(double) Firebase_Firestore_document_delete_:(NSDictionary*)fluent_obj//:(NSString*) jsonPath
{
    int listenerInd = [self Firestore_getListenerInd];
    [[[FIRFirestore firestore] documentWithPath:[fluent_obj valueForKey:@"_path"]] deleteDocumentWithCompletion:^(NSError * _Nullable error)
    {
        int dsMapIndex = dsMapCreate();
        dsMapAddString(dsMapIndex,(char*)"type",(char*)"FirebaseFirestore_Document_Delete");
        dsMapAddString(dsMapIndex,(char*)"path",(char*)[(NSString*)[fluent_obj valueForKey:@"_path"] UTF8String]);
        [self AddStatusToCallback:dsMapIndex error:error];
        dsMapAddDouble(dsMapIndex,(char*)"listener",listenerInd);
        CreateAsynEventWithDSMap(dsMapIndex,EVENT_OTHER_SOCIAL);
    }];
    return listenerInd;
}

-(double) Firebase_Firestore_document_listener_:(NSDictionary*)fluent_obj//:(NSString*) jsonPath
{
    int listenerInd = [self Firestore_getListenerInd];
    id<FIRListenerRegistration> ID = [[[FIRFirestore firestore] documentWithPath:[fluent_obj valueForKey:@"_path"]] addSnapshotListener:^(FIRDocumentSnapshot *snapshot, NSError *error)
    {
        int dsMapIndex = dsMapCreate();
        dsMapAddString(dsMapIndex,(char*)"type",(char*)"FirebaseFirestore_Document_Listener");
        dsMapAddString(dsMapIndex,(char*)"path",(char*)[(NSString*)[fluent_obj valueForKey:@"_path"] UTF8String]);
        dsMapAddDouble(dsMapIndex,(char*)"listener",listenerInd);
        if(error)
            [self AddStatusToCallback:dsMapIndex error:error];
        else
        {
            if(![snapshot exists])
            {
                dsMapAddDouble(dsMapIndex,(char*)"status",404);
                dsMapAddString(dsMapIndex,(char*)"errorMessage",(char*)"Some requested document was not found.");
            }
            else
            {
                dsMapAddDouble(dsMapIndex,(char*)"status",200);
                dsMapAddString(dsMapIndex,(char*)"value",(char*)[[YYFirebaseFirestore FIRDocumentSnapshotToJSON:snapshot] UTF8String]);
            }
        }
        CreateAsynEventWithDSMap(dsMapIndex,EVENT_OTHER_SOCIAL);
    }];
    [self Firestore_listenerToMaps:ID ind:listenerInd];
    return listenerInd;
}

-(void) Firebase_Firestore_listener_remove_:(NSDictionary*)fluent_obj//:(double) ind
{
    int ind = [[fluent_obj valueForKey:@"_value"] doubleValue];
    id<FIRListenerRegistration> ID = [Firestore_ListenerMap valueForKey:[NSString stringWithFormat:@"%d",(int)ind]];
    [ID remove];
    [Firestore_ListenerMap removeObjectForKey:[NSString stringWithFormat:@"%d",(int)ind]];
}

-(void) Firebase_Firestore_listener_removeAll
{
    NSMutableArray *array = [NSMutableArray new];
    for(NSString* key in Firestore_ListenerMap)
        [array addObject:key];
    
    for(NSString* key in array)
    {
        id<FIRListenerRegistration> ID = [Firestore_ListenerMap valueForKey:key];
        [ID remove];
        [Firestore_ListenerMap removeObjectForKey:key];
    }
}

+(NSString*) FIRQuerySnapshotToJSON:(FIRQuerySnapshot*)snapshot
{
    NSMutableDictionary *mutList = [NSMutableDictionary new];
    NSArray *array = snapshot.documents;
    for(int a = 0 ; a < array.count ; a ++)
    {
        [mutList setObject:[array[a] data] forKey:[array[a] documentID]];
    }
    return [YYFirebaseFirestore toJSON:mutList];
}

+(NSString*) FIRDocumentSnapshotToJSON:(FIRDocumentSnapshot*) snapshot
{
    if(snapshot == nil)
        return @"{}";
    if([snapshot data] == nil)
        return @"{}";
    
    return [YYFirebaseFirestore toJSON:[snapshot data]];
}

+(NSDictionary*) json2dic:(NSString*) json
{
    NSError *jsonError = nil;
    NSData *objectData = [json dataUsingEncoding:NSUTF8StringEncoding];
    NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:objectData
                                                               options:NSJSONReadingMutableContainers
                                                                 error:&jsonError];
    if(jsonError == nil)
        return dic;
    return nil;
}

+(NSString*) toJSON:(id) obj
{
    NSError *error = nil;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:obj
                                                           options:0//NSJSONWritingPrettyPrinted
                                                             error:&error];
    if(error == nil)
        return [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    else
        return @"{}";
}

enum Error {
  kErrorOk = 0,
  kErrorNone = 0,
  kErrorCancelled = 1,
  kErrorUnknown = 2,
  kErrorInvalidArgument = 3,
  kErrorDeadlineExceeded = 4,
  kErrorNotFound = 5,
  kErrorAlreadyExists = 6,
  kErrorPermissionDenied = 7,
  kErrorResourceExhausted = 8,
  kErrorFailedPrecondition = 9,
  kErrorAborted = 10,
  kErrorOutOfRange = 11,
  kErrorUnimplemented = 12,
  kErrorInternal = 13,
  kErrorUnavailable = 14,
  kErrorDataLoss = 15,
  kErrorUnauthenticated = 16
};

-(void) AddStatusToCallback:(int) dsMapIndex error:(NSError*) e
{
    //i found this code in Firestore/core/src/util/status.cc
    if(e)
    {
        NSLog(@"Kaguva Error: %@",[e localizedDescription]);
        dsMapAddString(dsMapIndex,(char*)"errorMessage",(char*)[[e localizedDescription] UTF8String]);
        switch(e.code)
        {
          case Error::kErrorCancelled:
                dsMapAddDouble(dsMapIndex,(char*)"status",400);
            break;
          case Error::kErrorUnknown:
                dsMapAddDouble(dsMapIndex,(char*)"status",400);
            break;
          case Error::kErrorInvalidArgument:
                dsMapAddDouble(dsMapIndex,(char*)"status",400);
            break;
          case Error::kErrorDeadlineExceeded:
                dsMapAddDouble(dsMapIndex,(char*)"status",400);
            break;
          case Error::kErrorNotFound:
                dsMapAddDouble(dsMapIndex,(char*)"status",404);
            break;
          case Error::kErrorAlreadyExists:
                dsMapAddDouble(dsMapIndex,(char*)"status",409);
            break;
          case Error::kErrorPermissionDenied:
                dsMapAddDouble(dsMapIndex,(char*)"status",403);
            break;
          case Error::kErrorUnauthenticated:
                dsMapAddDouble(dsMapIndex,(char*)"status",401);
            break;
          case Error::kErrorResourceExhausted:
                dsMapAddDouble(dsMapIndex,(char*)"status",400);
            break;
          case Error::kErrorFailedPrecondition:
                dsMapAddDouble(dsMapIndex,(char*)"status",400);
            break;
          case Error::kErrorAborted:
                dsMapAddDouble(dsMapIndex,(char*)"status",400);
            break;
          case Error::kErrorOutOfRange:
                dsMapAddDouble(dsMapIndex,(char*)"status",400);
            break;
          case Error::kErrorUnimplemented:
                dsMapAddDouble(dsMapIndex,(char*)"status",400);
            break;
          case Error::kErrorInternal:
                dsMapAddDouble(dsMapIndex,(char*)"status",400);
            break;
          case Error::kErrorUnavailable:
                dsMapAddDouble(dsMapIndex,(char*)"status",503);
            break;
          case Error::kErrorDataLoss:
                dsMapAddDouble(dsMapIndex,(char*)"status",400);
            break;
          default:
                dsMapAddDouble(dsMapIndex,(char*)"status",400);
            break;
        }
    }
    else
        dsMapAddDouble(dsMapIndex,(char*)"status",200);
}

@end

