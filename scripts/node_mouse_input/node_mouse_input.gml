function Node_Mouse_Input(_x, _y, _group = noone) : Node(_x, _y, _group) constructor {
	name = "Mouse Input";
	setDimension(96, 48);
	setDrawIcon();
	
	newInput( 0, nodeValue_EButton( "Update", 0, [ "Always", "On Event" ] ));
	// 1
	
	newOutput( 0, nodeValue_Output( "Window Position",  VALUE_TYPE.float,   [0,0] )).setDisplay(VALUE_DISPLAY.vector);
	newOutput( 1, nodeValue_Output( "Preview Position", VALUE_TYPE.float,   [0,0] )).setDisplay(VALUE_DISPLAY.vector);
	newOutput( 2, nodeValue_Output( "Left Button",      VALUE_TYPE.integer,  0    ));
	newOutput( 3, nodeValue_Output( "Right Button",     VALUE_TYPE.integer,  0    ));
	newOutput( 4, nodeValue_Output( "Middle Button",    VALUE_TYPE.integer,  0    ));
	
	input_display_list  = [ 0 ];
	
	////- Nodes
	
	live_update  = 0;
	
	mouse_left   = 0;
	mouse_right  = 0;
	mouse_middle = 0;
	
	static step = function() {
		LIVE_UPDATE |= live_update == 0;
		
		if(live_update == 1) {
			var _event = mouse_click(mb_any) || mouse_release(mb_any);
			if(_event) triggerRender();
		}
	}
	
	static update = function() {
		var _updt = inputs[ 0].getValue();
		live_update = _updt;
		
		var _mouse_lstat = 0;
		var _mouse_rstat = 0;
		var _mouse_mstat = 0;
		
		var _mouse_left   = mouse_lclick();
		var _mouse_right  = mouse_rclick();
		var _mouse_middle = mouse_click(mb_middle);
		
		if(!_mouse_left) {
			if(mouse_left)  _mouse_lstat = -1;
			else            _mouse_lstat =  0;
			
		} else {
			if(!mouse_left) _mouse_lstat =  2;
			else            _mouse_lstat =  1;
		}
		
		if(!_mouse_right) {
			if(mouse_right)  _mouse_rstat = -1;
			else             _mouse_rstat =  0;
			
		} else {
			if(!mouse_right) _mouse_rstat =  2;
			else             _mouse_rstat =  1;
		}
		
		if(!_mouse_middle) {
			if(mouse_middle)  _mouse_mstat = -1;
			else              _mouse_mstat =  0;
			
		} else {
			if(!mouse_middle) _mouse_mstat =  2;
			else              _mouse_mstat =  1;
		}
		
		mouse_left   = _mouse_left;
		mouse_right  = _mouse_right;
		mouse_middle = _mouse_middle;
		
		var px = PANEL_PREVIEW.canvas_mx;
		var py = PANEL_PREVIEW.canvas_my;
		
		outputs[0].setValue([mouse_x, mouse_y]);
		outputs[1].setValue([px, py]);
		
		outputs[2].setValue(_mouse_lstat);
		outputs[3].setValue(_mouse_rstat);
		outputs[4].setValue(_mouse_mstat);
	}
}
