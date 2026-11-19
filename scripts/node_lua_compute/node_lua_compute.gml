function Node_Lua_Compute(_x, _y, _group = noone) : Node(_x, _y, _group) constructor {
	name = "Lua Compute";
	update_on_frame = true;
	lua_state = lua_create();
	
	newInput(3, nodeValue(      "Execution Thread", self, CONNECT_TYPE.input, VALUE_TYPE.node, lua_state )).setVisible(false, true);
	newInput(4, nodeValue_Bool( "Execute on Frame", true ));
	
	////- =Function
	newInput(0, nodeValue_Text(    "Function Name", $"render{seed_random(6)}" ));
	newInput(1, nodeValue_EScroll( "Return Type",  0, { data: [ "Number", "String", "Struct" ], update_hover: false } ));
	
	////- =Script
	newInput(2, nodeValue_Text( "Lua Code" )).setDisplay(VALUE_DISPLAY.codeLUA)
		.setTooltip(function() /*=>*/ {return dialogPanelCall(new Panel_Code_Reference(global.lua_functions))}, __txt("Lua Reference"))
	// 5
	
	newOutput(0, nodeValue_Output( "Execution Thread", VALUE_TYPE.node, lua_state ));
	newOutput(1, nodeValue_Output( "Return Value",     VALUE_TYPE.any,  noone     ));
	
	argumentRenderer(global.lua_arguments);
	
	lb_pre = new Inspector_Label("", f_code);
	lb_pos = new Inspector_Label("", f_code);
	
	input_display_list = [ 3, 4, 
		[ "Function",  false ], 0, 1,
		[ "Arguments", false, noone, b_argAdd ], argument_renderer,
		[ "Script",    false ], lb_pre, 2, lb_pos,
		[ "Inputs",     true ], 
	];
	
	lua_dtype = [ "Number", "String", "Surface", "Struct" ];
	
	function createNewInput(index = array_length(inputs)) {
		var inAmo = array_length(inputs);
		
		newInput(index + 0, nodeValue_Text(    "Argument name" )).setDisplay(VALUE_DISPLAY.text_box);
		newInput(index + 1, nodeValue_EScroll( "Argument type",  0, { data: lua_dtype, update_hover: false }));
		newInput(index + 2, nodeValue_Any(     "Argument value", 0 )).setVisible(true, true);
		
		array_push(input_display_list, inAmo, inAmo + 1, inAmo + 2);
		postCreateNewInput(index);
		return inputs[index + 0];
	} 
	
	setDynamicInput(3, false, VALUE_TYPE.any, DYNA_INPUT_COND.all);
	if(!LOADING && !APPENDING) createNewInput();
	
	////- Nodes
	
	lua_state_current = lua_state;
	argument_name = [];
	argument_val  = [];
	
	static getState = function() /*=>*/ {return lua_state_current};
	
	static update = function(frame = CURRENT_FRAME) {
		#region data
			var _stat = getInputData( 3);
			var _exec = getInputData( 4);
			
			var _func = getInputData( 0);
			var _rtyp = getInputData( 1);
		#endregion
		
		#region inputs
			switch(_rtyp) {
				case 0 : outputs[1].setType(VALUE_TYPE.float);  break;
				case 1 : outputs[1].setType(VALUE_TYPE.text);   break;
				case 2 : outputs[1].setType(VALUE_TYPE.struct); break;
			}
			
			for( var i = input_fix_len, n = array_length(inputs); i < n; i += data_length ) {
				var name = getInputData(i + 0);
				var type = getInputData(i + 1);
			
				switch(type) {
					case 0 : inputs[i + 2].setType(VALUE_TYPE.float);	break;
					case 1 : inputs[i + 2].setType(VALUE_TYPE.text);	break;
					case 2 : inputs[i + 2].setType(VALUE_TYPE.surface);	break;
					case 3 : inputs[i + 2].setType(VALUE_TYPE.struct);	break;
				}
					
				inputs[i + 2].name = name;
				inputs[i + 2].setDisplay(VALUE_DISPLAY._default);
			}
		#endregion
		
		update_on_frame   = _exec;
		
		if(!lua_state_exists(_stat)) 
			_stat = lua_state;
		lua_state_current = _stat;
			
		if(!lua_state_exists(_stat)) {
			noti_warning("Lua state error");
			return;
		}
		
		argument_val = [];
		for( var i = input_fix_len, n = array_length(inputs); i < n; i += data_length )
			array_push(argument_val, getInputData(i + 2));
		
		lua_projectData(_stat);
		addCode();
		
		var res = 0;
		try	     { res = lua_call_w(_stat, _func, argument_val);   } 
		catch(e) { noti_warning(exception_print(e), noone, self); }
		draw_set_alpha(1);
		
		outputs[0].setValue(_stat);
		outputs[1].setValue(res);
	}
	
	static addCode = function() {
		var _func = getInputData(0);
		var _code = getInputData(2);
		argument_name = [];
		
		for( var i = input_fix_len, n = array_length(inputs); i < n; i += data_length )
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
	
	////- Action
	
	static onDestroy = function() /*=>*/ { lua_state_destroy(lua_state); }
	static onRestore = function() /*=>*/ { lua_state = lua_create(); inputs[3].setValue(lua_state); }
}