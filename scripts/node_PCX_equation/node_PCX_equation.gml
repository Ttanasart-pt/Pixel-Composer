function Node_PCX_Equation(_x, _y, _group = noone) : Node_PCX(_x, _y, _group) constructor {
	name = "Equation";
	
	w   = 96;
	ast = noone;
	
	inputs[| 0] = nodeValue("Equation", self, JUNCTION_CONNECT.input, VALUE_TYPE.text, "");
	
	static createNewInput = function() { #region
		var index = ds_list_size(inputs);
		inputs[| index + 0] = nodeValue("Argument name", self, JUNCTION_CONNECT.input, VALUE_TYPE.text, "" )
			.setDisplay(VALUE_DISPLAY.text_box);
		
		inputs[| index + 1] = nodeValue("Argument value", self, JUNCTION_CONNECT.input, VALUE_TYPE.PCXnode, noone )
			.setVisible(true, true);
		inputs[| index + 1].editWidget.interactable = false;
	} #endregion
	
	outputs[| 0] = nodeValue("Result", self, JUNCTION_CONNECT.output, VALUE_TYPE.PCXnode, noone );
	
	argument_renderer = new Inspector_Custom_Renderer(function(_x, _y, _w, _m, _hover, _focus) { #region
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
			_jName.editWidget.setFocusHover(_focus, _hover);
			_jName.editWidget.draw(tx, ty, ui(128), _th, _jName.showValue(), _m, _jName.display_type);
			
			draw_set_text(f_p1, fa_center, fa_top, COLORS._main_text_sub);
			draw_text_add(tx + ui(128 + 12), ty + ui(6), "=");
			
			var _jValue = inputs[| i + 1];
			_jValue.editWidget.setFocusHover(_focus, _hover);
			_jValue.editWidget.draw(tx + ui(128 + 24), ty, _w - ui(128 + 24 + 16), _th, _jValue.showValue(), _m);
			
			_h += _th + ui(6);
			hh += _h;
			ty += _h;
		}
		
		argument_renderer.h = hh;
		return hh;
	}); #endregion
	
	argument_renderer.register = function(parent = noone) { #region
		for( var i = input_fix_len; i < ds_list_size(inputs); i++ )
			inputs[| i].editWidget.register(parent);
	} #endregion
	
	input_display_list = [ 
		["Function",	false], 0,
		["Arguments",	false], argument_renderer,
		["Inputs",		 true], 
	]

	setIsDynamicInput(2);
	
	if(!LOADING && !APPENDING) createNewInput();
	
	static refreshDynamicInput = function() { #region
		var _in = ds_list_create();
		
		for( var i = 0; i < input_fix_len; i++ )
			ds_list_add(_in, inputs[| i]);
		
		array_resize(input_display_list, input_display_len);
		
		for( var i = input_fix_len; i < ds_list_size(inputs); i += data_length ) {
			var varName = inputs[| i].getValue();
			
			if(varName != "") {
				ds_list_add(_in, inputs[| i + 0]);
				ds_list_add(_in, inputs[| i + 1]);
				inputs[| i + 1].editWidget.setInteract(true);
				inputs[| i + 1].name = varName;
				
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
	} #endregion
	
	static onValueUpdate = function(index = 0) { #region
		if(LOADING || APPENDING) return;
		
		if(safe_mod(index - input_fix_len, data_length) == 0) //Variable name
			inputs[| index + 1].name = inputs[| index].getValue();
		
		refreshDynamicInput();
	} #endregion
	
	static update = function() { #region
		var eq = inputs[| 0].getValue();
		var fn = evaluateFunctionTree(eq);
		
		var _fnL = new __funcList();
		
		for( var i = input_fix_len; i < array_length(_data); i += data_length ) {
			var _pName = inputs[| i + 0].getValue();
			var _pVal  = inputs[| i + 1].getValue();
			
			_fnL.addFunction(new __funcTree("=", _pName, _pVal));
		}
		
		_fnL.addFunction(fn);
		outputs[| 0].setValue(fn);
	} #endregion
	
	static onDrawNode = function(xx, yy, _mx, _my, _s, _hover, _focus) { #region
		draw_set_text(f_h5, fa_center, fa_center, COLORS._main_text);
		var str = inputs[| 0].getValue();
		
		var bbox = drawGetBbox(xx, yy, _s);
		var ss	= string_scale(str, bbox.w, bbox.h);
		draw_text_transformed(bbox.xc, bbox.yc, str, ss, ss, 0);
	} #endregion
	
	static doApplyDeserialize = function() { refreshDynamicInput(); }
}