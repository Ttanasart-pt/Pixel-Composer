
function RESTFirebaseFirestore_Collection_Add(path,json)
{
	if(!FirebaseREST_Firestore_path_isCollection(path))
	{show_debug_message("error: path not correspond to collection") exit}
	
	var listener = FirebaseREST_asyncFunction_Firestore(
				"FirebaseFirestore_Collection_Add",
				Obj_FirebaseREST_Listener_Once_Firestore,
				FirebaseREST_Firestore_getURL(path),
				"POST",
				FirebaseREST_Firestore_headerToken(),
				FirebaseREST_Firestore_jsonEncode(json));
	listener.path = path
	return listener
}

function RESTFirebaseFirestore_Collection_Read(path)
{
	if(!FirebaseREST_Firestore_path_isCollection(path))
	{show_debug_message("error: path not correspond to collection") exit}
	
	var listener = FirebaseREST_asyncFunction_Firestore(
				"FirebaseFirestore_Collection_Read",
				Obj_FirebaseREST_Listener_Once_Firestore,
				FirebaseREST_Firestore_getURL(path),
				"GET",
				FirebaseREST_Firestore_headerToken(),
				"");
	listener.path = path
	return listener
}

function RESTFirebaseFirestore_Collection_Listener(path)
{
	if(!FirebaseREST_Firestore_path_isCollection(path))
	{show_debug_message("error: path not correspond to collection") exit}
	
	var listener = FirebaseREST_asyncFunction_Firestore(
				"FirebaseFirestore_Collection_Listener",
				Obj_FirebaseREST_Listener_On_firestore_collection,
				FirebaseREST_Firestore_getURL(path),
				"GET",
				FirebaseREST_Firestore_headerToken(),
				"");
			
	listener.path = path
	return listener
}

/*
function RESTFirebaseFirestore_Collection_Query(
				path,
				where_operation,where_ref,where_value,
				where_operation2,where_ref2,where_value2,
				orderBy_direction,orderBy_field,
				start,
				end_,
				limit,
				
				)
{
	Firestore_Query_ASCENDING
	Firestore_Query_DESCENDING
	Firestore_Query_equal
	Firestore_Query_greater_than
	Firestore_Query_greater_than_or_equal
	Firestore_Query_less_than
	Firestore_Query_less_than_or_equal
}
*/

function RESTFirebaseFirestore_Collection_Query(struct)
{
	var path = struct._path

	var start = struct._start
	var end_ = struct._end
	var limit = struct._limit
	
	if(!FirebaseREST_Firestore_path_isCollection(path))
	{show_debug_message("error: path not correspond to collection") exit}
	
	var original_ref = path
	//https://firebase.google.com/docs/firestore/reference/rest/v1/StructuredQuery

	/////////////////
	var collection = FirebaseFirestore_Path_GetName(path,0)

	//From
	var list_from = ds_list_create()
	var map_collector = ds_map_create()
	ds_map_add(map_collector,"collectionId",collection)
	ds_map_add(map_collector,"allDescendants","false")
	//var map_count = json_decode(path)
	//var size = ds_map_size(map_count)
	//ds_map_destroy(map_count)
	//if(true)//if(size mod 2 != 0)//unpair//collection
	{
		ds_list_add(list_from,map_collector)
		ds_list_mark_as_map(list_from,0)
	}
	
	path = FirebaseFirestore_Path_Back(path,1)
	
	//Where
	var map_where = ds_map_create()
	var map_compositeFilter = ds_map_create()
	ds_map_add(map_compositeFilter,"op","AND")
	var list_filters = ds_list_create()
	
	if(!is_undefined(struct._operations))
	for(var a = 0 ; a < array_length(struct._operations) ; a++)//if(!is_undefined(struct._operations[0]))
	{
		var map_FieldFilter = ds_map_create()
		ds_map_add_map(map_FieldFilter,"field",FirebaseREST_firestore_fieldReference(struct._operations[a].path))
		ds_map_add(map_FieldFilter,"op",struct._operations[a].operation)
		ds_map_add_map(map_FieldFilter,"value",FirebaseREST_firestore_value(struct._operations[a].value))
		var map_toList = ds_map_create()
		ds_map_add_map(map_toList,"fieldFilter",map_FieldFilter)
		ds_list_add(list_filters,map_toList)
	}
	
	for(var a = 0 ; a < ds_list_size(list_filters) ; a++)
		ds_list_mark_as_map(list_filters,a)

	ds_map_add_list(map_compositeFilter,"filters",list_filters)
	ds_map_add_map(map_where,"compositeFilter",map_compositeFilter)

	/////////////////////////////////////////// orderBy
	var list_orderBy = ds_list_create()
	
	if(!is_undefined(struct._orderBy_direction) and !is_undefined(struct._orderBy_field))
	{
		var map_orderList = ds_map_create()
		
		ds_map_add_map(map_orderList,"field",FirebaseREST_firestore_fieldReference(struct._orderBy_field))
	
		if(!is_undefined(struct._orderBy_direction))
			ds_map_add(map_orderList,"direction",struct._orderBy_direction)
	
		ds_list_add(list_orderBy,map_orderList)
		ds_list_mark_as_map(list_orderBy,0)
	}
	
	////////////////////////////////////////// startAt
	var map_startAt
	if(is_undefined(start))
		map_startAt = ds_map_create()
	else
		map_startAt = FirebaseREST_firestore_cursor(start,1)

	////////////////////////////////////////// endAt
	var map_endAt
	if(is_undefined(end_))
		map_endAt = ds_map_create()
	else
		map_endAt = FirebaseREST_firestore_cursor(end_,0)


	///////map_structuredQuery
	var map_structuredQuery = ds_map_create()

	ds_map_add_list(map_structuredQuery,"from",list_from)

	if(ds_map_size(map_where))
		ds_map_add_map(map_structuredQuery,"where",map_where)
	else
		ds_map_destroy(map_where)

	if(ds_list_size(list_orderBy))
		ds_map_add_list(map_structuredQuery,"orderBy",list_orderBy)
	else
		ds_list_destroy(list_orderBy)

	if(ds_map_size(map_startAt))
		ds_map_add_map(map_structuredQuery,"startAt",map_startAt)
	else
		ds_map_destroy(map_startAt)

	if(ds_map_size(map_endAt))
		ds_map_add_map(map_structuredQuery,"endAt",map_endAt)
	else
		ds_map_destroy(map_endAt)

	//limit
	if(!is_undefined(limit))
		ds_map_add(map_structuredQuery,"limit",limit)


	///////requestBody
	var map_requestBody = ds_map_create()
	ds_map_add_map(map_requestBody,"structuredQuery",map_structuredQuery)

	var json = json_encode(map_requestBody)
	ds_map_destroy(map_requestBody)
	
	var listener = FirebaseREST_asyncFunction_Firestore(
				"FirebaseFirestore_Collection_Query",
				Obj_FirebaseREST_Listener_Once_Firestore,
				FirebaseREST_Firestore_getURL(path),
				"POST",
				FirebaseREST_Firestore_headerToken(),
				json)

	listener.url += ":runQuery"
	listener.path = original_ref

	return listener
}


function RESTFirebaseFirestore_Document_Delete(path)
{
	if(!FirebaseREST_Firestore_path_isDocument(path))
	{show_debug_message("error: path not correspond to document") exit}
	
	var listener = FirebaseREST_asyncFunction_Firestore(
			"FirebaseFirestore_Document_Delete",
			Obj_FirebaseREST_Listener_Once_Firestore,
			FirebaseREST_Firestore_getURL(path),
			"DELETE",
			FirebaseREST_Firestore_headerToken(),
			"")
	listener.path = path
	
	return listener
}


function RESTFirebaseFirestore_Document_Read(path)
{
	if(!FirebaseREST_Firestore_path_isDocument(path))
	{show_debug_message("error: path not correspond to document") exit}
	
	var listener = FirebaseREST_asyncFunction_Firestore(
				"FirebaseFirestore_Document_Read",
				Obj_FirebaseREST_Listener_Once_Firestore,
				FirebaseREST_Firestore_getURL(path),
				"GET",
				FirebaseREST_Firestore_headerToken(),
				"")
	
	listener.path = path
	return listener
}

function RESTFirebaseFirestore_Document_Listener(path)
{
	if(!FirebaseREST_Firestore_path_isDocument(path))
	{show_debug_message("error: path not correspond to document") exit}
	
	var listener = FirebaseREST_asyncFunction_Firestore(
				"FirebaseFirestore_Document_Listener",
				Obj_FirebaseREST_Listener_On_firestore_document,
				FirebaseREST_Firestore_getURL(path),
				"GET",
				FirebaseREST_Firestore_headerToken(),
				"")
	
	listener.path = path
	return listener
}

/*Deprecated due if exists not override the document, and SDKs do it.....
function RESTFirebaseFirestore_Document_Set(path,json)
{
	if(!FirebaseREST_Firestore_path_isDocument(path))
	{show_debug_message("error: path not correspond to document") exit}
	
	var original_ref = path
	var doc_name = FirebaseFirestore_Path_GetName(path,0)
	var ref_ = FirebaseFirestore_Path_Back(path,1)
	var listener = FirebaseREST_asyncFunction_Firestore(
				"FirebaseFirestore_Document_Set",
				Obj_FirebaseREST_Listener_Once_Firestore,
				FirebaseREST_Firestore_getURL(ref_),
				"POST",
				FirebaseREST_Firestore_headerToken(),
				FirebaseREST_Firestore_jsonEncode(json),
				)
	listener.url += "?documentId=" + doc_name
	listener.path = original_ref
	return listener
}
*/

function RESTFirebaseFirestore_Document_Set(path,json)
{
	if(!FirebaseREST_Firestore_path_isDocument(path))
	{show_debug_message("error: path not correspond to document") exit}
	
	var listener = FirebaseREST_asyncFunction_Firestore(
					"RESTFirebaseFirestore_Document_Set",
					Obj_FirebaseREST_Listener_Once_Firestore,
					FirebaseREST_Firestore_getURL(path),
					"PATCH",
					FirebaseREST_Firestore_headerToken(),
					FirebaseREST_Firestore_jsonEncode(json))
	listener.path = path
	return listener
}

function RESTFirebaseFirestore_Document_Update(path,json)
{
	if(!FirebaseREST_Firestore_path_isDocument(path))
	{show_debug_message("error: path not correspond to document") exit}
	
	var listener = FirebaseREST_asyncFunction_Firestore(
					"RESTFirebaseFirestore_Document_Update",
					Obj_FirebaseREST_Listener_Once_Firestore,
					FirebaseREST_Firestore_getURL(path),
					"PATCH",
					FirebaseREST_Firestore_headerToken(),
					FirebaseREST_Firestore_jsonEncode(json)
				)
	listener.url += FriebaseREST_Firestore_urlUpdateMask(json)
	show_debug_message(listener.url)
	listener.path = path
	return listener
}
