//
// Copyright (C) 2020 Opera Norway AS. All rights reserved.
//
// This file is an original work developed by Opera.
//

#ifndef __YYRVALUE_H__
#define  __YYRVALUE_H__

typedef signed int  int32;
typedef long long int64;

class YYObjectBase;
class IBuffer;

#include "Extension_Interface.h"
#include "Ref.h"

#if !defined(__defined_RValue_consts__)
#define __defined_RValue_consts__
const int VALUE_REAL = 0;		// Real value
const int VALUE_STRING = 1;		// String value
const int VALUE_ARRAY = 2;		// Array value
const int VALUE_OBJECT = 6;		// YYObjectBase* value 
const int VALUE_INT32 = 7;		// Int32 value
const int VALUE_UNDEFINED = 5;	// Undefined value
const int VALUE_PTR = 3;		// Ptr value
const int VALUE_VEC3 = 4;		// Deprecated : unused : Vec3 (x,y,z) value (within the RValue)
const int VALUE_VEC4 = 8;		// Deprecated : unused :Vec4 (x,y,z,w) value (allocated from pool)
const int VALUE_VEC44 = 9;		// Deprecated : unused :Vec44 (matrix) value (allocated from pool)
const int VALUE_INT64 = 10;		// Int64 value
const int VALUE_ACCESSOR = 11;	// Actually an accessor
const int VALUE_NULL = 12;		// JS Null
const int VALUE_BOOL = 13;		// Bool value
const int VALUE_ITERATOR = 14;	// JS For-in Iterator
const int VALUE_REF = 15;		// Reference value (uses the ptr to point at a RefBase structure)
#define MASK_KIND_RVALUE	0x0ffffff
const int VALUE_UNSET = MASK_KIND_RVALUE;

struct RValue;
struct DynamicArrayOfRValue
{
	int length;
	RValue* arr;
};

class RefDynamicArrayOfRValue;

#define ARRAY_FLAG_IMMUTABLE		0x00000001				// true if the array is immutable and cannot be written to (NOTE: copies can be taken but the array cannot be written to, only read from)

struct vec3
{
	float	x, y, z;
};

struct vec4
{
	float	x, y, z, w;
};

struct matrix44
{
	vec4	m[4];
};

const int ERV_None = 0;
const int ERV_Enumerable = (1 << 0);
const int ERV_Configurable = (1 << 1);
const int ERV_Writable = (1 << 2);
const int ERV_Owned = (1 << 3);

#define JS_BUILTIN_PROPERTY_DEFAULT				(ERV_Writable | ERV_Configurable )
#define JS_BUILTIN_LENGTH_PROPERTY_DEFAULT		(ERV_None)


#pragma pack( push, 4)
struct RValue
{
	union {
		int32 v32;
		int64 v64;
		double	val;						// value when real
		union {
			union {
				RefString* pRefString;
				//char*	str;						// value when string
				RefDynamicArrayOfRValue* pRefArray;	// pointer to the array
				vec4* pVec4;
				matrix44* pMatrix44;
				void* ptr;
				YYObjectBase* pObj;
			};
		};
	};
	unsigned int		flags;							// use for flags (Hijack for Enumerable and Configurable bits in JavaScript)  (Note: probably will need a visibility as well, to support private variables that are promoted to object scope, but should not be seen (is that just not enumerated????) )
	unsigned int		kind;							// kind of value

#if defined(__YYGML_H__)
	void Serialise(IBuffer* _buffer);					// TODO :: these are not available in Extensions
	void DeSerialise(IBuffer* _buffer);
#endif

	const char* GetString() const { return (((kind & MASK_KIND_RVALUE) == VALUE_STRING) && (pRefString != NULL)) ? pRefString->get() : ""; }
//	long long asInt64() const { return INT64_RValue(this); }
//	double asReal() const { return REAL_RValue(this); }
//	bool asBool() const { return BOOL_RValue(this); }
	CInstance* asObject() const { return (((kind & MASK_KIND_RVALUE) == VALUE_OBJECT)) ? (CInstance*)pObj : NULL; }
};


// new structure used to initialise constant numbers at global scope (to eliminate construction overhead).
struct DValue
{
	double	val;
	int		dummy;
	int		kind;
};

struct DLValue
{
	int64	val;
	int		dummy;
	int		kind;
};

#pragma pack(pop)
#endif


#endif
