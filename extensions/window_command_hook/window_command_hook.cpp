#pragma once
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
// Used by window_command_hook.rc

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

#if ((defined(_MSVC_LANG) && _MSVC_LANG >= 201703L) || __cplusplus >= 201703L)
#define tiny_cpp17
#endif

#if defined(WIN32)
#define dllx extern "C" __declspec(dllexport)
#elif defined(GNUC)
#define dllx extern "C" __attribute__ ((visibility("default"))) 
#else
#define dllx extern "C"
#endif

#define _trace // requires user32.lib;Kernel32.lib
//#define tiny_memset
//#define tiny_memcpy
#define tiny_malloc
//#define tiny_dtoui3

#ifdef _trace
#ifdef _WINDOWS
void trace(const char* format, ...);
#else
#define trace(...) { printf("[window_command_hook:%d] ", __LINE__); printf(__VA_ARGS__); printf("\n"); fflush(stdout); }
#endif
#endif

#pragma region typed memory helpers
template<typename T> T* malloc_arr(size_t count) {
	return (T*)malloc(sizeof(T) * count);
}
template<typename T> T* realloc_arr(T* arr, size_t count) {
	return (T*)realloc(arr, sizeof(T) * count);
}
template<typename T> T* memcpy_arr(T* dst, const T* src, size_t count) {
	return (T*)memcpy(dst, src, sizeof(T) * count);
}
#pragma endregion

#include "gml_ext.h"

// TODO: reference additional headers your program requires here
#pragma once

// Including SDKDDKVer.h defines the highest available Windows platform.

// If you wish to build your application for a previous Windows platform, include WinSDKVer.h and
// set the _WIN32_WINNT macro to the platform you wish to support before including SDKDDKVer.h.

#include <SDKDDKVer.h>
/// tiny_array.h
#pragma once
#include "stdafx.h"

template<typename T> class tiny_array {
	T* _data;
	size_t _size;
	size_t _capacity;

	bool add_impl(T value) {
		if (_size >= _capacity) {
			auto new_capacity = _capacity * 2;
			auto new_data = realloc_arr(_data, _capacity);
			if (new_data == nullptr) {
				trace("Failed to reallocate %u bytes in tiny_array::add", sizeof(T) * new_capacity);
				return false;
			}
			for (size_t i = _capacity; i < new_capacity; i++) new_data[i] = {};
			_data = new_data;
			_capacity = new_capacity;
		}
		_data[_size++] = value;
		return true;
	}
public:
	tiny_array() { }
	tiny_array(size_t capacity) { init(capacity); }
	inline void init(size_t capacity = 4) {
		if (capacity < 1) capacity = 1;
		_size = 0;
		_capacity = capacity;
		_data = malloc_arr<T>(capacity);
	}
	inline void free() {
		if (_data) {
			::free(_data);
			_data = nullptr;
		}
	}

	size_t size() { return _size; }
	size_t capacity() { return _capacity; }
	T* data() { return _data; }

	bool resize(size_t newsize, T value = {}) {
		if (newsize > _capacity) {
			auto new_data = realloc_arr(_data, newsize);
			if (new_data == nullptr) {
				trace("Failed to reallocate %u bytes in tiny_array::resize", sizeof(T) * newsize);
				return false;
			}
			_data = new_data;
			_capacity = newsize;
		}
		for (size_t i = _size; i < newsize; i++) _data[i] = value;
		for (size_t i = _size; --i >= newsize;) _data[i] = value;
		_size = newsize;
		return true;
	}

	#ifdef tiny_cpp17
	template<class... Args>
	inline bool add(Args... values) {
		return (add_impl(values) && ...);
	}
	#else
	inline void add(T value) {
		add_impl(value);
	}
	#endif

	bool remove(size_t index, size_t count = 1) {
		size_t end = index + count;
		if (end < _size) memcpy_arr(_data + start, _data + end, _size - end);
		_size -= end - index;
		return true;
	}

	bool set(T* values, size_t count) {
		if (!resize(count)) return false;
		memcpy_arr(_data, values, count);
		return true;
	}
	template<size_t count> inline bool set(T(&values)[count]) {
		return set(values, count);
	}

	T operator[] (size_t index) const { return _data[index]; }
	T& operator[] (size_t index) { return _data[index]; }
};
/// tiny_set.h
#pragma once
#include "stdafx.h"

template<typename T> struct tiny_set {
private:
	T* _arr;
	size_t _length;
	size_t _capacity;
public:
	tiny_set() {}
	tiny_set(size_t capacity) { init(capacity); }
	void init(size_t capacity = 4) {
		_capacity = capacity;
		_length = 0;
		_arr = malloc_arr<T>(_capacity);
	}

	static const size_t npos = MAXSIZE_T;
	size_t find(T val) {
		for (size_t i = 0; i < _length; i++) {
			if (_arr[i] == val) return i;
		}
		return npos;
	}
	inline bool contains(T val) {
		return find(val) != npos;
	}

	bool add(T val) {
		if (find(val) != npos) return false;
		if (_length >= _capacity) {
			_capacity *= 2;
			_arr = realloc_arr(_arr, _capacity);
		}
		_arr[_length++] = val;
		return true;
	}
	bool remove(T val) {
		auto i = find(val);
		if (i == npos) return false;
		_length -= 1;
		for (; i < _length; i++) _arr[i] = _arr[i + 1];
		return true;
	}
	inline bool set(T val, bool on) {
		if (on) return add(val); else return remove(val);
	}
};
#include "gml_ext.h"
extern bool window_command_hook(GAME_HWND hwnd, int command);
dllx double window_command_hook_raw(void* _in_ptr, double _in_ptr_size) {
	gml_istream _in(_in_ptr);
	GAME_HWND _arg_hwnd;
	_arg_hwnd = (GAME_HWND)_in.read<uint64_t>();
	int _arg_command;
	_arg_command = _in.read<int>();
	return window_command_hook(_arg_hwnd, _arg_command);
}

extern bool window_command_unhook(GAME_HWND hwnd, int command);
dllx double window_command_unhook_raw(void* _in_ptr, double _in_ptr_size) {
	gml_istream _in(_in_ptr);
	GAME_HWND _arg_hwnd;
	_arg_hwnd = (GAME_HWND)_in.read<uint64_t>();
	int _arg_command;
	_arg_command = _in.read<int>();
	return window_command_unhook(_arg_hwnd, _arg_command);
}

extern bool window_command_check(int command);
dllx double window_command_check_raw(void* _in_ptr, double _in_ptr_size) {
	gml_istream _in(_in_ptr);
	int _arg_command;
	_arg_command = _in.read<int>();
	return window_command_check(_arg_command);
}

extern int window_command_run(GAME_HWND hwnd, int wParam, int lParam);
dllx double window_command_run_raw(void* _in_ptr, double _in_ptr_size) {
	gml_istream _in(_in_ptr);
	GAME_HWND _arg_hwnd;
	_arg_hwnd = (GAME_HWND)_in.read<uint64_t>();
	int _arg_wParam;
	_arg_wParam = _in.read<int>();
	int _arg_lParam;
	if (_in.read<bool>()) {
		_arg_lParam = _in.read<int>();
	} else _arg_lParam = 0;
	return window_command_run(_arg_hwnd, _arg_wParam, _arg_lParam);
}

extern int window_command_get_active(GAME_HWND hwnd, int command);
dllx double window_command_get_active_raw(void* _in_ptr, double _in_ptr_size) {
	gml_istream _in(_in_ptr);
	GAME_HWND _arg_hwnd;
	_arg_hwnd = (GAME_HWND)_in.read<uint64_t>();
	int _arg_command;
	_arg_command = _in.read<int>();
	return window_command_get_active(_arg_hwnd, _arg_command);
}

extern int window_command_set_active(GAME_HWND hwnd, int command, bool value);
dllx double window_command_set_active_raw(void* _in_ptr, double _in_ptr_size) {
	gml_istream _in(_in_ptr);
	GAME_HWND _arg_hwnd;
	_arg_hwnd = (GAME_HWND)_in.read<uint64_t>();
	int _arg_command;
	_arg_command = _in.read<int>();
	bool _arg_value;
	_arg_value = _in.read<bool>();
	return window_command_set_active(_arg_hwnd, _arg_command, _arg_value);
}

extern bool window_get_background_redraw();
dllx double window_get_background_redraw_raw(void* _in_ptr, double _in_ptr_size) {
	gml_istream _in(_in_ptr);
	return window_get_background_redraw();
}

extern bool window_set_background_redraw(GAME_HWND hwnd, bool enable);
dllx double window_set_background_redraw_raw(void* _in_ptr, double _in_ptr_size) {
	gml_istream _in(_in_ptr);
	GAME_HWND _arg_hwnd;
	_arg_hwnd = (GAME_HWND)_in.read<uint64_t>();
	bool _arg_enable;
	_arg_enable = _in.read<bool>();
	return window_set_background_redraw(_arg_hwnd, _arg_enable);
}

extern bool window_get_topmost(GAME_HWND hwnd);
dllx double window_get_topmost_raw(void* _in_ptr, double _in_ptr_size) {
	gml_istream _in(_in_ptr);
	GAME_HWND _arg_hwnd;
	_arg_hwnd = (GAME_HWND)_in.read<uint64_t>();
	return window_get_topmost(_arg_hwnd);
}

extern bool window_set_topmost(GAME_HWND hwnd, bool enable);
dllx double window_set_topmost_raw(void* _in_ptr, double _in_ptr_size) {
	gml_istream _in(_in_ptr);
	GAME_HWND _arg_hwnd;
	_arg_hwnd = (GAME_HWND)_in.read<uint64_t>();
	bool _arg_enable;
	_arg_enable = _in.read<bool>();
	return window_set_topmost(_arg_hwnd, _arg_enable);
}

extern bool window_get_taskbar_button_visible(GAME_HWND hwnd);
dllx double window_get_taskbar_button_visible_raw(void* _in_ptr, double _in_ptr_size) {
	gml_istream _in(_in_ptr);
	GAME_HWND _arg_hwnd;
	_arg_hwnd = (GAME_HWND)_in.read<uint64_t>();
	return window_get_taskbar_button_visible(_arg_hwnd);
}

extern bool window_set_taskbar_button_visible(GAME_HWND hwnd, bool show_button);
dllx double window_set_taskbar_button_visible_raw(void* _in_ptr, double _in_ptr_size) {
	gml_istream _in(_in_ptr);
	GAME_HWND _arg_hwnd;
	_arg_hwnd = (GAME_HWND)_in.read<uint64_t>();
	bool _arg_show_button;
	_arg_show_button = _in.read<bool>();
	return window_set_taskbar_button_visible(_arg_hwnd, _arg_show_button);
}

extern bool window_set_visible_w(GAME_HWND hwnd, bool visible);
dllx double window_set_visible_w_raw(void* _in_ptr, double _in_ptr_size) {
	gml_istream _in(_in_ptr);
	GAME_HWND _arg_hwnd;
	_arg_hwnd = (GAME_HWND)_in.read<uint64_t>();
	bool _arg_visible;
	_arg_visible = _in.read<bool>();
	return window_set_visible_w(_arg_hwnd, _arg_visible);
}

// stdafx.cpp : source file that includes just the standard includes
// window_command_hook.pch will be the pre-compiled header
// stdafx.obj will contain the pre-compiled type information

#include "stdafx.h"
#include <strsafe.h>
#ifdef tiny_dtoui3
#include <intrin.h>
#endif

#if _WINDOWS
// http://computer-programming-forum.com/7-vc.net/07649664cea3e3d7.htm
extern "C" int _fltused = 0;
#endif

// TODO: reference any additional headers you need in STDAFX.H
// and not in this file
#ifdef _trace
#ifdef _WINDOWS
// https://yal.cc/printf-without-standard-library/
void trace(const char* pszFormat, ...) {
	char buf[1025];
	va_list argList;
	va_start(argList, pszFormat);
	wvsprintfA(buf, pszFormat, argList);
	va_end(argList);
	DWORD done;
	auto len = strlen(buf);
	buf[len] = '\n';
	buf[++len] = 0;
	WriteFile(GetStdHandle(STD_OUTPUT_HANDLE), buf, len, &done, NULL);
}
#endif
#endif

#pragma warning(disable: 28251 28252)

#ifdef tiny_memset
#pragma function(memset)
void* __cdecl memset(void* _Dst, _In_ int _Val,_In_ size_t _Size) {
	auto ptr = static_cast<uint8_t*>(_Dst);
	while (_Size) {
		*ptr++ = _Val;
		_Size--;
	}
	return _Dst;
}
#endif

#ifdef tiny_memcpy
#pragma function(memcpy)
void* memcpy(void* _Dst, const void* _Src, size_t _Size) {
	auto src8 = static_cast<const uint64_t*>(_Src);
	auto dst8 = static_cast<uint64_t*>(_Dst);
	for (; _Size > 32; _Size -= 32) {
		*dst8++ = *src8++;
		*dst8++ = *src8++;
		*dst8++ = *src8++;
		*dst8++ = *src8++;
	}
	for (; _Size > 8; _Size -= 8) *dst8++ = *src8++;
	//
	auto src1 = (const uint8_t*)(src8);
	auto dst1 = (uint8_t*)(dst8);
	for (; _Size != 0; _Size--) *dst1++ = *src1++;
	return _Dst;
}
#endif

#ifdef tiny_malloc
void* __cdecl malloc(size_t _Size) {
	return HeapAlloc(GetProcessHeap(), 0, _Size);
}
void* __cdecl realloc(void* _Block, size_t _Size) {
	return HeapReAlloc(GetProcessHeap(), 0, _Block, _Size);
}
void __cdecl free(void* _Block) {
	HeapFree(GetProcessHeap(), 0, _Block);
}
#endif

#ifdef tiny_dtoui3
// https:/stackoverflow.com/a/55011686/5578773
extern "C" unsigned int _dtoui3(const double x) {
	return (unsigned int)_mm_cvttsd_si32(_mm_set_sd(x));
}
#endif

#pragma warning(default: 28251 28252)
/// @author YellowAfterlife

#include "stdafx.h"
#include "tiny_set.h"

bool window_command_direct;
bool window_background_redraw;
//HWND window_command_hwnd;
tiny_set<WPARAM> window_commands_hooked;
tiny_set<WPARAM> window_commands_caught;
tiny_set<WPARAM> window_commands_blocked;

WNDPROC window_command_proc_base;
LRESULT window_command_proc_hook(HWND hwnd, UINT msg, WPARAM wp, LPARAM lp) {
    //printf("msg=%d\n", msg); fflush(stdout);
    switch (msg) {
        case WM_ERASEBKGND:
            if (!window_background_redraw) return TRUE;
            break;
        case WM_SYSCOMMAND:
            if (window_command_direct) break;
            auto cmd = wp & ~15;
            if (window_commands_blocked.contains(cmd)) return TRUE;
            if (window_commands_hooked.contains(cmd)) {
                window_commands_caught.add(cmd);
                return TRUE;
            }
            break;
    }
    return CallWindowProc(window_command_proc_base, hwnd, msg, wp, lp);
}
void window_command_proc_ensure(HWND hwnd) {
    if (window_command_proc_base != nullptr) return;
    window_command_proc_base = (WNDPROC)SetWindowLongPtr(hwnd, GWLP_WNDPROC, (LONG_PTR)window_command_proc_hook);
}

#pragma region hooks
dllg bool window_command_hook(GAME_HWND hwnd, int command) {
    window_command_proc_ensure(hwnd);
    window_commands_hooked.add(command);
    return true;
}
dllg bool window_command_unhook(GAME_HWND hwnd, int command) {
    window_commands_hooked.remove(command);
    window_commands_caught.remove(command);
    return true;
}
dllg bool window_command_check(int command) {
    return window_commands_caught.remove(command);
}
#pragma endregion

#pragma region active
dllg int window_command_run(GAME_HWND hwnd, int wParam, int lParam = 0) {
    auto _direct = window_command_direct;
    window_command_direct = true;
    auto result = SendMessageW(hwnd, WM_SYSCOMMAND, wParam, lParam);
    window_command_direct = _direct;
    return result;
}
long window_command_long(WPARAM cmd) {
    switch (cmd) {
        case SC_SIZE: return WS_SIZEBOX;
        case SC_MINIMIZE: return WS_MINIMIZEBOX;
        case SC_MAXIMIZE: return WS_MAXIMIZEBOX;
        default: return -1;
    }
}
int window_command_acc_active(HWND hwnd, WPARAM wcmd, int _val) {
    auto get = _val < 0;
    auto set = _val > 0;
    switch (wcmd) {
        case SC_MOVE: case SC_SIZE: case SC_MOUSEMENU: {
            if (get) return window_commands_blocked.contains(wcmd);
            if (set) window_command_proc_ensure(hwnd);
            window_commands_blocked.set(wcmd, set);
            return 1;
        }; break;
        case SC_CLOSE: {
            auto menu = GetSystemMenu(hwnd, false);
            if (get) return (GetMenuState(menu, wcmd, MF_BYCOMMAND) & MF_GRAYED) == 0;
            if (EnableMenuItem(menu, wcmd, MF_BYCOMMAND | (set ? MF_ENABLED : MF_GRAYED)) < 0) return -1;
            return 1;
        }; break;
        default: {
            auto cl = window_command_long(wcmd);
            if (cl < 0) return -1;
            auto wl = GetWindowLong(hwnd, GWL_STYLE);
            if (get) return (wl & cl) == cl;
            if (set) wl |= cl; else wl &= ~cl;
            SetWindowLong(hwnd, GWL_STYLE, wl);
            return 1;
        }; break;
    }
}
dllg int window_command_get_active(GAME_HWND hwnd, int command) {
    return window_command_acc_active(hwnd, command, -1);
}
dllg int window_command_set_active(GAME_HWND hwnd, int command, bool value) {
    return window_command_acc_active(hwnd, command, value ? 1 : 0);
}
#pragma endregion

#pragma region misc
dllg bool window_get_background_redraw() {
    return window_background_redraw;
}
dllg bool window_set_background_redraw(GAME_HWND hwnd, bool enable) {
    window_command_proc_ensure(hwnd);
    return true;
}

dllg bool window_get_topmost(GAME_HWND hwnd) {
    return (GetWindowLong(hwnd, GWL_EXSTYLE) & WS_EX_TOPMOST) != 0;
}
dllg bool window_set_topmost(GAME_HWND hwnd, bool enable) {
    SetWindowPos(hwnd, enable ? HWND_TOPMOST : HWND_NOTOPMOST, 0, 0, 0, 0, SWP_NOMOVE | SWP_NOSIZE);
    return true;
}

dllg bool window_get_taskbar_button_visible(GAME_HWND hwnd) {
    return (GetWindowLong(hwnd, GWL_EXSTYLE) & WS_EX_TOOLWINDOW) == 0;
}
dllg bool window_set_taskbar_button_visible(GAME_HWND hwnd, bool show_button) {
    auto exStyle = GetWindowLong(hwnd, GWL_EXSTYLE);
    if (show_button) {
        exStyle &= ~WS_EX_TOOLWINDOW;
    } else exStyle |= WS_EX_TOOLWINDOW;
    SetWindowLong(hwnd, GWL_EXSTYLE, exStyle);
    return true;
}

dllg bool window_set_visible_w(GAME_HWND hwnd, bool visible) {
    ShowWindow(hwnd, visible ? SW_SHOW : SW_HIDE);
    return true;
}
#pragma endregion

static void init() {
	window_command_proc_base = nullptr;
    window_command_direct = false;
    window_background_redraw = false;
    window_commands_hooked.init();
    window_commands_caught.init();
    window_commands_blocked.init();
}
BOOL APIENTRY DllMain(HMODULE hModule, DWORD  ul_reason_for_call, LPVOID lpReserved) {
	if (ul_reason_for_call == DLL_PROCESS_ATTACH) init();
	return TRUE;
}
