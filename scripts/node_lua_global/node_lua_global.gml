function Node_Lua_Global(_x, _y, _group = noone) : Node(_x, _y, _group) constructor {
	name = "Lua Global";
	preview_channel = 1;
	
	inputs[| 0]  = nodeValue("Lua code", self, JUNCTION_CONNECT.input, VALUE_TYPE.text, "", o_dialog_lua_reference)
		.setDisplay(VALUE_DISPLAY.codeLUA);
		
	inputs[| 1]  = nodeValue("Run order", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, 0)
		.setDisplay(VALUE_DISPLAY.enum_scroll, [ "On start", "Every frame" ]);
	
	inputs[| 2]  = nodeValue("Execution thread", self, JUNCTION_CONNECT.input, VALUE_TYPE.node, noone)
		.setVisible(false, true);
	
	outputs[| 0] = nodeValue("Execution thread", self, JUNCTION_CONNECT.output, VALUE_TYPE.node, noone );
	
	input_display_list = [ 
		["Main", false], 2, 1, 0,
	];
	
	lua_state    = lua_create();
	is_beginning = false;
	
	static getState = function() { #region
		if(inputs[| 2].isLeaf()) return lua_state;
		return inputs[| 2].value_from.node.getState();
	} #endregion
	
	static update = function(frame = CURRENT_FRAME) { #region
		var _code = getInputData(0);
		var _type = getInputData(1);
		update_on_frame = _type;
		
		lua_projectData(getState());
		
		try		 { lua_add_code(getState(), _code);         }
		catch(e) { noti_warning(exception_print(e),, self); }
	} #endregion
	
	static onDestroy = function() { #region
		lua_state_destroy(lua_state);
		if(error_notification != noone)
			noti_remove(error_notification);
	} #endregion
}