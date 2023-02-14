function Node_Scatter_Points(_x, _y, _group = -1) : Node(_x, _y, _group) constructor {
	name = "Scatter Points";
	color = COLORS.node_blend_number;
	previewable   = false;
	
	w = 96;
	
	inputs[| 0] = nodeValue("Point area", self,   JUNCTION_CONNECT.input, VALUE_TYPE.float, [ def_surf_size / 2, def_surf_size / 2, def_surf_size / 2, def_surf_size / 2, AREA_SHAPE.rectangle ])
		.setDisplay(VALUE_DISPLAY.area);
	
	inputs[| 1] = nodeValue("Point distribution", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, 0)
		.setDisplay(VALUE_DISPLAY.enum_button, [ "Area", "Border", "Map" ])
		.rejectArray();
	
	inputs[| 2] = nodeValue("Scatter", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, 1)
		.setDisplay(VALUE_DISPLAY.enum_button, [ "Uniform", "Random" ])
		.rejectArray();
	
	inputs[| 3] = nodeValue("Point amount", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, 2, "Amount of particle spawn in that frame.")
		.rejectArray();
	
	inputs[| 4] = nodeValue("Distribution map", self, JUNCTION_CONNECT.input, VALUE_TYPE.surface, 0)
		.rejectArray();
	
	inputs[| 5] = nodeValue("Seed", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, irandom(99999))
		.rejectArray();
	
	input_display_list = [ 5, 0, 1, 4, 2, 3 ];
	
	outputs[| 0] = nodeValue("Points", self, JUNCTION_CONNECT.output, VALUE_TYPE.float, [ ])
		.setDisplay(VALUE_DISPLAY.vector);
	
	static step = function() {
		var _dist = inputs[| 1].getValue();
		
		inputs[| 2].setVisible(_dist != 2);
		inputs[| 4].setVisible(_dist == 2, _dist == 2);
	}
	
	static drawOverlay = function(active, _x, _y, _s, _mx, _my, _snx, _sny) {
		inputs[| 0].drawOverlay(active, _x, _y, _s, _mx, _my, _snx, _sny);
	}
	
	function update(frame = ANIMATOR.current_frame) { 
		var _area = inputs[| 0].getValue();
		var _dist = inputs[| 1].getValue();
		var _scat = inputs[| 2].getValue();
		var _amo  = inputs[| 3].getValue();
		var _distMap = inputs[| 4].getValue();
		var _seed = inputs[| 5].getValue();
		var pos;
		
		if(_dist != 2) {
			pos = array_create(_amo);
			for( var i = 0; i < _amo; i++ )
				pos[i] = area_get_random_point(_area, _dist, _scat, i, _amo, _seed++);
		} else {
			pos = [];
			var p = get_points_from_dist(_distMap, _amo, _seed);
			for( var i = 0; i < array_length(p); i++ ) {
				if(p[i] == 0) continue;
				p[i][0] = _area[0] + _area[2] * (p[i][0] * 2 - 1);
				p[i][1] = _area[1] + _area[3] * (p[i][1] * 2 - 1);
				
				array_push(pos, p[i]);
			}
		}
		
		outputs[| 0].setValue(pos);
	}
	
	static onDrawNode = function(xx, yy, _mx, _my, _s) {
		var bbox = drawGetBbox(xx, yy, _s);
		draw_sprite_fit(s_node_scatter_point, 0, bbox.xc, bbox.yc, bbox.w, bbox.h);
	}
}