function Node_VFX_effector(_x, _y, _group = noone) : Node(_x, _y, _group) constructor {
	name   = "Affector";
	color  = COLORS.node_blend_vfx;
	icon   = THEME.vfx;
	reloop = true;
	
	manual_ungroupable	 = false;
	node_draw_icon       = s_node_vfx_accelerate;

	setDimension(96, 48);
	
	newInput(0, nodeValue_Particle()).setVisible(true, true);
	
	////- =Area
	
	newInput(1, nodeValue_Area(  "Area",             DEF_AREA_REF )).setUnitRef(function() /*=>*/ {return getDimension()}, VALUE_UNIT.reference);
	newInput(2, nodeValue_Curve( "Falloff",          CURVE_DEF_01 ));
	newInput(3, nodeValue_Float( "Falloff distance", 4            ));
	
	////- =Effect
	
	newInput(8, nodeValueSeed());
	newInput(4, nodeValue_Vec2(           "Effect Vector",    [-1,0] ));
	newInput(5, nodeValue_Float(          "Strength",           1    ));
	newInput(6, nodeValue_Rotation_Range( "Rotate particle",   [0,0] ));
	newInput(7, nodeValue_Vec2_Range(     "Scale particle",    [0,0,0,0], { linked : true } ));
	
	// input 9
	
	array_foreach(inputs, function(i) /*=>*/ {return i.rejectArray()}, 1);
		
	effector_input_length = array_length(inputs);
		
	input_display_list = [ 0,
		["Area",	false], 1, 2, 3,
		["Effect",	false], 8, 4, 5, 6, 7,
	];
	
	newOutput(0, nodeValue_Output("Particles", VALUE_TYPE.particle, -1 ));
	
	////- Nodes
	
	UPDATE_PART_FORWARD
	
	falloff   = CURVE_DEF_01;
	fallDist  = 0;
	
	area_x    = 0; area_y   = 0;
	area_w    = 0; area_h   = 0;
	area_t    = 0;
	
	area_x0   = 0; area_x1  = 0;
	area_y0   = 0; area_y1  = 0;
	
	strength  = 0;
	effectVec = [ 0, 0 ];
	effectVx  = 0; effectVy = 0;
	
	rotate    = [ 0, 0 ];
	rotateX   = 0; rotateY  = 0;
	
	scale     = [ 0, 0, 0, 0 ];
	scaleX0   = 0; scaleX1  = 0;
	scaleY0   = 0; scaleY1  = 0;
	
	seed      = 1;
	
	static getDimension = function() { return is(inline_context, Node_VFX_Group_Inline)? inline_context.dimension : DEF_SURF; }
	
	static drawOverlay  = function(hover, active, _x, _y, _s, _mx, _my, _snx, _sny) {
		InputDrawOverlay(inputs[1].drawOverlay(w_hoverable, active, _x, _y, _s, _mx, _my, _snx, _sny, _params));
		
		var area = getInputData(1);
		var cx = _x + area[0] * _s;
		var cy = _y + area[1] * _s;
		var cw = area[2] * _s;
		var ch = area[3] * _s;
		var cs = area[4];
		
		var fall = getInputData(3) * _s;
		var x0 = cx - cw + fall;
		var x1 = cx + cw - fall;
		var y0 = cy - ch + fall;
		var y1 = cy + ch - fall;
		
		if(x1 > x0 && y1 > y0) {
			draw_set_color(COLORS._main_accent);
			draw_set_alpha(0.5);
			switch(cs) {
				case AREA_SHAPE.elipse :	draw_ellipse_dash(cx, cy, cw + fall * 2, ch + fall * 2); break;	
				case AREA_SHAPE.rectangle :	draw_rectangle_dashed(x0, y0, x1, y1); break;	
			}
			draw_set_alpha(1);
		}
		
		x0 = cx - cw - fall;
		x1 = cx + cw + fall;
		y0 = cy - ch - fall;
		y1 = cy + ch + fall;
		
		if(x1 > x0 && y1 > y0) {
			draw_set_color(COLORS._main_accent);
			draw_set_alpha(0.5);
			switch(cs) {
				case AREA_SHAPE.elipse :	draw_ellipse_dash(cx, cy, cw + fall * 2, ch + fall * 2); break;	
				case AREA_SHAPE.rectangle :	draw_rectangle_dashed(x0, y0, x1, y1); break;	
			}
			draw_set_alpha(1);
		}
	}
	
	static reset        = function() { resetSeed(); }
	static resetSeed    = function() { seed = getInputData(8); }
	
	static onAffect     = function(part, str) {}
	static affect       = function(part) {
		if(!part.active) return;
		
		var _in, _dst;
		var pv = part.getPivot();
		
		if(area_t == AREA_SHAPE.rectangle) {
			_in  =    point_in_rectangle(pv[0], pv[1], area_x0, area_y0, area_x1, area_y1)
			_dst = min(	distance_to_line(pv[0], pv[1], area_x0, area_y0, area_x1, area_y0), 
						distance_to_line(pv[0], pv[1], area_x0, area_y1, area_x1, area_y1), 
						distance_to_line(pv[0], pv[1], area_x0, area_y0, area_x0, area_y1), 
						distance_to_line(pv[0], pv[1], area_x1, area_y0, area_x1, area_y1));
						
		} else if(area_t == AREA_SHAPE.elipse) {
			var _dirr = point_direction(area_x, area_y, pv[0], pv[1]);
			var _epx = area_x + lengthdir_x(area_w, _dirr);
			var _epy = area_y + lengthdir_y(area_h, _dirr);
			
			_in  = point_distance(area_x, area_y, pv[0], pv[1]) < point_distance(area_x, area_y, _epx, _epy);
			_dst = point_distance(pv[0], pv[1], _epx, _epy);
		}
		
		var str = bool(_in);
		if(_dst <= fallDist) {
			var inf = _in? 0.5 + _dst / fallDist : 0.5 - _dst / fallDist;
			str = eval_curve_x(falloff, clamp(inf, 0., 1.));
		}
		
		if(str <= 0) return;
		random_set_seed(part.seed + seed);
		onAffect(part, str);
	}
	
	static update       = function(frame = CURRENT_FRAME) {
		var val = getInputData(0);
		outputs[0].setValue(val);
		
		if(val == noone) return;
		
		var _area = getInputData(1);
		falloff   = getInputData(2);
		fallDist  = getInputData(3);
		
		effectVec = getInputData(4);
		strength  = getInputData(5);
		rotate    = getInputData(6);
		scale     = getInputData(7);
		
		area_x    = _area[0];
		area_y    = _area[1];
		area_w    = _area[2];
		area_h    = _area[3];
		area_t    = _area[4];
		
		area_x0   = area_x - area_w;
		area_x1   = area_x + area_w;
		area_y0   = area_y - area_h;
		area_y1   = area_y + area_h;
		
		effectVx = effectVec[0];	effectVy = effectVec[1];
		rotateX  = rotate[0];		rotateY  = rotate[1];
		scaleX0  = scale[0];		scaleX1  = scale[1];
		scaleY0  = scale[2];		scaleY1  = scale[3];
		
		onVFXUpdate(frame);
		
		////////////////////////////////////////////////////////////////
		
		if(!is_array(val) || array_length(val) == 0) return;
		if(!is_array(val[0])) val = [ val ];
		
		for( var i = 0, n = array_length(val); i < n; i++ )
		for( var j = 0; j < array_length(val[i]); j++ )
			affect(val[i][j]);
	}
	
	static onVFXUpdate  = function(frame = CURRENT_FRAME) {}
	
	static onDrawNode   = function(xx, yy, _mx, _my, _s, _hover, _focus) {
		var bbox = drawGetBbox(xx, yy, _s);
		draw_sprite_fit(node_draw_icon, 0, bbox.xc, bbox.yc, bbox.w, bbox.h);
	}
	
	static getPreviewingNode = function() { return is(inline_context, Node_VFX_Group_Inline)? inline_context.getPreviewingNode() : self; }
	static getPreviewValues  = function() { return is(inline_context, Node_VFX_Group_Inline)? inline_context.getPreviewValues()  : self; }
}