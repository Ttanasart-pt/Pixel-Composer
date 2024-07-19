function asyncInit() {
	global.asyncCalls = ds_map_create();
}

function asyncCall(aid, callback = noone, parameters = {}) {
	global.asyncCalls[? aid] = [ callback, parameters ];
}

function asyncLoad(data) {
	if(!ds_map_exists(global.asyncCalls, data[? "id"])) return;
	
	var cal = global.asyncCalls[? data[? "id"]];
	var callback   = cal[0];
	var parameters = cal[1];
	if(callback != noone) callback(parameters, data);
	
	ds_map_delete(global.asyncCalls, data[? "id"]);
}