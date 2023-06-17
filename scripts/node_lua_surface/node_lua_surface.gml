function Node_Lua_Surface(_x, _y, _group = noone) : Node(_x, _y, _group) constructor {
	name = "Lua Surface";
	preview_channel = 1;
	
	inputs[| 0]  = nodeValue("Function name", self, JUNCTION_CONNECT.input, VALUE_TYPE.text, "render" + string(irandom_range(100000, 999999)));
	
	inputs[| 1]  = nodeValue("Output dimension", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, [ def_surf_size, def_surf_size ])
		.setDisplay(VALUE_DISPLAY.vector);
		
	inputs[| 2]  = nodeValue("Lua code", self, JUNCTION_CONNECT.input, VALUE_TYPE.text, "", o_dialog_lua_reference)
		.setDisplay(VALUE_DISPLAY.code);
	
	inputs[| 3]  = nodeValue("Execution thread", self, JUNCTION_CONNECT.input, VALUE_TYPE.node, noone)
		.setVisible(false, true);
	
	inputs[| 4]  = nodeValue("Execute on frame", self, JUNCTION_CONNECT.input, VALUE_TYPE.boolean, true)
	
	static createNewInput = function() {
		var index = ds_list_size(inputs);
		inputs[| index + 0] = nodeValue("Argument name", self, JUNCTION_CONNECT.input, VALUE_TYPE.text, "" );
		
		inputs[| index + 1] = nodeValue("Argument type", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, 0 )
			.setDisplay(VALUE_DISPLAY.enum_scroll, [ "Number", "String", "Surface", "Struct" ], { update_hover: false });
		inputs[| index + 1].editWidget.interactable = false;
		
		inputs[| index + 2] = nodeValue("Argument value", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, 0 )
			.setVisible(true, true);
		inputs[| index + 2].editWidget.interactable = false;
	}
	
	outputs[| 0] = nodeValue("Execution thread", self, JUNCTION_CONNECT.output, VALUE_TYPE.node, noone );
	
	outputs[| 1] = nodeValue("Surface out", self, JUNCTION_CONNECT.output, VALUE_TYPE.surface, noone);
	
	attribute_surface_depth();
	luaArgumentRenderer();
	
	input_display_list = [ 3, 4, 
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
	lua_error_handler = _lua_error;
	
	error_notification = noone;
	compiled = false;
	
	if(!LOADING && !APPENDING) createNewInput();
	
	static stepBegin = function() {
		if(ANIMATOR.frame_progress)
			setRenderStatus(false);
		
		setHeight();
		doStepBegin();
		
		value_validation[VALIDATION.error] = !compiled;
		if(!compiled && error_notification == noone) {
			error_notification = noti_error("Lua node [" + string(name) + "] not compiled.");
			error_notification.onClick = function() { PANEL_GRAPH.focusNode(self); };
		}
		
		if(compiled && error_notification != noone) {
			noti_remove(error_notification);
			error_notification = noone;
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
				
				inputs[| i + 1].editWidget.interactable = true;
				if(inputs[| i + 2].editWidget != noone)
					inputs[| i + 2].editWidget.interactable = true;
				
				var type = inputs[| i + 1].getValue();
				switch(type) {
					case 0 : inputs[| i + 2].type = VALUE_TYPE.float;	break;
					case 1 : inputs[| i + 2].type = VALUE_TYPE.text;	break;
					case 2 : inputs[| i + 2].type = VALUE_TYPE.surface;	break;
					case 3 : inputs[| i + 2].type = VALUE_TYPE.struct;	break;
				}
					
				inputs[| i + 2].setDisplay(VALUE_DISPLAY._default);
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
	
	static onValueUpdate = function(index = 0) {
		if(index == 0 || index == 2) compiled = false;
		
		if(index == 3) {
			for( var i = 0; i < ds_list_size(outputs[| 0].value_to); i++ ) {
				var _j = outputs[| 0].value_to[| i];
				if(_j.value_from != outputs[| 0]) continue;
				_j.node.compiled = false;
			}
			compiled = false;
		}
		
		if(LOADING || APPENDING) return;
		
		compiled = false;
		refreshDynamicInput();
	}
	
	static step = function() {
		for( var i = input_fix_len; i < ds_list_size(inputs) - data_length; i += data_length ) {
			var name = inputs[| i + 0].getValue();
			inputs[| i + 2].name = name;
		}
	}
	
	static update = function(frame = ANIMATOR.current_frame) {
		if(!compiled) return;
		//if(!ANIMATOR.is_playing || !ANIMATOR.frame_progress) return;
		
		var _func = inputs[| 0].getValue();
		var _dimm = inputs[| 1].getValue();
		var _exec = inputs[| 4].getValue();
		
		if(!is_real(_exec) || !_exec) return;
		
		argument_val  = [];
		for( var i = input_fix_len; i < ds_list_size(inputs) - data_length; i += data_length ) {
			array_push(argument_val,  inputs[| i + 2].getValue());
		}
		
		//if(ANIMATOR.current_frame == 0) { //rerfesh state on the first frame
		//	lua_state_destroy(lua_state);
		//	lua_state = lua_create();
		//	addCode();
		//}
		
		lua_projectData(getState());
		
		var _outSurf = outputs[| 1].getValue();
		_outSurf = surface_verify(_outSurf, _dimm[0], _dimm[1], attrDepth());
		
		surface_set_target(_outSurf);
			try      { lua_call_w(getState(), _func, argument_val); }
			catch(e) { noti_warning(exception_print(e),, self); }
		surface_reset_target();
		
		outputs[| 1].setValue(_outSurf);
	}
	
	static addCode = function() {
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
		lua_code += ")\n";
		lua_code += _code;
		lua_code += "\nend";
		
		lua_add_code(getState(), lua_code);
	}
	
	static onInspector1Update = function() { //compile
		var thrd = inputs[| 3].value_from;
		if(thrd == noone) {
			doCompile();
			return;
		}
		
		thrd.node.onInspector1Update();
	}
	
	static doCompile = function() {
		addCode();
		compiled = true;
		
		for( var i = 0; i < ds_list_size(outputs[| 0].value_to); i++ ) {
			var _j = outputs[| 0].value_to[| i];
			if(_j.value_from != outputs[| 0]) continue;
			_j.node.doCompile();
		}
		
		doUpdate();
	}
	
	static postDeserialize = function() {
		var _inputs = load_map.inputs;
		
		for(var i = input_fix_len; i < array_length(_inputs); i += data_length)
			createNewInput();
	}
	
	static doApplyDeserialize = function() {
		refreshDynamicInput();
		
		for( var i = input_fix_len; i < ds_list_size(inputs) - data_length; i += data_length ) {
			var name = inputs[| i + 0].getValue();
			var type = inputs[| i + 1].getValue();
			
			inputs[| i + 2].name = name;
			
			switch(type) {
				case 0 : inputs[| i + 2].type = VALUE_TYPE.float;	break;
				case 1 : inputs[| i + 2].type = VALUE_TYPE.text;	break;
				case 2 : inputs[| i + 2].type = VALUE_TYPE.surface;	break;
				case 3 : inputs[| i + 2].type = VALUE_TYPE.struct;	break;
			}
			
			inputs[| i + 2].setDisplay(VALUE_DISPLAY._default);
		}
	}
	
	static onDestroy = function() {
		lua_state_destroy(lua_state);
		if(error_notification != noone)
			noti_remove(error_notification);
	}
}