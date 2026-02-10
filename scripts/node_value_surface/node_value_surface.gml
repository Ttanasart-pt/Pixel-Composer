#region global
	global.SURFACE_MASK_JUNC = {
		icon:  function() /*=>*/ {return THEME.node_junction_surface_ext},
		color: function() /*=>*/ {return #ff6b97},
	}
	
	global.SURFACE_UV_JUNC = {
		icon:  function() /*=>*/ {return THEME.node_junction_surface_ext},
		color: function() /*=>*/ {return #ff6b97},
	}
	
	global.SURFACE_MAP_JUNC = {
		icon:  function() /*=>*/ {return THEME.node_junction_surface_map},
		color: function() /*=>*/ {return #ff6b97},
	}
	
	global.SURFACE_GREY_JUNC = {
		icon:  function() /*=>*/ {return THEME.node_junction_surface_ext},
		color: function() /*=>*/ {return #ff6b97},
	}
#endregion

function nodeValue_Surface(_name, _value = noone, _tooltip = "") { return new __NodeValue_Surface(_name, self, _value, _tooltip); }
function __NodeValue_Surface(_name, _node, _value = noone, _tooltip = "") : NodeValue(_name, _node, CONNECT_TYPE.input, VALUE_TYPE.surface, _value, _tooltip) constructor {
	animable = false;
	if(_name == "Mask") {
		setCustomData(global.SURFACE_MASK_JUNC);
		
		var _dimTarget = array_safe_get(node.inputs, node.dimension_input);
		if(is(_dimTarget, __NodeValue_Dimension)) {
			_dimTarget.use_mask   = true;
			_dimTarget.mask_input = self;
			array_push(_dimTarget.unitTooltip.data, "Mask");
		}
	}
	
	if(_name == "UV Map") 
		setCustomData(global.SURFACE_UV_JUNC);
	
	/////============== VALUE =============
	
	static setBW = function() { 
		// draw_junction_index = VALUE_TYPE.rigid;
		// custom_color = #ff6b97;
		return self; 
	}
	
	/////============== GET =============
	
	static getValue = function(_time = NODE_CURRENT_FRAME, applyUnit = true, arrIndex = 0, useCache = false, log = false) { 
		if(__tempValue != undefined) return __tempValue;
		
		getValueRecursive(self.__curr_get_val, _time);
		var val = __curr_get_val[0];
		var nod = __curr_get_val[1]; if(!is(nod, NodeValue)) return val;
		
		if(is(val, dynaDraw)) val.node = node;
		
		if(is(val, dynaDraw_canvas)) return val.surfaces[0];
		return val;
	}
	
	static __getAnimValue = function(_time = NODE_CURRENT_FRAME) { 
		var _anim  = animator;
		if(array_empty(_anim.values)) return noone;
		
		var _val = _anim.values[0].value;
		if(is_string(_val)) return get_asset(_val);
		
		return _val; 
	}
	
	static arrayLength = arrayLengthSimple;
}