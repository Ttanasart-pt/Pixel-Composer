function Node_Scatter_Points(_x, _y, _group = noone) : Node(_x, _y, _group) constructor {
	name = "Scatter Points";
	color = COLORS.node_blend_number;
	previewable   = false;
	
	w = 96;
	
	inputs[| 0] = nodeValue("Point area", self,   JUNCTION_CONNECT.input, VALUE_TYPE.float, [ DEF_SURF_W / 2, DEF_SURF_H / 2, DEF_SURF_W / 2, DEF_SURF_H / 2, AREA_SHAPE.rectangle ])
		.setDisplay(VALUE_DISPLAY.area, function() { return inputs[| 7].getValue(); });
	
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
	
	inputs[| 6] = nodeValue("Fixed position", self, JUNCTION_CONNECT.input, VALUE_TYPE.boolean, false, "Fix point position, and only select point in the area.");
	
	inputs[| 7] = nodeValue("Reference dimension", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, DEF_SURF)
		.setDisplay(VALUE_DISPLAY.vector);
	
	input_display_list = [ 
		["Base",	false], 5, 6, 7, 
		["Scatter",	false], 0, 1, 4, 2, 3, 
	];
	
	outputs[| 0] = nodeValue("Points", self, JUNCTION_CONNECT.output, VALUE_TYPE.float, [ ])
		.setDisplay(VALUE_DISPLAY.vector);
	
	refVal = nodeValue("Reference value", self, JUNCTION_CONNECT.input, VALUE_TYPE.surface, 0);
	
	static step = function() {
		var _dist = inputs[| 1].getValue();
		
		inputs[| 2].setVisible(_dist != 2);
		inputs[| 4].setVisible(_dist == 2, _dist == 2);
	}
	
	static drawOverlay = function(active, _x, _y, _s, _mx, _my, _snx, _sny) {
		inputs[| 0].drawOverlay(active, _x, _y, _s, _mx, _my, _snx, _sny);
	}
	
	static getPreviewValues = function() { return refVal.getValue(); }
	
	function update(frame = PROJECT.animator.current_frame) { 
		var _area	 = inputs[| 0].getValue();
		var _dist	 = inputs[| 1].getValue();
		var _scat	 = inputs[| 2].getValue();
		var _amo	 = inputs[| 3].getValue();
		var _distMap = inputs[| 4].getValue();
		var _seed	 = inputs[| 5].getValue();
		var _fix	 = inputs[| 6].getValue();
		var _fixRef  = inputs[| 7].getValue();
		
		inputs[| 7].setVisible(_fix);
		var pos = [];
		
		if(_fix) {
			var ref = refVal.getValue();
			ref = surface_verify(ref, _fixRef[0], _fixRef[1]);
			refVal.setValue(ref);
		}
			
		var aBox = area_get_bbox(_area);
			
		if(_dist != 2) {
			pos = [];
			for( var i = 0; i < _amo; i++ ) {
				if(_fix) {
					var p = area_get_random_point([_fixRef[0], _fixRef[1], _fixRef[0], _fixRef[1]], _dist, _scat, i, _amo, _seed++);
					if(point_in_rectangle(p[0], p[1], aBox[0], aBox[1], aBox[2], aBox[3]))
						array_push(pos, p);
				} else
					pos[i] = area_get_random_point(_area, _dist, _scat, i, _amo, _seed++);
			}
		} else {
			pos = [];
			var p = get_points_from_dist(_distMap, _amo, _seed, 8);
			for( var i = 0, n = array_length(p); i < n; i++ ) {
				if(p[i] == 0) continue;
				if(_fix) {
					p[i][0] *= _fixRef[0];
					p[i][1] *= _fixRef[1];
				} else {
					p[i][0] = _area[0] + _area[2] * (p[i][0] * 2 - 1);
					p[i][1] = _area[1] + _area[3] * (p[i][1] * 2 - 1);
				}
				
				array_push(pos, p[i]);
			}
		}
		
		outputs[| 0].setValue(pos);
	}
	
	static onDrawNode = function(xx, yy, _mx, _my, _s, _hover, _focus) {
		var bbox = drawGetBbox(xx, yy, _s);
		draw_sprite_fit(s_node_scatter_point, 0, bbox.xc, bbox.yc, bbox.w, bbox.h);
	}
}