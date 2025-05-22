enum AREA_SHAPE {
	rectangle,
	elipse
}

enum AREA_MODE {
	area,
	padding,
	two_point,
}

enum AREA_INDEX {
	center_x,
	center_y,
	half_w,
	half_h,
	shape
}

#macro DEF_AREA [ DEF_SURF_W / 2, DEF_SURF_H / 2, DEF_SURF_W / 2, DEF_SURF_H / 2, AREA_SHAPE.rectangle, AREA_MODE.area ]
#macro DEF_AREA_REF [ 0.5, 0.5, 0.5, 0.5, AREA_SHAPE.rectangle, AREA_MODE.area ]
#macro AREA_ARRAY_LENGTH 6

function nodeValue_Area(_name, _value = DEF_AREA, _data = {}) { return new __NodeValue_Area(_name, self, _value, _data); }

function __NodeValue_Area(_name, _node, _value, _data = {}) : NodeValue(_name, _node, CONNECT_TYPE.input, VALUE_TYPE.float, _value, "") constructor {
	
	setDisplay(VALUE_DISPLAY.area, _data);
	def_length = AREA_ARRAY_LENGTH;
	
	/////============== GET =============
	
	static valueProcess = function(val, nodeFrom, applyUnit = true, arrIndex = 0) {
		val = array_verify(val, AREA_ARRAY_LENGTH);
		
		if(!is_undefined(nodeFrom) && struct_has(nodeFrom.display_data, "onSurfaceSize")) {
			var surf     = nodeFrom.display_data.onSurfaceSize();
			var dispType = array_safe_get_fast(val, 5, AREA_MODE.area);
			
			switch(dispType) {
				case AREA_MODE.area : 
					break;
				
				case AREA_MODE.padding : 
					var ww = unit.mode == VALUE_UNIT.reference? 1 : surf[0];
					var hh = unit.mode == VALUE_UNIT.reference? 1 : surf[1];
					
					var cx = (ww - val[0] + val[2]) / 2
					var cy = (val[1] + hh - val[3]) / 2;
					var sw = abs((ww - val[0]) - val[2]) / 2;
					var sh = abs(val[1] - (hh - val[3])) / 2;
					
					val = [cx, cy, sw, sh, val[4], val[5]];
					break;
				
				case AREA_MODE.two_point : 
					var cx = (val[0] + val[2]) / 2
					var cy = (val[1] + val[3]) / 2;
					var sw = abs(val[0] - val[2]) / 2;
					var sh = abs(val[1] - val[3]) / 2;
				
					val = [cx, cy, sw, sh, val[4], val[5]];
					break;
			}
		}
		
		return applyUnit? unit.apply(val, arrIndex) : val;
	}
	
	static getValue = function(_time = CURRENT_FRAME, applyUnit = true, arrIndex = 0, useCache = false, log = false) { //// Get value
		getValueRecursive(self.__curr_get_val, _time);
		var val = __curr_get_val[0];
		var nod = __curr_get_val[1]; if(!is(nod, NodeValue)) return val;
		
		return valueProcess(val, nod, applyUnit, arrIndex);
	}
	
	static __getAnimValue = function(_time = CURRENT_FRAME) {
		
		if(!is_anim) {
			if(sep_axis) return array_create_ext(AREA_ARRAY_LENGTH, function(i) /*=>*/ {return animators[i].processType(animators[i].values[0].value)});
			return array_empty(animator.values)? 0 : animator.processType(animator.values[0].value);
		}
		
		if(sep_axis) {
			__temp_time = _time;
			return array_create_ext(AREA_ARRAY_LENGTH, function(i) /*=>*/ {return animators[i].getValue(__temp_time)});
		} 
		
		return animator.getValue(_time);
	}
}