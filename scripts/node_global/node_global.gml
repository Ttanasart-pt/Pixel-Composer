function variable_editor(nodeVal) constructor {
	value = nodeVal;
	
	val_type      = [ VALUE_TYPE.integer, VALUE_TYPE.float, VALUE_TYPE.boolean, VALUE_TYPE.color, VALUE_TYPE.path, VALUE_TYPE.curve, VALUE_TYPE.text ];
	val_type_name = [ "Integer", "Float", "Boolean", "Color", "Path", "Curve", "Text" ];
	display_list  = [
		/*Integer*/	[ "Default", "Range", "Rotation", "Rotation range", "Slider", "Slider range", "Padding", "Vector2", "Vector3", "Vector4", "Vector range", "Vector2 range", "Area" ],
		/*Float*/	[ "Default", "Range", "Rotation", "Rotation range", "Slider", "Slider range", "Padding", "Vector2", "Vector3", "Vector4", "Vector range", "Vector2 range", "Area" ],
		/*Boolean*/	[ "Default" ],
		/*Color*/	[ "Default", "Gradient", "Palette" ],
		/*Path*/	[ "Import", "Export", "Font" ],
		/*Curve*/	[ "Default", ],
		/*Text*/	[ "Default", ],
	]
	
	tb_name = new textArea(TEXTBOX_INPUT.text, function(str) { 
		value_name = str;
		value.name = str;
		
		if(string_pos(" ", value.name))
			noti_warning("Global variable name can't have space.");
		UPDATE |= RENDER_TYPE.full;
	});
	
	vb_range = new vectorBox(2, function(index, val) { 
		slider_range[index] = val;
	});
	
	tb_step = new textBox(TEXTBOX_INPUT.number, function(val) { 
		slider_step = val;
	});
	
	sc_type = new scrollBox(val_type_name, function(val) {
		type_index = val;
		sc_disp.data_list = display_list[val];
		disp_index = 0;
		refreshInput();
		
		UPDATE |= RENDER_TYPE.full;
	} );
	sc_type.update_hover = false;
	
	sc_disp = new scrollBox(display_list[0], function(val) {
		disp_index = val;
		refreshInput();
		
		UPDATE |= RENDER_TYPE.full;
	} );
	sc_disp.update_hover = false;
	
	value_name  = "NewValue";
	type_index  = 0;
	_type_index = 0;
	
	disp_index  = 0;
	_disp_index = 0;
	
	slider_range = [ 0, 1 ];
	slider_step  = 0.01;
	
	static refreshInput = function() {
		value.type = val_type[type_index];
		value.name = value_name;
		
		if(_type_index != type_index || _disp_index != disp_index) {
			_type_index = type_index;
			_disp_index = disp_index;
			
			switch(value.type) {
				case VALUE_TYPE.integer :
				case VALUE_TYPE.float :
					switch(sc_disp.data_list[disp_index]) {
						case "Vector2" :	
						case "Vector range" :	
						case "Slider range" :	
						case "Rotation range" :	
							value.setValue([0, 0]);		
							break;
						case "Vector3" :	
							value.setValue([0, 0, 0]);
							break;
						case "Vector4" :	
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
						case "Gradient" :	
							value.setValue(new gradientObject(c_black));		
							break;
						case "Palette" :	
							value.setValue([0]);
							break;
						default :
							value.setValue(0);
							break;
					}
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
		
		switch(sc_disp.data_list[disp_index]) {
			case "Default" :		value.setDisplay(VALUE_DISPLAY._default);		break;
			case "Range" :			value.setDisplay(VALUE_DISPLAY.range);			break;
			case "Rotation" :		value.setDisplay(VALUE_DISPLAY.rotation);		break;
			case "Rotation range" : value.setDisplay(VALUE_DISPLAY.rotation_range);	break;
			case "Slider" :			
				value.setDisplay(VALUE_DISPLAY.slider, [0, 1, 0.01]);		
				break;
			case "Slider range" :	
				value.setDisplay(VALUE_DISPLAY.slider_range, [0, 1, 0.01]);	
				break;
			case "Padding" :		value.setDisplay(VALUE_DISPLAY.padding);		break;
			case "Vector2" :		value.setDisplay(VALUE_DISPLAY.vector);			break;
			case "Vector3" :		value.setDisplay(VALUE_DISPLAY.vector);			break;
			case "Vector4" :		value.setDisplay(VALUE_DISPLAY.vector);			break;
			case "Vector range" :	value.setDisplay(VALUE_DISPLAY.vector_range);	break;
			case "Vector2 range" :	value.setDisplay(VALUE_DISPLAY.vector_range);	break;
			case "Area" :			value.setDisplay(VALUE_DISPLAY.area);			break;
			case "Gradient" :		value.setDisplay(VALUE_DISPLAY.gradient);		break;
			case "Palette" :		value.setDisplay(VALUE_DISPLAY.palette);		break;
			
			case "Import" :		value.setDisplay(VALUE_DISPLAY.path_load, ["", ""]);	break;
			case "Export" :		value.setDisplay(VALUE_DISPLAY.path_save, ["", ""]);	break;
			case "Font" :		value.setDisplay(VALUE_DISPLAY.path_font);				break;
		}
	}
	
	static draw = function(_x, _y, _w, _m, _focus, _hover) {
		var _h = 0;
		
		switch(sc_disp.data_list[disp_index]) {
			case "Slider" :			
			case "Slider range" :	
				var wd_h = ui(32);
				var lb_w = ui(72);
				
				vb_range.setActiveFocus(_focus, _hover);
				 tb_step.setActiveFocus(_focus, _hover);
				
				draw_set_text(f_p0, fa_left, fa_center, COLORS._main_text_sub);
				draw_text(_x + ui(8), _y + wd_h / 2, "Range");
						
				vb_range.draw(_x + lb_w, _y, _w - lb_w, wd_h, slider_range, _m);
				_h += wd_h + ui(4);
				_y += wd_h + ui(4);
				
				draw_set_text(f_p0, fa_left, fa_center, COLORS._main_text_sub);
				draw_text(_x + ui(8), _y + wd_h / 2, "Step");
				
				 tb_step.draw(_x + lb_w, _y, _w - lb_w, wd_h, slider_step , _m);
				_h += wd_h + ui(8);
				_y += wd_h + ui(8);
				break;
		}
		
		return _h;
	}
}

#region define
	globalvar GLOBAL;
	gml_pragma("global", @"
		globalvar GLOBAL;
		GLOBAL = new Node_Global();
	");
#endregion

function Node_Global(_x = 0, _y = 0) : __Node_Base(_x, _y) constructor {
	name = "GLOBAL";
	display_name = "";
	
	group = noone;
	use_cache = false;
	value = ds_map_create();
	input_display_list = -1;
	anim_priority = -999;
	
	static valueUpdate = function(index) {
		UPDATE |= RENDER_TYPE.full;
	}
	
	static createValue = function() {
		var _in    = nodeValue("NewValue", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, 0);
		_in.editor = new variable_editor(_in);
		ds_list_add(inputs, _in);
		
		return _in;
	}
	
	static inputExist = function(key) {
		return ds_map_exists(value, key);
	}
	
	static inputGetable = function(from, key) {
		if(!inputExist(key)) return false;
		var to = value[? key];
		
		if(!typeCompatible(from.type, to.type))
			return false;
		if(typeIncompatible(from, to))
			return false;
		
		return true;
	}
	
	static getInput = function(key, def = noone) {
		if(!ds_map_exists(value, key)) return def;
		return value[? key];
	}
	
	static step = function() {
		for( var i = 0; i < ds_list_size(inputs); i++ ) {
			var _inp = inputs[| i];
			value[? _inp.name] = _inp;
			
			var val   = true;
			if(string_pos(" ", _inp.name)) val = false;
			_inp.editor.tb_name.boxColor = val? c_white : COLORS._main_value_negative;
		}
	}
	
	static serialize = function() {
		var _map = ds_map_create();
		
		var _inputs = ds_list_create();
		for(var i = 0; i < ds_list_size(inputs); i++) {
			var _ser = inputs[| i].serialize();
			
			_ser[? "global_type"]	 = inputs[| i].editor.type_index;
			_ser[? "global_disp"]	 = inputs[| i].editor.disp_index;
			_ser[? "global_name"]	 = inputs[| i].editor.value_name;
			_ser[? "global_s_range"] = ds_list_create_from_array(inputs[| i].editor.slider_range);
			_ser[? "global_s_step "] = inputs[| i].editor.slider_step;
			
			ds_list_add(_inputs, _ser);	
			ds_list_mark_as_map(_inputs, i);
		}
		
		ds_map_add_list(_map, "inputs", _inputs);
		
		return _map;
	}
	
	static deserialize = function(_map) {
		var _inputs = _map[? "inputs"];
		
		for(var i = 0; i < ds_list_size(_inputs); i++) {
			var _des = _inputs[| i];
			var _in  = createValue();
			
			_in.editor.type_index = ds_map_try_get(_des, "global_type", 0);
			_in.editor.disp_index = ds_map_try_get(_des, "global_disp", 0);
			_in.editor.disp_index = ds_map_try_get(_des, "global_disp", 0);
			_in.editor.value_name = ds_map_try_get(_des, "global_name", "");
			
			_in.editor.slider_range = array_create_from_list(ds_map_try_get(_des, "global_s_range", [ 0, 0 ]));
			_in.editor.slider_step  = ds_map_try_get(_des, "global_s_step",  0.01);
			
			_in.editor.refreshInput();
			
			_in.applyDeserialize(_des);
		}
		
		step();
	}
}