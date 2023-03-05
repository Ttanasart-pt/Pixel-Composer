function Node_Equation(_x, _y, _group = noone) : Node_Processor(_x, _y, _group) constructor {
	name		= "Equation";
	color		= COLORS.node_blend_number;
	previewable = false;
	
	w = 96;
	
	
	inputs[| 0] = nodeValue("Equation", self, JUNCTION_CONNECT.input, VALUE_TYPE.text, "");
	
	static createNewInput = function() {
		var index = ds_list_size(inputs);
		inputs[| index + 0] = nodeValue("Argument name", self, JUNCTION_CONNECT.input, VALUE_TYPE.text, "" );
		
		inputs[| index + 1] = nodeValue("Argument value", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, 0 )
			.setVisible(true, true);
		inputs[| index + 1].editWidget.interactable = false;
	}
	
	outputs[| 0] = nodeValue("Result", self, JUNCTION_CONNECT.output, VALUE_TYPE.float, 0);
	
	argument_renderer = new Inspector_Custom_Renderer(function(_x, _y, _w, _m, _hover, _focus) {
		argument_renderer.x = _x;
		argument_renderer.y = _y;
		argument_renderer.w = _w;
		
		var tx = _x + ui(8);
		var ty = _y + ui(8);
		var hh = ui(8);
		var _th = TEXTBOX_HEIGHT;
		
		for( var i = input_fix_len; i < ds_list_size(inputs); i += data_length ) {
			var _h = 0;
			
			var _jName = inputs[| i + 0];
			_jName.editWidget.setActiveFocus(_focus, _hover);
			_jName.editWidget.draw(tx, ty, ui(128), _th, _jName.showValue(), _m, _jName.display_type);
			
			draw_set_text(f_p1, fa_center, fa_top, COLORS._main_text_sub);
			draw_text_over(tx + ui(128 + 12), ty + ui(6), "=");
			
			var _jValue = inputs[| i + 1];
			_jValue.editWidget.setActiveFocus(_focus, _hover);
			_jValue.editWidget.draw(tx + ui(128 + 24), ty, _w - ui(128 + 24 + 16), _th, _jValue.showValue(), _m);
			
			_h += _th + ui(6);
			hh += _h;
			ty += _h;
		}
		
		argument_renderer.h = hh;
		return hh;
	});
	
	argument_renderer.register = function(parent = noone) {
		for( var i = input_fix_len; i < ds_list_size(inputs); i++ ) {
			inputs[| i].editWidget.register(parent);
		}
	}
	
	input_display_list = [ 
		["Function",	false], 0,
		["Arguments",	false], argument_renderer,
		["Inputs",		true], 
	]
	
	input_fix_len	  = ds_list_size(inputs);
	input_display_len = array_length(input_display_list);
	data_length		  = 2;
	
	if(!LOADING && !APPENDING) createNewInput();
	
	static refreshDynamicInput = function() {
		var _in = ds_list_create();
		
		for( var i = 0; i < input_fix_len; i++ )
			ds_list_add(_in, inputs[| i]);
		
		array_resize(input_display_list, input_display_len);
		
		for( var i = input_fix_len; i < ds_list_size(inputs); i += data_length ) {
			if(inputs[| i].getValue() != "") {
				ds_list_add(_in, inputs[| i + 0]);
				ds_list_add(_in, inputs[| i + 1]);
				inputs[| i + 1].editWidget.interactable = true;
				
				array_push(input_display_list, i + 1);
			} else {
				delete inputs[| i + 0];
				delete inputs[| i + 1];
			}
		}
		
		for( var i = 0; i < ds_list_size(_in); i++ )
			_in[| i].index = i;
		
		ds_list_destroy(inputs);
		inputs = _in;
		
		createNewInput();
	}
	
	static onValueUpdate = function(index = 0) {
		if(index < input_fix_len) return;
		if(LOADING || APPENDING) return;
		
		if(safe_mod(index - input_fix_len, data_length) == 0) { //Variable name
			inputs[| index + 1].name = inputs[| index].getValue();
		}
		
		refreshDynamicInput();
	}
	
	function process_data(_output, _data, _output_index, _array_index = 0) {  
		var eq = _data[0];
		var params = {};
		
		for( var i = input_fix_len; i < array_length(_data); i += data_length ) {
			var _pName = _data[i + 0];
			var _pVal  = _data[i + 1];
			
			variable_struct_set(params, _pName, _pVal);
		}
		
		return evaluateFunction(eq, params);
	}
	
	static onDrawNode = function(xx, yy, _mx, _my, _s, _hover, _focus) {
		draw_set_text(f_h5, fa_center, fa_center, COLORS._main_text);
		var str = inputs[| 0].getValue();
		
		var bbox = drawGetBbox(xx, yy, _s);
		var ss	= string_scale(str, bbox.w, bbox.h);
		draw_text_transformed(bbox.xc, bbox.yc, str, ss, ss, 0);
	}
	
	static postDeserialize = function() {
		var _inputs = load_map[? "inputs"];
		
		for(var i = input_fix_len; i < ds_list_size(_inputs); i += data_length)
			createNewInput();
	}
}