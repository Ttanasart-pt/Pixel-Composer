#pragma once
#include "stdafx.h"

// As per http://help.yoyogames.com/hc/en-us/articles/216755258:
typedef int gml_ds_map;
//
typedef void (*gml_event_perform_async_t)(gml_ds_map map, int event_type);
typedef int (*gml_ds_map_create_ext_t)(int n, ...);
typedef bool (*gml_ds_map_set_double_t)(gml_ds_map map, char* key, double value);
typedef bool (*gml_ds_map_set_string_t)(gml_ds_map map, char* key, const char* value);
//
extern gml_event_perform_async_t gml_event_perform_async;
extern gml_ds_map_create_ext_t gml_ds_map_create_ext;
extern gml_ds_map_set_double_t gml_ds_map_set_double;
extern gml_ds_map_set_string_t gml_ds_map_set_string;
//
inline gml_ds_map gml_ds_map_create() {
	return gml_ds_map_create_ext(0);
}

// A wrapper for queuing async events for GML easier.
class gml_async_event {
private:
	gml_ds_map map;
public:
	gml_async_event() {
		map = gml_ds_map_create();
	}
	gml_async_event(char* type) {
		map = gml_ds_map_create();
		gml_ds_map_set_string(map, "event_type", type);
	}
	~gml_async_event() {
		//
	}
	/// Dispatches this event and cleans up the map.
	void dispatch(int kind) {
		gml_event_perform_async(map, kind);
	}
	bool set(char* key, double value) {
		return gml_ds_map_set_double(map, key, value);
	}
	bool set(char* key, const char* value) {
		return gml_ds_map_set_string(map, key, value);
	}
	void setPosKeyState(POINTL pos, DWORD keyState) {
		set("x", pos.x);
		set("y", pos.y);
		set("key_state", keyState);
	}
};#pragma once
#include "stdafx.h"
#include <vector>
#if ((defined(_MSVC_LANG) && _MSVC_LANG >= 201703L) || __cplusplus >= 201703L)
#include <optional>
#endif
#include <stdint.h>
#include <cstring>
#include <tuple>
using namespace std;

#define dllg /* tag */

#if defined(WIN32)
#define dllx extern "C" __declspec(dllexport)
#elif defined(GNUC)
#define dllx extern "C" __attribute__ ((visibility("default"))) 
#else
#define dllx extern "C"
#endif

#ifdef _WINDEF_
typedef HWND GAME_HWND;
#endif

struct gml_buffer {
private:
	uint8_t* _data;
	int32_t _size;
	int32_t _tell;
public:
	gml_buffer() : _data(nullptr), _tell(0), _size(0) {}
	gml_buffer(uint8_t* data, int32_t size, int32_t tell) : _data(data), _size(size), _tell(tell) {}

	inline uint8_t* data() { return _data; }
	inline int32_t tell() { return _tell; }
	inline int32_t size() { return _size; }
};

class gml_istream {
	uint8_t* pos;
	uint8_t* start;
public:
	gml_istream(void* origin) : pos((uint8_t*)origin), start((uint8_t*)origin) {}

	template<class T> T read() {
		static_assert(std::is_trivially_copyable_v<T>, "T must be trivially copyable to be read");
		T result{};
		std::memcpy(&result, pos, sizeof(T));
		pos += sizeof(T);
		return result;
	}

	char* read_string() {
		char* r = (char*)pos;
		while (*pos != 0) pos++;
		pos++;
		return r;
	}

	template<class T> std::vector<T> read_vector() {
		static_assert(std::is_trivially_copyable_v<T>, "T must be trivially copyable to be read");
		auto n = read<uint32_t>();
		std::vector<T> vec(n);
		std::memcpy(vec.data(), pos, sizeof(T) * n);
		pos += sizeof(T) * n;
		return vec;
	}

	gml_buffer read_gml_buffer() {
		auto _data = (uint8_t*)read<int64_t>();
		auto _size = read<int32_t>();
		auto _tell = read<int32_t>();
		return gml_buffer(_data, _size, _tell);
	}

	#pragma region Tuples
	#if ((defined(_MSVC_LANG) && _MSVC_LANG >= 201703L) || __cplusplus >= 201703L)
	template<typename... Args>
	std::tuple<Args...> read_tuple() {
		std::tuple<Args...> tup;
		std::apply([this](auto&&... arg) {
			((
				arg = this->read<std::remove_reference_t<decltype(arg)>>()
				), ...);
			}, tup);
		return tup;
	}

	template<class T> optional<T> read_optional() {
		if (read<bool>()) {
			return read<T>;
		} else return {};
	}
	#else
	template<class A, class B> std::tuple<A, B> read_tuple() {
		A a = read<A>();
		B b = read<B>();
		return std::tuple<A, B>(a, b);
	}

	template<class A, class B, class C> std::tuple<A, B, C> read_tuple() {
		A a = read<A>();
		B b = read<B>();
		C c = read<C>();
		return std::tuple<A, B, C>(a, b, c);
	}

	template<class A, class B, class C, class D> std::tuple<A, B, C, D> read_tuple() {
		A a = read<A>();
		B b = read<B>();
		C c = read<C>();
		D d = read<d>();
		return std::tuple<A, B, C, D>(a, b, c, d);
	}
	#endif
};

class gml_ostream {
	uint8_t* pos;
	uint8_t* start;
public:
	gml_ostream(void* origin) : pos((uint8_t*)origin), start((uint8_t*)origin) {}

	template<class T> void write(T val) {
		static_assert(std::is_trivially_copyable_v<T>, "T must be trivially copyable to be write");
		memcpy(pos, &val, sizeof(T));
		pos += sizeof(T);
	}

	void write_string(const char* s) {
		for (int i = 0; s[i] != 0; i++) write<char>(s[i]);
		write<char>(0);
	}

	template<class T> void write_vector(std::vector<T>& vec) {
		static_assert(std::is_trivially_copyable_v<T>, "T must be trivially copyable to be write");
		auto n = vec.size();
		write<uint32_t>(n);
		memcpy(pos, vec.data(), n * sizeof(T));
		pos += n * sizeof(T);
	}

	#if ((defined(_MSVC_LANG) && _MSVC_LANG >= 201703L) || __cplusplus >= 201703L)
	template<typename... Args>
	void write_tuple(std::tuple<Args...> tup) {
		std::apply([this](auto&&... arg) {
			(this->write(arg), ...);
			}, tup);
	}

	template<class T> void write_optional(optional<T>& val) {
		auto hasValue = val.has_value();
		write<bool>(hasValue);
		if (hasValue) write<T>(val.value());
	}
	#else
	template<class A, class B> void write_tuple(std::tuple<A, B>& tup) {
		write<A>(std::get<0>(tup));
		write<B>(std::get<1>(tup));
	}
	template<class A, class B, class C> void write_tuple(std::tuple<A, B, C>& tup) {
		write<A>(std::get<0>(tup));
		write<B>(std::get<1>(tup));
		write<C>(std::get<2>(tup));
	}
	template<class A, class B, class C, class D> void write_tuple(std::tuple<A, B, C, D>& tup) {
		write<A>(std::get<0>(tup));
		write<B>(std::get<1>(tup));
		write<C>(std::get<2>(tup));
		write<D>(std::get<3>(tup));
	}
	#endif
};
//{{NO_DEPENDENCIES}}
// Microsoft Visual C++ generated include file.
// Used by file_dropper.rc

// Next default values for new objects
// 
#ifdef APSTUDIO_INVOKED
#ifndef APSTUDIO_READONLY_SYMBOLS
#define _APS_NEXT_RESOURCE_VALUE        101
#define _APS_NEXT_COMMAND_VALUE         40001
#define _APS_NEXT_CONTROL_VALUE         1001
#define _APS_NEXT_SYMED_VALUE           101
#endif
#endif
// stdafx.h : include file for standard system include files,
// or project specific include files that are used frequently, but
// are changed infrequently
//

#pragma once

#ifdef _WINDOWS
	#include "targetver.h"
	
	#define WIN32_LEAN_AND_MEAN // Exclude rarely-used stuff from Windows headers
	#include <windows.h>
#endif

#if defined(WIN32)
#define dllx extern "C" __declspec(dllexport)
#elif defined(GNUC)
#define dllx extern "C" __attribute__ ((visibility("default"))) 
#else
#define dllx extern "C"
#endif

#define trace(...) { printf("[file_dropper:%d] ", __LINE__); printf(__VA_ARGS__); printf("\n"); fflush(stdout); }

#include "gml_ext.h"

// TODO: reference additional headers your program requires here#pragma once

// Including SDKDDKVer.h defines the highest available Windows platform.

// If you wish to build your application for a previous Windows platform, include WinSDKVer.h and
// set the _WIN32_WINNT macro to the platform you wish to support before including SDKDDKVer.h.

#include <SDKDDKVer.h>
#pragma once
#include "stdafx.h"

template<typename T> T* malloc_arr(size_t count) {
	return (T*)malloc(sizeof(T) * count);
}
template<typename T> T* realloc_arr(T* arr, size_t count) {
	return (T*)realloc(arr, sizeof(T) * count);
}
template<typename T> T* memcpy_arr(T* dst, const T* src, size_t count) {
	return (T*)memcpy(dst, src, sizeof(T) * count);
}

template<typename C> class tiny_string_t {
	C* _data = nullptr;
	size_t _size = 0;
	size_t _capacity = 0;
public:
	tiny_string_t() {}
	inline void init(size_t capacity = 32) {
		_data = malloc_arr<C>(capacity);
		_size = 0;
		_capacity = capacity;
	}
	inline void init(const C* val) {
		init(4);
		set(val);
	}

	/// Returns current size, in characters (not including final NUL)
	inline size_t size() { return _size; }
	inline void setSize(size_t size) { _size = size; }

	inline bool empty() {
		return _size == 0;
	}
	inline C* c_str() {
		return _data;
	}
	inline C* prepare(size_t capacity) {
		if (_capacity < capacity) {
			auto new_data = realloc_arr(_data, capacity);
			if (new_data == nullptr) {
				trace("Failed to reallocate %zu bytes in tiny_string::prepare", sizeof(C) * capacity);
				return nullptr;
			}
			_data = new_data;
			_capacity = capacity;
		}
		return _data;
	}
	inline const C* set(const C* value, size_t len = SIZE_MAX) {
		if (len == SIZE_MAX) {
			const C* iter = value;
			len = 1;
			while (*iter) { iter++; len++; }
		}
		C* result = prepare(len);
		memcpy_arr(result, value, len);
		_size = len - 1;
		return result;
	}
	//
	inline void operator=(const C* value) { set(value); }
	template<size_t size> inline void operator =(const C(&value)[size]) { set(value, size); }
};
struct tiny_string : public tiny_string_t<char> {
public:
	inline char* conv(const wchar_t* wstr) {
		auto size = WideCharToMultiByte(CP_UTF8, 0, wstr, -1, NULL, 0, NULL, NULL);
		auto str = prepare(size);
		WideCharToMultiByte(CP_UTF8, 0, wstr, -1, str, size, NULL, NULL);
		setSize(size - 1);
		return str;
	}

	inline void operator=(const char* value) { set(value); }
	template<size_t size> inline void operator =(const char(&value)[size]) { set(value, size); }
};
struct tiny_wstring : public tiny_string_t<wchar_t> {
public:
	inline wchar_t* conv(const char* str) {
		auto size = MultiByteToWideChar(CP_UTF8, 0, str, -1, NULL, 0);
		auto wstr = prepare(size);
		MultiByteToWideChar(CP_UTF8, 0, str, -1, wstr, size);
		setSize(size - 1);
		return wstr;
	}

	inline void operator=(const wchar_t* value) { set(value); }
	template<size_t size> inline void operator =(const wchar_t(&value)[size]) { set(value, size); }
};#include "gml_ext.h"
extern bool file_dropper_init(GAME_HWND hwnd);
dllx double file_dropper_init_raw(void* _in_ptr, void* _in_ptr_size) {
	gml_istream _in(_in_ptr);
	GAME_HWND _arg_hwnd;
	_arg_hwnd = (GAME_HWND)_in.read<uint64_t>();
	return file_dropper_init(_arg_hwnd);
}

extern void file_dropper_set_allow(bool allow);
dllx double file_dropper_set_allow_raw(void* _in_ptr, void* _in_ptr_size) {
	gml_istream _in(_in_ptr);
	bool _arg_allow;
	_arg_allow = _in.read<bool>();
	file_dropper_set_allow(_arg_allow);
	return 1;
}

extern double file_dropper_set_effect(int effect);
dllx double file_dropper_set_effect_raw(void* _in_ptr, void* _in_ptr_size) {
	gml_istream _in(_in_ptr);
	int _arg_effect;
	_arg_effect = _in.read<int>();
	return file_dropper_set_effect(_arg_effect);
}

extern void file_dropper_set_default_allow(bool allow);
dllx double file_dropper_set_default_allow_raw(void* _in_ptr, void* _in_ptr_size) {
	gml_istream _in(_in_ptr);
	bool _arg_allow;
	_arg_allow = _in.read<bool>();
	file_dropper_set_default_allow(_arg_allow);
	return 1;
}

extern double file_dropper_set_default_effect(int effect);
dllx double file_dropper_set_default_effect_raw(void* _in_ptr, void* _in_ptr_size) {
	gml_istream _in(_in_ptr);
	int _arg_effect;
	_arg_effect = _in.read<int>();
	return file_dropper_set_default_effect(_arg_effect);
}

// dllmain.cpp : Defines the entry point for the DLL application.
#include "stdafx.h"

void file_dropper_preinit();
BOOL APIENTRY DllMain( HMODULE hModule,
                       DWORD  ul_reason_for_call,
                       LPVOID lpReserved
					 )
{
	if (ul_reason_for_call == DLL_PROCESS_ATTACH) {
		file_dropper_preinit();
	}
	return TRUE;
}

/// @author YellowAfterlife

#include <oleidl.h>
#include <shlobj.h>
#include <objbase.h>
#include <shellapi.h>
#include <string>

#include "stdafx.h"
#include "gml_async_glue.h"
#include "tiny_string.h"

static tiny_string utf8c;
static tiny_wstring utf8wc;
namespace GMDropTargetState {
    UINT refCount = 0;
    //
    bool defaultAllow = true;
    int defaultEffect = DROPEFFECT_COPY;
    //
    bool allow = true;
    int effect = DROPEFFECT_COPY;
};

///
enum class file_dropper_mk : int {
    lbutton = 1,
    rbutton = 2,  
    shift = 4,
    control = 8,
    mbutton = 16,
    alt = 32,
};
///
enum class file_dropper_effect : int{
    none = 0,
    copy = 1,
    move = 2,
    link = 4,
};

void file_dropper_preinit() {
    static_assert((int)file_dropper_mk::lbutton == MK_LBUTTON, "MK_LBUTTON");
    static_assert((int)file_dropper_mk::rbutton == MK_RBUTTON, "MK_RBUTTON");
    static_assert((int)file_dropper_mk::mbutton == MK_MBUTTON, "MK_MBUTTON");
    //
    static_assert((int)file_dropper_mk::alt == MK_ALT, "MK_ALT");
    static_assert((int)file_dropper_mk::shift == MK_SHIFT, "MK_SHIFT");
    static_assert((int)file_dropper_mk::control == MK_CONTROL, "MK_CONTROL");
    //
    utf8c.init();
    utf8wc.init();
    GMDropTargetState::refCount = 0;
    GMDropTargetState::defaultAllow = true;
    GMDropTargetState::defaultEffect = DROPEFFECT_COPY;
    GMDropTargetState::allow = true;
    GMDropTargetState::effect = DROPEFFECT_COPY;
}

struct GMDropTarget : IDropTarget {
    // Inherited via IDropTarget
    virtual HRESULT __stdcall QueryInterface(REFIID riid, void** ppvObject) override {
        if (IsEqualIID(riid, IID_IDropTarget) || IsEqualIID(riid, IID_IUnknown)) {
            *ppvObject = this;
            this->AddRef();
            return NOERROR;
        } else {
            *ppvObject = nullptr;
            return E_NOINTERFACE;
        }
    }
    virtual ULONG __stdcall AddRef(void) override {
        return ++GMDropTargetState::refCount;
    }
    virtual ULONG __stdcall Release(void) override {
        return --GMDropTargetState::refCount;
    }
    virtual HRESULT __stdcall DragEnter(IDataObject* pDataObj, DWORD grfKeyState, POINTL pt, DWORD* pdwEffect) override {
        // there should be at least one valid file in the batch
        FORMATETC formatEtc;
        formatEtc.cfFormat = CF_HDROP;
        formatEtc.dwAspect = DVASPECT_CONTENT;
        formatEtc.lindex = -1;
        formatEtc.ptd = NULL;
        formatEtc.tymed = TYMED_HGLOBAL;

        STGMEDIUM medium;
        auto hr = pDataObj->GetData(&formatEtc, &medium);
        if (FAILED(hr)) return hr;
        if (medium.tymed != TYMED_HGLOBAL) return S_OK;

        auto drop = (HDROP)medium.hGlobal;
        auto fileCount = DragQueryFileW(drop, UINT32_MAX, NULL, 0);
        auto found = false;
        for (auto k = 0u; k < fileCount; k++) {
            auto nameLen = DragQueryFileW(drop, k, nullptr, 0);
            if (nameLen == 0) continue;
            gml_async_event e("file_drag_enter");
            e.setPosKeyState(pt, grfKeyState);
            e.dispatch(75);
            GMDropTargetState::allow = GMDropTargetState::defaultAllow;
            GMDropTargetState::effect = GMDropTargetState::defaultEffect;
            *pdwEffect = GMDropTargetState::effect;
            return S_OK;
        }
        return S_FALSE;
    }
    virtual HRESULT __stdcall DragOver(DWORD grfKeyState, POINTL pt, DWORD* pdwEffect) override {
        // dispatches often, but what can we do about it
        gml_async_event e("file_drag_over");
        e.setPosKeyState(pt, grfKeyState);
        e.dispatch(75);
        if (GMDropTargetState::allow) {
            *pdwEffect = GMDropTargetState::effect;
            return S_OK;
        } else return S_FALSE;
    }
    virtual HRESULT __stdcall DragLeave(void) override {
        gml_async_event e("file_drag_leave");
        e.dispatch(75);
        return S_OK;
    }
    virtual HRESULT __stdcall Drop(IDataObject* pDataObj, DWORD grfKeyState, POINTL pt, DWORD* pdwEffect) override {
        //trace("drop");
        FORMATETC formatEtc;
        formatEtc.cfFormat = CF_HDROP;
        formatEtc.dwAspect = DVASPECT_CONTENT;
        formatEtc.lindex = -1;
        formatEtc.ptd = NULL;
        formatEtc.tymed = TYMED_HGLOBAL;

        STGMEDIUM medium;
        auto hr = pDataObj->GetData(&formatEtc, &medium);
        if (FAILED(hr)) return hr;
        if (medium.tymed != TYMED_HGLOBAL) return S_OK;
        *pdwEffect = GMDropTargetState::effect;

        auto drop = (HDROP)medium.hGlobal;
        auto fileCountBase = DragQueryFileW(drop, UINT32_MAX, NULL, 0);

        // collect the file names:
        auto filenames = malloc_arr<char*>(fileCountBase);
        auto fileCount = 0u;
        for (auto k = 0u; k < fileCountBase; k++) {
            auto wnameLen = DragQueryFileW(drop, k, nullptr, 0);
            if (wnameLen == 0) continue;

            auto wname = malloc_arr<wchar_t>(wnameLen + 1);
            DragQueryFile(drop, k, wname, wnameLen + 1);
            auto nameCopy = utf8c.conv(wname);
            auto nameLen = strlen(nameCopy);
            auto name = malloc_arr<char>(nameLen + 1);
            memcpy(name, nameCopy, nameLen + 1);
            filenames[fileCount++] = name;
            delete wname;
        }

        // start:
        {
            gml_async_event e("file_drop_start");
            e.setPosKeyState(pt, grfKeyState);
            e.set("file_count", fileCount);
            e.dispatch(75);
        }

        // per-file events:
        for (auto k = 0u; k < fileCount; k++) {
            gml_async_event e("file_drop");
            e.setPosKeyState(pt, grfKeyState);
            e.set("filename", filenames[k]);
            e.dispatch(75); // async system
            delete filenames[k];
        }
        delete filenames;

        // end:
        {
            gml_async_event e("file_drop_end");
            e.setPosKeyState(pt, grfKeyState);
            e.set("file_count", fileCount);
            e.dispatch(75);
        }
        //
        return S_OK;
    }
};
static GMDropTarget* dropTarget = nullptr;

dllg bool file_dropper_init(GAME_HWND hwnd) {
    if (dropTarget != nullptr) return true;

    auto hr = OleInitialize(0);
    if (hr != S_OK && hr != S_FALSE) {
        trace("OleInitialize failed, hresult=0x%x", hr);
        return false;
    }

    dropTarget = new GMDropTarget();
    hr = RegisterDragDrop(hwnd, dropTarget);
    if (FAILED(hr)) trace("RegisterDragDrop failed, hresult=0x%x", hr);
    return SUCCEEDED(hr);
}

//
dllg bool file_dropper_get_allow() {
    return GMDropTargetState::allow;
}
dllg void file_dropper_set_allow(bool allow) {
    GMDropTargetState::allow = allow;
}
//
dllg double file_dropper_get_effect(int effect) {
    return GMDropTargetState::effect;
}
dllg double file_dropper_set_effect(int effect) {
    GMDropTargetState::effect = effect;
    return 1;
}
//
dllg bool file_dropper_get_default_allow() {
    return GMDropTargetState::defaultAllow;
}
dllg void file_dropper_set_default_allow(bool allow) {
    GMDropTargetState::defaultAllow = allow;
}
//
dllg double file_dropper_get_default_effect(int effect) {
    return GMDropTargetState::defaultEffect;
}
dllg double file_dropper_set_default_effect(int effect) {
    GMDropTargetState::defaultEffect = effect;
    return 1;
}#include "gml_async_glue.h"

gml_event_perform_async_t gml_event_perform_async = nullptr;
gml_ds_map_create_ext_t gml_ds_map_create_ext = nullptr;
gml_ds_map_set_double_t gml_ds_map_set_double = nullptr;
gml_ds_map_set_string_t gml_ds_map_set_string = nullptr;

// Called by GM on DLL init
dllx double RegisterCallbacks(void* f1, void* f2, void* f3, void* f4) {
	gml_event_perform_async = (gml_event_perform_async_t)f1;
	gml_ds_map_create_ext = (gml_ds_map_create_ext_t)f2;
	gml_ds_map_set_double = (gml_ds_map_set_double_t)f3;
	gml_ds_map_set_string = (gml_ds_map_set_string_t)f4;
	return 0;
}// stdafx.cpp : source file that includes just the standard includes
// file_dropper.pch will be the pre-compiled header
// stdafx.obj will contain the pre-compiled type information

#include "stdafx.h"

// TODO: reference any additional headers you need in STDAFX.H
// and not in this file
