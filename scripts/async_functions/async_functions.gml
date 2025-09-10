function asyncInit() {
	global.asyncCalls = ds_map_create();
}

function asyncCall(aid, callback = noone, parameters = {}) {
	global.asyncCalls[? aid] = { callback, parameters };
}

function asyncLoad(data) {
	if(!ds_map_exists(global.asyncCalls, data[? "id"])) return false;
	
	var cal = global.asyncCalls[? data[? "id"]];
	var callback   = cal.callback;
	var parameters = cal.parameters;
	if(callback != noone) callback(parameters, data);
	
	if(data[? "status"] == 0) ds_map_delete(global.asyncCalls, data[? "id"]);
	
	return true;
}