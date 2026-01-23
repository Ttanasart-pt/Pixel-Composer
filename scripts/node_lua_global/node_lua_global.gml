function Node_Lua_Global(_x, _y, _group = noone) : Node(_x, _y, _group) constructor {
	name = "Lua Global";
	preview_channel = 1;
	lua_state = lua_create();
	
	////- =Main
	newInput(0, nodeValue_Text("Lua code")).setDisplay(VALUE_DISPLAY.codeLUA).setTooltip(function() /*=>*/ {return dialogPanelCall(new Panel_Lua_Reference())});
	newInput(2, nodeValue("Execution thread", self, CONNECT_TYPE.input, VALUE_TYPE.node, lua_state)).setVisible(false, true);
	newInput(1, nodeValue_EScroll("Run order",  0, [ "On start", "Every frame" ]));
	// 3
	
	newOutput(0, nodeValue_Output("Execution thread", VALUE_TYPE.node, lua_state ));
	
	input_display_list = [ 
		["Main", false], 2, 1, 0,
	];
	
	////- Nodes
	
	is_beginning = false;
	
	static getState = function() /*=>*/ {return inputs[3].getValue()};
	
	static update = function(frame = CURRENT_FRAME) {
		var _code = getInputData(0);
		var _type = getInputData(1);
		update_on_frame = _type;
		
		var stat = getState();
		
		lua_projectData(stat);
		outputs[0].setValue(stat);
		
		try		 { lua_add_code(stat, _code);         }
		catch(e) { noti_warning(exception_print(e), noone, self); }
	}
	
	static onDestroy = function() /*=>*/ { lua_state_destroy(lua_state); }
	static onRestore = function() /*=>*/ { lua_state = lua_create(); inputs[2].setValue(lua_state); }
}