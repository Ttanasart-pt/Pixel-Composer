
#macro FirebaseFirestore_Library_useSDK false
#macro Firestore_Query_less_than "LESS_THAN"
#macro Firestore_Query_less_than_or_equal "LESS_THAN_OR_EQUAL"
#macro Firestore_Query_greater_than "GREATER_THAN"
#macro Firestore_Query_greater_than_or_equal "GREATER_THAN_OR_EQUAL"
#macro Firestore_Query_equal "EQUAL"
#macro Firestore_Query_not_equal "NOT_EQUAL"
#macro Firestore_Query_ASCENDING "ASCENDING"
#macro Firestore_Query_DESCENDING "DESCENDING"

function FirebaseFirestore(path = undefined)
{
	return new Firebase_Firestore_builder(path)
}

function FirebaseFirestore_updatedPath(path)
{
	if(is_undefined(path))
	{
		_isDocument = 0.0//false
		_isCollection = 0.0//false
	}	
	else if(FirebaseREST_Firestore_path_isDocument(path))
	{
		_isDocument = 1.0//true
		_isCollection = 0.0//false
	}
	else
	{
		_isDocument = 0.0//false
		_isCollection = 1.0//true
	}
}

function Firebase_Firestore_builder(path) constructor
{
	_path = path
	
	_operations = undefined//[] where_operation,where_ref,where_value,
	
	//_order = undefined
	_orderBy_field = undefined
	_orderBy_direction = undefined
	
	_start = undefined
	_end = undefined
	_limit = undefined
	
	_action = ""
	_value = undefined
	
	FirebaseFirestore_updatedPath(_path)
	//_isDocument = undefined
	//_isCollection = undefined
	
	/*
	/// @function Document(child_path)
	static Document = function(child_path)
	{
		_path = FirebaseFirestore_Path_Join(_path,child_path)
		FirebaseFirestore_updatedPath(_path)
		return self
	}
	
	/// @function Collection(child_path)
	static Collection = function(child_path)
	{
		_path = FirebaseFirestore_Path_Join(_path,child_path)
		FirebaseFirestore_updatedPath(_path)
		
		return self
	}
	*/
	
	/// @function Child(child_path)
	static Child = function(child_path)
	{
		_path = FirebaseFirestore_Path_Join(_path,child_path)
		FirebaseFirestore_updatedPath(_path)
		
		return self
	}
	
	/// @function Parent()
	static Parent = function()
	{
		_path = FirebaseFirestore_Path_Back(_path,1)
		return self
	}
		
	/// @function OrderBy(path)
	static OrderBy = function(path)
	{
		if(argument_count == 2)
		{
			_orderBy_field = path
			_orderBy_direction = argument[1]
		}
		else
			_orderBy_field = path
		
		return self
	}
	
	/// @function Where(path, op, value)
	static Where = function(path, op, value) 
	{
		if(is_undefined(_operations))
			_operations = []
		
		op = FirebaseFirestore_operationFromSymbol(op);
			
		array_push(_operations, {operation: op, path: path, value: value})
		return self;
	}

	static WhereEqual = function(path,value)
	{
		if(is_undefined(_operations))
			_operations = []
		array_push(_operations,{operation: Firestore_Query_equal,path: path,value: value})
		return self
	}
	
	static WhereGreaterThan = function(path,value)
	{
		if(is_undefined(_operations))
			_operations = []
		array_push(_operations,{operation: Firestore_Query_greater_than,path: path,value: value})
		return self
	}
	
	static WhereGreaterThanOrEqual = function(path,value)
	{
		if(is_undefined(_operations))
			_operations = []
		array_push(_operations,{operation: Firestore_Query_greater_than_or_equal,path: path,value: value})
		return self
	}
	
	static WhereLessThan = function(path,value)
	{
		if(is_undefined(_operations))
			_operations = []
		array_push(_operations,{operation: Firestore_Query_less_than_or_equal,path: path,value: value})
		return self
	}
	
	static WhereLessThanOrEqual = function(path,value)
	{
		if(is_undefined(_operations))
			_operations = []
		array_push(_operations,{operation: Firestore_Query_equal,path: path,value: value})
		return self
	}
	
	static WhereNotEqual = function(path,value)
	{
		if(is_undefined(_operations))
			_operations = []
		array_push(_operations,{operation: Firestore_Query_not_equal,path: path,value: value})
		return self
	}
	
	/// @function Start(value)
	static StartAt = function(value)
    {
		_start = value
		return self
    }
	
	/// @function End(value)
	static EndAt = function(value)
    {
		_end = value
		return self
    }
	
	/// @function Limit(value)
	static Limit = function(value)
    {
		_limit = value
		return self
    }
	
	//Actions
	
	/// @function Set(value)
    static Set = function(value)
    {
		_action = "Set"
		_value = value
		
		if(FirebaseFirestore_Library_useSDK)
			return FirebaseFirestore_SDK(json_stringify(self))
		if(FirebaseREST_Firestore_path_isDocument(_path))
			return RESTFirebaseFirestore_Document_Set(_path,value)
		else
			return RESTFirebaseFirestore_Collection_Add(_path,value)
    }
	
	/// @function Update(value)
    static Update = function(value)
    {
		_action = "Update"
		_value = value
		if(FirebaseFirestore_Library_useSDK)
			return FirebaseFirestore_SDK(json_stringify(self))
		if(FirebaseREST_Firestore_path_isDocument(_path))
			return RESTFirebaseFirestore_Document_Update(_path,value)
		else
		{
			show_debug_message("Firestore: You can't update a Collection")
			exit
		}
    }
	
	/// @function Read()
    static Read = function()
    {
		_action = "Read"
		if(FirebaseFirestore_Library_useSDK)
			return FirebaseFirestore_SDK(json_stringify(self))
		if(FirebaseREST_Firestore_path_isDocument(_path))
			return RESTFirebaseFirestore_Document_Read(_path)
		else
			return RESTFirebaseFirestore_Collection_Read(_path)
    }
	
	/// @function Query()
	static Query = function()
	{
		_action = "Query"
		if(FirebaseFirestore_Library_useSDK)
		{
			return FirebaseFirestore_SDK(json_stringify(self))
		}
		if(FirebaseREST_Firestore_path_isCollection(_path))
			return RESTFirebaseFirestore_Collection_Query(self)
		else
			show_debug_message("Firestore: You can't query documents")
	}
	
	/// @function Listener()
    static Listener = function()
    {
		_action = "Listener"
		if(FirebaseFirestore_Library_useSDK)
			return FirebaseFirestore_SDK(json_stringify(self))
		if(FirebaseREST_Firestore_path_isDocument(_path))
			return RESTFirebaseFirestore_Document_Listener(_path)
		else
			return RESTFirebaseFirestore_Collection_Listener(_path)
    }
	
	/// @function Delete()
	static Delete = function()
    {
		_action = "Delete"
		if(FirebaseFirestore_Library_useSDK)
			return FirebaseFirestore_SDK(json_stringify(self))
		if(FirebaseREST_Firestore_path_isDocument(_path))
			return RESTFirebaseFirestore_Document_Delete(_path)
		else
		{
			show_debug_message("Firestore: You can't delete a Collection")
			exit
		}
    }
	
	static ListenerRemove = function(listener)
	{
		_action = "ListenerRemove"
		_value = listener
		if(FirebaseFirestore_Library_useSDK)
			return FirebaseFirestore_SDK(json_stringify(self))
		with(listener)
		    instance_destroy()
	}
	
	static ListenerRemoveAll = function()
	{
		_action = "ListenerRemoveAll"
		if(FirebaseFirestore_Library_useSDK)
			return FirebaseFirestore_SDK(json_stringify(self))
		with(Obj_FirebaseREST_Listener_Firestore)
		if(string_count("Listener",event))
			instance_destroy()
	}
}

