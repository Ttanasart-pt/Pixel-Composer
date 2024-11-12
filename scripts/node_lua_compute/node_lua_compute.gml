function Node_Lua_Compute(_x, _y, _group = noone) : Node(_x, _y, _group) constructor {
	name = "Lua Compute";
	update_on_frame = true;
	
	newInput(0, nodeValue_Text("Function name", self, "render" + string(irandom_range(100000, 999999))));
	
	newInput(1, nodeValue_Enum_Scroll("Return type", self,  0, { data: [ "Number", "String", "Struct" ], update_hover: false }));
	
	newInput(2, nodeValue_Text("Lua code", self, "", o_dialog_lua_reference))
		.setDisplay(VALUE_DISPLAY.codeLUA);
	
	newInput(3, nodeValue("Execution thread", self, CONNECT_TYPE.input, VALUE_TYPE.node, noone))
		.setVisible(false, true);
	
	newInput(4, nodeValue_Bool("Execute on frame", self, true))
	
	newOutput(0, nodeValue_Output("Execution thread", self, VALUE_TYPE.node, noone ));
	
	newOutput(1, nodeValue_Output("Return value", self, VALUE_TYPE.any, noone));
	
	argumentRenderer(global.lua_arguments);
	
	lb_pre = new Inspector_Label("", _f_code_s);
	lb_pos = new Inspector_Label("", _f_code_s);
	
	input_display_list = [ 3, 4, 
		["Function",	false], 0, 1,
		["Arguments",	false], argument_renderer,
		["Script",		false], lb_pre, 2, lb_pos,
		["Inputs",		 true], 
	];

	argument_name = [];
	argument_val  = [];
	
	lua_state = lua_create();
	
	static createNewInput = function() {
		var index = array_length(inputs);
		newInput(index + 0, nodeValue_Text("Argument name", self, "" ));
		
		newInput(index + 1, nodeValue_Enum_Scroll("Argument type", self,  0 , { data: [ "Number", "String", "Surface", "Struct" ], update_hover: false }));
		inputs[index + 1].editWidget.interactable = false;
		
		newInput(index + 2, nodeValue("Argument value", self, CONNECT_TYPE.input, VALUE_TYPE.float, 0 ))
			.setVisible(true, true);
		inputs[index + 2].editWidget.interactable = false;
		
		return inputs[index + 0];
	} 
	
	setDynamicInput(3, false);
	if(!LOADING && !APPENDING) createNewInput();
	
	static getState = function() {
		if(inputs[3].value_from == noone) return lua_state;
		return inputs[3].value_from.node.getState();
	}
	
	static refreshDynamicInput = function() {
		var _in = [];
		
		for( var i = 0; i < input_fix_len; i++ )
			array_push(_in, inputs[i]);
		
		array_resize(input_display_list, input_display_len);
		
		for( var i = input_fix_len; i < array_length(inputs); i += data_length ) {
			if(getInputDataForce(i) != "") {
				array_push(_in, inputs[i + 0]);
				array_push(_in, inputs[i + 1]);
				array_push(_in, inputs[i + 2]);
				
				inputs[i + 1].editWidget.interactable = true;
				if(inputs[i + 2].editWidget != noone)
					inputs[i + 2].editWidget.interactable = true;
				
				array_push(input_display_list, i + 2);
			} else {
				delete inputs[i + 0];
				delete inputs[i + 1];
				delete inputs[i + 2];
			}
		}
		
		for( var i = 0; i < array_length(_in); i++ )
			_in[i].index = i;
		
		inputs = _in;
		
		refreshInputType();
		createNewInput();
	}
	
	static refreshInputType = function() {
		for( var i = input_fix_len; i < array_length(inputs); i += data_length ) {
			var type = getInputData(i + 1);
			switch(type) {
				case 0 : inputs[i + 2].setType(VALUE_TYPE.float);	break;
				case 1 : inputs[i + 2].setType(VALUE_TYPE.text);	break;
				case 2 : inputs[i + 2].setType(VALUE_TYPE.surface);	break;
				case 3 : inputs[i + 2].setType(VALUE_TYPE.struct);	break;
			}
				
			inputs[i + 2].setDisplay(VALUE_DISPLAY._default);
		}
	}
	
	static onValueUpdate = function(index = 0) {
		if(LOADING || APPENDING) return;
		
		var _ind = (index - input_fix_len) % data_length;
		
			 if(_ind == 0) refreshDynamicInput();
		else if(_ind == 1) refreshInputType();
	}
	
	static step = function() {
		var _type = getInputData(1);
		switch(_type) {
			case 0 : outputs[1].setType(VALUE_TYPE.float);  break;
			case 1 : outputs[1].setType(VALUE_TYPE.text);   break;
			case 2 : outputs[1].setType(VALUE_TYPE.struct); break;
		}
		
		for( var i = input_fix_len; i < array_length(inputs) - data_length; i += data_length ) {
			var name = getInputData(i + 0);
			inputs[i + 2].name = name;
		}
	}
	
	static update = function(frame = CURRENT_FRAME) {
		var _func = getInputData(0);
		var _dimm = getInputData(1);
		var _exec = getInputData(4);
		update_on_frame = _exec;
		
		argument_val = [];
		for( var i = input_fix_len; i < array_length(inputs) - data_length; i += data_length )
			array_push(argument_val, getInputData(i + 2));
		
		lua_projectData(getState());
		addCode();
		
		var res = 0;
		try	     { res = lua_call_w(getState(), _func, argument_val); } 
		catch(e) { noti_warning(exception_print(e),, self);           }
		
		outputs[1].setValue(res);
	}
	
	static addCode = function() {
		var _func = getInputData(0);
		var _code = getInputData(2);
		argument_name = [];
		
		for( var i = input_fix_len; i < array_length(inputs) - data_length; i += data_length )
			if(getInputData(i) != "") array_push(argument_name, getInputData(i));
		
		var lua_code = $"function {_func}(";
		for( var i = 0, n = array_length(argument_name); i < n; i++ ) {
			if(i) lua_code += ", "
			lua_code += argument_name[i];
		}
		
		lb_pre.text = lua_code + ")";
		lb_pos.text = "end";
		
		lua_code   += $")\n{_code}\nend";
		
		lua_add_code(getState(), lua_code);
	}
	
	static postApplyDeserialize = function() {
		refreshDynamicInput();
		
		for( var i = input_fix_len; i < array_length(inputs) - data_length; i += data_length ) {
			var name = getInputData(i + 0);
			var type = getInputData(i + 1);
			
			inputs[i + 2].name = name;
			
			switch(type) {
				case 0 : inputs[i + 2].setType(VALUE_TYPE.float);	break;
				case 1 : inputs[i + 2].setType(VALUE_TYPE.text);	break;
				case 2 : inputs[i + 2].setType(VALUE_TYPE.surface);	break;
				case 3 : inputs[i + 2].setType(VALUE_TYPE.struct);	break;
			}
			
			inputs[i + 2].setDisplay(VALUE_DISPLAY._default);
		}
		
	}
	
	static onDestroy = function() { lua_state_destroy(lua_state); }
	static onRestore = function() { lua_state = lua_create();     }
}