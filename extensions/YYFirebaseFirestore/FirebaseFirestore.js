
let Firestore_Firestore_listenerIdMap = {};

//Start point of index
//Autentication 5000
//storage 6000
//Firestore 7000
//RealTime 10000
let Firestore_indMap = 7000;

function FirebaseFirestore_SDK(json,callback)
{
	let fluent_obj = JSON.parse(json);
	let action = fluent_obj._action;
	let isDocument = fluent_obj._isDocument;
	
	if(action == "Set")
	{
		if(isDocument >= 0.5)
			return YYFirebasetore_Document_Set(fluent_obj);
		else
			return YYFirebasetore_collection_add_(fluent_obj);
	}
	else if(action == "Update")
	{
		if(isDocument >= 0.5)
			return YYFirebasetore_document_update_(fluent_obj);
		else
			console.log("Firestore: You can't update a Collection");
	}
	else if(action == "Read")
	{
		if(isDocument >= 0.5)
			return YYFirebasetore_document_get_(fluent_obj);
		else
			return YYFirebasetore_collection_get_(fluent_obj);
	}
	else if(action == "Listener")
	{
		if(isDocument >= 0.5)
			return YYFirebasetore_document_listener_(fluent_obj);
		else
			return YYFirebasetore_collection_listener_(fluent_obj);			
	}
	else if(action == "Delete")
	{
		if(isDocument >= 0.5)
			return YYFirebasetore_document_delete_(fluent_obj);
		else
			console.log("Firestore: You can't delete a Collection");
	}
	else if(action == "Query")
	{
		if(isDocument < 0.5)
			return YYFirebasetore_collection_query_(fluent_obj);
		else
			console.log("Firebase: You can't Query documents");
	}
	else if(action == "ListenerRemove")
		YYFirebasetore_listener_remove_(fluent_obj);
	else if(action == "ListenerRemoveAll")
		YYFirebasetore_listener_removeAll();
	
	return 0.0;
}

function YYFirebasetore_Document_Set(fluent_obj)
{
	const listenerInd = Firestore_getListenerInd();
	let ref = firebase.firestore().doc(fluent_obj._path).set(JSON.parse(fluent_obj._value)).then(() => 
	{
		GMS_API.send_async_event_social({
			type:"FirebaseFirestore_Document_Set",
			listener:listenerInd,
			path:fluent_obj._path,
			status:200,
		});
	}).catch((error) => 
	{
		let data = {
				type:"FirebaseFirestore_Document_Set",
				listener:listenerInd,
				path:fluent_obj._path,
			};
		data = InsertStatusData(data,error);
		GMS_API.send_async_event_social(data);
	});
	return(listenerInd);
}

function YYFirebasetore_collection_add_(fluent_obj)
{
	const listenerInd = Firestore_getListenerInd();
	firebase.firestore().collection(fluent_obj._path).add(JSON.parse(fluent_obj._value)).then((docRef) => 
	{
		GMS_API.send_async_event_social({
			type:"FirebaseFirestore_Collection_Add",
			listener:listenerInd,
			path:fluent_obj._path,
			status:200,
			//value:
			});
	}).catch((error) => 
	{
		let data = {
				type:"FirebaseFirestore_Collection_Add",
				listener:listenerInd,
				path:fluent_obj._path,
			};
		data = InsertStatusData(data,error);
		GMS_API.send_async_event_social(data);
	});
	return(listenerInd);
}

function YYFirebasetore_document_update_(fluent_obj)
{
	const listenerInd = Firestore_getListenerInd();
	firebase.firestore().doc(fluent_obj._path).update(JSON.parse(fluent_obj._value)).then(() => 
	{
		GMS_API.send_async_event_social({
			type:"FirebaseFirestore_Document_Update",
			listener:listenerInd,
			path:fluent_obj._path,
			status:200,
			//value:
			});
	}).catch((error) => 
	{
		let data = {
				type:"FirebaseFirestore_Document_Update",
				listener:listenerInd,
				path:fluent_obj._path,
			};
		data = InsertStatusData(data,error);
		GMS_API.send_async_event_social(data);
	});
	return(listenerInd);
}

function YYFirebasetore_document_get_(fluent_obj)
{
	const listenerInd = Firestore_getListenerInd();
	firebase.firestore().doc(fluent_obj._path).get().then((doc) => 
	{
		if(doc.exists)
		{
			GMS_API.send_async_event_social({
				type:"FirebaseFirestore_Document_Read",
				listener:listenerInd,
				path:fluent_obj._path,
				status:200,
				value: JSON.stringify(doc.data())
				});
		} 
		else
		{
			GMS_API.send_async_event_social({
				type:"FirebaseFirestore_Document_Read",
				listener:listenerInd,
				path:fluent_obj._path,
				status:404,
				errorMessage:"DOCUMENT NOT FOUND"
				});
		}
				
	}).catch((error) => 
	{
		let data = {
				type:"FirebaseFirestore_Document_Read",
				listener:listenerInd,
				path:fluent_obj._path,
			};
		data = InsertStatusData(data,error);
		GMS_API.send_async_event_social(data);
	});
	return(listenerInd);
}

function YYFirebasetore_collection_get_(fluent_obj)
{
	const listenerInd = Firestore_getListenerInd();
	firebase.firestore().collection(fluent_obj._path).get().then((querySnapshot) => 
		{
			let array = querysnap2array(querySnapshot);
			GMS_API.send_async_event_social({
				type:"FirebaseFirestore_Collection_Read",
				listener:listenerInd,
				path:fluent_obj._path,
				status:200,
				value: JSON.stringify(array)
				});
		}).catch((error) => 
		{
			let data = {
					type:"FirebaseFirestore_Collection_Read",
					listener:listenerInd,
					path:fluent_obj._path,
				};
			data = InsertStatusData(data,error);
			GMS_API.send_async_event_social(data);
		});
	return(listenerInd);
}

function YYFirebasetore_document_listener_(fluent_obj)
{
	const listenerInd = Firestore_getListenerInd();
	let listener = firebase.firestore().doc(fluent_obj._path).onSnapshot((docSnap) => 
	{
		GMS_API.send_async_event_social({
			type:"FirebaseFirestore_Document_Listener",
			listener:listenerInd,
			path:fluent_obj._path,
			status:200,
			value: JSON.stringify(docSnap.data())
			});
	},(error) => 
	{
		let data = {
				type:"FirebaseFirestore_Document_Listener",
				listener:listenerInd,
				path:fluent_obj._path,
			};
		data = InsertStatusData(data,error);
		GMS_API.send_async_event_social(data);
	});

	listenerToMaps(listener,listenerInd);
	return(listenerInd);
}

function YYFirebasetore_collection_listener_(fluent_obj)
{
	const listenerInd = Firestore_getListenerInd();
	let listener = firebase.firestore().collection(fluent_obj._path).onSnapshot((querySnapshot) => 
		{
			let array = querysnap2array(querySnapshot);
			GMS_API.send_async_event_social({
				type:"FirebaseFirestore_Collection_Listener",
				listener:listenerInd,
				path:fluent_obj._path,
				status:200,
				value: JSON.stringify(array)
				});
		},(error) => 
		{
			let data = {
					type:"FirebaseFirestore_Collection_Listener",
					listener:listenerInd,
					path:fluent_obj._path,
				};
			data = InsertStatusData(data,error);
			GMS_API.send_async_event_social(data);
		});
	
	listenerToMaps(listener,listenerInd);
	return(listenerInd);
}

function YYFirebasetore_document_delete_(fluent_obj)
{
	const listenerInd = Firestore_getListenerInd();
	firebase.firestore().doc(fluent_obj._path).delete().then(() => 
	{
		GMS_API.send_async_event_social({
			type:"FirebaseFirestore_Document_Delete",
			listener:listenerInd,
			path:fluent_obj._path,
			status:200,
			// value: 
			});
	}).catch((error) => 
	{
		let data = {
				type:"FirebaseFirestore_Document_Delete",
				listener:listenerInd,
				path:fluent_obj._path,
			};
		data = InsertStatusData(data,error);
		GMS_API.send_async_event_social(data);
	});
	return(listenerInd);
}

function YYFirebasetore_collection_query_(fluent_obj)
{
	const listenerInd = Firestore_getListenerInd();
	let query = firebase.firestore().collection(fluent_obj._path);
	
	if(fluent_obj._orderBy_direction !== null && fluent_obj._orderBy_field !== null)
	{
		if(fluent_obj._orderBy_direction == "ASCENDING")
			query = query.orderBy(fluent_obj._orderBy_field,"asc");
		if(fluent_obj._orderBy_direction == "DESCENDING")
			query = query.orderBy(fluent_obj._orderBy_field,"desc");
	} else if(fluent_obj._orderBy_field !== null)
		query = query.orderBy(fluent_obj._orderBy_field);
	
	if(fluent_obj._operations !== null)
	{
		let array = fluent_obj._operations;
		for(let a = 0 ; a < array.length ; a ++)
		{
			let map = array[a];
			let path = map.path;
			switch(map.operation)
			{
				case "EQUAL": query = query.where(path, "==", map.value); break;
				case "GREATER_THAN_OR_EQUAL": query = query.where(path, ">=", map.value); break;
				case "GREATER_THAN": query = query = query.where(path, ">", map.value); break;
				case "LESS_THAN_OR_EQUAL": query = query.where(path, "<=", map.value); break;
				case "LESS_THAN": query = query.where(path, "<", map.value); break;
			}
		}
	}
	
	if(fluent_obj._start !== null)
		query = query.startAt(fluent_obj._start);
	
	if(fluent_obj._end !== null)
		query = query.endAt(fluent_obj._end);
	
	if(fluent_obj._limit !== null)
		query = query.limit(fluent_obj._limit);
		
		
	query.get().then((querySnapshot) => 
		{
			let array = querysnap2array(querySnapshot);
			GMS_API.send_async_event_social({
				type:"FirebaseFirestore_Collection_Query",
				listener:listenerInd,
				path:fluent_obj._path,
				status:200,
				value: JSON.stringify(array)
				});
		}).catch((error) => 
		{
			let data = {
					type:"FirebaseFirestore_Collection_Query",
					listener:listenerInd,
					path:fluent_obj._path,
				};
			data = InsertStatusData(data,error);
			GMS_API.send_async_event_social(data);
		});
	return(listenerInd);
}

function listenerToMaps(listenerId,ind)
{
	Firestore_Firestore_listenerIdMap[ind.toString()] = listenerId;
}

function Firestore_getListenerInd()
{
	Firestore_indMap ++;
	return(Firestore_indMap);
}

function querysnap2array(querySnap)
{
	let array = [];
	var docs = querySnap.docs;
	for(let a = 0 ; a < docs.length ; a ++)
		array.push(docs[a].data());
	
	return array
}

function YYFirebasetore_listener_remove_(fluent_obj)
{
	let ind = fluent_obj._value;
	let func = Firestore_Firestore_listenerIdMap[ind.toString()];
	func();
	delete Firestore_Firestore_listenerIdMap[ind.toString()];
}

function YYFirebasetore_listener_removeAll()
{
	for (let key in Firestore_Firestore_listenerIdMap) 
	{
		let ind = key;
		let func = Firestore_Firestore_listenerIdMap[ind];
		func();
		delete Firestore_Firestore_listenerIdMap[ind];
	}
}


//https://firebase.google.com/docs/reference/js/v8/firebase.firestore.FirestoreError
//https://firebase.google.com/docs/reference/js/v8/firebase.firestore#firestoreerrorcode
//https://firebase.google.com/docs/reference/js/v8/firebase.functions.HttpsError#error
function InsertStatusData(obj,error)
{
	if(error == null)
	{
		obj.status = 200;
		return obj;
	}
	
	let http_status = 400;
	if("code" in error)//if(error instanceof firebase.functions.HttpsError)
	switch(error.code)
	{
		case "ok": http_status = 200; break;
		case "cancelled": http_status = 400; break;
		case "unknown": http_status = 400; break;
		case "invalid-argument": http_status = 400; break;
		case "deadline-exceeded": http_status = 400; break;
		case "not-found": http_status = 400; break;
		case "already-exists": http_status = 409; break;
		case "permission-denied": http_status = 403; break;
		case "resource-exhausted": http_status = 400; break;
		case "failed-precondition": http_status = 400; break;
		case "aborted": http_status = 400; break;
		case "out-of-range": http_status = 400; break;
		case "unimplemented": http_status = 400; break;
		case "internal": http_status = 400; break;
		case "unavailable": http_status = 503; break;
		case "data-loss": http_status = 400; break;
		case "unauthenticated": http_status = 401; break;
	}
	
	obj.status = http_status;
	obj.errorMessage = error.message;
	
	return obj;
}




