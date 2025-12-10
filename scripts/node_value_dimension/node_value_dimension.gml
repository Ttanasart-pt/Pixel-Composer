function nodeValue_Dimension(name = "Dimension") { return new __NodeValue_Dimension(self, [1,1], name); }
function __NodeValue_Dimension(_node, value, _name = "Dimension") : __NodeValue_Vec2("Dimension", _node, value, { linked: true }) constructor {
	def_length = 2;
	
	attributes.use_project_dimension = true;
	
	editProjDim = button(function() /*=>*/ {
		var sw = attributes.use_project_dimension? DEF_SURF_W : 1 / DEF_SURF_W;
		var sh = attributes.use_project_dimension? DEF_SURF_H : 1 / DEF_SURF_H;
		
		for( var i = 0, n = array_length(animator.values); i < n; i++ ) {
			var v = animator.values[i];
			v.value[0] *= sw;
			v.value[1] *= sh;
		}
		
		for( var i = 0, n = array_length(animators[0].values); i < n; i++ )
			animators[0].values[i].value *= sw;
		
		for( var i = 0, n = array_length(animators[1].values); i < n; i++ )
			animators[1].values[i].value *= sh;
		
		attributes.use_project_dimension = !attributes.use_project_dimension;
		node.triggerRender();
		
	}).setIcon(THEME.node_use_project, 0, COLORS._main_icon).iconPad().setTooltip("Use project dimension");
	
	editWidget.setSideButton(editProjDim);
	
	/////============== GET =============
	
	static getValue = function(_time = NODE_CURRENT_FRAME, applyUnit = true, arrIndex = 0, useCache = false, log = false) { 
		if(__tempValue != undefined) return __tempValue;
		
		var _pdim = attributes.use_project_dimension;
		editProjDim.icon_index = _pdim;
		editProjDim.icon_blend = _pdim? c_white : COLORS._main_icon;
		
		getValueRecursive(self.__curr_get_val, _time);
		var val = __curr_get_val[0];
		var nod = __curr_get_val[1]; if(!is(nod, NodeValue)) return val;
		
		if(applyUnit && attributes.use_project_dimension && nod == self) {
			val[0] *= DEF_SURF_W;
			val[1] *= DEF_SURF_H;
			return val;
		}
		
		var typ = nod.type;
		
		if(typ == VALUE_TYPE.pbBox) {
			if (is(val, __pbBox))  {
				var _bbox = val.getBBOX();
				return [ _bbox[2] - _bbox[0], _bbox[3] - _bbox[1] ];
			}
			
			return [ 1, 1 ];
		}
		
		if(typ != VALUE_TYPE.surface) {
			var _d = array_get_depth(val);
			
			__nod       = nod;
			__applyUnit = applyUnit;
			__arrIndex  = arrIndex;
			
			if(_d == 0) return [ val, val ];
			if(_d == 1) return array_verify(val, 2);
			if(_d == 2) return array_map(val, function(v, i) /*=>*/ {return array_verify(v, 2)});
			
			return val;
		}
		
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
	
	static __getAnimValue = function(_time = NODE_CURRENT_FRAME) {
		if(!getAnim()) {
			if(sep_axis) return array_create_ext(2, function(i) /*=>*/ {return animators[i].processType(animators[i].values[0].value)});
			return array_empty(animator.values)? 0 : animator.processType(animator.values[0].value);
		}
		
		if(sep_axis) {
			__temp_time = _time;
			return array_create_ext(2, function(i) /*=>*/ {return animators[i].getValue(__temp_time)});
		} 
		
		return animator.getValue(_time);
	}
	
	static postApplyDeserialize = function() {
		if(LOADING_VERSION < 1_20_01_3 && attributes.use_project_dimension && is_modified) {
			for( var i = 0, n = array_length(animator.values); i < n; i++ ) {
				var v = animator.values[i];
				v.value[0] /= DEF_SURF_W;
				v.value[1] /= DEF_SURF_H;
			}
			
			for( var i = 0, n = array_length(animators[0].values); i < n; i++ ) {
				var v = animators[0].values[i];
				v.value /= DEF_SURF_W;
			}
			
			for( var i = 0, n = array_length(animators[1].values); i < n; i++ ) {
				var v = animators[1].values[i];
				v.value /= DEF_SURF_H;
			}
		}
	}
	
}