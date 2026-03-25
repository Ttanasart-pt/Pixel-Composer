function Node_Global(_x = 0, _y = 0) : __Node_Base(_x, _y) constructor {
	name          = "GLOBAL";
	display_name  = "";
	
	node_id       = 0;
	group         = noone;
	use_cache     = CACHE_USE.none;
	value         = ds_map_create();
	overrideValue = ds_map_create();
	
	input_display_list = -1;
	anim_priority      = -999;
	
	static isActiveDynamic = function(frame = CURRENT_FRAME) /*=>*/ {return true}
	static valueUpdate     = function(index) /*=>*/ { RENDER_ALL }
	
	////- Inputs
	
	function createValue() {
		var _ind   = array_length(inputs);
		while(inputExist($"NewValue{_ind}")) _ind++;
		
		var _key = $"NewValue{_ind}";
		var _inp = nodeValue_Global(_key);
		array_push(inputs, _inp);
		valueUpdate();
		
		return _inp;
	}
	
	static valueRename = function(_val, _name) {
		if(!string_variable_valid(s)) { 
			noti_warning("Invalid globalvar name."); 
			return false; 
		}
			
		if(getInputKey(s) != noone) { noti_warning("Duplicate globalvar name."); return false; }
		
		_val.name = _name;
		RENDER_ALL
		return true;
	}
	
	static inputExist = function(key) { return ds_map_exists(value, key); }
	
	////- Get Data
	
	static inputGetable = function(from, key) {
		if(!inputExist(key)) return false;
		var to = value[? key];
		
		if(!typeCompatible(from.type, to.type)) return false;
		if(typeIncompatible(from, to))          return false;
		
		return true;
	}
	
	static getInputKey  = function(key, def = noone) { return ds_map_exists(value, key)? value[? key] : def; }
	static getInputData = function(key, frame) { 
		if(ds_map_exists(overrideValue, key))
			return overrideValue[? key];
		
		var inp = getInputKey(key) 
		return inp? inp.__getAnimValue(frame) : 0;
	}
	
	////- Update
	
	static update = function() {
		ds_map_clear(value);
		
		for( var i = 0, n = array_length(inputs); i < n; i++ ) {
			var _inp = inputs[i];
			if(!is(_inp, NodeValue)) continue;
			
			value[? _inp.name] = _inp;
			
			var val = true;
			if(string_pos(" ", _inp.name)) val = false;
			_inp.editor.tb_name.boxColor = val? c_white : COLORS._main_value_negative;
		}
	}
	
	////- Serialize
	
	static serialize = function() {
		var _map = {};
		
		var _inputs = [];
		for( var i = 0, n = array_length(inputs); i < n; i++ ) {
			var _inp = inputs[i];
			if(!is(_inp, NodeValue)) continue;
			
			var _ser = _inp.serialize();
			_ser.global_name    = _inp.name;
			_ser.global_type    = _inp.editor.type_index;
			_ser.global_disp    = _inp.editor.disp_index;
			_ser.global_s_range = _inp.editor.slider_range;
			_ser.global_s_step  = _inp.editor.slider_step;
			
			array_push(_inputs, _ser);
		}
		
		_map.inputs = _inputs;
		_map.attri  = attributes;
		
		return _map;
	}
	
	static deserialize = function(_map) {
		var _inputs = _map.inputs;
		
		for( var i = 0, n = array_length(_inputs); i < n; i++ ) {
			var _des  = _inputs[i];
			if(!is_struct(_des)) continue;
			
			var _in = createValue();
			
			_in.editor.type_index = struct_try_get(_des, "global_type", 0);
			_in.editor.disp_index = struct_try_get(_des, "global_disp", 0);
			
			_in.editor.slider_range = _des.global_s_range;
			_in.editor.slider_step  = struct_try_get(_des, "global_s_step",  0.01);
			
			_in.editor.refreshInput();
			
			_in.applyDeserialize(_des);
		}
		
		if(struct_has(_map, "attr")) struct_override(attributes, _map.attr); 
		
		step();
	}
}