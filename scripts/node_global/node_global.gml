function variable_editor(nodeVal) constructor {
	value = nodeVal;
	
	val_type      = [ VALUE_TYPE.integer, VALUE_TYPE.float, VALUE_TYPE.boolean, VALUE_TYPE.color, VALUE_TYPE.gradient, VALUE_TYPE.path, VALUE_TYPE.curve, VALUE_TYPE.text ];
	val_type_name = [ "Integer", "Float", "Boolean", "Color", "Gradient", "Path", "Curve", "Text" ];
	display_list  = [
		/*Integer*/	[ "Default", "Range", "Rotation", "Rotation range", "Slider", "Slider range", "Padding", "Vector2", "Vector3", "Vector4", "Vector range", "Vector2 range", "Area" ],
		/*Float*/	[ "Default", "Range", "Rotation", "Rotation range", "Slider", "Slider range", "Padding", "Vector2", "Vector3", "Vector4", "Vector range", "Vector2 range", "Area" ],
		/*Boolean*/	[ "Default" ],
		/*Color*/	[ "Default", "Palette" ],
		/*Gradient*/[ "Default" ],
		/*Path*/	[ "Read", "Write", "Font" ],
		/*Curve*/	[ "Default", ],
		/*Text*/	[ "Default", ],
	]
	
	tb_name = new textBox(TEXTBOX_INPUT.text, function(s) /*=>*/ { 
		if(string_pos(" ", s)) { noti_warning("Global variable name can't have space."); return; }
		
		var _node = value.node;
		for( var i = 0, n = array_length(_node.inputs); i < n; i++ ) {
			var _in = _node.inputs[i];
			if(_in == value) continue;
			
			if(_in.name == s) {
				noti_warning("Duplicate variable name."); 
				return;
			}
		}
		
		value.name = s;
		RENDER_ALL
	});
	tb_name.hide = 1;
	tb_name.slidable = false;
	
	vb_range = new vectorBox(2, function(v, i) /*=>*/ { slider_range[i] = v; refreshInput(); });
	vb_range.linkable = false;
	
	tb_step  = new textBox(TEXTBOX_INPUT.number, function(v) /*=>*/ { slider_step = v; refreshInput(); });
	
	sc_type = new scrollBox(val_type_name, function(v) /*=>*/ {
		type_index = v;
		sc_disp.data_list = display_list[v];
		disp_index = 0;
		refreshInput();
		RENDER_ALL
	});
	sc_type.text_color   = CDEF.main_mdwhite;
	sc_type.update_hover = false;
	
	sc_disp = new scrollBox(display_list[0], function(v) /*=>*/ {
		disp_index = v;
		refreshInput();
		RENDER_ALL
	});
	sc_disp.text_color   = CDEF.main_mdwhite;
	sc_disp.update_hover = false;
	
	type_index  = 0;
	_type_index = 0;
	
	disp_index  = 0;
	_disp_index = 0;
	
	slider_range = [ 0, 1 ];
	slider_step  = 0.01;
	
	static setFont = function(_f) { 
		tb_name.setFont(_f);
		sc_type.setFont(_f);
		sc_disp.setFont(_f);
		vb_range.setFont(_f);
		tb_step.setFont(_f);
		
		return self;
	}
	
	static refreshInput = function() {
		value.setType(val_type[type_index]);
		
		if(_type_index != type_index || _disp_index != disp_index) {
			switch(value.type) {
				case VALUE_TYPE.integer :
				case VALUE_TYPE.float :
					switch(sc_disp.data_list[disp_index]) {
						case "Vector2" :	
						case "Range" :
						case "Vector range" :	
						case "Slider range" :	
						case "Rotation range" :	value.setValue([0, 0]);          break;
						
						case "Vector3" :        value.setValue([0, 0, 0]);       break;
						
						case "Vector4" :	
						case "Vector2 range" :	
						case "Padding" :	    value.setValue([0, 0, 0, 0]);    break;
							
						case "Area" :	        value.setValue([0, 0, 0, 0, 0]); break;
							
						default : value.setValue(0);
					}
					break;
					
				case VALUE_TYPE.color : 
					switch(sc_disp.data_list[disp_index]) {
						case "Palette" : value.setValue([0]); break;
						default :        value.setValue(0);   break;
					}
					break;
					
				case VALUE_TYPE.gradient : value.setValue(new gradientObject(c_black)); break;
				case VALUE_TYPE.boolean :  value.setValue(false);                       break;
					
				case VALUE_TYPE.text :
				case VALUE_TYPE.path :     value.setValue("");                          break;
				
				case VALUE_TYPE.curve :    value.setValue(CURVE_DEF_01);                break;
			}
		}
		
		_type_index = type_index;
		_disp_index = disp_index;
		
		switch(sc_disp.data_list[disp_index]) {
			case "Default" :		value.setDisplay(VALUE_DISPLAY._default);		break;
			case "Range" :			value.setDisplay(VALUE_DISPLAY.range);			break;
			case "Rotation" :		value.setDisplay(VALUE_DISPLAY.rotation);		break;
			case "Rotation range" : value.setDisplay(VALUE_DISPLAY.rotation_range);	break;
			case "Slider" :			value.setDisplay(VALUE_DISPLAY.slider,       { range: [slider_range[0], slider_range[1], slider_step] }); break;
			case "Slider range" :	value.setDisplay(VALUE_DISPLAY.slider_range, { range: [slider_range[0], slider_range[1], slider_step] }); break;
				
			case "Padding" :		value.setDisplay(VALUE_DISPLAY.padding);		break;
			case "Vector2" :		
			case "Vector3" :		
			case "Vector4" :		value.setDisplay(VALUE_DISPLAY.vector);			break;
			case "Vector range" :	
			case "Vector2 range" :	value.setDisplay(VALUE_DISPLAY.vector_range);	break;
			case "Area" :			value.setDisplay(VALUE_DISPLAY.area);			break;
			case "Palette" :		value.setDisplay(VALUE_DISPLAY.palette);		break;
			
			case "Read" :		value.setDisplay(VALUE_DISPLAY.path_load, { filter: "" });	break;
			case "Write" :		value.setDisplay(VALUE_DISPLAY.path_save, { filter: "" });	break;
			case "Font" :		value.setDisplay(VALUE_DISPLAY.path_font);					break;
		}
	}
	
	static draw = function(_x, _y, _w, _m, _focus, _hover, viewMode) {
		var _h = 0;
		var _font = viewMode == INSP_VIEW_MODE.spacious? f_p0 : f_p2;
		
		var _wd_h = viewMode == INSP_VIEW_MODE.spacious? ui(32) : ui(24);
		var _pd_h = viewMode == INSP_VIEW_MODE.spacious? ui(4)  : ui(2)

		switch(sc_disp.data_list[disp_index]) {
			case "Slider" :			
			case "Slider range" :	
				if(viewMode == INSP_VIEW_MODE.compact) { _h += ui(2); _y += ui(2); }
				
				vb_range.setFocusHover(_focus, _hover);
				 tb_step.setFocusHover(_focus, _hover);
				
				vb_range.axis = [ __txt("min"), __txt("max") ];
				tb_step.label = __txt("step");
				
				var stw = _w / 3;
				var _wx = _x;
				var _ww = _w - (stw + ui(4));
				vb_range.draw(_wx, _y, _ww, _wd_h, slider_range, noone, _m);
				tb_step.draw(_x + _w - stw, _y, stw, _wd_h, slider_step , _m);
				
				_h += _wd_h + ui(2);
				_y += _wd_h + ui(2);
				break;
		}
		
		return _h;
	}
}

function Node_Global(_x = 0, _y = 0) : __Node_Base(_x, _y) constructor {
	name = "GLOBAL";
	display_name = "";
	
	node_id = 0;
	group   = noone;
	
	use_cache = CACHE_USE.none;
	value     = ds_map_create();
	
	input_display_list = -1;
	anim_priority = -999;
	
	static isActiveDynamic = function(frame = CURRENT_FRAME) { return true; }
		
	static valueUpdate = function(index) { RENDER_ALL }
	
	static createValue = function() {
		var _key = $"NewValue{array_length(inputs)}";
		var _in  = nodeValue_Float(_key, self, 0);
		_in.editor = new variable_editor(_in);
		array_push(inputs, _in);
		
		return _in;
	}
	
	static inputExist = function(key) { return ds_map_exists(value, key); }
	
	static inputGetable = function(from, key) {
		if(!inputExist(key)) return false;
		var to = value[? key];
		
		if(!typeCompatible(from.type, to.type)) return false;
		if(typeIncompatible(from, to))          return false;
		
		return true;
	}
	
	static getInputKey = function(key, def = noone) {
		if(!ds_map_exists(value, key)) return def;
		return value[? key];
	}
	
	static step = function() {
		for( var i = 0; i < array_length(inputs); i++ ) {
			var _inp = inputs[i];
			value[? _inp.name] = _inp;
			
			var val = true;
			if(string_pos(" ", _inp.name)) val = false;
			_inp.editor.tb_name.boxColor = val? c_white : COLORS._main_value_negative;
		}
	}
	
	static serialize = function() {
		var _map = {};
		
		var _inputs = [];
		for(var i = 0; i < array_length(inputs); i++) {
			var _ser = inputs[i].serialize();
			
			_ser.global_type    = inputs[i].editor.type_index;
			_ser.global_disp    = inputs[i].editor.disp_index;
			_ser.global_s_range = inputs[i].editor.slider_range;
			_ser.global_s_step  = inputs[i].editor.slider_step;
			
			array_push(_inputs, _ser);
		}
		
		_map.inputs = _inputs;
		_map.attri  = attributes;
		
		return _map;
	}
	
	static deserialize = function(_map) {
		var _inputs = _map.inputs;
		
		for(var i = 0; i < array_length(_inputs); i++) {
			var _des  = _inputs[i];
			var _in   = createValue();
			
			_in.editor.type_index = struct_try_get(_des, "global_type", 0);
			_in.editor.disp_index = struct_try_get(_des, "global_disp", 0);
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