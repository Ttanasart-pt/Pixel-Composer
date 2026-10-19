function Node_Device_Input(_x, _y, _group = noone) : Node(_x, _y, _group) constructor {
	name = "Device Input";
	setDimension(96, 48);
	setDrawIcon();
	
	// newInput( 0, nodeValue_EButton( "Device", 0, [ "Mouse", "Keyboard" ] ));
	// 1
	
	newOutput( 0, nodeValue_Output( "Left Mouse Button",   VALUE_TYPE.integer, 0 ));
	newOutput( 1, nodeValue_Output( "Right Mouse Button",  VALUE_TYPE.integer, 0 ));
	newOutput( 2, nodeValue_Output( "Middle Mouse Button", VALUE_TYPE.integer, 0 ));
	
	input_display_list  = [ 0 ];
	output_display_list = [ 0, 1, 2 ];
	
	////- Nodes
	
	attributes.live_update = true;
	array_push(attributeEditors, Node_Attribute("Live update", function() /*=>*/ {return attributes.live_update}, function() /*=>*/ {return new checkBox(function() /*=>*/ {return toggleAttribute("live_update")})}));
	
	static step = function() {
		LIVE_UPDATE = attributes.live_update;
	}
	
	static update = function() {
		
	}
}

