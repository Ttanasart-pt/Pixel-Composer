// apollo_buffer.h:
#pragma once
#include "stdafx.h"

///~
enum lua_btype {
	lua_btype_nil,
	lua_btype_bool,
	lua_btype_int32,
	lua_btype_int64,
	lua_btype_real,
	lua_btype_string,
	lua_btype_array,
	lua_btype_struct,
	lua_btype_script,
	lua_btype_method,
	lua_btype_ref,
};

struct buffer {
	int8* pos;
public:
	buffer(void* origin) : pos((char*)origin) {}
	template<class T> T read() {
		T r = *(T*)pos;
		pos += sizeof(T);
		return r;
	}
	template<class T> void write(T val) {
		*(T*)pos = val;
		pos += sizeof(T);
	}
	template<class T> T* writeStore(T val) {
		auto p = (T*)pos;
		*p = val;
		pos += sizeof(T);
		return p;
	}
	//
	lua_btype read_type() { return (lua_btype)read<char>(); }
	void write_type(lua_btype t) { write<int8>((int8)t); }
	void write_lua_bool(bool val) { write_type(lua_btype_bool); write(val); }
	void write_lua_real(double val) { write_type(lua_btype_real); write(val); }
	void write_lua_int64(long long val) { write_type(lua_btype_int64); write(val); }
	//
	const char* read_string() {
		const char* r = pos;
		while (*pos != 0) pos++;
		pos++;
		return r;
	}
	void write_string(const char* s) {
		if (s != nullptr) for (int i = 0; s[i] != 0; i++) write<char>(s[i]);
		write<char>(0);
	}
	/// Reads a value and pushes it to Lua state
	void read_to(lua_State* q);
	/// Writes i-th value on state's stack
	void write_from(lua_State* q, int i);
};
// apollo_method.h:
#pragma once
#include "stdafx.h"

extern lua_status_t lua_yield_status;
int lua_script_closure(lua_State* q);

namespace apollo_method {
	constexpr const char* metaName = "gml_method";
	struct impl {
		int64 index;
		char nameStart[];
	};
	void init(lua_State* q);
	void create(lua_State* q, int64 index, const char* fname);
}// apollo_ref.h
#pragma once
#include "stdafx.h"
#include "apollo_method.h"

namespace apollo_array {
	struct impl {
		int64 index;
		bool rec;
	};
	constexpr const char* metaName = "gml_array";
	extern gml_script_id getter;
	extern gml_script_id setter;
	extern gml_script_id length;
	void init(lua_State* q);
	void create(lua_State* q, int64 index, bool rec);
}
namespace apollo_struct {
	struct impl {
		int64 index;
		bool rec;
	};
	constexpr const char* metaName = "gml_struct";
	extern gml_script_id getter;
	extern gml_script_id setter;
	extern gml_script_id length;
	extern gml_script_id gml_keys;
	void init(lua_State* q);
	void create(lua_State* q, int64 index, bool rec);
}// apollo_ref_shared.h
// note: partial!

gml_script_id getter;
gml_script_id setter;
gml_script_id length;
#ifndef apollo_ref
#include "apollo_ref.h"
extern const char* metaName;
#endif
static int toString(lua_State* q);

static impl* toImpl(lua_State* q, int index) {
	luaL_checktype(q, index, LUA_TUSERDATA);
	impl* box = (impl*)luaL_checkudata(q, index, metaName);
	if (box == nullptr) luaL_typeerror(q, index, metaName);
	return box;
}
static int gc(lua_State* q) {
	auto box = toImpl(q, 1);
	if (!box) return 0;
	ref_recycle.push(box->index);
	return 0;
}
static int get(lua_State* q) {
	auto box = toImpl(q, 1);
	if (!box) return 0;
	//
	buffer b(lua_outbuf);
	b.write<gml_script_id>(getter);
	b.write<int32>(3);
	b.write_lua_int64(box->index);
	b.write_from(q, 2);
	b.write_lua_bool(box->rec);
	lua_pop(q, lua_gettop(q));
	lua_yield_status = lua_status_call;
	return lua_yield(q, 0);
}
static int set(lua_State* q) {
	auto box = toImpl(q, 1);
	if (!box) return 0;
	//
	buffer b(lua_outbuf);
	b.write<gml_script_id>(setter);
	b.write<int32>(3);
	b.write_lua_int64(box->index);
	b.write_from(q, 2);
	b.write_from(q, 3);
	lua_pop(q, lua_gettop(q));
	lua_yield_status = lua_status_call;
	return lua_yield(q, 0);
}

void create(lua_State* q, int64 index, bool rec) {
	impl* box = (impl*)lua_newuserdata(q, sizeof(impl));
	box->index = index;
	box->rec = rec;
	luaL_getmetatable(q, metaName);
	lua_setmetatable(q, -2);
}// apollo_shared.h
#pragma once

#if defined(WIN32)
#define dllx extern "C" __declspec(dllexport)
#elif defined(GNUC)
#define dllx extern "C" __attribute__ ((visibility("default"))) 
#else
#define dllx extern "C"
#endif

extern "C" {
	#include "./../Lua/lua.h"
	#include "./../Lua/lualib.h"
	#include "./../Lua/lauxlib.h"
}

#pragma region typedefs
typedef char int8;
typedef int int32;
typedef long long int64;
typedef unsigned int uint32;
typedef double real;
typedef int32 gml_script_id;
extern void* lua_outbuf;
#pragma endregion

///~
enum lua_status_t {
	lua_status_amiss = 0,
	lua_status_no_state,
	lua_status_no_func,
	lua_status_done,
	lua_status_error,
	lua_status_call,
	lua_status_yield,
	lua_status_callmethod,
};

#define trace(...) { printf(__VA_ARGS__); printf("\n"); fflush(stdout); }// apollo_buffer.cpp:
#include "apollo_buffer.h"
#include "apollo_method.h"
#include "apollo_ref.h"

void buffer::read_to(lua_State* q) {
	switch (read_type()) {
		case lua_btype_bool: lua_pushboolean(q, read<int8>()); break;
		case lua_btype_int32: lua_pushinteger(q, read<int32>()); break;
		case lua_btype_int64: lua_pushinteger(q, read<int64>()); break;
		case lua_btype_real: lua_pushnumber(q, read<real>()); break;
		case lua_btype_string: lua_pushstring(q, read_string()); break;
		case lua_btype_array: {
			lua_newtable(q);
			auto t = lua_gettop(q);
			auto n = read<uint32>();
			for (auto i = 0u; i < n; i++) {
				read_to(q);
				lua_rawseti(q, t, (lua_Integer)i + 1);
			}
		} break;
		case lua_btype_struct: {
			lua_newtable(q);
			auto t = lua_gettop(q);
			auto n = read<uint32>();
			for (auto i = 0u; i < n; i++) {
				lua_pushstring(q, read_string());
				read_to(q);
				lua_rawset(q, t);
			}
		} break;
		case lua_btype_script: {
			lua_pushnumber(q, read<int32>());
			lua_pushcclosure(q, lua_script_closure, 1);
		} break;
		case lua_btype_method: {
			auto index = read<int64>();
			auto name = read_string();
			apollo_method::create(q, index, name);
		} break;
		case lua_btype_ref: {
			auto index = read<int64>();
			auto kind = read<int8>();
			auto rec = read<int8>() != 0;
			if (kind == 0) {
				apollo_array::create(q, index, rec);
			} else {
				apollo_struct::create(q, index, rec);
			}
		} break;
		default: lua_pushnil(q);
	}
}

void buffer::write_from(lua_State* q, int i) {
	switch (lua_type(q, i)) {
		case LUA_TBOOLEAN:
			write_type(lua_btype_bool);
			write<int8>(lua_toboolean(q, i));
			break;
		case LUA_TNUMBER:
			write_type(lua_btype_real);
			write<real>(lua_tonumber(q, i));
			break;
		case LUA_TSTRING:
			write_type(lua_btype_string);
			write_string(lua_tostring(q, i));
			break;
		case LUA_TTABLE: {
			auto len = lua_rawlen(q, i); // lua_objlen in <= 5.1
			if (len > 0) {
				write_type(lua_btype_array);
				write<uint32>(len);
				for (auto k = 1; k <= len; k++) {
					lua_rawgeti(q, i, k);
					write_from(q, lua_gettop(q));
					lua_pop(q, 1);
				}
			} else {
				write_type(lua_btype_struct);
				auto foundAt = writeStore<uint32>(0);
				auto found = 0u;
				lua_pushnil(q);
				while (lua_next(q, i)) {
					auto key = lua_tostring(q, -2);
					if (key) {
						found++;
						write_string(key);
						write_from(q, lua_gettop(q));
					}
					lua_pop(q, 1);
				}
				*foundAt = found;
			}
		} break;
		case LUA_TUSERDATA:
			if (auto mtd = (apollo_method::impl*)luaL_testudata(q, i, apollo_method::metaName)) {
				write_type(lua_btype_method);
				write<int64>(mtd->index);
			} else if (auto arr = (apollo_array::impl*)luaL_testudata(q, i, apollo_array::metaName)) {
				write_type(lua_btype_ref);
				write<int64>(arr->index);
			} else if (auto obj = (apollo_struct::impl*)luaL_testudata(q, i, apollo_struct::metaName)) {
				write_type(lua_btype_ref);
				write<int64>(obj->index);
			}
			else write_type(lua_btype_nil);
			break;
		default: write_type(lua_btype_nil);
	}
}// apollo_core.cpp:
/// @author YellowAfterlife
#define _CRT_SECURE_NO_WARNINGS
#include "stdafx.h"
#include <vector>
#include <queue>
#include <stack>
#include <map>
#ifdef APOLLO_WINAPI
#include <codecvt>
#else
#include <unistd.h>
#endif
#include "apollo_buffer.h"
#include "apollo_method.h"
#include "apollo_ref.h"
using namespace std;

void* lua_outbuf;

#ifdef APOLLO_WINAPI // codepage conversion (Windows)
wstring_convert<codecvt_utf8_utf16<wchar_t>> ccvt;
string ccvt_utf8;
char* ret_string(wstring& ws) {
	ccvt_utf8 = ccvt.to_bytes(ws);
	return (char*)ccvt_utf8.c_str();
}
char* ret_string(wchar_t* ws) {
	ccvt_utf8 = ccvt.to_bytes(ws);
	return (char*)ccvt_utf8.c_str();
}
#endif
char* ret_string(const char* s) {
	static char* buf = nullptr;
	static size_t buf_size = 0;
	size_t n = strlen(s) + 1;
	if (buf_size < n) {
		auto tmp = realloc(buf, n);
		if (tmp) {
			buf = (char*)tmp;
			buf_size = n;
		}
	}
	if (n > buf_size) {
		strncpy((char*)buf, s, buf_size - 1);
		buf[buf_size - 1] = 0;
	} else strcpy((char*)buf, s);
	return (char*)buf;
}

#pragma region states
struct lua_state_t {
	// The actual Lua state (or thread)
	lua_State* state;

	// If this is a thread, indicates the parent state. Otherwise is null
	lua_State* parent;

	// This is only for errors thrown via lua_show_error - rethrows into state upon resuming
	char* error_text = nullptr;

	// A specific set of conditions urges us to have a stack of sub-states:
	// - To be able to suspend Lua calls and return to GML, it must be a coroutine
	// - If an error occurs in a coroutine, it is pronounced dead and can no longer be used
	// - Calls can be nested (GML->Lua->GML->Other function in same Lua state)
	// So we'll maintain a stack of temporary states and create/clean them up as we might
	stack<lua_State*> substates;

	lua_state_t(lua_State* q, lua_State* p) : state(q), parent(p) {}
};
vector<lua_state_t*> lua_state_vec;
queue<size_t> lua_state_reusable;
stack<lua_state_t*> lua_state_stack;
lua_State* lua_state_find(double index) {
	size_t i = (size_t)index;
	return i < lua_state_vec.size() ? lua_state_vec[i]->state : nullptr;
}
lua_state_t* lua_state_find_t(double index) {
	size_t i = (size_t)index;
	return i < lua_state_vec.size() ? lua_state_vec[i] : nullptr;
}
///
dllx double lua_show_error(char* text) {
	if (lua_state_stack.empty()) return false;
	lua_state_t* qt = lua_state_stack.top();
	if (qt->error_text == nullptr) {
		char* s = (char*)malloc(strlen(text) + 1);
		strcpy(s, text);
		qt->error_text = s;
		return true;
	} else return false;
}
#pragma endregion

/// Destroys every single state at once
dllx double lua_reset() {
	size_t n = lua_state_vec.size();
	for (size_t i = 0; i < n; i++) {
		auto q = lua_state_vec[i];
		if (q != nullptr) {
			// child states are GC-ed, no need to dealloc them
			if (q->parent == nullptr) lua_close(q->state);
			if (q->error_text != nullptr) free(q->error_text);
			delete q;
		}
	}
	lua_state_vec.clear();
	lua_state_reusable = queue<size_t>();
	return true;
}

#pragma region Current working directory
dllx const char* lua_get_cwd() {
	#ifdef APOLLO_WINAPI
	auto dir = _wgetcwd(NULL, 0);
	if (dir != NULL) {
		char* result = ret_string(dir);
		free(dir);
		return result;
	} else return "";
	#else
	auto dir = getcwd(NULL, 0);
	if (dir != NULL) {
		char* result = ret_string(dir);
		free(dir);
		return result;
	} else return "";
	#endif
}
dllx double lua_set_cwd(char* path) {
	#ifdef APOLLO_WINAPI
	int wsize = MultiByteToWideChar(CP_UTF8, 0, path, -1, NULL, 0);
	WCHAR* wpath = new WCHAR[wsize + 1];
	MultiByteToWideChar(CP_UTF8, 0, path, -1, wpath, wsize);
	auto result = (_wchdir(wpath) == 0);
	delete wpath;
	return result;
	#else
	return chdir(path) == 0;
	#endif
}
#pragma endregion

#pragma region Naming helpers
#define sprintf_exec(s, i) sprintf(s, "__Apollo_auto_%zu", i)
#define sprintf_thread(s, i) sprintf(s, "__Apollo_thread_%zu", i)
#pragma endregion

#pragma region State
size_t lua_state_create_impl(lua_state_t* qt) {
	size_t i;
	if (lua_state_reusable.empty()) {
		i = lua_state_vec.size();
		lua_state_vec.push_back(qt);
	} else {
		i = lua_state_reusable.front();
		lua_state_reusable.pop();
		lua_state_vec[i] = qt;
	}
	return i;
}
///
dllx double lua_state_create() {
	auto q = luaL_newstate();
	auto qt = new lua_state_t(q, nullptr);
	auto i = lua_state_create_impl(qt);
	luaL_openlibs(q);
	apollo_method::init(q);
	apollo_array::init(q);
	apollo_struct::init(q);
	return (double)i;
}
///
dllx double lua_state_destroy(double state_id) {
	size_t i = (size_t)state_id;
	size_t n = lua_state_vec.size();
	if (i < n) {
		auto q = lua_state_vec[i];
		if (q != nullptr) {
			if (q->parent != nullptr) {
				char name[32];
				sprintf_thread(name, i);
				lua_pushnil(q->parent);
				lua_setglobal(q->parent, name);
			} else {
				lua_close(q->state);
				// remove children:
				for (size_t k = 0; k < n; k++) {
					auto qk = lua_state_vec[k];
					if (qk != nullptr && qk->parent == q->state) {
						if (qk->error_text != nullptr) free(qk->error_text);
						delete qk;
						lua_state_vec[k] = nullptr;
					}
				}
			}
			if (q->error_text != nullptr) free(q->error_text);
			delete q;
			lua_state_vec[i] = nullptr;
			return true;
		} else return false;
	} else return false;
}
///
dllx double lua_thread_create(double state_id) {
	auto ot = lua_state_find_t(state_id);
	if (ot == nullptr) return -1;
	auto o = ot->state;
	auto q = lua_newthread(o);
	auto qt = new lua_state_t(q, o);
	auto i = lua_state_create_impl(qt);
	// put the thread from the top of stack in base to a global so that GC won't eat it:
	char name[32];
	sprintf_thread(name, i);
	lua_setglobal(o, name);
	//
	return (double)i;
}
///
dllx double lua_thread_destroy(double state_id) {
	return lua_state_destroy(state_id);
}
///
dllx double lua_state_exists(double state_id) {
	return lua_state_find_t(state_id) != nullptr;
}
/// Allows the indexes of all currently destroyed states/threads to be reused for new ones
dllx double lua_state_reuse_indexes() {
	lua_state_reusable = queue<size_t>();
	auto n = lua_state_vec.size();
	auto r = 0;
	for (size_t i = 0; i < n; i++) {
		if (lua_state_vec[i] == nullptr) {
			lua_state_reusable.push(i);
			r += 1;
		}
	}
	return r;
}
#pragma endregion

#pragma region function
dllx double lua_add_function_raw(double state_id, char* name, double script_id) {
	auto q = lua_state_find(state_id);
	if (q == nullptr) return lua_status_no_state;
	lua_pushnumber(q, script_id);
	lua_pushcclosure(q, lua_script_closure, 1);
	lua_setglobal(q, name);
	return lua_status_done;
}
#pragma endregion

#pragma region sub-state management
lua_State* lua_state_exec_start(lua_state_t* qt) {
	lua_State* q = lua_newthread(qt->state);
	char v[32];
	sprintf_exec(v, qt->substates.size());
	lua_setglobal(qt->state, v);
	qt->substates.push(q);
	return q;
}
void lua_state_exec_end(lua_state_t* qt) {
	qt->substates.pop();
	char v[32];
	sprintf_exec(v, qt->substates.size());
	lua_pushnil(qt->state);
	lua_setglobal(qt->state, v);
}
/// Returns how many layers of interop (GML->Lua->GML->...) a state is deep (debug info)
dllx double lua_state_get_interop_depth(double state_id) {
	lua_state_t* qt = lua_state_find_t(state_id);
	if (qt == nullptr) return 0;
	return (double)qt->substates.size();
}
#pragma endregion

#pragma region calls
void lua_state_throw_error(lua_State *q, lua_Debug *ar) {
	lua_sethook(q, lua_state_throw_error, 0, 0);
	auto qt = lua_state_stack.top();
	if (qt->error_text != nullptr) {
		luaL_where(q, 1);
		lua_pushstring(q, qt->error_text);
		lua_concat(q, 2);
		free(qt->error_text);
		qt->error_text = nullptr;
		lua_error(q); // we don't return from there
	}
}
lua_status_t lua_state_exec(lua_state_t* qt, lua_State* q, void* data, bool start) {
	lua_outbuf = data;
	buffer b(data);
	int argc = b.read<int32>();
	for (int i = 0; i < argc; i++) b.read_to(q);
	lua_yield_status = lua_status_yield;
	//
	if (qt->error_text != nullptr) {
		// here's the deal: if we want LuaJIT compatibility (5.1/5.2 equivalent),
		// we can't use lua_yieldk, so... I guess just bind a one-use hook?
		lua_sethook(q, lua_state_throw_error, LUA_MASKCOUNT, 1);
	}
	//
	argc = lua_gettop(q);
	if (start) argc -= 1; // if it's the first invocation, first argument is the function to run
	int retc = 0;
	int result = lua_resume(q, NULL, argc, &retc);
	switch (result) {
		case LUA_OK: {
			// we finished execution! let's get the returned values out of there:
			b = buffer(data);
			b.write<int32>(retc);
			for (int i = 0; i < retc; i++) b.write_from(q, i + 1);
			lua_pop(q, retc);
			// remove the call-coroutine and we're good
			lua_state_exec_end(qt);
			lua_state_stack.pop();
			return lua_status_done;
		};
		case LUA_YIELD: {
			if (lua_yield_status != lua_status_yield) {
				return lua_yield_status;
			} else {
				b = buffer(data);
				b.write<int32>(retc);
				for (int i = 0; i < retc; i++) b.write_from(q, i + 1);
				lua_pop(q, retc);
				lua_state_stack.pop();
				return lua_status_yield;
			}
		};
		default: {
			auto text = lua_tostring(q, -1);
			luaL_traceback(q, q, text, 0);
			text = lua_tostring(q, -1);
			buffer b(data);
			b.write_string(text);
			lua_pop(q, lua_gettop(q));
			lua_state_exec_end(qt);
			lua_state_stack.pop();
			return lua_status_error;
		};
	}
}

dllx double lua_state_exec_raw(void* data) {
	if (lua_state_stack.empty()) return lua_status_no_state;
	auto qt = lua_state_stack.top();
	return lua_state_exec(qt, qt->substates.top(), data, false);
}

dllx double lua_call_raw(double state_id, char* name, void* data) {
	auto qt = lua_state_find_t(state_id);
	if (qt == nullptr) return lua_status_no_state;
	auto q = lua_state_exec_start(qt);
	//
	lua_getglobal(q, name);
	if (lua_type(q, -1) != LUA_TFUNCTION) {
		lua_state_exec_end(qt);
		return lua_status_no_func;
	}
	lua_state_stack.push(qt);
	return lua_state_exec(qt, q, data, true);
}
#pragma endregion

#pragma region add code
dllx double lua_add_code_raw(double state_id, char* code, void* data) {
	auto qt = lua_state_find_t(state_id);
	if (qt == nullptr) return lua_status_no_state;
	lua_state_stack.push(qt);
	auto q = lua_state_exec_start(qt);
	luaL_loadstring(q, code);
	return lua_state_exec(qt, q, data, true);
}

dllx double lua_add_file_raw(double state_id, char* full_path, void* data) {
	auto qt = lua_state_find_t(state_id);
	if (qt == nullptr) return lua_status_no_state;
	lua_state_stack.push(qt);
	auto q = lua_state_exec_start(qt);
	luaL_loadfile(q, full_path);
	return lua_state_exec(qt, q, data, true);
}
#pragma endregion

#pragma region globals
dllx double lua_global_get_raw(double state_id, char* name, void* data) {
	auto q = lua_state_find(state_id);
	if (q == nullptr) return false;
	lua_getglobal(q, name);
	buffer b(data);
	b.write_from(q, 1);
	lua_pop(q, 1);
	return true;
}
dllx double lua_global_set_raw(double state_id, char* name, void* data) {
	auto q = lua_state_find(state_id);
	if (q == nullptr) return false;
	buffer b(data);
	b.read_to(q);
	lua_setglobal(q, name);
	return true;
}
///
enum lua_type_t {
	lua_type_none,
	lua_type_nil,
	lua_type_bool,
	lua_type_number,
	lua_type_string,
	lua_type_table,
	lua_type_function,
	lua_type_thread,
	lua_type_userdata,
	lua_type_lightuserdata,
	lua_type_unknown,
};
dllx double lua_global_type_raw(double state_id, char* name) {
	auto q = lua_state_find(state_id);
	if (q == nullptr) return -1;
	lua_getglobal(q, name);
	int t = lua_type(q, -1);
	lua_pop(q, 1);
	switch (t) {
		case LUA_TNONE: return lua_type_none;
		case LUA_TNIL: return lua_type_nil;
		case LUA_TBOOLEAN: return lua_type_bool;
		case LUA_TNUMBER: return lua_type_number;
		case LUA_TSTRING: return lua_type_string;
		case LUA_TTABLE: return lua_type_table;
		case LUA_TFUNCTION: return lua_type_function;
		case LUA_TTHREAD: return lua_type_thread;
		case LUA_TUSERDATA: return lua_type_userdata;
		case LUA_TLIGHTUSERDATA: return lua_type_lightuserdata;
		default: return lua_type_unknown;
	}
}
#pragma endregion

#pragma region coroutines
dllx double lua_call_start_raw(double state_id, char* name, void* data) {
	auto qt = lua_state_find_t(state_id);
	if (qt == nullptr) return lua_status_no_state;
	auto q = lua_state_exec_start(qt);
	lua_getglobal(q, name);
	if (lua_type(q, -1) != LUA_TFUNCTION) {
		lua_state_exec_end(qt);
		return lua_status_no_func;
	}
	//
	buffer b(data);
	auto argc = b.read<int32>();
	for (int i = 0; i < argc; i++) b.read_to(q);
	//
	return lua_status_done;
}
dllx double lua_call_next_raw(double state_id, void* data) {
	auto qt = lua_state_find_t(state_id);
	if (qt == nullptr) return lua_status_no_state;
	if (qt->substates.empty()) return lua_status_no_state;
	//
	lua_state_stack.push(qt);
	return lua_state_exec(qt, qt->substates.top(), data, true);
}
#pragma endregion// apollo_init.cpp:
#include "stdafx.h"
#include "apollo_ref.h"

struct lua_init_t {
	gml_script_id array_getter;
	gml_script_id array_setter;
	gml_script_id array_length;
	gml_script_id struct_getter;
	gml_script_id struct_setter;
	gml_script_id struct_length;
	gml_script_id struct_keys;
};
dllx double lua_init_raw(lua_init_t* init) {
	apollo_array::getter = init->array_getter;
	apollo_array::setter = init->array_setter;
	apollo_array::length = init->array_length;
	apollo_struct::getter = init->struct_getter;
	apollo_struct::setter = init->struct_setter;
	apollo_struct::length = init->struct_length;
	apollo_struct::gml_keys = init->struct_keys;
	return true;
}// apollo_method.cpp:
#include "apollo_method.h"
#include "apollo_buffer.h"
#include <queue>
namespace apollo_method {
	std::queue<int64> recycle{};
	static impl* toImpl(lua_State* q, int index) {
		luaL_checktype(q, index, LUA_TUSERDATA);
		impl* box = (impl*)luaL_checkudata(q, index, metaName);
		if (box == nullptr) luaL_typeerror(q, index, metaName);
		return box;
	}
	static int gc(lua_State* q) {
		auto box = toImpl(q, 1);
		if (!box) return 0;
		recycle.push(box->index);
		return 0;
	}
	static int toString(lua_State* q) {
		auto box = toImpl(q, 1);
		if (!box) return 0;
		lua_pushstring(q, box->nameStart);
		return 1;
	}
	static int call(lua_State* q) {
		auto box = toImpl(q, 1);
		if (!box) return 0;
		//
		int argc = lua_gettop(q) - 1;
		buffer b(lua_outbuf);
		b.write<int64>(box->index);
		b.write<int32>(argc);
		for (int i = 0; i < argc; i++) b.write_from(q, i + 2);
		lua_pop(q, argc + 1);
		//
		lua_yield_status = lua_status_callmethod;
		return lua_yield(q, 0);
	}
	luaL_Reg meta[] = {
		{"__gc", gc},
		{"__tostring", toString},
		{"__call", call},
		{0, 0}
	};
	void init(lua_State* q) {
		luaL_newmetatable(q, metaName);
		luaL_setfuncs(q, meta, 0);
		lua_pop(q, 1);
	}
	void create(lua_State* q, int64 index, const char* fname) {
		auto fnamen = strlen(fname);
		auto size = sizeof(impl) + fnamen + 1;
		auto ptr = (impl*)lua_newuserdata(q, size);
		ptr->index = index;
		char* nameStart = ptr->nameStart;
		nameStart[fnamen] = 0;
		strncpy(nameStart, fname, fnamen);
		luaL_getmetatable(q, metaName);
		lua_setmetatable(q, -2);
	}
}

dllx double lua_update_method_gc(int64* out, double _max) {
	auto n = apollo_method::recycle.size();
	auto max = (size_t)_max;
	if (n > max) n = max;
	for (auto i = 0u; i < n; i++) {
		out[i] = apollo_method::recycle.front();
		apollo_method::recycle.pop();
	}
	return (double)n;
}

lua_status_t lua_yield_status;
int lua_script_closure(lua_State* q) {
	// Push the closure context from the pseudoindex (4.2)
	lua_pushvalue(q, lua_upvalueindex(1));

	// stack: [...args, script]
	int argc = lua_gettop(q) - 1;
	int script = (int)lua_tonumber(q, argc + 1);
	buffer b(lua_outbuf);
	b.write<int32>(script);
	b.write<int32>(argc);
	for (int i = 0; i < argc; i++) b.write_from(q, i + 1);
	lua_pop(q, argc + 1);
	//
	lua_yield_status = lua_status_call;
	return lua_yield(q, 0);
}// apollo_ref.cpp
#include "apollo_buffer.h"
#include "apollo_ref.h"

#include <queue>
static std::queue<int64> ref_recycle{};
#define apollo_ref
namespace apollo_array {
	#include "apollo_ref_shared.h"
	static int len(lua_State* q) {
		auto box = toImpl(q, 1);
		if (!box) return 0;
		//
		buffer b(lua_outbuf);
		b.write<gml_script_id>(length);
		b.write<int32>(1);
		b.write_lua_int64(box->index);
		lua_pop(q, lua_gettop(q));
		lua_yield_status = lua_status_call;
		return lua_yield(q, 0);
	}

	static int toString(lua_State* q) {
		auto box = toImpl(q, 1);
		if (!box) return 0;
		lua_pushfstring(q, "gml_array#%I", box->index);
		return 1;
	}

	luaL_Reg meta[] = {
		{"__gc", gc},
		{"__tostring", toString},
		{"__index", get},
		{"__newindex", set},
		{"__len", len},
		{0, 0}
	};
	void init(lua_State* q) {
		luaL_newmetatable(q, metaName);
		luaL_setfuncs(q, meta, 0);
		luaL_dostring(q, R"(return function(arr) -- pairs
	local i = 1
	local n = nil
	return function()
		if n == nil then
			n = #arr or 0
		end
		local k = i
		i = i + 1
		if k <= n then
			return k, arr[k]
		else
			return nil, nil
		end
	end, q, nil
end)");
		lua_setfield(q, -2, "__pairs");
		lua_pop(q, 1);
	}
}

namespace apollo_struct {
	#include "apollo_ref_shared.h"
	gml_script_id gml_keys;
	static int toString(lua_State* q) {
		auto box = toImpl(q, 1);
		if (!box) return 0;
		lua_pushfstring(q, "gml_struct#%I", box->index);
		return 1;
	}

	static int keys(lua_State* q) {
		auto box = toImpl(q, 1);
		if (!box) return 0;
		//
		buffer b(lua_outbuf);
		b.write<gml_script_id>(gml_keys);
		b.write<int32>(1);
		b.write_lua_int64(box->index);
		lua_pop(q, lua_gettop(q));
		lua_yield_status = lua_status_call;
		return lua_yield(q, 0);
	}

	luaL_Reg meta[] = {
		{"__gc", gc},
		{"__tostring", toString},
		{"__index", get},
		{"__newindex", set},
		{"__gml_keys", keys},
		{0, 0}
	};
	void init(lua_State* q) {
		luaL_newmetatable(q, metaName);
		luaL_setfuncs(q, meta, 0);
		luaL_dostring(q, R"(return function(q) -- pairs
	local keys = nil
	local i = 1
	local n
	return function()
		if keys == nil then
			keys = getmetatable(q).__gml_keys(q)
			n = #keys
		end
		local k = keys[i]
		i = i + 1
		if k ~= nil then
			return k, q[k]
		else
			return nil, nil
		end
	end, q, nil
end)");
		lua_setfield(q, -2, "__pairs");
		lua_pop(q, 1);
	}
}
#undef apollo_ref

dllx double lua_update_ref_gc(int64* out, double _max) {
	auto n = ref_recycle.size();
	auto max = (size_t)_max;
	if (n > max) n = max;
	for (auto i = 0u; i < n; i++) {
		out[i] = ref_recycle.front();
		ref_recycle.pop();
	}
	return (double)n;
}
