globalvar USER_DATA; USER_DATA = undefined;

function UserAccount() constructor {
	userid   = STEAM_USER_ID;
	steamid  = string(STEAM_ID);
	username = STEAM_USERNAME;
	active   = bool(IS_PATREON);
	
	badges   = [];
	voteData = {};
	
	static getVoteData = function(_fid) {
		if(struct_has(voteData, _fid)) return voteData[$ _fid];
		
		voteData[$ _fid] = -4;
		var _vote_id = md5_string_unicode($"{_fid},{steamid}");
		
		asyncCallGroup("social", FirebaseFirestore($"votes/{_vote_id}").Read(), function(_params, _data) /*=>*/ {
			var stat = _data[? "status"];
	    	var _fid = _params.file_id;
	    	
	    	if(stat == 404) { voteData[$ _fid] = 0; return; }
			if(_data[? "status"] != 200) { print($"update user data error {_data[? "errorMessage"]}"); return; }
	    	
		    var res  = _data[? "value"];
		    var resJ = json_try_parse(res, undefined);
		    if(resJ == undefined) return;
	    	
		    voteData[$ _fid] = resJ.vote_type;
		    
		}, { file_id: _fid });
	}  
	
	static appendData = function(_data) {
		if(!is_struct(_data)) return;
		
		userid   = _data[$ "userid"]   ?? userid;
		steamid  = _data[$ "steamid"]  ?? steamid;
		username = _data[$ "username"] ?? username;
		active   = _data[$ "active"]   ?? active;
		
		if(has(_data, "badges"))           badges           = json_try_parse(_data[$ "badges"]);
	}
	
	static serialize = function() {
		var _data = { 
			userid   : userid,
			steamid  : steamid,
			username : username,
			active   : active,
			
			badges   : json_stringify(badges),
		};
		
		return json_stringify(_data);
	}
	
	static update = function() {
		var _sdata = serialize();
			
		asyncCallGroup("social", FirebaseFirestore($"steam/{steamid}").Update(_sdata), function(_params, _data) /*=>*/ {
			var _type = _data[? "type"];
		    if (_data[? "status"] != 200) { print($"update user data error {_data[? "errorMessage"]}"); return; }
		});
	}
}

function __initUser() {
	IS_PATREON = false;
	var _path = DIRECTORY + "patreon";
	
	if(!file_exists_empty(_path)) return;
	var _load = ds_map_secure_load(_path);
	var _code = ds_map_try_get(_load, "code")
	
	IS_PATREON = string_starts_with(_code, "pxc");
	
	if(STEAM_ENABLED) {
		asyncCallGroup("social", FirebaseFirestore($"steam").Where("steamid", "==", string(STEAM_ID)).Query(), function(_params, _data) /*=>*/ {
			if (_data[? "status"] != 200) { print("get user data error", _data[? "errorMessage"]); return; }
		    
		    USER_DATA = new UserAccount();
		    
		    var res  = _data[? "value"];
		    var resJ = json_try_parse(res, undefined);
		    
		    if(resJ != undefined) {
			    var resA = struct_try_get(resJ, string(STEAM_ID));
			    USER_DATA.appendData(resA);
		    }
		    
		    USER_DATA.update();
		});
	}
	
	__initAccount();
}

