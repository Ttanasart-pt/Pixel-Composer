function Node_VFX_effector(_x, _y, _group = -1) : Node(_x, _y, _group) constructor {
	name = "Effector";
	previewable = false;
	node_draw_icon = s_node_vfx_accel;
	
	w = 96;
	h = 80;
	min_h = h;
	
	inputs[| 0] = nodeValue(0, "Particles", self, JUNCTION_CONNECT.input, VALUE_TYPE.object, -1 )
		.setVisible(true, true);
	
	inputs[| 1] = nodeValue(1, "Area", self,   JUNCTION_CONNECT.input, VALUE_TYPE.float, [ 16, 16, 4, 4, AREA_SHAPE.rectangle ])
		.setDisplay(VALUE_DISPLAY.area);
	
	inputs[| 2] = nodeValue(2, "Falloff", self, JUNCTION_CONNECT.input, VALUE_TYPE.curve, CURVE_DEF_01 )
		.setDisplay(VALUE_DISPLAY.curve);
	
	inputs[| 3] = nodeValue(3, "Falloff distance", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, 4 );
	
	inputs[| 4] = nodeValue(4, "Effect Vector", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, [ -1, 0 ] )
		.setDisplay(VALUE_DISPLAY.vector);
	
	inputs[| 5] = nodeValue(5, "Strength", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, 1 );
	
	inputs[| 6] = nodeValue(6, "Rotate particle", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, [ 0, 0 ] )
		.setDisplay(VALUE_DISPLAY.rotation_range);
	
	inputs[| 7] = nodeValue(7, "Scale particle", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, [ 0, 0, 0, 0 ] )
		.setDisplay(VALUE_DISPLAY.vector_range);
	
	input_display_list = [ 0,
		["Area",	false], 1, 2, 3,
		["Effect",	false], 4, 5, 6, 7,
	];
	
	outputs[| 0] = nodeValue(0, "Particles", self, JUNCTION_CONNECT.output, VALUE_TYPE.object, -1 );
	
	current_data = [];
	
	static drawOverlay = function(active, _x, _y, _s, _mx, _my, _snx, _sny) {
		inputs[| 1].drawOverlay(active, _x, _y, _s, _mx, _my, _snx, _sny);
		
		var area = inputs[| 1].getValue();
		var cx = _x + area[0] * _s;
		var cy = _y + area[1] * _s;
		var cw = area[2] * _s;
		var ch = area[3] * _s;
		var cs = area[4];
		
		var fall = inputs[| 3].getValue() * _s;
		var x0 = cx - cw + fall;
		var x1 = cx + cw - fall;
		var y0 = cy - ch + fall;
		var y1 = cy + ch - fall;
		
		if(x1 > x0 && y1 > y0) {
			draw_set_color(COLORS._main_accent);
			draw_set_alpha(0.5);
			switch(cs) {
				case AREA_SHAPE.elipse :	draw_ellipse_dash(x0, y0, x1, y1); break;	
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
				case AREA_SHAPE.elipse :	draw_ellipse_dash(x0, y0, x1, y1); break;	
				case AREA_SHAPE.rectangle :	draw_rectangle_dashed(x0, y0, x1, y1); break;	
			}
			draw_set_alpha(1);
		}
	}
	
	function onAffect(part, str) {}
	
	function affect(part) {
		if(!part.active) return;
		
		var _area = current_data[1];
		var _fall = current_data[2];
		var _fads = current_data[3];
		
		var _area_x = _area[0];
		var _area_y = _area[1];
		var _area_w = _area[2];
		var _area_h = _area[3];
		var _area_t = _area[4];
		
		var _area_x0 = _area_x - _area_w;
		var _area_x1 = _area_x + _area_w;
		var _area_y0 = _area_y - _area_h;
		var _area_y1 = _area_y + _area_h;
		
		random_set_seed(part.seed);
		
		var str = 0, in, _dst;
		var pv = part.getPivot();
		
		if(_area_t == AREA_SHAPE.rectangle) {
			in = point_in_rectangle(pv[0], pv[1], _area_x0, _area_y0, _area_x1, _area_y1)
			_dst = min(	distance_to_line(pv[0], pv[1], _area_x0, _area_y0, _area_x1, _area_y0), 
							distance_to_line(pv[0], pv[1], _area_x0, _area_y1, _area_x1, _area_y1), 
							distance_to_line(pv[0], pv[1], _area_x0, _area_y0, _area_x0, _area_y1), 
							distance_to_line(pv[0], pv[1], _area_x1, _area_y0, _area_x1, _area_y1));
		} else if(_area_t == AREA_SHAPE.elipse) {
			var _dirr = point_direction(_area_x, _area_y, pv[0], pv[1]);
			var _epx = _area_x + lengthdir_x(_area_w, _dirr);
			var _epy = _area_y + lengthdir_y(_area_h, _dirr);
			
			in   = point_distance(_area_x, _area_y, pv[0], pv[1]) < point_distance(_area_x, _area_y, _epx, _epy);
			_dst = point_distance(pv[0], pv[1], _epx, _epy);
		}
		
		if(_dst <= _fads) {
			var inf = in? 0.5 + _dst / _fads : 0.5 - _dst / _fads;
			str = eval_curve_bezier_cubic_t(_fall, clamp(inf, 0., 1.));
		} else if(in)
			str = 1;
		
		if(str == 0) return;
		
		onAffect(part, str);
	}
	
	static update = function() {
		var val = inputs[| 0].getValue();
		outputs[| 0].setValue(val);
		if(val == -1) return;
		
		for( var i = 0; i < ds_list_size(inputs); i++ ) {
			current_data[i] = inputs[| i].getValue();
		}
		
		if(!is_array(val[0])) val = [ val ];
		for( var i = 0; i < array_length(val); i++ )
		for( var j = 0; j < array_length(val[i]); j++ ) {
			affect(val[i][j]);
		}
		
		var jun = outputs[| 0];
		for(var j = 0; j < ds_list_size(jun.value_to); j++) {
			if(jun.value_to[| j].value_from == jun)
				jun.value_to[| j].node.doUpdate();
		}
	}
	
	static onDrawNode = function(xx, yy, _mx, _my, _s) {
		var bbox = drawGetBbox(xx, yy, _s);
		draw_sprite_fit(node_draw_icon, 0, bbox.xc, bbox.yc, bbox.w, bbox.h);
	}
}