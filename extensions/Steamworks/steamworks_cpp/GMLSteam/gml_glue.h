/// gml_glue.h
#pragma once

#include "steam_glue.h"
#include "gml_ext.h"
#include "Extension_Interface.h"

// A wrapper for queuing async events for GML easier.
class steam_net_event {
private:
	int map;
public:
	steam_net_event() {
		map = CreateDsMap(0,0);
	}
	steam_net_event(char* type) {
		map = CreateDsMap(0,0);
		set((char*)"event_type", type);
	}
	~steam_net_event() {
		//
	}
	/// Dispatches this event and cleans up the map.
	void dispatch() {
		CreateAsyncEventWithDSMap(map, 69);
	}
	bool set(char* key, double value) {
		DsMapAddDouble(map, key, value);
		return true;
	}
	bool set(char* key, char* value) {
		DsMapAddString(map, key, value);
		return true;
	}
	bool set(char* key, uint64 value) {
		DsMapAddInt64(map, key, value);
		return true;
	}	
	bool set(char* key, int32 value) {
		DsMapAddDouble(map, key, (double)value);
		return true;
	}
	bool set(char* key, uint32 value) {
		DsMapAddDouble(map, key, (double)value);
		return true;
	}
	bool set(char* key, bool value) {
		DsMapAddBool(map, key, value);
		return true;
	}
	template<size_t size> void set_uint64_all(const char(&key)[size], uint64 value) {
		DsMapAddInt64(map, key, value);
	}
	template<size_t size> void set_steamid_all(const char(&key)[size], CSteamID& id) {
		DsMapAddInt64(map, key, id.ConvertToUint64());
	}
	void set_success(bool success) {
		set((char*)"success", success);
		set((char*)"result", success ? k_EResultOK : k_EResultFail);
	}
	void set_result(int result) {
		set((char*)"success", result == k_EResultOK);
		set((char*)"result", result);
	}
};
