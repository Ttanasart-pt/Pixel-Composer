function Node_Offset(_x, _y, _group = noone) : Node_Processor(_x, _y, _group) constructor {
	name = "Offset";
	
	newInput(0, nodeValue_Surface( "Surface In"   ));
	newInput(1, nodeValue_Slider(  "X Offset", .5 ));
	newInput(2, nodeValue_Slider(  "Y Offset", .5 ));
	
	newActiveInput(3);
		
	input_display_list = [ 3, 
		["Surfaces", true],	0, 
		["Offset",	false],	1, 2, 
	]
	
	newOutput(0, nodeValue_Output("Surface Out", VALUE_TYPE.surface, noone));
	
	////- Node
	
	attribute_surface_depth();
	
	anchor_hovering = 0;
	anchor_dragging = false;
	anchor_drag_sx  = 0;
	anchor_drag_sy  = 0;
	anchor_drag_mx  = 0;
	anchor_drag_my  = 0;
	
	static drawOverlay = function(hover, active, _x, _y, _s, _mx, _my, _snx, _sny, _params) { 
		var _surf = getSingleValue(0);
		if(!is_surface(_surf)) return;
		
		var _dim = surface_get_dimension(_surf);
		var _ofx = getSingleValue(1);
		var _ofy = getSingleValue(2);
		
		var _dx = _x + _ofx * _s * _dim[0];
		var _dy = _y + _ofy * _s * _dim[1];
		
		var hov = hover && point_in_circle(_mx, _my, _dx, _dy, ui(8));
		anchor_hovering = lerp_float(anchor_hovering, bool(hov || anchor_dragging), 5);
		
		if(hov && mouse_lpress(active)) {
			anchor_dragging = true;
			anchor_drag_sx  = _ofx;
			anchor_drag_sy  = _ofy;
			anchor_drag_mx  = _mx;
			anchor_drag_my  = _my;
		}
		
		if(anchor_dragging) {
			var vx = anchor_drag_sx + (_mx - anchor_drag_mx) / _s / _dim[0];
			var vy = anchor_drag_sy + (_my - anchor_drag_my) / _s / _dim[1];
			
			var _edit = false;
			if(inputs[1].setValue(vx)) _edit = true;
			if(inputs[2].setValue(vy)) _edit = true;
			
			if(_edit) UNDO_HOLDING = true;
			
			if(mouse_lrelease()) {
				anchor_dragging = false;
				UNDO_HOLDING    = false;
			}
				
		}
		
		draw_anchor(anchor_hovering, _dx, _dy);
		
		return hov;
	}
	
	static processData = function(_outSurf, _data, _array_index) {
		
		surface_set_shader(_outSurf, sh_offset);
			shader_set_f("offset", -_data[1], -_data[2]);
			
			draw_surface_safe(_data[0]);
		surface_reset_shader();
		
		return _outSurf;
	}
}