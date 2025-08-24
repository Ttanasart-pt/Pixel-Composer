
#include <stdint.h>

//
// Copyright (C) 2020 Opera Norway AS. All rights reserved.
//
// This file is an original work developed by Opera.
//

#ifndef __YY__RUNNER_INTERFACE_H_
#define __YY__RUNNER_INTERFACE_H_

#if !defined (OS_Windows) && !defined(OS_MacOs)
#define OS_Linux
#endif

#ifdef OS_Windows
#define YYEXPORT __declspec(dllexport)
#endif

#if defined(OS_Linux) || defined(OS_MacOs)
#define YYEXPORT __attribute__((visibility("default")))
#include <stddef.h>
#endif

#include <stdint.h>

class	IBuffer;

struct RValue;
class YYObjectBase;
class CInstance;
struct YYRunnerInterface;
struct HTTP_REQ_CONTEXT;
typedef int (*PFUNC_async)(HTTP_REQ_CONTEXT* _pContext, void* _pPayload, int* _pMap);
typedef void (*PFUNC_cleanup)(HTTP_REQ_CONTEXT* _pContext);
typedef void (*PFUNC_process)(HTTP_REQ_CONTEXT* _pContext);

typedef void (*TSetRunnerInterface)(const YYRunnerInterface* pRunnerInterface, size_t _functions_size);
typedef void (*TYYBuiltin)(RValue& Result, CInstance* selfinst, CInstance* otherinst, int argc, RValue* arg);
typedef long long int64;
typedef unsigned long long uint64;
typedef int32_t int32;
typedef uint32_t uint32;
typedef int16_t int16;
typedef uint16_t uint16;
typedef int8_t int8;
typedef uint8_t uint8;

typedef void* HYYMUTEX;
typedef void* HSPRITEASYNC;

//#ifdef GDKEXTENSION_EXPORTS
enum eBuffer_Format {
    eBuffer_Format_Fixed = 0,
    eBuffer_Format_Grow = 1,
    eBuffer_Format_Wrap = 2,
    eBuffer_Format_Fast = 3,
    eBuffer_Format_VBuffer = 4,
    eBuffer_Format_Network = 5,
};
//#else
/* For eBuffer_Format */
//#include <Files/Buffer/IBuffer.h>
//#endif

struct RValue;
class YYObjectBase;
class CInstance;
struct YYRunnerInterface;
struct HTTP_REQ_CONTEXT;
typedef int (*PFUNC_async)(HTTP_REQ_CONTEXT* _pContext, void* _pPayload, int* _pMap);
typedef void (*PFUNC_cleanup)(HTTP_REQ_CONTEXT* _pContext);
typedef void (*PFUNC_process)(HTTP_REQ_CONTEXT* _pContext);

typedef void (*TSetRunnerInterface)(const YYRunnerInterface* pRunnerInterface, size_t _functions_size);
typedef void (*TYYBuiltin)(RValue& Result, CInstance* selfinst, CInstance* otherinst, int argc, RValue* arg);
typedef long long int64;
typedef unsigned long long uint64;
typedef int32_t int32;
typedef uint32_t uint32;
typedef int16_t int16;
typedef uint16_t uint16;
typedef int8_t int8;
typedef uint8_t uint8;

#ifdef GDKEXTENSION_EXPORTS
enum eBuffer_Format {
	eBuffer_Format_Fixed = 0,
	eBuffer_Format_Grow = 1,
	eBuffer_Format_Wrap = 2,
	eBuffer_Format_Fast = 3,
	eBuffer_Format_VBuffer = 4,
	eBuffer_Format_Network = 5,
};

class IBuffer;
#else
/* For eBuffer_Format */
//#include <Files/Buffer/IBuffer.h>
#endif

typedef void* HYYMUTEX;
typedef void* HSPRITEASYNC;

struct YYRunnerInterface
{
	// basic interaction with the user
	void (*DebugConsoleOutput)(const char* fmt, ...); // hook to YYprintf
	void (*ReleaseConsoleOutput)(const char* fmt, ...);
	void (*ShowMessage)(const char* msg);

	// for printing error messages
	void (*YYError)(const char* _error, ...);

	// alloc, realloc and free
	void* (*YYAlloc)(int _size);
	void* (*YYRealloc)(void* pOriginal, int _newSize);
	void  (*YYFree)(const void* p);
	const char* (*YYStrDup)(const char* _pS);

	// yyget* functions for parsing arguments out of the arg index
	bool (*YYGetBool)(const RValue* _pBase, int _index);
	float (*YYGetFloat)(const RValue* _pBase, int _index);
	double (*YYGetReal)(const RValue* _pBase, int _index);
	int32_t(*YYGetInt32)(const RValue* _pBase, int _index);
	uint32_t(*YYGetUint32)(const RValue* _pBase, int _index);
	int64(*YYGetInt64)(const RValue* _pBase, int _index);
	void* (*YYGetPtr)(const RValue* _pBase, int _index);
	intptr_t(*YYGetPtrOrInt)(const RValue* _pBase, int _index);
	const char* (*YYGetString)(const RValue* _pBase, int _index);

	// typed get functions from a single rvalue
	bool (*BOOL_RValue)(const RValue* _pValue);
	double (*REAL_RValue)(const RValue* _pValue);
	void* (*PTR_RValue)(const RValue* _pValue);
	int64(*INT64_RValue)(const RValue* _pValue);
	int32_t(*INT32_RValue)(const RValue* _pValue);

	// calculate hash values from an RValue
	int (*HASH_RValue)(const RValue* _pValue);

	// copying, setting and getting RValue
	void (*SET_RValue)(RValue* _pDest, RValue* _pV, YYObjectBase* _pPropSelf, int _index);
	bool (*GET_RValue)(RValue* _pRet, RValue* _pV, YYObjectBase* _pPropSelf, int _index, bool fPrepareArray, bool fPartOfSet);
	void (*COPY_RValue)(RValue* _pDest, const RValue* _pSource);
	int (*KIND_RValue)(const RValue* _pValue);
	void (*FREE_RValue)(RValue* _pValue);
	void (*YYCreateString)(RValue* _pVal, const char* _pS);

	void (*YYCreateArray)(RValue* pRValue, int n_values, const double* values);

	// finding and runnine user scripts from name
	int (*Script_Find_Id)(const char* name);
	bool (*Script_Perform)(int ind, CInstance* selfinst, CInstance* otherinst, int argc, RValue* res, RValue* arg);

	// finding builtin functions
	bool  (*Code_Function_Find)(const char* name, int* ind);

	// http functions
	void (*HTTP_Get)(const char* _pFilename, int _type, PFUNC_async _async, PFUNC_cleanup _cleanup, void* _pV);
	void (*HTTP_Post)(const char* _pFilename, const char* _pPost, PFUNC_async _async, PFUNC_cleanup _cleanup, void* _pV);
	void (*HTTP_Request)(const char* _url, const char* _method, const char* _headers, const char* _pBody, PFUNC_async _async, PFUNC_cleanup _cleanup, void* _pV, int _contentLength);

	// sprite loading helper functions
	int (*ASYNCFunc_SpriteAdd)(HTTP_REQ_CONTEXT* _pContext, void* _p, int* _pMap);
	void (*ASYNCFunc_SpriteCleanup)(HTTP_REQ_CONTEXT* _pContext);
	HSPRITEASYNC(*CreateSpriteAsync)(int* _pSpriteIndex, int _xOrig, int _yOrig, int _numImages, int _flags);

	// timing
	int64(*Timing_Time)(void);
	void (*Timing_Sleep)(int64 slp, bool precise);

	// mutex handling
	HYYMUTEX(*YYMutexCreate)(const char* _name);
	void (*YYMutexDestroy)(HYYMUTEX hMutex);
	void (*YYMutexLock)(HYYMUTEX hMutex);
	void (*YYMutexUnlock)(HYYMUTEX hMutex);

	// ds map manipulation for 
	void (*CreateAsyncEventWithDSMap)(int _map, int _event);
	void (*CreateAsyncEventWithDSMapAndBuffer)(int _map, int _buffer, int _event);
	int (*CreateDsMap)(int _num, ...);

	bool (*DsMapAddDouble)(int _index, const char* _pKey, double value);
	bool (*DsMapAddString)(int _index, const char* _pKey, const char* pVal);
	bool (*DsMapAddInt64)(int _index, const char* _pKey, int64 value);

	// buffer access
	bool (*BufferGetContent)(int _index, void** _ppData, int* _pDataSize);
	int (*BufferWriteContent)(int _index, int _dest_offset, const void* _pSrcMem, int _size, bool _grow, bool _wrap);
	int (*CreateBuffer)(int _size, enum eBuffer_Format _bf, int _alignment);

	// variables
	volatile bool* pLiveConnection;
	int* pHTTP_ID;

	int (*DsListCreate)();
	void (*DsMapAddList)(int _dsMap, const char* _key, int _listIndex);
	void (*DsListAddMap)(int _dsList, int _mapIndex);
	void (*DsMapClear)(int _dsMap);
	void (*DsListClear)(int _dsList);

	bool (*BundleFileExists)(const char* _pszFileName);
	bool (*BundleFileName)(char* _name, int _size, const char* _pszFileName);
	bool (*SaveFileExists)(const char* _pszFileName);
	bool (*SaveFileName)(char* _name, int _size, const char* _pszFileName);

	bool (*Base64Encode)(const void* input_buf, size_t input_len, void* output_buf, size_t output_len);

	void (*DsListAddInt64)(int _dsList, int64 _value);

	void (*AddDirectoryToBundleWhitelist)(const char* _pszFilename);
	void (*AddFileToBundleWhitelist)(const char* _pszFilename);
	void (*AddDirectoryToSaveWhitelist)(const char* _pszFilename);
	void (*AddFileToSaveWhitelist)(const char* _pszFilename);

	const char* (*KIND_NAME_RValue)(const RValue* _pV);

	void (*DsMapAddBool)(int _index, const char* _pKey, bool value);
	void (*DsMapAddRValue)(int _index, const char* _pKey, RValue* value);
	void (*DestroyDsMap)(int _index);

	void (*StructCreate)(RValue* _pStruct);
	void (*StructAddBool)(RValue* _pStruct, const char* _pKey, bool _value);
	void (*StructAddDouble)(RValue* _pStruct, const char* _pKey, double _value);
	void (*StructAddInt)(RValue* _pStruct, const char* _pKey, int _value);
	void (*StructAddRValue)(RValue* _pStruct, const char* _pKey, RValue* _pValue);
	void (*StructAddString)(RValue* _pStruct, const char* _pKey, const char* _pValue);

	bool (*WhitelistIsDirectoryIn)(const char* _pszDirectory);
	bool (*WhiteListIsFilenameIn)(const char* _pszFilename);
	void (*WhiteListAddTo)(const char* _pszFilename, bool _bIsDir);
	bool (*DirExists)(const char* filename);
	IBuffer* (*BufferGetFromGML)(int ind);
	int (*BufferTELL)(IBuffer* buff);
	unsigned char* (*BufferGet)(IBuffer* buff);
	const char* (*FilePrePend)(void);

	void (*StructAddInt32)(RValue* _pStruct, const char* _pKey, int32 _value);
	void (*StructAddInt64)(RValue* _pStruct, const char* _pKey, int64 _value);
	RValue* (*StructGetMember)(RValue* _pStruct, const char* _pKey);

	/**
	 * @brief Query the keys in a struct.
	 *
	 * @param _pStruct  Pointer to a VALUE_OBJECT RValue.
	 * @param _keys     Pointer to an array of const char* pointers to receive the names.
	 * @param _count    Length of _keys (in elements) on input, number filled on output.
	 *
	 * @return Total number of keys in the struct.
	 *
	 * NOTE: The strings in _keys are owned by the runner. You do not need to free them, however
	 * you should make a copy if you intend to keep them around as the runner may invalidate them
	 * in the future when performing variable modifications.
	 *
	 * Usage example:
	 *
	 *    // Get total number of keys in struct
	 *    int num_keys = YYRunnerInterface_p->StructGetKeys(struct_rvalue, NULL, NULL);
	 *
	 *    // Fetch keys from struct
	 *    std::vector<const char*> keys(num_keys);
	 *    YYRunnerInterface_p->StructGetKeys(struct_rvalue, keys.data(), &num_keys);
	 *
	 *    // Loop over struct members
	 *    for(int i = 0; i < num_keys; ++i)
	 *    {
	 *        RValue *member = YYRunnerInterface_p->StructGetMember(struct_rvalue, keys[i]);
	 *        ...
	 *    }
	*/
	int (*StructGetKeys)(RValue* _pStruct, const char** _keys, int* _count);

	RValue* (*YYGetStruct)(RValue* _pBase, int _index);

	void (*extOptGetRValue)(RValue& result, const char* _ext, const  char* _opt);
	const char* (*extOptGetString)(const char* _ext, const  char* _opt);
	double (*extOptGetReal)(const char* _ext, const char* _opt);

	bool (*isRunningFromIDE)();
};

#define __YYDEFINE_EXTENSION_FUNCTIONS__
#if defined(__YYDEFINE_EXTENSION_FUNCTIONS__)
extern YYRunnerInterface* g_pYYRunnerInterface;

// basic interaction with the user
#define BAR(...) printf(FIRST(__VA_ARGS__) "\n" REST(__VA_ARGS__))
#define DebugConsoleOutput(...) g_pYYRunnerInterface->DebugConsoleOutput(FIRST(__VA_ARGS__) /*"\n"*/ REST(__VA_ARGS__))
#define ReleaseConsoleOutput(fmt, ...) g_pYYRunnerInterface->ReleaseConsoleOutput(FIRST(__VA_ARGS__) "\n" REST(__VA_ARGS__))

//This #definitions make compatible DebugConsoleOutput() with MacOS//https://stackoverflow.com/a/11172679/10547574
#define FIRST(...) FIRST_HELPER(__VA_ARGS__, throwaway)
#define FIRST_HELPER(first, ...) first
#define REST(...) REST_HELPER(NUM(__VA_ARGS__), __VA_ARGS__)
#define REST_HELPER(qty, ...) REST_HELPER2(qty, __VA_ARGS__)
#define REST_HELPER2(qty, ...) REST_HELPER_##qty(__VA_ARGS__)
#define REST_HELPER_ONE(first)
#define REST_HELPER_TWOORMORE(first, ...) , __VA_ARGS__
#define NUM(...) \
    SELECT_10TH(__VA_ARGS__, TWOORMORE, TWOORMORE, TWOORMORE, TWOORMORE,\
                TWOORMORE, TWOORMORE, TWOORMORE, TWOORMORE, ONE, throwaway)
#define SELECT_10TH(a1, a2, a3, a4, a5, a6, a7, a8, a9, a10, ...) a10
inline void ShowMessage(const char* msg) { g_pYYRunnerInterface->ShowMessage(msg); }

// for printing error messages
#define YYError(_error, ...)				g_pYYRunnerInterface->YYError( _error, __VA_ARGS__ )

// alloc, realloc and free
inline void* YYAlloc(int _size) { return g_pYYRunnerInterface->YYAlloc(_size); }
inline void* YYRealloc(void* pOriginal, int _newSize) { return g_pYYRunnerInterface->YYRealloc(pOriginal, _newSize); }
inline void  YYFree(const void* p) { g_pYYRunnerInterface->YYFree(p); }
inline const char* YYStrDup(const char* _pS) { return g_pYYRunnerInterface->YYStrDup(_pS); }

// yyget* functions for parsing arguments out of the arg index
inline bool YYGetBool(const RValue* _pBase, int _index) { return g_pYYRunnerInterface->YYGetBool(_pBase, _index); }
inline float YYGetFloat(const RValue* _pBase, int _index) { return g_pYYRunnerInterface->YYGetFloat(_pBase, _index); }
inline double YYGetReal(const RValue* _pBase, int _index) { return g_pYYRunnerInterface->YYGetReal(_pBase, _index); }
inline int32_t YYGetInt32(const RValue* _pBase, int _index) { return g_pYYRunnerInterface->YYGetInt32(_pBase, _index); }
inline uint32_t YYGetUint32(const RValue* _pBase, int _index) { return g_pYYRunnerInterface->YYGetUint32(_pBase, _index); }
inline int64 YYGetInt64(const RValue* _pBase, int _index) { return g_pYYRunnerInterface->YYGetInt64(_pBase, _index); }
inline void* YYGetPtr(const RValue* _pBase, int _index) { return g_pYYRunnerInterface->YYGetPtr(_pBase, _index); }
inline intptr_t YYGetPtrOrInt(const RValue* _pBase, int _index) { return g_pYYRunnerInterface->YYGetPtrOrInt(_pBase, _index); }
inline const char* YYGetString(const RValue* _pBase, int _index) { return g_pYYRunnerInterface->YYGetString(_pBase, _index); }
inline RValue* YYGetStruct(RValue* _pBase, int _index) { return g_pYYRunnerInterface->YYGetStruct(_pBase, _index); }

// typed get functions from a single rvalue
inline bool BOOL_RValue(const RValue* _pValue) { return g_pYYRunnerInterface->BOOL_RValue(_pValue); }
inline double REAL_RValue(const RValue* _pValue) { return g_pYYRunnerInterface->REAL_RValue(_pValue); }
inline void* PTR_RValue(const RValue* _pValue) { return g_pYYRunnerInterface->PTR_RValue(_pValue); }
inline int64 INT64_RValue(const RValue* _pValue) { return g_pYYRunnerInterface->INT64_RValue(_pValue); }
inline int32_t INT32_RValue(const RValue* _pValue) { return g_pYYRunnerInterface->INT32_RValue(_pValue); }

// calculate hash values from an RValue
inline int HASH_RValue(const RValue* _pValue) { return g_pYYRunnerInterface->HASH_RValue(_pValue); }

// copying, setting and getting RValue
inline void SET_RValue(RValue* _pDest, RValue* _pV, YYObjectBase* _pPropSelf, int _index) { return g_pYYRunnerInterface->SET_RValue(_pDest, _pV, _pPropSelf, _index); }
inline bool GET_RValue(RValue* _pRet, RValue* _pV, YYObjectBase* _pPropSelf, int _index, bool fPrepareArray = false, bool fPartOfSet = false) { return g_pYYRunnerInterface->GET_RValue(_pRet, _pV, _pPropSelf, _index, fPrepareArray, fPartOfSet); }
inline void COPY_RValue(RValue* _pDest, const RValue* _pSource) { g_pYYRunnerInterface->COPY_RValue(_pDest, _pSource); }
inline int KIND_RValue(const RValue* _pValue) { return g_pYYRunnerInterface->KIND_RValue(_pValue); }
inline void FREE_RValue(RValue* _pValue) { return g_pYYRunnerInterface->FREE_RValue(_pValue); }
inline void YYCreateString(RValue* _pVal, const char* _pS) { g_pYYRunnerInterface->YYCreateString(_pVal, _pS); }
inline const char* KIND_NAME_RValue(const RValue* _pV) { return g_pYYRunnerInterface->KIND_NAME_RValue(_pV); }

inline void YYCreateArray(RValue* pRValue, int n_values = 0, const double* values = NULL) { g_pYYRunnerInterface->YYCreateArray(pRValue, n_values, values); }

// finding and runnine user scripts from name
inline int Script_Find_Id(char* name) { return g_pYYRunnerInterface->Script_Find_Id(name); }
inline bool Script_Perform(int ind, CInstance* selfinst, CInstance* otherinst, int argc, RValue* res, RValue* arg) {
	return g_pYYRunnerInterface->Script_Perform(ind, selfinst, otherinst, argc, res, arg);
}

// finding builtin functions
inline bool  Code_Function_Find(char* name, int* ind) { return g_pYYRunnerInterface->Code_Function_Find(name, ind); }

// Http function
inline void HTTP_Get(const char* _pFilename, int _type, PFUNC_async _async, PFUNC_cleanup _cleanup, void* _pV) { g_pYYRunnerInterface->HTTP_Get(_pFilename, _type, _async, _cleanup, _pV); }
inline void HTTP_Post(const char* _pFilename, const char* _pPost, PFUNC_async _async, PFUNC_cleanup _cleanup, void* _pV) { g_pYYRunnerInterface->HTTP_Post(_pFilename, _pPost, _async, _cleanup, _pV); }
inline void HTTP_Request(const char* _url, const char* _method, const char* _headers, const char* _pBody, PFUNC_async _async, PFUNC_cleanup _cleanup, void* _pV, int _contentLength = -1) {
	g_pYYRunnerInterface->HTTP_Request(_url, _method, _headers, _pBody, _async, _cleanup, _pV, _contentLength);
} // end HTTP_Request

// sprite async loading
inline HSPRITEASYNC CreateSpriteAsync(int* _pSpriteIndex, int _xOrig, int _yOrig, int _numImages, int _flags) {
	return g_pYYRunnerInterface->CreateSpriteAsync(_pSpriteIndex, _xOrig, _yOrig, _numImages, _flags);
} // end CreateSpriteAsync


// timing
inline int64 Timing_Time(void) { return g_pYYRunnerInterface->Timing_Time(); }
inline void Timing_Sleep(int64 slp, bool precise = false) { g_pYYRunnerInterface->Timing_Sleep(slp, precise); }

// mutex functions
inline HYYMUTEX YYMutexCreate(const char* _name) { return g_pYYRunnerInterface->YYMutexCreate(_name); }
inline void YYMutexDestroy(HYYMUTEX hMutex) { g_pYYRunnerInterface->YYMutexDestroy(hMutex); }
inline void YYMutexLock(HYYMUTEX hMutex) { g_pYYRunnerInterface->YYMutexLock(hMutex); }
inline void YYMutexUnlock(HYYMUTEX hMutex) { g_pYYRunnerInterface->YYMutexUnlock(hMutex); }

// ds map manipulation for 
inline void CreateAsyncEventWithDSMap(int _map, int _event) { return g_pYYRunnerInterface->CreateAsyncEventWithDSMap(_map, _event); }
inline void CreateAsyncEventWithDSMapAndBuffer(int _map, int _buffer, int _event) { return g_pYYRunnerInterface->CreateAsyncEventWithDSMapAndBuffer(_map, _buffer, _event); }
#define CreateDsMap(_num, ...) g_pYYRunnerInterface->CreateDsMap( _num, __VA_ARGS__ )

inline bool DsMapAddDouble(int _index, const char* _pKey, double value) { return g_pYYRunnerInterface->DsMapAddDouble(_index, _pKey, value); }
inline bool DsMapAddString(int _index, const char* _pKey, const char* pVal) { return g_pYYRunnerInterface->DsMapAddString(_index, _pKey, pVal); }
inline bool DsMapAddInt64(int _index, const char* _pKey, int64 value) { return g_pYYRunnerInterface->DsMapAddInt64(_index, _pKey, value); }
inline void DsMapAddList(int _dsMap, const char* _pKey, int _listIndex) { return g_pYYRunnerInterface->DsMapAddList(_dsMap, _pKey, _listIndex); }
inline void DsMapAddBool(int _dsMap, const char* _pKey, bool value) { return g_pYYRunnerInterface->DsMapAddBool(_dsMap, _pKey, value); }
inline void DsMapAddRValue(int _dsMap, const char* _pKey, RValue* value) { return g_pYYRunnerInterface->DsMapAddRValue(_dsMap, _pKey, value); }
inline void DsMapClear(int _index) { return g_pYYRunnerInterface->DsMapClear(_index); }
inline void DestroyDsMap(int _index) { g_pYYRunnerInterface->DestroyDsMap(_index); }

inline int DsListCreate() { return g_pYYRunnerInterface->DsListCreate(); }
inline void DsListAddMap(int _dsList, int _mapIndex) { return g_pYYRunnerInterface->DsListAddMap(_dsList, _mapIndex); }
inline void DsListClear(int _dsList) { return g_pYYRunnerInterface->DsListClear(_dsList); }

// buffer access
inline bool BufferGetContent(int _index, void** _ppData, int* _pDataSize) { return g_pYYRunnerInterface->BufferGetContent(_index, _ppData, _pDataSize); }
inline int BufferWriteContent(int _index, int _dest_offset, const void* _pSrcMem, int _size, bool _grow = false, bool _wrap = false) { return g_pYYRunnerInterface->BufferWriteContent(_index, _dest_offset, _pSrcMem, _size, _grow, _wrap); }
inline int CreateBuffer(int _size, enum eBuffer_Format _bf, int _alignment) { return g_pYYRunnerInterface->CreateBuffer(_size, _bf, _alignment); }

inline bool Base64Encode(const void* input_buf, size_t input_len, void* output_buf, size_t output_len) {return g_pYYRunnerInterface->Base64Encode(input_buf, input_len, output_buf, output_len); }

inline void AddDirectoryToBundleWhitelist(const char* _pszFilename) { g_pYYRunnerInterface->AddDirectoryToBundleWhitelist(_pszFilename); }
inline void AddFileToBundleWhitelist(const char* _pszFilename) { g_pYYRunnerInterface->AddFileToBundleWhitelist(_pszFilename); }
inline void AddDirectoryToSaveWhitelist(const char* _pszFilename) { g_pYYRunnerInterface->AddDirectoryToSaveWhitelist(_pszFilename); }
inline void AddFileToSaveWhitelist(const char* _pszFilename) { g_pYYRunnerInterface->AddFileToSaveWhitelist(_pszFilename); }

inline void YYStructCreate(RValue* _pStruct) { g_pYYRunnerInterface->StructCreate(_pStruct); }
inline void YYStructAddBool(RValue* _pStruct, const char* _pKey, double _value) { return g_pYYRunnerInterface->StructAddBool(_pStruct, _pKey, _value); }
inline void YYStructAddDouble(RValue* _pStruct, const char* _pKey, double _value) { return g_pYYRunnerInterface->StructAddDouble(_pStruct, _pKey, _value); }
inline void YYStructAddInt(RValue* _pStruct, const char* _pKey, int _value) { return g_pYYRunnerInterface->StructAddInt(_pStruct, _pKey, _value); }
inline void YYStructAddRValue(RValue* _pStruct, const char* _pKey, RValue* _pValue) { return g_pYYRunnerInterface->StructAddRValue(_pStruct, _pKey, _pValue); }
inline void YYStructAddString(RValue* _pStruct, const char* _pKey, const char* _pValue) { return g_pYYRunnerInterface->StructAddString(_pStruct, _pKey, _pValue); }

inline bool WhitelistIsDirectoryIn(const char* _pszDirectory) { return g_pYYRunnerInterface->WhitelistIsDirectoryIn(_pszDirectory); }
inline bool WhiteListIsFilenameIn(const char* _pszFilename) { return g_pYYRunnerInterface->WhiteListIsFilenameIn(_pszFilename); }
inline void WhiteListAddTo(const char* _pszFilename, bool _bIsDir) { return g_pYYRunnerInterface->WhiteListAddTo(_pszFilename, _bIsDir); }
inline bool DirExists(const char* filename) { return g_pYYRunnerInterface->DirExists(filename); }

inline IBuffer* BufferGetFromGML(int ind) { return g_pYYRunnerInterface->BufferGetFromGML(ind); }
inline int BufferTELL(IBuffer* buff) { return g_pYYRunnerInterface->BufferTELL(buff); }
inline unsigned char* BufferGet(IBuffer* buff) { return g_pYYRunnerInterface->BufferGet(buff); }
inline const char* FilePrePend(void) { return g_pYYRunnerInterface->FilePrePend(); }

inline void YYStructAddInt32(RValue* _pStruct, const char* _pKey, int32 _value) { return g_pYYRunnerInterface->StructAddInt32(_pStruct, _pKey, _value); }
inline void YYStructAddInt64(RValue* _pStruct, const char* _pKey, int64 _value) { return g_pYYRunnerInterface->StructAddInt64(_pStruct, _pKey, _value); }
inline RValue* YYStructGetMember(RValue* _pStruct, const char* _pKey) { return g_pYYRunnerInterface->StructGetMember(_pStruct, _pKey); }
inline int YYStructGetKeys(RValue* _pStruct, const char** _keys, int* _count) { return g_pYYRunnerInterface->StructGetKeys(_pStruct, _keys, _count); }

inline void extOptGetRValue(RValue& result, const char* _ext, const char* _opt) { return g_pYYRunnerInterface->extOptGetRValue(result, _ext, _opt); };
inline const char* extOptGetString(const char* _ext, const char* _opt) { return g_pYYRunnerInterface->extOptGetString(_ext, _opt); }
inline double extOptGetReal(const char* _ext, const char* _opt) { return g_pYYRunnerInterface->extOptGetReal(_ext, _opt); };

inline bool isRunningFromIDE() { return g_pYYRunnerInterface->isRunningFromIDE(); };


#define g_LiveConnection	(*g_pYYRunnerInterface->pLiveConnection)
#define g_HTTP_ID			(*g_pYYRunnerInterface->pHTTP_ID)


#endif


/*
#define YY_HAS_FUNCTION(interface, interface_size, function) \
	(interface_size >= (offsetof(GameMaker_RunnerInterface, function) + sizeof(GameMaker_RunnerInterface::function)) && interface->function != NULL)

#define YY_REQUIRE_FUNCTION(interface, interface_size, function) \
	if(!GameMaker_HasFunction(interface, interface_size, function)) \
	{ \
		interface->DebugConsoleOutput("Required function missing: %s\n", #function); \
		interface->DebugConsoleOutput("This extension may not be compatible with this version of GameMaker\n"); \
		return false; \
	}
*/

#ifndef __Action_Class_H__
const int ARG_CONSTANT = -1;           // Argument kinds
const int ARG_EXPRESSION = 0;
const int ARG_STRING = 1;
const int ARG_STRINGEXP = 2;
const int ARG_BOOLEAN = 3;
const int ARG_MENU = 4;
const int ARG_SPRITE = 5;
const int ARG_SOUND = 6;
const int ARG_BACKGROUND = 7;
const int ARG_PATH = 8;
const int ARG_SCRIPT = 9;
const int ARG_OBJECT = 10;
const int ARG_ROOM = 11;
const int ARG_FONTR = 12;
const int ARG_COLOR = 13;
const int ARG_TIMELINE = 14;
const int ARG_FONT = 15;
#endif

#endif
