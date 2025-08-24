//{{NO_DEPENDENCIES}}
// Microsoft Visual C++ generated include file.
// Used by display_screenshot.rc

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
//{{NO_DEPENDENCIES}}
// Microsoft Visual C++ generated include file.
// Used by display_screenshot.rc

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

#include "targetver.h"

#define WIN32_LEAN_AND_MEAN             // Exclude rarely-used stuff from Windows headers
// Windows Header Files:
#include <windows.h>



// TODO: reference additional headers your program requires here
#pragma once

// Including SDKDDKVer.h defines the highest available Windows platform.

// If you wish to build your application for a previous Windows platform, include WinSDKVer.h and
// set the _WIN32_WINNT macro to the platform you wish to support before including SDKDDKVer.h.

#include <SDKDDKVer.h>
/// @author YellowAfterlife

#include "stdafx.h"
#include <stdio.h>
#include <d3d11.h>
#include <vector>

#define dllx extern "C" __declspec(dllexport)
#define trace(...) { printf(__VA_ARGS__); printf("\n"); fflush(stdout); }

struct dss_cache_t {
	int width;
	int height;
	HBITMAP bitmap;
	void* data;
	bool dirty;
};
dss_cache_t dss_cache = { 0, 0, NULL, NULL, false };

void dss_prepare(int w, int h, HDC dc) {
	//trace("%d:%d %d:%d", dss_cache.width, w, dss_cache.height, h);
	if (dss_cache.width == w && dss_cache.height == h) return;
	if (dss_cache.bitmap != NULL) DeleteObject(dss_cache.bitmap);
	dss_cache.width = w;
	dss_cache.height = h;
	dss_cache.dirty = false;
	BITMAPINFO bmi = { 0 };
	bmi.bmiHeader.biSize = sizeof(bmi.bmiHeader);
	bmi.bmiHeader.biPlanes = 1;
	bmi.bmiHeader.biBitCount = 32;
	bmi.bmiHeader.biWidth = w;
	bmi.bmiHeader.biHeight = -h;
	dss_cache.bitmap = CreateDIBSection(dc, &bmi, DIB_RGB_COLORS, &dss_cache.data, NULL, 0);
	//trace("cache flushed");
}
//
struct dss_region {
	int x;
	int y;
	int width;
	int height;
};
//
bool dss_multiscreen = false;
///
dllx double display_capture_mode(double all_screens) {
	dss_multiscreen = all_screens > 0.5;
	return true;
}
//
dllx double display_capture_measure_raw(dss_region* region) {
	bool z = dss_multiscreen;
	region->x = z ? GetSystemMetrics(SM_XVIRTUALSCREEN) : 0;
	region->y = z ? GetSystemMetrics(SM_YVIRTUALSCREEN) : 0;
	region->width = GetSystemMetrics(z ? SM_CXVIRTUALSCREEN : SM_CXSCREEN);
	region->height = GetSystemMetrics(z ? SM_CYVIRTUALSCREEN : SM_CYSCREEN);
	return true;
}
//
std::vector<HMONITOR> display_capture_measure_vec;
BOOL CALLBACK display_capture_measure_all_proc(HMONITOR m, HDC hdc, LPRECT rect, LPARAM p) {
	display_capture_measure_vec.push_back(m);
	return TRUE;
}
dllx double display_capture_measure_all_start_raw() {
	display_capture_measure_vec.clear();
	EnumDisplayMonitors(NULL, NULL, display_capture_measure_all_proc, 0);
	return display_capture_measure_vec.size();
}
//
struct dss_measure_ext {
	int mx, my, mw, mh;
	int wx, wy, ww, wh;
	int flags;
	char name[128];
};
dllx double display_capture_measure_all_next_raw(double _i, dss_measure_ext* out) {
	int i = (int)_i;
	if (i < 0 || i >= display_capture_measure_vec.size()) return false;
	MONITORINFOEXA inf;
	inf.cbSize = sizeof inf;
	if (!GetMonitorInfoA(display_capture_measure_vec[i], &inf)) return false;
	//
	auto& rect = inf.rcMonitor;
	out->mx = rect.left;
	out->mw = rect.right - rect.left;
	out->my = rect.top;
	out->mh = rect.bottom - rect.top;
	//
	rect = inf.rcWork;
	out->wx = rect.left;
	out->ww = rect.right - rect.left;
	out->wy = rect.top;
	out->wh = rect.bottom - rect.top;
	//
	out->flags = inf.dwFlags;
	if (strncpy_s(out->name, inf.szDevice, sizeof inf.szDevice) != 0) {
		strncpy_s(out->name, "<unknown>", 32);
	}
	//
	return true;
}
//
dllx double display_capture_buffer_raw(dss_region* region, char* out) {
	HDC hScreen = GetDC(NULL);
	HDC hMain = CreateCompatibleDC(hScreen);
	dss_prepare(region->width, region->height, hMain);
	HGDIOBJ hSwap = SelectObject(hMain, dss_cache.bitmap);
	char* p = (char*)dss_cache.data;
	int n = region->width * region->height * 4;
	//trace("%d %d %d %d", region->x, region->y, region->width, region->height);
	if (dss_cache.dirty) {
		memset(p, 0, n);
	} else dss_cache.dirty = true;
	BitBlt(hMain, 0, 0, region->width, region->height,
		hScreen, region->x, region->y, SRCCOPY);
	char* p1 = p + n;
	char* q = out;
	while (p < p1) {
		q[0] = p[2];
		q[1] = p[1];
		q[2] = p[0];
		q[3] = p[3];
		q += 4;
		p += 4;
	}
	SelectObject(hMain, hSwap);
	DeleteDC(hMain);
	ReleaseDC(NULL, hScreen);
	return true;
}
//
double display_capture_fast_raw(dss_region* region, char* out, ID3D11Device* device) {
	int result = 1;
	HRESULT hr;
	ID3D11DeviceContext* ctx = NULL;
	ID3D11RenderTargetView* view = NULL;
	do {
		device->GetImmediateContext(&ctx);
		if (!ctx) { result = 1; break; } 
		ctx->OMGetRenderTargets(1, &view, NULL);
		D3D11_RENDER_TARGET_VIEW_DESC desc;
		view->GetDesc(&desc);
		trace("%d", desc.Format);
	} while (false);
	if (ctx) ctx->Release();
	if (view) view->Release();
	return true;
}
//
dllx double display_capture_init_raw() {
	return true;
}
// dllmain.cpp : Defines the entry point for the DLL application.
#include "stdafx.h"

BOOL APIENTRY DllMain( HMODULE hModule,
                       DWORD  ul_reason_for_call,
                       LPVOID lpReserved
					 )
{
	switch (ul_reason_for_call)
	{
	case DLL_PROCESS_ATTACH:
	case DLL_THREAD_ATTACH:
	case DLL_THREAD_DETACH:
	case DLL_PROCESS_DETACH:
		break;
	}
	return TRUE;
}

// stdafx.cpp : source file that includes just the standard includes
// display_screenshot.pch will be the pre-compiled header
// stdafx.obj will contain the pre-compiled type information

#include "stdafx.h"

// TODO: reference any additional headers you need in STDAFX.H
// and not in this file
