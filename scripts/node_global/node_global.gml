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
		/*Path*/	[ "Import", "Export", "Font" ],
		/*Curve*/	[ "Default", ],
		/*Text*/	[ "Default", ],
	]
	
	tb_name = new textBox(TEXTBOX_INPUT.text, function(str) { 
		value_name = str;
		value.name = str;
		
		if(string_pos(" ", value.name))
			noti_warning("Global variable name can't have space.");
		RENDER_ALL
	});
	
	vb_range = new vectorBox(2, function(value, index) { 
		slider_range[index] = value;
		refreshInput();
	});
	
	tb_step = new textBox(TEXTBOX_INPUT.number, function(value) { 
		slider_step = value;
		refreshInput();
	});
	
	sc_type = new scrollBox(val_type_name, function(value) {
		type_index = value;
		sc_disp.data_list = display_list[value];
		disp_index = 0;
		refreshInput();
		
		RENDER_ALL
	} );
	sc_type.update_hover = false;
	
	sc_disp = new scrollBox(display_list[0], function(value) {
		disp_index = value;
		refreshInput();
		
		RENDER_ALL
	} );
	sc_disp.update_hover = false;
	
	value_name  = "NewValue";
	type_index  = 0;
	_type_index = 0;
	
	disp_index  = 0;
	_disp_index = 0;
	
	slider_range = [ 0, 1 ];
	slider_step  = 0.01;
	
	static refreshInput = function() { #region
		value.setType(val_type[type_index]);
		value.name = value_name;
		
		if(_type_index != type_index || _disp_index != disp_index) {
			switch(value.type) {
				case VALUE_TYPE.integer :
				case VALUE_TYPE.float :
					switch(sc_disp.data_list[disp_index]) {
						case "Vector2" :	
						case "Range" :
						case "Vector range" :	
						case "Slider range" :	
						case "Rotation range" :	
							value.setValue([0, 0]);		
							break;
						case "Vector3" :	
							value.setValue([0, 0, 0]);
							break;
						case "Vector4" :	
						case "Vector2 range" :	
						case "Padding" :	
							value.setValue([0, 0, 0, 0]);
							break;
						case "Area" :	
							value.setValue([0, 0, 0, 0, 0]);
							break;
						default :
							value.setValue(0);
							break;
					}
					break;
				case VALUE_TYPE.color : 
					switch(sc_disp.data_list[disp_index]) {
						case "Palette" :	
							value.setValue([0]);
							break;
						default :
							value.setValue(0);
							break;
					}
					break;
				case VALUE_TYPE.gradient :	
					value.setValue(new gradientObject(c_black));		
					break;
				case VALUE_TYPE.boolean : 
					value.setValue(false);
					break;
				case VALUE_TYPE.text :
				case VALUE_TYPE.path : 
					value.setValue("");
					break;
				case VALUE_TYPE.curve :
					value.setValue(CURVE_DEF_01);
					break;
			}
		}
		
		_type_index = type_index;
		_disp_index = disp_index;
		
		switch(sc_disp.data_list[disp_index]) {
			case "Default" :		value.setDisplay(VALUE_DISPLAY._default);		break;
			case "Range" :			value.setDisplay(VALUE_DISPLAY.range);			break;
			case "Rotation" :		value.setDisplay(VALUE_DISPLAY.rotation);		break;
			case "Rotation range" : value.setDisplay(VALUE_DISPLAY.rotation_range);	break;
			case "Slider" :			
				value.setDisplay(VALUE_DISPLAY.slider, { range: [slider_range[0], slider_range[1], slider_step] });
				break;
			case "Slider range" :	
				value.setDisplay(VALUE_DISPLAY.slider_range, { range: [slider_range[0], slider_range[1], slider_step] });	
				break;
			case "Padding" :		value.setDisplay(VALUE_DISPLAY.padding);		break;
			case "Vector2" :		
			case "Vector3" :		
			case "Vector4" :		value.setDisplay(VALUE_DISPLAY.vector);			break;
			case "Vector range" :	
			case "Vector2 range" :	value.setDisplay(VALUE_DISPLAY.vector_range);	break;
			case "Area" :			value.setDisplay(VALUE_DISPLAY.area);			break;
			case "Palette" :		value.setDisplay(VALUE_DISPLAY.palette);		break;
			
			case "Import" :		value.setDisplay(VALUE_DISPLAY.path_load, { filter: "" });	break;
			case "Export" :		value.setDisplay(VALUE_DISPLAY.path_save, { filter: "" });	break;
			case "Font" :		value.setDisplay(VALUE_DISPLAY.path_font);					break;
		}
	} #endregion
	
	static draw = function(_x, _y, _w, _m, _focus, _hover) { #region
		var _h = 0;
		
		switch(sc_disp.data_list[disp_index]) {
			case "Slider" :			
			case "Slider range" :	
				var wd_h = ui(32);
				var lb_w = ui(72);
				
				vb_range.setFocusHover(_focus, _hover);
				 tb_step.setFocusHover(_focus, _hover);
				
				draw_set_text(f_p0, fa_left, fa_center, COLORS._main_text_sub);
				draw_text(_x + ui(8), _y + wd_h / 2, __txt("Range"));
						
				vb_range.draw(_x + lb_w, _y, _w - lb_w, wd_h, slider_range, noone, _m);
				_h += wd_h + ui(4);
				_y += wd_h + ui(4);
				
				draw_set_text(f_p0, fa_left, fa_center, COLORS._main_text_sub);
				draw_text(_x + ui(8), _y + wd_h / 2, __txt("Step"));
				
				 tb_step.draw(_x + lb_w, _y, _w - lb_w, wd_h, slider_step , _m);
				_h += wd_h + ui(8);
				_y += wd_h + ui(8);
				break;
		}
		
		return _h;
	} #endregion
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
	
	static valueUpdate = function(index) { RENDER_ALL }
	
	static createValue = function() { #region
		var _in    = nodeValue("NewValue", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, 0);
		_in.editor = new variable_editor(_in);
		ds_list_add(inputs, _in);
		
		return _in;
	} #endregion
	
	static inputExist = function(key) { #region
		return ds_map_exists(value, key);
	} #endregion
	
	static inputGetable = function(from, key) { #region
		if(!inputExist(key)) return false;
		var to = value[? key];
		
		if(!typeCompatible(from.type, to.type))
			return false;
		if(typeIncompatible(from, to))
			return false;
		
		return true;
	} #endregion
	
	static getInputKey = function(key, def = noone) { #region
		if(!ds_map_exists(value, key)) return def;
		return value[? key];
	} #endregion
	
	static step = function() { #region
		for( var i = 0; i < ds_list_size(inputs); i++ ) {
			var _inp = inputs[| i];
			value[? _inp.name] = _inp;
			
			var val   = true;
			if(string_pos(" ", _inp.name)) val = false;
			_inp.editor.tb_name.boxColor = val? c_white : COLORS._main_value_negative;
		}
	} #endregion
	
	static serialize = function() { #region
		var _map = {};
		
		var _inputs = [];
		for(var i = 0; i < ds_list_size(inputs); i++) {
			var _ser = inputs[| i].serialize();
			
			_ser.global_type    = inputs[| i].editor.type_index;
			_ser.global_disp    = inputs[| i].editor.disp_index;
			_ser.global_name    = inputs[| i].editor.value_name;
			_ser.global_s_range = inputs[| i].editor.slider_range;
			_ser.global_s_step  = inputs[| i].editor.slider_step;
			
			array_push(_inputs, _ser);
		}
		
		_map.inputs = _inputs;
		_map.attri  = attributes;
		
		return _map;
	} #endregion
	
	static deserialize = function(_map) { #region
		var _inputs = _map.inputs;
		
		for(var i = 0; i < array_length(_inputs); i++) {
			var _des  = _inputs[i];
			var _in   = createValue();
			var _name = struct_try_get(_des, "global_name", "");
			
			_in.editor.type_index = struct_try_get(_des, "global_type", 0);
			_in.editor.disp_index = struct_try_get(_des, "global_disp", 0);
			_in.editor.disp_index = struct_try_get(_des, "global_disp", 0);
			_in.editor.value_name = _name;
			
			_in.editor.slider_range = _des.global_s_range;
			_in.editor.slider_step  = struct_try_get(_des, "global_s_step",  0.01);
			
			_in.editor.refreshInput();
			
			_in.applyDeserialize(_des);
			
			if(struct_has(PROGRAM_ARGUMENTS, _name)) _in.setValue(PROGRAM_ARGUMENTS[$ _name]);
		}
		
		if(struct_has(_map, "attr")) struct_override(attributes, _map.attr); 
		
		step();
	} #endregion
}