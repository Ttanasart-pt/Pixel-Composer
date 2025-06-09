function nodeValue_Vec2( _name, _value, _data = {}) { return new __NodeValue_Vec2( _name, self, _value, _data); }
function nodeValue_IVec2(_name, _value, _data = {}) { return new __NodeValue_IVec2(_name, self, _value, _data); }

function __NodeValue_Vec2(_name, _node, _value, _data = {}) : NodeValue(_name, _node, CONNECT_TYPE.input, VALUE_TYPE.float, _value, "") constructor {
	setDisplay(VALUE_DISPLAY.vector, _data);
	def_length = 2;
	
	////- GET
	
	static valueProcess = function(value, nodeFrom = undefined, applyUnit = true, arrIndex = 0) {
		var typeFrom = nodeFrom == undefined? VALUE_TYPE.any : nodeFrom.type;
		
		if(typeFrom == VALUE_TYPE.text) value = toNumber(value);
		if(validator != noone)          value = validator.validate(value);
		
		return applyUnit? unit.apply(value, arrIndex) : value;
	}
	
	static getValue = function(_time = CURRENT_FRAME, applyUnit = true, arrIndex = 0, useCache = false, log = false) { //// Get value
		getValueRecursive(self.__curr_get_val, _time);
		var val = __curr_get_val[0];
		var nod = __curr_get_val[1]; if(!is(nod, NodeValue)) return val;
		var typ = nod.type;
		
		if(typ != VALUE_TYPE.surface) {
			if(array_empty(val)) return val;
			var _d = array_get_depth(val);
			
			__nod       = nod;
			__applyUnit = applyUnit;
			__arrIndex  = arrIndex;
			
			if(_d == 0) return valueProcess([ val, val ], nod, applyUnit, arrIndex);
			if(_d == 1) return valueProcess(val, nod, applyUnit, arrIndex);
			if(_d == 2) return array_map(val, function(v, i) /*=>*/ {return valueProcess(array_verify(v, 2), __nod, __applyUnit, __arrIndex)});
			
			return val;
		}
		
		// Dimension conversion
		if(is_array(val)) {
			var eqSize = true;
			var sArr = [];
			var _osZ = 0;
			
			for( var i = 0, n = array_length(val); i < n; i++ ) {
				if(!is_surface(val[i])) continue;
				
				var surfSz = surface_get_dimension(val[i]);
				array_push(sArr, surfSz);
				
				if(i && !array_equals(surfSz, _osZ))
					eqSize = false;
				
				_osZ = surfSz;
			}
			
			if(eqSize) return _osZ;
			return sArr;
			
		} else if (is_surface(val)) 
			return surface_get_dimension(val);
			
		return [ 1, 1 ];
	}
	
	static __getAnimValue = function(_time = CURRENT_FRAME) {
		var _anim  = animator;
		var _anims = animators;
		
		if(!is_anim) {
			if(sep_axis) return array_create_ext(2, function(i) /*=>*/ {return _anims[i].processType(_anims[i].values[0].value)});
			return array_empty(_anim.values)? 0 : _anim.processType(_anim.values[0].value);
		}
		
		if(sep_axis) {
			__temp_time = _time;
			return array_create_ext(2, function(i) /*=>*/ {return _anims[i].getValue(__temp_time)});
		} 
		
		return _anim.getValue(_time);
	}

	////- DRAW
	
	static drawOverlay = function(hover, active, _x, _y, _s, _mx, _my, _snx, _sny, _typ = 0, _sca = [ 1, 1 ]) {
		if(expUse || value_from != noone) return -1;
		
		if(is_anim) {
			var ox, oy, nx, ny;
			draw_set_color(COLORS._main_accent);
			
			if(sep_axis) {
				// TODO	
				
			} else {
				for( var i = 0, n = array_length(animator.values); i < n; i++ ) {
					var _v = animator.values[i].value;
					    _v = unit.apply(_v, node.preview_index);
					
					nx = _x + _v[0] * _s;
					ny = _y + _v[1] * _s;
					
					draw_circle_prec(nx, ny, 4, false);
					if(i) {
						draw_set_alpha(.5);
						draw_line_dashed(ox, oy, nx, ny);
						draw_set_alpha(1);
					}
					
					ox = nx;
					oy = ny;
				}
			}
		}
		
		if(!is_array(_sca)) _sca = [ _sca, _sca ];
		
		return preview_overlay_vector(hover, active, _x, _y, _s, _mx, _my, _snx, _sny, _typ, _sca);
	}
	
}

function __NodeValue_IVec2(_name, _node, _value, _data = {}) : NodeValue(_name, _node, CONNECT_TYPE.input, VALUE_TYPE.integer, _value, "") constructor {
	setDisplay(VALUE_DISPLAY.vector, _data);
	def_length = 2;
}