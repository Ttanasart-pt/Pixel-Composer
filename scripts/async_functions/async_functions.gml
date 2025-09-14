function asyncInit() {
	global.asyncCalls = ds_map_create();
}

function asyncCall(            aid, callback = noone, parameters = {}) { global.asyncCalls[? aid] = { callback, parameters, group: "" }; }
function asyncCallGroup(group, aid, callback = noone, parameters = {}) { global.asyncCalls[? aid] = { callback, parameters, group     }; }

function asyncLoad(data, _key = "id", _group = "") {
	var _id = data[? _key];
	if(!ds_map_exists(global.asyncCalls, _id)) return false;
	
	var cal = global.asyncCalls[? _id];
	if(cal.group != "" && cal.group != _group) return false;
	
	var callback   = cal.callback;
	var parameters = cal.parameters;
	if(callback != noone) callback(parameters, data);
	
	ds_map_delete(global.asyncCalls, _id);
	
	return true;
}