function Node_PCX_Equation(_x, _y, _group = noone) : Node_PCX(_x, _y, _group) constructor {
	name = "Equation";
	
	setDimension(96, 48);
	ast = noone;
	
	newInput(0, nodeValue_Text("Equation"));
	
	newOutput(0, nodeValue_Output("Result", VALUE_TYPE.PCXnode, noone ));
	
	argument_renderer = new Inspector_Custom_Renderer(function(_x, _y, _w, _m, _hover, _focus, _panel = noone) {
		argument_renderer.x = _x;
		argument_renderer.y = _y;
		argument_renderer.w = _w;
		
		var tx = _x + ui(8);
		var ty = _y + ui(8);
		
		var font = _panel != noone && _panel.viewMode == INSP_VIEW_MODE.compact? f_p3 : f_p2;
		var th   = line_get_height(font);
		
		var w1 = ui(128);
		var w2 = _w - w1 - ui(24 + 16);
		var _wh;
		
		for( var i = input_fix_len, n = array_length(inputs); i < n; i += data_length ) {
			var _th = th;
			
			var _jNam = inputs[i + 0];
			var _jVal = inputs[i + 1];
			
			var _wNam = has(_jNam, "__inspWidget")? _jNam.__inspWidget : _jNam.editWidget.clone(); _jNam.__inspWidget = _wNam;
			var _wVal = has(_jVal, "__inspWidget")? _jVal.__inspWidget : _jVal.editWidget.clone(); _jVal.__inspWidget = _wVal;
			
			_wNam.setFocusHover(_focus, _hover);
			_wVal.setFocusHover(_focus, _hover);
			
			_wNam.setFont(font);
			_wVal.setFont(font);
			
			_wh = _wNam.draw(tx, ty, w1, th, _jNam.showValue(), _m, _jNam.display_type);
			_th = max(_th, _wh);
			
			draw_set_text(font, fa_center, fa_top, COLORS._main_text_sub);
			draw_text_add(tx + w1 + ui(12), ty + ui(6), "=");
			
			_wh = _wVal.draw(tx + w1 + ui(24), ty, w2, th, _jVal.showValue(), _m, _jVal.display_type);
			_th = max(_th, _wh);
			
			hh += _th + ui(6);
			ty += _th + ui(6);
		}
		
		argument_renderer.h = hh;
		return hh;
	});
	
	
	input_display_list = [ 
		["Function",	false], 0,
		["Arguments",	false], argument_renderer,
		["Inputs",		 true], 
	]
	
	function createNewInput(index = array_length(inputs)) {
		var inAmo = array_length(inputs);
		
		newInput(index + 0, nodeValue_Text("Argument name"))
			.setDisplay(VALUE_DISPLAY.text_box);
		
		newInput(index + 1, nodeValue("Argument value", self, CONNECT_TYPE.input, VALUE_TYPE.PCXnode, noone ))
			.setVisible(true, true);
		inputs[index + 1].editWidget.interactable = false;
		
		return inputs[index + 0];
	} setDynamicInput(2, false);
	
	argument_renderer.register = function(parent = noone) {
		for( var i = input_fix_len; i < array_length(inputs); i++ )
			inputs[i].editWidget.register(parent);
	}
	
	static refreshDynamicInput = function() {
		var _in = [];
		
		for( var i = 0; i < input_fix_len; i++ )
			array_push(_in, inputs[i]);
		
		array_resize(input_display_list, input_display_len);
		
		for( var i = input_fix_len; i < array_length(inputs); i += data_length ) {
			var varName = getInputData(i);
			
			if(varName != "") {
				array_push(_in, inputs[i + 0]);
				array_push(_in, inputs[i + 1]);
				inputs[i + 1].editWidget.setInteract(true);
				inputs[i + 1].name = varName;
				
				array_push(input_display_list, i + 1);
			} else {
				delete inputs[i + 0];
				delete inputs[i + 1];
			}
		}
		
		for( var i = 0; i < array_length(_in); i++ )
			_in[i].index = i;
		

		inputs = _in;
		
		createNewInput();
	}
	
	static onValueUpdate = function(index = 0) {
		if(LOADING || APPENDING) return;
		
		if(safe_mod(index - input_fix_len, data_length) == 0) //Variable name
			inputs[index + 1].name = getInputData(index);
		
		refreshDynamicInput();
	}
	
	static update = function() {
		var eq = getInputData(0);
		var fn = evaluateFunctionTree(eq);
		
		var _fnL = new __funcList();
		
		for( var i = input_fix_len; i < array_length(_data); i += data_length ) {
			var _pName = getInputData(i + 0);
			var _pVal  = getInputData(i + 1);
			
			_fnL.addFunction(new __funcTree("=", _pName, _pVal));
		}
		
		_fnL.addFunction(fn);
		outputs[0].setValue(fn);
	}
	
	static onDrawNode = function(xx, yy, _mx, _my, _s, _hover, _focus) {
		draw_set_text(f_h5, fa_center, fa_center, COLORS._main_text);
		var str = getInputData(0);
		
		var bbox = draw_bbox;
		var ss	= string_scale(str, bbox.w, bbox.h);
		draw_text_transformed(bbox.xc, bbox.yc, str, ss, ss, 0);
	}
	
	static postApplyDeserialize = function() { refreshDynamicInput(); }
}