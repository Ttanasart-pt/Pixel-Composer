function Node_Lua_Surface(_x, _y, _group = noone) : Node(_x, _y, _group) constructor {
	name = "Lua Surface";
	preview_channel = 1;
	update_on_frame = true;
	
	newInput(0, nodeValue_Text("Function name", $"render{irandom_range(100000, 999999)}"));
	
	newInput(1, nodeValue_Vec2("Output dimension", DEF_SURF));
		
	newInput(2, nodeValue_Text("Lua code"))
		.setTooltip(function() /*=>*/ {return dialogPanelCall(new Panel_Lua_Reference())})
		.setDisplay(VALUE_DISPLAY.codeLUA);
	
	newInput(3, nodeValue("Execution thread", self, CONNECT_TYPE.input, VALUE_TYPE.node, noone))
		.setVisible(false, true);
	
	newInput(4, nodeValue_Bool("Execute on frame", true))
	
	newOutput(0, nodeValue_Output("Execution thread", VALUE_TYPE.node, noone ));
	
	newOutput(1, nodeValue_Output("Surface Out", VALUE_TYPE.surface, noone));
	
	attribute_surface_depth();
	argumentRenderer(global.lua_arguments);
	
	lb_pre = new Inspector_Label("", f_code);
	lb_pos = new Inspector_Label("", f_code);
	
	input_display_list = [ 3, 4, 
		["Function",	false], 0, 1,
		["Arguments",	false], argument_renderer,
		["Script",		false], lb_pre, 2, lb_pos,
		["Inputs",		 true], 
	];

	argument_name = [];
	argument_val  = [];
	
	lua_state = lua_create();
	
	function createNewInput(index = array_length(inputs)) {
		var inAmo = array_length(inputs);
		
		newInput(index + 0, nodeValue_Text("Argument name"));
		
		newInput(index + 1, nodeValue_Enum_Scroll("Argument type",  0 , { data: [ "Number", "String", "Surface", "Struct" ], update_hover: false }));
		inputs[index + 1].editWidget.interactable = false;
		
		newInput(index + 2, nodeValue("Argument value", self, CONNECT_TYPE.input, VALUE_TYPE.float, 0 ))
			.setVisible(true, true);
		inputs[index + 2].editWidget.interactable = false;
		
		array_push(input_display_list, inAmo, inAmo + 1, inAmo + 2);
		return inputs[index + 0];
	} 
	
	setDynamicInput(3, false);
	if(!LOADING && !APPENDING) createNewInput();
	
	static getState = function() {
		if(inputs[3].value_from == noone) 
			return lua_state;
		return inputs[3].value_from.node.getState();
	}
	
	static refreshDynamicInput = function() {
		var _in = [];
		
		for( var i = 0; i < input_fix_len; i++ )
			array_push(_in, inputs[i]);
		
		array_resize(input_display_list, input_display_len);
		
		for( var i = input_fix_len; i < array_length(inputs); i += data_length ) {
			if(inputs[i].getValue() != "") {
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
		refreshNodeDisplay();
	}
	
	static refreshInputType = function() {
		for( var i = input_fix_len; i < array_length(inputs); i += data_length ) {
			var type = getInputData(i + 1);
			switch(type) {
				case 0 : inputs[i + 2].setType(VALUE_TYPE.float);		break;
				case 1 : inputs[i + 2].setType(VALUE_TYPE.text);		break;
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
		
		argument_val  = [];
		for( var i = input_fix_len; i < array_length(inputs) - data_length; i += data_length )
			array_push(argument_val, getInputData(i + 2));
		
		lua_projectData(getState());
		addCode();
		
		var _outSurf = outputs[1].getValue();
		_outSurf = surface_verify(_outSurf, _dimm[0], _dimm[1], attrDepth());
		
		surface_set_target(_outSurf);
			try      { lua_call_w(getState(), _func, argument_val); }
			catch(e) { noti_warning(exception_print(e), noone, self);     }
		surface_reset_target();
		
		outputs[1].setValue(_outSurf);
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