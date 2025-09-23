#region global
	globalvar ACCOUNT_ID;   ACCOUNT_ID   = undefined;
	globalvar ACCOUNT_DATA; ACCOUNT_DATA = undefined;
	
#endregion

function __initAccount() {
	ACCOUNT_ID   = undefined;
	ACCOUNT_DATA = undefined;

	var _path = $"{DIRECTORY}token";
	if(!file_exists_empty(_path)) return;
	
	var _m = ds_map_secure_load(_path);
	var email = _m[? "email"];
	var passw = _m[? "passw"];
	
	asyncCallGroup("social", FirebaseAuthentication_SignIn_Email(email, passw), function(_params, _data) /*=>*/ {
		if (_data[? "status"] == 200) {
	        noti_status("Login successfully!");
	        loginAccount(_params.email, _params.passw);

	    } else
	        noti_warning(_data[? "errorMessage"]);
	    
	}, { email, passw } );
	
}

function createAccount(data, email) {
	var jdata  = json_try_parse(data);
	var userId = jdata.users[0].localId;
	var _sdata = json_stringify({ 
		email, 
		userId,
		
		steamid: "",
	});
	
	asyncCallGroup("social", FirebaseFirestore($"users/{userId}").Update(_sdata), function(_params, _data) /*=>*/ {
		if (_data[? "status"] != 200) { print(_data[? "errorMessage"]); return; }
	});
}

function loginAccount(email, passw) {
	var _m = ds_map_create();
	_m[? "email"] = email;
	_m[? "passw"] = passw;
	
	ds_map_secure_save(_m, $"{DIRECTORY}token");
	ds_map_destroy(_m);
	
	var userId = FirebaseAuthentication_GetLocalId();
	PXC_Login(userId);
}

function PXC_Login(uid) {
	log_message("ACCOUNT", "Re-Login successful");
	ACCOUNT_ID = uid;
	
	ACCOUNT_DATA = {
		displayName: FirebaseAuthentication_GetDisplayName(),
		email:       FirebaseAuthentication_GetEmail(),
		photoUrl:    FirebaseAuthentication_GetPhotoUrl(),
		steamid: "",
	}
	
	asyncCallGroup("social", FirebaseFirestore($"user").Where("userId", "==", ACCOUNT_ID).Query(), function(_params, _data) /*=>*/ {
		if (_data[? "status"] != 200) { noti_warning(_data[? "errorMessage"]); return; }
	    
	    var res  = _data[? "value"];
	    var resJ = json_try_parse(res, undefined);
	    if(resJ == undefined) return;
	    
	    var resA = struct_try_get(resJ, ACCOUNT_ID);
	    if(!is_struct(resA)) return;
	    
    	data = resA;
    	ACCOUNT_DATA.steamid = data[$ "steamid"] ?? "";
	});
	
}

function PXC_Logout() {
	if(ACCOUNT_ID == undefined) return;
	
	ACCOUNT_ID   = undefined;
	ACCOUNT_DATA = undefined;
	file_delete_safe($"{DIRECTORY}token");
}