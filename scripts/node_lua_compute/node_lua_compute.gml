function Node_Lua_Compute(_x, _y, _group = -1) : Node(_x, _y, _group) constructor {
	name = "Lua compute";
	preview_channel = 1;
	
	previewable = false;
	min_h = 0;
	
	inputs[| 0]  = nodeValue(0, "Function name", self, JUNCTION_CONNECT.input, VALUE_TYPE.text, "render" + string(irandom_range(100000, 999999)));
	
	inputs[| 1]  = nodeValue(1, "Return type", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, 0)
		.setDisplay(VALUE_DISPLAY.enum_scroll, [ "Number", "String" ]);
		
	inputs[| 2]  = nodeValue(2, "Lua code", self, JUNCTION_CONNECT.input, VALUE_TYPE.text, "")
		.setDisplay(VALUE_DISPLAY.code);
	
	inputs[| 3]  = nodeValue(3, "Execution thread", self, JUNCTION_CONNECT.input, VALUE_TYPE.node, noone)
		.setVisible(false, true);
	
	static createNewInput = function() {
		var index = ds_list_size(inputs);
		inputs[| index + 0] = nodeValue( index + 0, "Argument name", self, JUNCTION_CONNECT.input, VALUE_TYPE.text, "" );
		
		inputs[| index + 1] = nodeValue( index + 1, "Argument type", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, 0 )
			.setDisplay(VALUE_DISPLAY.enum_scroll, [ "Number", "String", "Surface" ]);
			
		inputs[| index + 2] = nodeValue( index + 2, "Argument value", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, 0 )
			.setVisible(true, true);
	}
	
	outputs[| 0] = nodeValue(0, "Execution thread", self, JUNCTION_CONNECT.output, VALUE_TYPE.node, noone );
	
	outputs[| 1] = nodeValue(1, "Return value", self, JUNCTION_CONNECT.output, VALUE_TYPE.surface, PIXEL_SURFACE);
	
	luaArgumentRenderer();
	
	input_display_list = [ 3,
		["Function",	false], 0, 1,
		["Arguments",	false], argument_renderer,
		["Script",		false], 2,
		["Inputs",		 true], 
	];
	
	input_fix_len	  = ds_list_size(inputs);
	input_display_len = array_length(input_display_list);
	data_length		  = 3;
	
	argument_name = [];
	argument_val  = [];
	
	lua_state = lua_create();
	
	compiled = false;
	
	if(!LOADING && !APPENDING) createNewInput();
	
	static stepBegin = function() {
		if(ANIMATOR.frame_progress) {
			setRenderStatus(false);
			UPDATE |= RENDER_TYPE.partial;
		}
		
		setHeight();
		doStepBegin();
		
		value_validation[VALIDATION.error] = !compiled;
		
		var _type = inputs[| 1].getValue();
		switch(_type) {
			case 0 : outputs[| 1].type = VALUE_TYPE.float; break;
			case 1 : outputs[| 1].type = VALUE_TYPE.text; break;
		}
	}
	
	static getState = function() {
		if(inputs[| 3].value_from == noone)
			return lua_state;
		return inputs[| 3].value_from.node.getState();
	}
	
	static refreshDynamicInput = function() {
		var _in = ds_list_create();
		
		for( var i = 0; i < input_fix_len; i++ )
			ds_list_add(_in, inputs[| i]);
		
		array_resize(input_display_list, input_display_len);
		
		for( var i = input_fix_len; i < ds_list_size(inputs); i += data_length ) {
			if(inputs[| i].getValue() != "") {
				ds_list_add(_in, inputs[| i + 0]);
				ds_list_add(_in, inputs[| i + 1]);
				ds_list_add(_in, inputs[| i + 2]);
				
				array_push(input_display_list, i + 2);
			} else {
				delete inputs[| i + 0];
				delete inputs[| i + 1];
				delete inputs[| i + 2];
			}
		}
		
		for( var i = 0; i < ds_list_size(_in); i++ )
			_in[| i].index = i;
		
		ds_list_destroy(inputs);
		inputs = _in;
		
		createNewInput();
	}
	
	static onValueFromUpdate = function(index) {
		if(index == 0 || index == 2) compiled = false;
	}
	
	static onValueUpdate = function(index) {
		if(index == 0 || index == 2) compiled = false;
		
		if(index == 3) {
			for( var i = 0; i < ds_list_size(outputs[| 0].value_to); i++ ) {
				var _j = outputs[| 0].value_to[| i];
				if(_j.value_from != outputs[| 0]) continue;
				_j.node.compiled = false;
			}
			compiled = false;
		}
		
		if(index < input_fix_len) return;
		if(LOADING || APPENDING) return;
		
		if((index - input_fix_len) % data_length == 0) { //Variable name
			inputs[| index + 2].name = inputs[| index].getValue();
			compiled = false;
		} else if((index - input_fix_len) % data_length == 1) { //Variable type
			var type = inputs[| index].getValue();
			switch(type) {
				case 0 : inputs[| index + 1].type = VALUE_TYPE.float;	break;
				case 1 : inputs[| index + 1].type = VALUE_TYPE.text;	break;
				case 2 : inputs[| index + 1].type = VALUE_TYPE.surface;	break;
			}
			
			inputs[| index + 1].setDisplay(VALUE_DISPLAY._default);
			compiled = false;
		}
		
		refreshDynamicInput();
	}
	
	static update = function() {
		if(!compiled) return;
		
		var _func = inputs[| 0].getValue();
		var _dimm = inputs[| 1].getValue();
		
		argument_val  = [];
		for( var i = input_fix_len; i < ds_list_size(inputs) - data_length; i += data_length ) {
			array_push(argument_val,  inputs[| i + 2].getValue());
		}
		
		var res = 0;
		try {
			res = lua_call_w(getState(), _func, argument_val);
		} catch(e) {
			noti_warning(exception_print(e));
		}
		
		outputs[| 1].setValue(res);
	}
	
	static inspectorUpdate = function() { //compile
		var _func = inputs[| 0].getValue();
		var _code = inputs[| 2].getValue();
		argument_name = [];
		
		for( var i = input_fix_len; i < ds_list_size(inputs) - data_length; i += data_length ) {
			array_push(argument_name, inputs[| i + 0].getValue());
		}
		
		var lua_code = "function " + _func + "(";
		for( var i = 0; i < array_length(argument_name); i++ ) {
			if(i) lua_code += ", "
			lua_code += argument_name[i];
		}
		lua_code += ")";
		lua_code += _code;
		lua_code += "end";
		
		lua_add_code(getState(), lua_code);
		
		compiled = true;
		
		for( var i = 0; i < ds_list_size(outputs[| 0].value_to); i++ ) {
			var _j = outputs[| 0].value_to[| i];
			if(_j.value_from != outputs[| 0]) continue;
			_j.node.inspectorUpdate();
		}
		
		doUpdate();
	}
	
	static postDeserialize = function() {
		var _inputs = load_map[? "inputs"];
		
		for(var i = input_fix_len; i < ds_list_size(_inputs); i += data_length)
			createNewInput();
	}
	
	static doApplyDeserialize = function() {
		refreshDynamicInput();
	}
}