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
	var complete   = false;
	if(callback != noone) {
		var res = callback(parameters, data);
		if(res != undefined) complete = res;
	}
	
	if(complete) ds_map_delete(global.asyncCalls, _id);
	return true;
}

/*[cpp] async_test
//init RegisterCallbacks
#include <thread>

typedef void (*CreateAsyncEventFn)(int ds_map_id, int event_type);
typedef int  (*DSMapCreateFn)(int _num, ...);
typedef bool (*DSMapAddStringFn)(int _index, const char* _key, const char* _value);
typedef bool (*DSMapAddDoubleFn)(int _index, const char* _key, double _value);

CreateAsyncEventFn CreateAsyncEvent = nullptr;
DSMapCreateFn      DSMapCreate      = nullptr;
DSMapAddStringFn   DSMapAddString   = nullptr;
DSMapAddDoubleFn   DSMapAddDouble   = nullptr;

cfunction void RegisterCallbacks( char* arg1, char* arg2, char* arg3, char* arg4 ) {
    CreateAsyncEvent = reinterpret_cast<CreateAsyncEventFn>(arg1);
    DSMapCreate      = reinterpret_cast<DSMapCreateFn>(arg2);
    DSMapAddDouble   = reinterpret_cast<DSMapAddDoubleFn>(arg3);
    DSMapAddString   = reinterpret_cast<DSMapAddStringFn>(arg4);
}

int asyncCall(int event_id_val, int event_type, char* type, double status, char* message) {
    int async_map = DSMapCreate(0);
    if (async_map < 0) return -2;

    bool ok = true;
    ok &= DSMapAddString( async_map, "type",     type         );
    ok &= DSMapAddDouble( async_map, "status",   status       );
    ok &= DSMapAddDouble( async_map, "event_id", event_id_val );
    ok &= DSMapAddString( async_map, "message",  message      );
    if (!ok) return -3;

    CreateAsyncEvent(async_map, event_type);
    return 0;
}

int task(int event_id_val) {
    std::this_thread::sleep_for(std::chrono::seconds(1));
    return asyncCall(event_id_val, 70, "async_test", 200.0, "Hello from C++ DLL!");
}

cfunction double TriggerAsyncEvent(double event_id_val) {
    if (!CreateAsyncEvent || !DSMapCreate || !DSMapAddString || !DSMapAddDouble)
        return -1.0;
    
    std::thread(task, static_cast<int>(event_id_val)).detach();

    return 1.0;
}
*/

