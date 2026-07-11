/// @description 
event_inherited();

#region addon
	panels    = {}
	panelMain = Key_Displayer_Settings;
#endregion

#region main
	position  = [1,1];
	
	align_x   = 1;
	align_y   = 1;
	
	dispScale = 1;
	dispAlpha = .25;
	dispColor = c_white;
	
	keyColor  = c_white;
#endregion

#region keys
	name      = "Key display";
	alpha     = 0;
	depth     = -999;
	disp_key  = "";
	disp_keys = [];
	
	last_key  = 0;
	last_char = "";
	
	show_doubleclick = false;
	show_graph		 = false;
	
	menu = [
		menuItem("Toggle double click bar", function() /*=>*/ { show_doubleclick = !show_doubleclick; }),
		menuItem("Toggle graph",            function() /*=>*/ { show_graph       = !show_graph;       }),
	];
	
	mouse_left  = [];
	mouse_right = [];
	
	mouse_pos = [];
#endregion

function serialize()     { 
	var _m = { 
		position : array_clone(position), 
		align_x, 
		align_y,
		
		dispScale, 
		dispAlpha,
		dispColor,
		
		keyColor,
	}; 
	
	return _m;
}
	
function deserialize(_m) {
	position  = array_clone(_m[$ "position"] ?? position);
	align_x   = _m[$ "align_x"]   ?? align_x;
	align_y   = _m[$ "align_y"]   ?? align_y;
	
	dispScale = _m[$ "dispScale"] ?? dispScale;
	dispAlpha = _m[$ "dispAlpha"] ?? dispAlpha;
	dispColor = _m[$ "dispColor"] ?? dispColor;
	
	keyColor  = _m[$ "keyColor"]  ?? keyColor;
	
	return self;
}