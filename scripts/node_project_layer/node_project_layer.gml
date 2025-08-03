function Node_Project_Layer(_x, _y, _group = noone) : Node(_x, _y, _group) constructor {
	name = "Layer";
	if(NODE_NEW_MANUAL) name = $"Layer {array_length(project.globalLayer_nodes)}";
	
	newInput(0, nodeValue_Surface( "Surface In"    ));
	newInput(1, nodeValue_Int(     "Depth",      0 ));
	
	////- =Transform
	
	newInput(2, nodeValue_Vec2(     "Position",  [.5,.5] )).setUnitRef(function(i) /*=>*/ {return project.attributes.surface_dimension}, VALUE_UNIT.reference);
	newInput(3, nodeValue_Anchor());
	newInput(4, nodeValue_Rotation( "Rotation",   0      ));
	newInput(5, nodeValue_Vec2(     "Scale",     [1,1]   ));
		
	input_display_list = [ 0, 1, 
		["Transform", false], 2, 3, 4, 5, 
	];
	
	array_foreach(inputs, function(i) /*=>*/ {return i.rejectArray()});
	array_push(project.globalLayer_nodes, self);
	
	////- Nodes
	
	dragging = 0;
	drag_sx  = 0;
	drag_sy  = 0;
	drag_mx  = 0;
	drag_my  = 0;
	
	layer_surf = noone;
	layer_pos  = [0,0];
	layer_anc  = 0;
	layer_rot  = 0;
	layer_sca  = [1,1];
	
	__d0 = [0,0];
	__d1 = [0,0];
	__d2 = [0,0];
	__d3 = [0,0];
	
	draw_transforms = [0,0,1,1,0];
	static drawOverlayTransform = function(_n) /*=>*/ {return draw_transforms};
	
	static drawOverlay = function(hover, active, _x, _y, _s, _mx, _my, _snx, _sny, _params) { 
		if(!is_surface(layer_surf)) return;
		
		var _dim = project.attributes.surface_dimension;
		var _ww  = surface_get_width_safe(layer_surf);
		var _hh  = surface_get_height_safe(layer_surf);
		
		var _sw = _ww * layer_sca[0];
		var _sh = _hh * layer_sca[1];
		
		var _ax = _sw *      layer_anc[0];
		var _ay = _sh *      layer_anc[1];
		var iax = _sw * (1 - layer_anc[0]);
		var iay = _sh * (1 - layer_anc[1]);
		
		var _cx = layer_pos[0];
		var _cy = layer_pos[1];
		
		var _d0 = point_rotate(_cx - _ax, _cy - _ay, _cx, _cy, layer_rot, __d0);
		var _d1 = point_rotate(_cx - _ax, _cy + iay, _cx, _cy, layer_rot, __d1);
		var _d2 = point_rotate(_cx + iax, _cy - _ay, _cx, _cy, layer_rot, __d2);
		var _d3 = point_rotate(_cx + iax, _cy + iay, _cx, _cy, layer_rot, __d3);
		
		_d0 = [ overlay_x(_d0[0], _x, _s), overlay_y(_d0[1], _y, _s) ];
		_d1 = [ overlay_x(_d1[0], _x, _s), overlay_y(_d1[1], _y, _s) ];
		_d2 = [ overlay_x(_d2[0], _x, _s), overlay_y(_d2[1], _y, _s) ];
		_d3 = [ overlay_x(_d3[0], _x, _s), overlay_y(_d3[1], _y, _s) ];
		
		var _hov = hover && point_in_rectangle_points(_mx, _my, _d0[0], _d0[1], _d1[0], _d1[1], _d2[0], _d2[1], _d3[0], _d3[1]);
		var _th  = _hov? 2 : 1;
		
		draw_set_color(_hov? COLORS._main_accent : COLORS._main_icon);
		
		draw_line_round(_d0[0], _d0[1], _d1[0], _d1[1], _th);
		draw_line_round(_d0[0], _d0[1], _d2[0], _d2[1], _th);
		draw_line_round(_d3[0], _d3[1], _d1[0], _d1[1], _th);
		draw_line_round(_d3[0], _d3[1], _d2[0], _d2[1], _th);
		
		if(_hov) {
			
			if(mouse_lpress(active)) {
				dragging = 1;
				
				drag_sx  = layer_pos[0];
				drag_sy  = layer_pos[1];
				drag_mx  = _mx;
				drag_my  = _my;
			}
		}
		
		if(dragging) {
			if(dragging == 1) {
				var _dx = drag_sx + (_mx - drag_mx) / _s;
				var _dy = drag_sy + (_my - drag_my) / _s;
				
				if(inputs[2].setValue([_dx, _dy]))
					UNDO_HOLDING = true;
			}
			
			if(mouse_release(mb_left)) {
				UNDO_HOLDING = false;
				dragging = 0; 
			}
		}
		
		return _hov;
	}
	
	static update = function() {
		layer_surf = inputs[0].getValue();
		layer_pos  = inputs[2].getValue();
		layer_anc  = inputs[3].getValue();
		layer_rot  = inputs[4].getValue();
		layer_sca  = inputs[5].getValue();
		
		draw_transforms[0] = layer_pos[0];
		draw_transforms[1] = layer_pos[1];
		draw_transforms[2] = layer_sca[0];
		draw_transforms[3] = layer_sca[1];
		draw_transforms[4] = layer_rot;
	}
	
	static getPreviewValues       = function() /*=>*/ {return project.globalLayer_surface};
	static getGraphPreviewSurface = function() /*=>*/ {return inputs[0].getValue()};
	
	////- Render
	
	static getNextNodes    = function() /*=>*/ {return project.globalLayer_output};
	static getNextNodesRaw = function() /*=>*/ {return project.globalLayer_output};
	static getNodeTo       = function() /*=>*/ {return project.globalLayer_output};
	
}