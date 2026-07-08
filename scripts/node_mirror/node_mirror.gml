#region
	FN_NODE_CONTEXT_INVOKE {
		addHotkey("Node_Mirror", "Angle > Rotate CCW", "R", MOD_KEY.none, function() /*=>*/ { GRAPH_FOCUS _n.inputs[2].setValue((_n.inputs[2].getValue() + 90) % 360); });
		addHotkey("Node_Mirror", "Flip > Toggle",      "F", MOD_KEY.none, function() /*=>*/ { GRAPH_FOCUS _n.inputs[5].setValue(!_n.inputs[5].getValue());             });
		addHotkey("Node_Mirror", "Both Side > Toggle", "S", MOD_KEY.none, function() /*=>*/ { GRAPH_FOCUS _n.inputs[4].setValue(!_n.inputs[4].getValue());             });
	});
#endregion

function Node_Mirror(_x, _y, _group = noone) : Node_Processor(_x, _y, _group) constructor {
	name = "Mirror";
	
	newActiveInput(3);
	
	////- =Surfaces
	newInput( 0, nodeValue_Surface( "Surface In" ));
	
	////- =Mirror
	newInput( 1, nodeValue_Vec2(     "Position", [.5,.5] )).setHotkey("G").setUnitSimple().setPieMenu();
	newInput( 2, nodeValue_Rotation( "Angle",     0      )).setHotkey("R").hideLabel().setPieMenu();
	newInput( 5, nodeValue_Bool(     "Flip",      false  )).setPieMenu();
	newInput( 4, nodeValue_Bool(     "Both Side", false  )).setPieMenu();
	// input 6
	
	newOutput( 0, nodeValue_Output( "Surface Out", VALUE_TYPE.surface, noone ));
	newOutput( 1, nodeValue_Output( "Mirror Mask", VALUE_TYPE.surface, noone )).setCustomData(global.SURFACE_MASK_JUNC);
	
	input_display_list = [ 3,
		[ "Surfaces", false ],  0, 
		[ "Mirror",   false ],  1,  2,  5,  4, 
	];
	
	////- Node
	
	attribute_surface_depth();
	
	static drawOverlay = function(hover, active, _x, _y, _s, _mx, _my, _params) { 
		PROCESSOR_OVERLAY_CHECK
		
		var _pos  = current_data[ 1];
		var _ang  = current_data[ 2];
		var _flp  = current_data[ 5];
		    _ang += _flp * 180;
		
		var _posx = _pos[0] * _s + _x;
		var _posy = _pos[1] * _s + _y;
		
		var dx0 = _posx + lengthdir_x(1000, _ang);
		var dy0 = _posy + lengthdir_y(1000, _ang);
		
		var dx1 = _posx + lengthdir_x(1000, _ang + 180);
		var dy1 = _posy + lengthdir_y(1000, _ang + 180);
		
		var dxp = _posx + lengthdir_x(ui(64), _ang - 90);
		var dyp = _posy + lengthdir_y(ui(64), _ang - 90);
		
		draw_set_color(COLORS._main_accent);
		draw_line(dx0, dy0, dx1, dy1);
		draw_arrow(_posx, _posy, dxp, dyp, ui(16));
		
		drawOverlayInput(inputs[1].drawOverlay(w_hoverable, active, _x, _y, _s, _mx, _my));
		drawOverlayInput(inputs[2].drawOverlay(w_hoverable, active, _posx, _posy, _s, _mx, _my));
		
		return w_hovering;
	}
	
	static processData = function(_outData, _data, _array_index) {
		#region data
			var _suf = _data[ 0];
			
			var _pos = _data[ 1];
			var _ang = _data[ 2];
			var _inv = _data[ 5];
			var _bth = _data[ 4];
			
			if(!is_surface(_suf)) return _outData;
		#endregion
		
		var _dim = surface_get_dimension(_suf);
		_outData[0] = surface_verify(_outData[0], _dim[0], _dim[1]);
		_outData[1] = surface_verify(_outData[1], _dim[0], _dim[1]);
		
		surface_set_shader(_outData, sh_mirror);
			shader_set_f( "dimension", _dim );
			shader_set_2( "position",  _pos );
			shader_set_f( "angle",     _ang );
			shader_set_i( "bothSide",  _bth );
			shader_set_i( "invert",    _inv );
			
			draw_surface_safe(_suf);
		surface_reset_shader();
		
		return _outData;
	}
}