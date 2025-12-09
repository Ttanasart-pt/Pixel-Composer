#region creation 
	function array_create_2d(_x, _y, val = 0) {
		var _arr = array_create(_x);
		for( var i = 0; i < _x; i++ )
			_arr[i] = array_create(_y, val);
		return _arr;
	}
	
	function array_create_from_list(list) {
		if(list == undefined) return [];
		if(!ds_exists(list, ds_type_list)) return [];
		
		var arr = array_create(ds_list_size(list));
		for( var i = 0; i < ds_list_size(list); i++ )
			arr[i] = list[| i];
		return arr;
	}
	
	function array_clone(arr, _depth = -1) {
		INLINE
		
		if(_depth == 0)    return arr;
		if(!is_array(arr)) return arr;
		
		var _res = [];
		 for( var i = 0, n = array_length(arr); i < n; i++ )
			 _res[i] = array_clone(arr[i], _depth--);
			 
		 return _res;
	}
#endregion

#region check
	function array_empty(arr)   { INLINE return  is_array(arr) && array_length(arr) == 0; }
	function array_valid(arr)   { INLINE return  is_array(arr) && array_length(arr) > 0;  }
	function array_invalid(arr) { INLINE return !is_array(arr) || array_length(arr) == 0; }
	
	function array_verify_new(arr, length) {
		INLINE
		
		if(!is_array(arr)) return array_create(length);
		if(array_length(arr) == length) return arr;
		
		arr = array_clone(arr, 1);
		array_resize(arr, length);
		return arr;
	}
	
	function array_verify_min(arr, length) {
		INLINE
		
		if(!is_array(arr)) return array_create(length);
		if(array_length(arr) >= length) return arr;
		
		array_resize(arr, length);
		return arr;
	}
	
	function _array_verify(arr, length) { INLINE 
		if(!is_array(arr)) return array_create(length);
		if(array_length(arr) == length) return arr;
		
		array_resize(array_clone(arr), length);
		return arr;
	}
		
	function  array_verify(arr, length) { INLINE
		if(!is_array(arr)) return array_create(length);
		if(array_length(arr) == length) return arr;
		
		array_resize(arr, length);
		return arr;
	}
	
	function array_verify_ext(arr, length, generator) {
		INLINE
		
		if(!is_array(arr)) return array_create_ext(length, generator);
		
		var _len = array_length(arr);
		if(_len == length) return arr;
		
		array_resize(arr, length);
		var i = _len;
		
		repeat(length - _len) 
			arr[i++] = generator();
		
		return arr;
	}

#endregion

#region get set
	
	enum ARRAY_OVERFLOW {
		_default,
		loop,
		pingpong,
		clamp
	}
	
	#macro aGetF array_safe_get_fast
	function array_safe_get_fast(arr, index=0, def=0) {
		INLINE
		
		return is_array(arr) && index >= 0 && index < array_length(arr)? arr[index] : def;
	}
	
	function array_safe_get(arr, index, def = 0, overflow = ARRAY_OVERFLOW._default) {
		INLINE
		
		if(!is_array(arr))  return def;
		if(is_array(index)) return def;
		
		var len = array_length(arr);
		if(len == 0) return def;
		
		if(overflow == ARRAY_OVERFLOW.clamp) {
			index = clamp(index, 0, len - 1);
			
		} else if(overflow == ARRAY_OVERFLOW.loop) {
			if(index < 0)
				index = len - safe_mod(abs(index), len);
			index = index % len;
			
		} else if(overflow == ARRAY_OVERFLOW.pingpong) {
			if(index < 0) index = len - safe_mod(abs(index), len);
			
			var _plen = len * 2 - 1;
			index = index % _plen;
			
			if(index >= len)
				index = _plen - index;
		}
		
		if(index < 0 || index >= len) return def;
		return arr[index] == undefined? def : arr[index];
	}
	
	function array_get_decimal(arr, index, color = false) {
		INLINE
		
		if(!is_array(arr)) return 0;
		if(frac(index) == 0) return array_safe_get_fast(arr, index);
		
		var v0 = array_safe_get_fast(arr, floor(index));
		var v1 = array_safe_get_fast(arr, floor(index) + 1);
		
		return color? merge_color(v0, v1, frac(index)) : lerp(v0, v1, frac(index));
	}
	
	function array_safe_length(arr,def=0) {
		INLINE
		return is_array(arr)? array_length(arr) : def;
	}

	function array_get_dimension(arr) {
		INLINE
		
		return is_array(arr)? array_length(arr) : 1;
	}
	
	function array_shape(arr, first = true, isSurface = false) {
		if(!is_array(arr)) {
			if(isSurface && is_surface(arr)) 
				return (first? "" : " x ") + string(surface_get_width_safe(arr)) + " x " + string(surface_get_height_safe(arr)) + " px";
			return "";
		}
		
		var dim = string(array_length(arr));
		
		if(array_length(arr)) 
			dim += array_shape(arr[0], false, isSurface);
		
		return (first? "" : " x ") + dim;
	}
	
	function __array_get_depth(arr) { // Read all member, slower
		INLINE
		
		if(!is_array(arr)) return 0;
		var dep = 0;
		for (var i = 0, n = array_length(arr); i < n; i++)
			dep = max(dep, __array_get_depth(arr[i]));
		return 1 + dep;
	}
	
	function array_get_depth(arr) { // Read only the first member, faster
		INLINE
		
		if(!is_array(arr)) return 0;
		var d = 0;
		var p = arr;
		
		while(is_array(p) && !array_empty(p)) {
			d++;
			p = p[0];
		}
		
		return d;
	}

	function array_safe_set(arr, index, value, fill = 0) {
		if(!is_array(arr))  return arr;
		if(is_array(index)) return arr;
		
		if(index < 0) return arr;
		if(index >= array_length(arr)) {
			var i = array_length(arr);
			for(; i <= index; i++ )
				arr[i] = fill;
			arr[index] = value;
			return arr;
		}
		
		array_set(arr, index, value);
		return arr;
	}
	
	function array_fill(arr, startIndex, endIndex, value = 0) {
		INLINE
		
		for( var i = max(0, startIndex); i < endIndex; i++ ) 
			arr[i] = value;
	}
	
	function array_get_sub(arr, startIndex, amount) {
		var _sub = array_create(amount);
		for( var i = 0; i < amount; i++ ) _sub[i] = arr[startIndex + i];
		return _sub;
	}
	
	function array_sum(arr) { return array_reduce(arr, function(s, v) /*=>*/ {return s + v}, 0); }
	
	function array_search_min_bin(arr, value) {
	    var _len = array_length(arr);
	    if(_len <= 2) return 0;
	    
	    var low  = 0;
	    var high = _len - 1;
	
	    while (low <= high) {
	        var mid = floor((low + high) / 2);
	        var mid_v0 = arr[mid];
	        var mid_v1 = arr[mid + 1];
	
	        if(mid_v0 < value && mid_v1 >= value)
	            return mid;
	        
	        if (mid_v0 < value) 
	            low = mid + 1;
	        else
	            high = mid - 1;
	    }
	
	    return 0;
	}
	
	function array_2d_toString(arr) {
		var _txt = "";
		
		for( var i = 0, n = array_length(arr); i < n; i++ )
			_txt += $"{arr[i]},\n"
		
		return _txt;
	}
	
	function array_get_random(arr) {
		return array_length(arr) == 0? 0 : arr[irandom(array_length(arr) - 1)];
	}
#endregion

#region find
	
	function array_exists(arr, val) {
		INLINE
		self.__temp_val = val;
		
		if(!is_array(arr)) return false;
		var _a = array_any(arr, function(_val, _ind) { return isEqual(_val, self.__temp_val); });
		
		self.__temp_val = 0;
		return _a;
	}

	function array_find(arr, val) {
		INLINE
		self.__temp_val = val;
		
		if(!is_array(arr)) return -1;
		var _a = array_find_index(arr, function(_val, _ind) { return isEqual(_val, self.__temp_val); });
		
		self.__temp_val = 0;
		return _a;
	}
	
	function array_find_string(arr, val) {
		INLINE
		self.__temp_val = string_lower(val);
		
		if(!is_array(arr)) return -1;
		var _a = array_find_index(arr, function(_val, _ind) { return string_lower(_val) == self.__temp_val; });
		
		self.__temp_val = 0;
		return _a;
	}

	function array_min(arr) {
		INLINE
		if(!is_array(arr))         return arr;
		if(array_length(arr) == 0) return 0;
		
		var mn = arr[0];
		for( var i = 0, n = array_length(arr); i < n; i++ )
			mn = min(mn, arr[i]);
		return mn;
	}
	
	function array_max(arr) {
		INLINE
		if(!is_array(arr))         return arr;
		if(array_length(arr) == 0) return 0;
		
		var mx = arr[0];
		for( var i = 0, n = array_length(arr); i < n; i++ )
			mx = max(mx, arr[i]);
		return mx;
	}

#endregion

#region modify
			
	function array_append(arr, arr0) {
		INLINE
		
		if(is_undefined(arr0)) return arr;
		if(!is_array(arr))     return arr;
		if(!is_array(arr0))  { array_push(arr, arr0); return arr; }
		
		array_copy(arr, array_length(arr), arr0, 0, array_length(arr0));
		return arr;
	}
	
	function array_append_unique(arr, arr0) {
		INLINE
		
		if(is_undefined(arr0)) return arr;
		if(!is_array(arr))     return arr;
		if(!is_array(arr0))  { array_push(arr, arr0); return arr; }
		
		for( var i = 0, n = array_length(arr0); i < n; i++ )
			array_push_unique(arr, arr0[i]);
		return arr;
	}

	function array_merge() {
		INLINE
		
		var arr = [];
		for( var i = 0; i < argument_count; i++ )
			array_append(arr, argument[i]);
		
		return arr;
	}
	
	function array_merge_array(arrs) {
		INLINE
		
		var arr = [];
		for( var i = 0, n = array_length(arrs); i < n; i++ )
			array_append(arr, arrs[i]);
		
		return arr;
	}

	function array_resize_fill(arr, size, fill = 0) {
		if(size < array_length(arr)) {
			array_resize(arr, size);
			return arr;
		}
		
		var i = array_length(arr);
		for(; i < size; i++)
			arr[i] = fill;
		return arr;
	}
	
	function array_push_create(arr, val) {
		INLINE
		
		if(!is_array(arr)) return [ val ];
		array_push(arr, val);
		return arr;
	}
		
	function array_remove(arr, val) {
		INLINE
		
		if(!is_array(arr)) return;
		if(!array_exists(arr, val)) return;
		var ind = array_find(arr, val);
		array_delete(arr, ind, 1);
	}
	
	function array_push_unique(arr, val) {
		INLINE
		
		if(!is_array(arr)) return;
		if(array_exists(arr, val)) return;
		array_push(arr, val);
	}
	
	function array_insert_unique(arr, ind, val) {
		INLINE
		
		if(!is_array(arr)) return;
		if(array_exists(arr, val)) return;
		array_insert(arr, ind, val);
	}

	function array_insert_array(arr, _ind, values) {
		INLINE
		
		for( var i = 0, n = array_length(values); i < n; i++ )
			array_insert(arr, _ind + i, values[i]);
	}
		
	function array_insert_after(arr, before, values) {
		INLINE
		
		var _ind = array_find(arr, before) + 1;
		
		for( var i = 0, n = array_length(values); i < n; i++ )
			array_insert(arr, _ind + i, values[i]);
	}
		
	function array_insert_before(arr, before, values) {
		INLINE
		
		var _ind = array_find(arr, before);
		
		for( var i = 0, n = array_length(values); i < n; i++ )
			array_insert(arr, _ind + i, values[i]);
	}
	
	function array_push_to_back(arr, value) {
		if(!array_exists(arr, value)) return;
		
		array_remove(arr, value);
		array_push(arr, value);
	}

	function array_push_to_back_index(arr, index) {
		var _val = arr[index];
		array_delete(arr, index, 1);
		array_push(arr, _val);
	}

	function array_spread(arr, _arr = [], _minDepth = 0) {
		if(array_get_depth(arr) == _minDepth) { array_push(_arr, arr); return _arr; }
		
		for( var i = 0, n = array_length(arr); i < n; i++ ) 
			array_spread(arr[i], _arr, _minDepth);
		return _arr;
	}
	
	function array_toggle(arr, value) {
		if(array_exists(arr, value)) array_remove(arr, value);
		else                         array_push(arr, value);
	}

	function array_copy_trim_start(arr, _amo) {
		var len = array_length(arr);
		if(_amo >= len) return [];

		var _arr = array_create(len - _amo);
		array_copy(_arr, 0, arr, _amo, len - _amo);
		return _arr;
	}
	
	function array_copy_trim_end(arr, _amo) {
		var len = array_length(arr);
		if(_amo >= len) return [];

		var _arr = array_create(len - _amo);
		array_copy(_arr, 0, arr, 0, len - _amo);
		return _arr;
	}
#endregion

#region binary opr

	function array_overlap(arr0, arr1) {
		INLINE
		self.__temp_arr = arr1;
		
		if(!is_array(arr0) || !is_array(arr1)) return false;
		
		var _a = array_any(arr0, function(_val, _ind) { return array_exists(self.__temp_arr, _val); });
		
		self.__temp_arr = 0;
		return _a;
	}

	#macro array_equals array_equals_overwrite
	#macro __array_equals array_equals
	
	function array_equals_overwrite(arr1, arr2) { 
		if(!is_array(arr1) &&  is_array(arr2)) return false;
		if( is_array(arr1) && !is_array(arr2)) return false;
		if(!is_array(arr1) && !is_array(arr2)) return arr1 == arr2;
		return __array_equals(arr1, arr2)
	}
	
	function array_equals_ext(arr1, arr2, offset = 0) { 
		if(!is_array(arr1) &&  is_array(arr2)) return false;
		if( is_array(arr1) && !is_array(arr2)) return false;
		if(!is_array(arr1) && !is_array(arr2)) return arr1 == arr2;
		
		var _l1 = array_length(arr1);
		var _l2 = array_length(arr2);
		if(_l1 != _l2) return false;
		
		for( var i = offset; i < _l1; i++ )
			if(arr1[i] != arr2[i]) return false;
		
		return true;
	}
	
	function array_substract(arr1, arr2) {
		if(!is_array(arr1) || !is_array(arr2)) return [];
		
		var _hsh = {};
		var _arr = [];
		
		for( var i = 0, n = array_length(arr2); i < n; i++ )
			_hsh[$ arr2[i]] = (_hsh[$ arr2[i]] ?? 0) + 1;
		
		for( var i = 0, n = array_length(arr1); i < n; i++ ) {
			if(!struct_has(_hsh, arr1[i]) || _hsh[$ arr1[i]]-- <= 0)
				array_push(_arr, arr1[i]);
		}
		
		return _arr;
	}
	
	function array_xor(arr1, arr2) {
		if(!is_array(arr1) || !is_array(arr2)) return;
		
		var _arr = array_union(array_substract(arr1, arr2), array_substract(arr2, arr1));
		return _arr;
	}
#endregion
