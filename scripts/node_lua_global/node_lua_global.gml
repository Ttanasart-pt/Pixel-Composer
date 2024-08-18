function Node_Lua_Global(_x, _y, _group = noone) : Node(_x, _y, _group) constructor {
	name = "Lua Global";
	preview_channel = 1;
	
	newInput(0, nodeValue_Text("Lua code", self, "", o_dialog_lua_reference))
		.setDisplay(VALUE_DISPLAY.codeLUA);
		
	newInput(1, nodeValue_Enum_Scroll("Run order", self,  0, [ "On start", "Every frame" ]));
	
	newInput(2, nodeValue("Execution thread", self, JUNCTION_CONNECT.input, VALUE_TYPE.node, noone))
		.setVisible(false, true);
	
	outputs[0] = nodeValue_Output("Execution thread", self, VALUE_TYPE.node, noone );
	
	input_display_list = [ 
		["Main", false], 2, 1, 0,
	];
	
	lua_state    = lua_create();
	is_beginning = false;
	
	static getState = function() {
		if(inputs[2].value_from == noone) return lua_state;
		return inputs[2].value_from.node.getState();
	}
	
	static update = function(frame = CURRENT_FRAME) {
		var _code = getInputData(0);
		var _type = getInputData(1);
		update_on_frame = _type;
		
		lua_projectData(getState());
		
		try		 { lua_add_code(getState(), _code);         }
		catch(e) { noti_warning(exception_print(e),, self); }
	}
	
	static onDestroy = function() { lua_state_destroy(lua_state); }
	static onRestore = function() { lua_state = lua_create(); }
}