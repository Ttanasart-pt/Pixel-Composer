function nodeValue_Dimension(name = "Dimension") { 
	var _unit = PREFERENCES.node_def_dim_unit;
	var _val  = _unit? [1,1] : NPROJ_SURF;
	
	return new __NodeValue_Dimension(self, _val, name); 
}

function __NodeValue_Dimension(_node, value, _name = "Dimension") : __NodeValue_Vec2("Dimension", _node, value, { linked: true }) constructor {
	def_length = 2;
	
	use_mask    = false;
	mask_input  = undefined;
	unitTooltip = new tooltipSelector("Unit", ["Pixel", "Global"]);
	node.dimension_input = index;
	attributes.use_project_dimension = PREFERENCES.node_def_dim_unit;
	
	editProjDim = undefined;
	static onInitWidget = function() { 
		editProjDim = button(function() /*=>*/ {
			var ot = attributes.use_project_dimension;
			var nt = (ot + 1) % (2 + use_mask);
			attributes.use_project_dimension = nt;
			
			var sw;
			var sh;
			
			if(!use_mask) {
				sw = ot? NPROJ_SURF_W : 1 / NPROJ_SURF_W;
				sh = ot? NPROJ_SURF_H : 1 / NPROJ_SURF_H;
				
			} else {
				var _msk = mask_input.getValue();
				var mx = surface_get_width_safe(_msk);
				var my = surface_get_height_safe(_msk);
				
				switch(ot) {
					case 0 : sw = 1 / NPROJ_SURF_W;   sh = 1 / NPROJ_SURF_H;  break;
					case 1 : sw = NPROJ_SURF_W / mx;  sh = NPROJ_SURF_H / my; break;
					case 2 : sw = mx;               sh = my;              break;
				}
			}
			
			for( var i = 0, n = array_length(animator.values); i < n; i++ ) {
				var v = animator.values[i];
				v.value[0] *= sw;
				v.value[1] *= sh;
			}
			
			if(sep_axis) {
				var _anims = getAnimators();
				for( var i = 0, n = array_length(_anims[0].values); i < n; i++ )
					_anims[0].values[i].value *= sw;
				
				for( var i = 0, n = array_length(_anims[1].values); i < n; i++ )
					_anims[1].values[i].value *= sh;
			}
			
			node.triggerRender();
			
		}).setIcon(THEME.node_use_project, attributes.use_project_dimension, COLORS._main_icon).iconPad().setTooltip(unitTooltip);
		editWidget.setSideButton(editProjDim); 
		editWidget.setSuffix(attributes.use_project_dimension? "x" : "");
	}
	
	/////============== GET =============
	
	static getValue = function(_time = NODE_CURRENT_FRAME, applyUnit = true, arrIndex = 0, useCache = false, log = false) { 
		if(__tempValue != undefined) return __tempValue;
		
		unitTooltip.index = attributes.use_project_dimension;
		if(editProjDim) editProjDim.icon_index = attributes.use_project_dimension;
		if(editWidget)  editWidget.setSuffix(attributes.use_project_dimension? "x" : "");
		
		getValueRecursive(self.__curr_get_val, _time);
		var val = __curr_get_val[0];
		var nod = __curr_get_val[1]; if(!is(nod, NodeValue)) return val;
		
		if(applyUnit && nod == self) {
			switch(attributes.use_project_dimension) {
				case 1 : 
					val[0] *= NPROJ_SURF_W;
					val[1] *= NPROJ_SURF_H;
					return val;
				
				case 2 : 
					var _msk = mask_input.getValue(_time);
					val[0] *= surface_get_width_safe(_msk);
					val[1] *= surface_get_height_safe(_msk);
					return val;
			}
			
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
		if(sep_axis) getAnimators();
		
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
				v.value[0] /= NPROJ_SURF_W;
				v.value[1] /= NPROJ_SURF_H;
			}
			
			if(sep_axis) {
				var _anims = getAnimators();
			
				for( var i = 0, n = array_length(_anims[0].values); i < n; i++ ) {
					var v = _anims[0].values[i];
					v.value /= NPROJ_SURF_W;
				}
				
				for( var i = 0, n = array_length(_anims[1].values); i < n; i++ ) {
					var v = _anims[1].values[i];
					v.value /= NPROJ_SURF_H;
				}
			}
		}
	}
	
}