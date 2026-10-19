function Node_Keyboard_Input(_x, _y, _group = noone) : Node(_x, _y, _group) constructor {
	name = "Keyboard Input";
	setDimension(96, 48);
	setDrawIcon();
	
	newInput( 0, nodeValue_EButton( "Update", 0, [ "Always", "On Event" ] ));
	// 1
	
	newOutput( 0, nodeValue_Output( "Keyboard String",  VALUE_TYPE.text, "" ));
	newOutput( 1, nodeValue_Output( "Last Key",         VALUE_TYPE.text, "" ));
	
	input_display_list  = [ 0 ];
	
	////- Nodes
	
	live_update  = 0;
	
	static step = function() {
		LIVE_UPDATE |= live_update == 0;
		
		if(live_update == 1) {
			var _event = keyboard_check_pressed(vk_anykey);
			if(_event) triggerRender();
		}
	}
	
	static update = function() {
		var _updt = inputs[ 0].getValue();
		live_update = _updt;
		
		outputs[0].setValue(KEYBOARD_STRING);
		outputs[1].setValue(keyboard_lastchar);
	}
}
