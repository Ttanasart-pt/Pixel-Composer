
package ${YYAndroidPackageName};

import ${YYAndroidPackageName}.R;
import com.yoyogames.runner.RunnerJNILib;

import com.google.firebase.firestore.FirebaseFirestore;
import com.google.firebase.firestore.Blob;
import com.google.firebase.firestore.CollectionReference;
import com.google.firebase.firestore.DocumentChange;
import com.google.firebase.firestore.DocumentReference;
import com.google.firebase.firestore.DocumentSnapshot;
import com.google.firebase.firestore.FieldPath;
import com.google.firebase.firestore.FieldValue;
import com.google.firebase.firestore.FirebaseFirestoreSettings;
import com.google.firebase.firestore.FirebaseFirestoreSettings.Builder;
import com.google.firebase.firestore.GeoPoint;
import com.google.firebase.firestore.Query;
import com.google.firebase.firestore.QueryDocumentSnapshot;
import com.google.firebase.firestore.QuerySnapshot;
import com.google.firebase.firestore.SetOptions;
import com.google.firebase.firestore.SnapshotMetadata;
import com.google.firebase.firestore.Transaction;
import com.google.firebase.firestore.WriteBatch;
import com.google.firebase.firestore.EventListener;
import com.google.firebase.firestore.FirebaseFirestoreException;
import com.google.firebase.firestore.ListenerRegistration;

import com.google.android.gms.tasks.OnCompleteListener;
import com.google.android.gms.tasks.Task;
import com.google.android.gms.tasks.OnFailureListener;
import com.google.android.gms.tasks.OnSuccessListener;

import android.content.Context;
import android.app.Activity;
import android.content.Intent;
import android.util.Log;

import org.json.JSONObject;
import org.json.JSONArray;

import java.util.Map;
import java.util.HashMap;
import java.util.List;
import java.util.ArrayList;
import java.util.Iterator;
import java.lang.NullPointerException;
import java.lang.Exception;
import java.lang.Double;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;

public class YYFirebaseFirestore extends RunnerSocial
{
	private static final int EVENT_OTHER_SOCIAL = 70;
	public static Activity activity = RunnerActivity.CurrentActivity;
	
	private HashMap<String,ListenerRegistration> Firestore_listenerRegistration;
	
	//Start point of index
	//Autentication 5000
	//storage 6000
	//Firestore 7000
	//RealTime 10000
	private double Firestore_valueListernerInd = 7000;
	
	public YYFirebaseFirestore()
	{
		Firestore_listenerRegistration = new HashMap<String,ListenerRegistration>();
	}
	
	public double FirebaseFirestore_SDK(String fluent_json)
	{
		JSONObject fluent_obj;
		try 
		{fluent_obj = new JSONObject(fluent_json);}
		catch (Exception e) 
		{return(0.0);}
		
		String action = (String) JSONObjectGet(fluent_obj,"_action");
		double isDocument = ((Double)JSONObjectGet(fluent_obj,"_isDocument")).doubleValue();
		if(action.equals("Set"))
		{
			if(isDocument >= 0.5)
				return FirebaseFirestore_Document_Set(fluent_obj);
			else
				return Firebase_Firestore_collection_add_(fluent_obj);
		}
		else if(action.equals("Update"))
		{
			if(isDocument >= 0.5)
				return Firebase_Firestore_document_update_(fluent_obj);
			else
				return Log.i("yoyo","Firestore: You can't update a Collection");
		}
		else if(action.equals("Read"))
		{
			if(isDocument >= 0.5)
				return Firebase_Firestore_document_get_(fluent_obj);
			else
				return Firebase_Firestore_collection_get_(fluent_obj);
		}
		else if(action.equals("Listener"))
		{
			if(isDocument >= 0.5)
				return Firebase_Firestore_document_listener_(fluent_obj);
			else
				return Firebase_Firestore_collection_listener_(fluent_obj);			
		}
		else if(action.equals("Delete"))
		{
			if(isDocument >= 0.5)
				return Firebase_Firestore_document_delete_(fluent_obj);
			else
				return Log.i("yoyo","Firestore: You can't delete a Collection");
		}
		else if(action.equals("Query"))
		{
			if(isDocument < 0.5)
				return Firebase_Firestore_collection_query_(fluent_obj);
			else
				return Log.i("yoyo","Firestore: You can't Query documents");
		}
		else if(action.equals("ListenerRemove"))
			Firebase_Firestore_listener_remove_(fluent_obj);
		else if(action.equals("ListenerRemoveAll"))
			Firebase_Firestore_listener_removeAll();
		
		return 0.0;
	}
	
	//https://firebase.google.com/docs/reference/android/com/google/firebase/firestore/CollectionReference#document(java.lang.String)
	public double Firebase_Firestore_collection_add_(final JSONObject fluent_obj)
	{
		final double listenerInd = Firestore_getListenerInd();
		FirebaseFirestore.getInstance().collection((String) JSONObjectGet(fluent_obj,"_path")).add(jsonToMap((String) JSONObjectGet(fluent_obj,"_value"))).addOnCompleteListener(activity,new OnCompleteListener<DocumentReference>() 
		{
            @Override
            public void onComplete(@NonNull Task<DocumentReference> task)
			{
				int dsMapIndex = RunnerJNILib.jCreateDsMap(null,null,null);
				RunnerJNILib.DsMapAddString(dsMapIndex,"type","FirebaseFirestore_Collection_Add");
				RunnerJNILib.DsMapAddString(dsMapIndex,"path",(String)JSONObjectGet(fluent_obj,"_path"));
				RunnerJNILib.DsMapAddDouble(dsMapIndex,"listener",listenerInd);
                if(task.isSuccessful()) 
					RunnerJNILib.DsMapAddDouble(dsMapIndex,"status",200);
				else
					AddErrorCodeToCallback(dsMapIndex,task.getException());
				RunnerJNILib.CreateAsynEventWithDSMap(dsMapIndex,EVENT_OTHER_SOCIAL);				
            }
        });
		
		return listenerInd;
	}
	
	public double Firebase_Firestore_collection_get_(final JSONObject fluent_obj)
	{
		final double listenerInd = Firestore_getListenerInd();
		FirebaseFirestore.getInstance().collection((String) JSONObjectGet(fluent_obj,"_path")).get().addOnCompleteListener(activity,new OnCompleteListener<QuerySnapshot>() 
		{
            @Override
            public void onComplete(@NonNull Task<QuerySnapshot> task)
			{
				int dsMapIndex = RunnerJNILib.jCreateDsMap(null,null,null);
				RunnerJNILib.DsMapAddString(dsMapIndex,"type","FirebaseFirestore_Collection_Read");
				RunnerJNILib.DsMapAddString(dsMapIndex,"path",(String)JSONObjectGet(fluent_obj,"_path"));
				RunnerJNILib.DsMapAddDouble(dsMapIndex,"listener",listenerInd);
                if(task.isSuccessful()) 
				{
					RunnerJNILib.DsMapAddDouble(dsMapIndex,"status",200);
					RunnerJNILib.DsMapAddString(dsMapIndex,"value",Firestore_QuerySnapshot2String(task.getResult()));
				}
				else
					AddErrorCodeToCallback(dsMapIndex,task.getException());
				RunnerJNILib.CreateAsynEventWithDSMap(dsMapIndex,EVENT_OTHER_SOCIAL);
            }
        });
		
		return listenerInd;
	}
	
	public double Firebase_Firestore_collection_listener_(final JSONObject fluent_obj)
	{
		final double listenerInd = Firestore_getListenerInd();
		ListenerRegistration listenerRegistration = FirebaseFirestore.getInstance().collection((String) JSONObjectGet(fluent_obj,"_path")).addSnapshotListener(new EventListener<QuerySnapshot>()
		{
			@Override
			public void onEvent(@Nullable QuerySnapshot querySnapshot,@Nullable FirebaseFirestoreException error) 
			{
				int dsMapIndex = RunnerJNILib.jCreateDsMap(null, null, null);
				RunnerJNILib.DsMapAddString(dsMapIndex,"type","FirebaseFirestore_Collection_Listener");
				RunnerJNILib.DsMapAddString(dsMapIndex,"path",(String)JSONObjectGet(fluent_obj,"_path"));
				if(querySnapshot == null || error != null)
					AddErrorCodeToCallback(dsMapIndex,error);
				else
				{
					RunnerJNILib.DsMapAddDouble(dsMapIndex,"status",200);
					RunnerJNILib.DsMapAddString(dsMapIndex,"value",Firestore_QuerySnapshot2String(querySnapshot));
				}
				RunnerJNILib.DsMapAddDouble(dsMapIndex,"listener",listenerInd);
				RunnerJNILib.CreateAsynEventWithDSMap(dsMapIndex,EVENT_OTHER_SOCIAL);
			}
		});
		
		Firestore_listenerToMaps(listenerRegistration,listenerInd);
		return listenerInd;
	}
	
	//QUERY  https://firebase.google.com/docs/reference/android/com/google/firebase/firestore/Query
	public double Firebase_Firestore_collection_query_(final JSONObject fluent_obj)
	{
		final double listenerInd = Firestore_getListenerInd();
		Query query = FirebaseFirestore.getInstance().collection((String) JSONObjectGet(fluent_obj,"_path"));
		
		if(JSONObjectGet(fluent_obj,"_operations") != null)
		{
			JSONArray array;
			try 
			{array = fluent_obj.getJSONArray("_operations");}
			catch(Exception e)
			{Log.i("yoyo","Query: Operations Error"); return -4;}
			
			for(int a = 0 ; a < array.length() ; a ++)
			{
				JSONObject map;
				try 
				{map = array.getJSONObject(a);}
				catch(Exception e)
				{Log.i("yoyo","Query: Operations Error 2"); return -4;}
				
				String path = (String)JSONObjectGet(map,"path");
				switch((String) JSONObjectGet(map,"operation"))
				{
					case "EQUAL": query = query.whereEqualTo(path,JSONObjectGet(map,"value")); break;
					case "GREATER_THAN_OR_EQUAL": query = query.whereGreaterThanOrEqualTo(path,JSONObjectGet(map,"value")); break;
					case "GREATER_THAN": query = query.whereGreaterThan(path,JSONObjectGet(map,"value")); break;
					case "LESS_THAN_OR_EQUAL": query = query.whereLessThanOrEqualTo(path,JSONObjectGet(map,"value")); break;
					case "LESS_THAN": query = query.whereLessThan(path,JSONObjectGet(map,"value")); break;
				}
			}
		}
		
		if(JSONObjectGet(fluent_obj,"_orderBy_direction") != null && JSONObjectGet(fluent_obj,"_orderBy_field") != null)
		{
			if(((String)(JSONObjectGet(fluent_obj,"_orderBy_direction"))).equals("ASCENDING"))
				query = query.orderBy((String)JSONObjectGet(fluent_obj,"_orderBy_field"),com.google.firebase.firestore.Query.Direction.ASCENDING);
			if(((String)(JSONObjectGet(fluent_obj,"_orderBy_direction"))).equals("DESCENDING"))
				query = query.orderBy((String)JSONObjectGet(fluent_obj,"_orderBy_field"),com.google.firebase.firestore.Query.Direction.DESCENDING);
		} else if(JSONObjectGet(fluent_obj,"_orderBy_field") != null)
			query = query.orderBy((String)JSONObjectGet(fluent_obj,"_orderBy_field"));
		
		if(JSONObjectGet(fluent_obj,"_start") != null)
			query = query.startAt(JSONObjectGet(fluent_obj,"_start"));
		
		if(JSONObjectGet(fluent_obj,"_end") != null)
			query = query.endAt(JSONObjectGet(fluent_obj,"_end"));
		
		if(JSONObjectGet(fluent_obj,"_limit") != null)
			query = query.limit(((Double)JSONObjectGet(fluent_obj,"_limit")).intValue());
		
		query.get().addOnCompleteListener(activity,new OnCompleteListener<QuerySnapshot>() 
		{
            @Override
            public void onComplete(@NonNull Task<QuerySnapshot> task)
			{
				int dsMapIndex = RunnerJNILib.jCreateDsMap(null,null,null);
				RunnerJNILib.DsMapAddString(dsMapIndex,"type","FirebaseFirestore_Collection_Query");
				RunnerJNILib.DsMapAddString(dsMapIndex,"path",(String)JSONObjectGet(fluent_obj,"_path"));
				RunnerJNILib.DsMapAddDouble(dsMapIndex,"listener",listenerInd);
                if(task.isSuccessful()) 
				{
					RunnerJNILib.DsMapAddDouble(dsMapIndex,"status",200);
					RunnerJNILib.DsMapAddString(dsMapIndex,"value",Firestore_QuerySnapshot2String(task.getResult()));
				}
				else
					AddErrorCodeToCallback(dsMapIndex,task.getException());
				RunnerJNILib.CreateAsynEventWithDSMap(dsMapIndex,EVENT_OTHER_SOCIAL);				
            }
        });
		return listenerInd;
	}
	
	
	//https://firebase.google.com/docs/reference/android/com/google/firebase/firestore/DocumentReference
	// public double Firebase_Firestore_document_set_(final String jsonPath,String jsonValue)
	public double FirebaseFirestore_Document_Set(final JSONObject fluent_obj)
	{
		final double listenerInd = Firestore_getListenerInd();
		FirebaseFirestore.getInstance().document((String) JSONObjectGet(fluent_obj,"_path")).set(jsonToMap((String) JSONObjectGet(fluent_obj,"_value"))).addOnCompleteListener(activity,new OnCompleteListener<Void>() 
		{
            @Override
            public void onComplete(@NonNull Task<Void> task)
			{
				int dsMapIndex = RunnerJNILib.jCreateDsMap(null,null,null);
				RunnerJNILib.DsMapAddString(dsMapIndex,"type","FirebaseFirestore_Document_Set");
				RunnerJNILib.DsMapAddString(dsMapIndex,"path",(String)JSONObjectGet(fluent_obj,"_path"));
				RunnerJNILib.DsMapAddDouble(dsMapIndex,"listener",listenerInd);
                if(task.isSuccessful()) 
					RunnerJNILib.DsMapAddDouble(dsMapIndex,"status",200);
				else
					AddErrorCodeToCallback(dsMapIndex,task.getException());
				RunnerJNILib.CreateAsynEventWithDSMap(dsMapIndex,EVENT_OTHER_SOCIAL);				
            }
        });
		
		return listenerInd;
	}
	
	public double Firebase_Firestore_document_update_(final JSONObject fluent_obj)
	{
		final double listenerInd = Firestore_getListenerInd();
		FirebaseFirestore.getInstance().document((String) JSONObjectGet(fluent_obj,"_path")).update(jsonToMap((String) JSONObjectGet(fluent_obj,"_value"))).addOnCompleteListener(activity,new OnCompleteListener<Void>() 
		{
            @Override
            public void onComplete(@NonNull Task<Void> task)
			{
				int dsMapIndex = RunnerJNILib.jCreateDsMap(null,null,null);
				RunnerJNILib.DsMapAddString(dsMapIndex,"type","FirebaseFirestore_Document_Update");
				RunnerJNILib.DsMapAddString(dsMapIndex,"path",(String)JSONObjectGet(fluent_obj,"_path"));
				RunnerJNILib.DsMapAddDouble(dsMapIndex,"listener",listenerInd);
                if(task.isSuccessful()) 
					RunnerJNILib.DsMapAddDouble(dsMapIndex,"status",200);
				else
					AddErrorCodeToCallback(dsMapIndex,task.getException());
				RunnerJNILib.CreateAsynEventWithDSMap(dsMapIndex,EVENT_OTHER_SOCIAL);				
            }
        });
		return listenerInd;
	}
	
	 public double Firebase_Firestore_document_get_(final JSONObject fluent_obj)
	{
		final double listenerInd = Firestore_getListenerInd();
		FirebaseFirestore.getInstance().document((String) JSONObjectGet(fluent_obj,"_path")).get().addOnSuccessListener(new OnSuccessListener<DocumentSnapshot>() 
		{
			@Override
			public void onSuccess(DocumentSnapshot documentSnapshot)
			{
				int dsMapIndex = RunnerJNILib.jCreateDsMap(null, null, null);
				RunnerJNILib.DsMapAddString(dsMapIndex,"type","FirebaseFirestore_Document_Read");
				RunnerJNILib.DsMapAddString(dsMapIndex,"path",(String)JSONObjectGet(fluent_obj,"_path"));
				if(documentSnapshot.exists())
				{
					RunnerJNILib.DsMapAddDouble(dsMapIndex,"status",200);
					RunnerJNILib.DsMapAddString(dsMapIndex,"value",MapToJSON(documentSnapshot.getData()));
				}
				else
				{
					RunnerJNILib.DsMapAddDouble(dsMapIndex,"status",404);
					RunnerJNILib.DsMapAddString(dsMapIndex,"errorMessage","DOCUMENT NOT FOUND");
				}
				RunnerJNILib.DsMapAddDouble(dsMapIndex,"listener",listenerInd);
				RunnerJNILib.CreateAsynEventWithDSMap(dsMapIndex,EVENT_OTHER_SOCIAL);
			}
		}).addOnFailureListener(new OnFailureListener()
		{
			@Override
			public void onFailure(@NonNull Exception e) 
			{
				int dsMapIndex = RunnerJNILib.jCreateDsMap(null, null, null);
				RunnerJNILib.DsMapAddString(dsMapIndex,"type","FirebaseFirestore_Document_Read");
				RunnerJNILib.DsMapAddString(dsMapIndex,"path",(String)JSONObjectGet(fluent_obj,"_path"));
				AddErrorCodeToCallback(dsMapIndex,e);
				RunnerJNILib.DsMapAddDouble(dsMapIndex,"listener",listenerInd);
				RunnerJNILib.CreateAsynEventWithDSMap(dsMapIndex,EVENT_OTHER_SOCIAL);
			}
		});
		return listenerInd;
	}
	
	public double Firebase_Firestore_document_delete_(final JSONObject fluent_obj)
	{
		final double listenerInd = Firestore_getListenerInd();
		FirebaseFirestore.getInstance().document((String) JSONObjectGet(fluent_obj,"_path")).delete().addOnCompleteListener(activity,new OnCompleteListener<Void>() 
		{
            @Override
            public void onComplete(@NonNull Task<Void> task)
			{
				int dsMapIndex = RunnerJNILib.jCreateDsMap(null,null,null);
				RunnerJNILib.DsMapAddString(dsMapIndex,"type","FirebaseFirestore_Document_Delete");
				RunnerJNILib.DsMapAddString(dsMapIndex,"path",(String)JSONObjectGet(fluent_obj,"_path"));
				RunnerJNILib.DsMapAddDouble(dsMapIndex,"listener",listenerInd);
                if(task.isSuccessful()) 
					RunnerJNILib.DsMapAddDouble(dsMapIndex,"status",200);
				else
					AddErrorCodeToCallback(dsMapIndex,task.getException());
				RunnerJNILib.CreateAsynEventWithDSMap(dsMapIndex,EVENT_OTHER_SOCIAL);				
            }
        });
		
		return listenerInd;
	}
	
	public double Firebase_Firestore_document_listener_(final JSONObject fluent_obj)
	{
		final double listenerInd = Firestore_getListenerInd();
		ListenerRegistration listenerRegistration = FirebaseFirestore.getInstance().document((String) JSONObjectGet(fluent_obj,"_path")).addSnapshotListener(new EventListener<DocumentSnapshot>()
		{
			@Override
			public void onEvent(@Nullable DocumentSnapshot documentSnapshot,@Nullable FirebaseFirestoreException e) 
			{
				int dsMapIndex = RunnerJNILib.jCreateDsMap(null, null, null);
				RunnerJNILib.DsMapAddString(dsMapIndex,"type","FirebaseFirestore_Document_Listener");
				RunnerJNILib.DsMapAddString(dsMapIndex,"path",(String)JSONObjectGet(fluent_obj,"_path"));
				if(documentSnapshot == null || e != null)
					AddErrorCodeToCallback(dsMapIndex,e);
				else
				if(documentSnapshot.exists())
				{
					RunnerJNILib.DsMapAddDouble(dsMapIndex,"status",200);
					RunnerJNILib.DsMapAddString(dsMapIndex,"value",MapToJSON(documentSnapshot.getData()));
				}
				else
				{
					RunnerJNILib.DsMapAddDouble(dsMapIndex,"status",404);
					RunnerJNILib.DsMapAddString(dsMapIndex,"errorMessage","DOCUMENT NOT FOUND");
				}
				RunnerJNILib.DsMapAddDouble(dsMapIndex,"listener",listenerInd);
				RunnerJNILib.CreateAsynEventWithDSMap(dsMapIndex,EVENT_OTHER_SOCIAL);
			}
		});
		
		Firestore_listenerToMaps(listenerRegistration,listenerInd);
		return listenerInd;
	}
	
	//https://firebase.google.com/docs/reference/android/com/google/firebase/firestore/ListenerRegistration
	public void Firebase_Firestore_listener_remove_(final JSONObject fluent_obj)
	{
		double ID = ((Double) JSONObjectGet(fluent_obj,"_value")).doubleValue();
		Firestore_listenerRegistration.remove(String.valueOf(ID)).remove();
	}
	
	public void Firebase_Firestore_listener_removeAll()
	{
		
		JSONArray json_arr = new JSONArray();
		for(Map.Entry m : Firestore_listenerRegistration.entrySet())
			json_arr.put(m.getKey());
		
		for (int i = 0; i < json_arr.length(); i++)
		{
			try 
			{Firestore_listenerRegistration.remove(json_arr.getString(i)).remove();}
			catch(Exception e)
			{}
		}
	}
	
	///////////////////// Firestore Tools
	
	private Object JSONObjectGet(JSONObject jsonObj,String key)
	{
		try 
		{
			if(jsonObj.isNull(key)) 
				return null;
			return jsonObj.get(key);
		}
		catch(Exception e)
		{return null;}
	}
	
	private double Firestore_getListenerInd()
	{
		Firestore_valueListernerInd ++;
		return(Firestore_valueListernerInd);
	}
	
	private void Firestore_listenerToMaps(ListenerRegistration listenerRegistration,double ind)
	{
		Firestore_listenerRegistration.put(String.valueOf(ind),listenerRegistration);
	}
	
	private String Firestore_QuerySnapshot2String(QuerySnapshot querySnapshot)
	{				
		JSONObject obj = new JSONObject();
		for(DocumentSnapshot documentSnapshot : querySnapshot.getDocuments())
		{
			JSONObject json_obj = new JSONObject();
			Map<String, Object> map = documentSnapshot.getData();
			for(Map.Entry<String, Object> entry : map.entrySet())
			{
				String key = entry.getKey();
				Object value = entry.getValue();
				try {json_obj.put(key,value);} 
				catch (Exception e) 
				{e.printStackTrace();}
			}
			try {obj.put(documentSnapshot.getId(),json_obj);}
			catch (Exception e) 
			{e.printStackTrace();}
		}
		return obj.toString();
	}
	
	///////////////////// LIST/MAP TOOLS
	
	public static String MapToJSON(Map map)
	{
		try
		{
			return (new JSONObject(map).toString());
		}
		catch(Exception e)
		{
			return "{}";
		}
	}

	public static Map<String,Object> jsonToMap(String jsonStr)
	{
		try
		{
			JSONObject json = new JSONObject(jsonStr);
			Map<String,Object> retMap = new HashMap<String,Object>();
			if(json != JSONObject.NULL) 
				retMap = toMap(json);
			return retMap;
		}
		catch(Exception e)
		{
			return new HashMap<String,Object>();
		}	
	}

	public static Map<String,Object> toMap(JSONObject object) throws Exception 
	{
		Map<String,Object> map = new HashMap<String,Object>();
		Iterator<String> keysItr = object.keys();
		while(keysItr.hasNext()) 
		{
			String key = keysItr.next();
			Object value = object.get(key);

			if(value instanceof JSONArray) 
			{
				value = toList((JSONArray) value);
			}
			else 
				if(value instanceof JSONObject) 
				{
					value = toMap((JSONObject) value);
				}
				
			map.put(key,value);
		}
		return map;
	}

	public static List<Object> toList(JSONArray array) throws Exception 
	{
		List<Object> list = new ArrayList<Object>();
		for(int i = 0; i < array.length(); i++) 
		{
			Object value = array.get(i);
			if(value instanceof JSONArray) 
			{
				value = toList((JSONArray) value);
			}
			else 
				if(value instanceof JSONObject) 
				{
					value = toMap((JSONObject) value);
				}
			list.add(value);
		}
		return list;
	}
	
	public String ListOfMaps2JSONstring(List<Map<Map,Object>> list)
	{
		JSONArray json_arr = new JSONArray();
		for (Map<Map,Object> map : list) 
		{
			JSONObject json_obj = new JSONObject();
			json_arr.put(json_obj);
		}
		return json_arr.toString();
	}
	
	//https://firebase.google.com/docs/firestore/use-rest-api
	//https://firebase.google.com/docs/reference/android/com/google/firebase/firestore/FirebaseFirestoreException.Code
	//https://github.com/grpc/grpc/blob/master/doc/http-grpc-status-mapping.md
	
	public void AddErrorCodeToCallback(int dsMapIndex,Exception e)
	{
		double status = 400;
		if(e instanceof FirebaseFirestoreException)
		{
			FirebaseFirestoreException e_ = (FirebaseFirestoreException) e;
			if(e_.getCode() == FirebaseFirestoreException.Code.ABORTED) status = 400;
			if(e_.getCode() == FirebaseFirestoreException.Code.ALREADY_EXISTS) status = 409;
			if(e_.getCode() == FirebaseFirestoreException.Code.CANCELLED) status = 400;
			if(e_.getCode() == FirebaseFirestoreException.Code.DATA_LOSS) status = 400;
			if(e_.getCode() == FirebaseFirestoreException.Code.DEADLINE_EXCEEDED) status = 400;
			if(e_.getCode() == FirebaseFirestoreException.Code.FAILED_PRECONDITION) status = 400;
			if(e_.getCode() == FirebaseFirestoreException.Code.INTERNAL) status = 400;
			// if(e_.getCode() == FirebaseFirestoreException.Code.INVALID_ARGUMEN) status = 400;
			if(e_.getCode() == FirebaseFirestoreException.Code.NOT_FOUND) status = 404;
			if(e_.getCode() == FirebaseFirestoreException.Code.OUT_OF_RANGE) status = 400;
			if(e_.getCode() == FirebaseFirestoreException.Code.PERMISSION_DENIED) status = 403;
			if(e_.getCode() == FirebaseFirestoreException.Code.RESOURCE_EXHAUSTED) status = 400;
			if(e_.getCode() == FirebaseFirestoreException.Code.UNAUTHENTICATED) status = 401;
			if(e_.getCode() == FirebaseFirestoreException.Code.UNAVAILABLE) status = 503;
			if(e_.getCode() == FirebaseFirestoreException.Code.UNIMPLEMENTED) status = 400;
			if(e_.getCode() == FirebaseFirestoreException.Code.UNKNOWN) status = 400;
		}
		
		RunnerJNILib.DsMapAddDouble(dsMapIndex,"status",status);
		RunnerJNILib.DsMapAddString(dsMapIndex,"errorMessage",e.getMessage());
	}
}

