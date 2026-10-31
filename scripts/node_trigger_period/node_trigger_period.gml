function Node_Trigger_Period(_x, _y, _group = noone) : Node(_x, _y, _group) constructor {
	name = "Trigger Beat";
	update_on_frame = true;
	always_pad      = true;
	
	setDimension(96, 48);
	
	newInput( 0, nodeValue_Bool(  "Active", true ));
	
	////- =Trigger
	newInput( 1, nodeValue_Float( "Period", 2 ));
	newInput( 2, nodeValue_Float( "Shift",  0 ));
	// 3
	
	newOutput( 0, nodeValue_Output( "Trigger", VALUE_TYPE.trigger, false ));
	
	input_display_list = [  0, 
		[ "Trigger", false ],  1,  2, 
	]
	
	////- Node
	
	static update = function() { 
		#region data
			var _act = getInputData( 0);
			
			var _per = getInputData( 1);
			var _shf = getInputData( 2);
		#endregion
		
		var _trg = false;
		
		if(_act) {
			var _frm = CURRENT_FRAME;
			_trg = ((_frm - _shf) % _per + _per) % _per < 1;
		}
		
		outputs[0].setValue(_trg);
	}
	
	////- Draw
	
	static onDrawNode = function(xx, yy, _mx, _my, _s, _hover, _focus) {
		var trg  = outputs[0].getValue();
		draw_sprite_bbox_uniform(THEME.node_trigger_icon, trg, draw_bbox, trg? COLORS._main_value_positive : COLORS._main_icon);
	}
	
	static drawAnimationTimeline = function(_x, _w, _h, _s) {
		var _per = getInputData( 1);
		var _shf = getInputData( 2);
			
		draw_set_color(COLORS._main_value_positive);
		draw_set_alpha(1);
		
		_shf = ((_shf % _per) + _per) % _per;
		var _amo = ceil(TOTAL_FRAMES / _per);
		
		for( var i = 0; i < _amo; i++ ) {
			var xx = _x + (_shf + i * _per + 1) * _s;
			draw_line_width(xx, 0, xx, _h, ui(1));
		}
	}
	
}