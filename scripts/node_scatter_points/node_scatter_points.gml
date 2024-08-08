function Node_Scatter_Points(_x, _y, _group = noone) : Node(_x, _y, _group) constructor {
	name  = "Scatter Points";
	color = COLORS.node_blend_number;
	
	setDimension(96, 48);
	
	onSurfaceSize = function() { return getInputData(7, DEF_SURF); };
	inputs[0] = nodeValue_Area("Point area", self, DEF_AREA_REF, { onSurfaceSize } )
		.setUnitRef(onSurfaceSize, VALUE_UNIT.reference);
	
	inputs[1] = nodeValue_Enum_Button("Point distribution", self,  0, [ "Area", "Border", "Map" ])
		.rejectArray();
	
	inputs[2] = nodeValue_Enum_Button("Scatter", self,  1, [ "Uniform", "Random" ])
		.rejectArray();
	
	inputs[3] = nodeValue_Int("Point amount", self, 2, "Amount of particle spawn in that frame.")
		.rejectArray();
	
	inputs[4] = nodeValue_Surface("Distribution map", self)
		.rejectArray();
	
	inputs[5] = nodeValue_Float("Seed", self, seed_random(6))
		.setDisplay(VALUE_DISPLAY._default, { side_button : button(function() { randomize(); inputs[5].setValue(seed_random(6)); }).setIcon(THEME.icon_random, 0, COLORS._main_icon) })
		.rejectArray();
	
	inputs[6] = nodeValue_Bool("Fixed position", self, false, "Fix point position, and only select point in the area.");
	
	inputs[7] = nodeValue_Vector("Reference dimension", self, DEF_SURF);
	
	inputs[8] = nodeValue_Surface("Reference value", self);
	
	inputs[9] = nodeValue_Bool("Output 3D", self, false);
	
	inputs[10] = nodeValue_Enum_Button("Normal", self,  0, [ "X", "Y", "Z" ]);
	
	inputs[11] = nodeValue_Float("Plane position", self, 0);
	
	input_display_list = [ 
		["Base",	false], 5, 6, 7, 
		["Scatter",	false], 0, 1, 4, 2, 3, 
		["3D",		 true, 9], 10, 11
	];
	
	outputs[0] = nodeValue_Output("Points", self, VALUE_TYPE.float, [ ])
		.setDisplay(VALUE_DISPLAY.vector);
	
	static step = function() {
		var _dist = getInputData(1);
		
		inputs[2].setVisible(_dist != 2);
		inputs[4].setVisible(_dist == 2, _dist == 2);
	}
	
	static drawOverlay = function(hover, active, _x, _y, _s, _mx, _my, _snx, _sny) {
		inputs[0].drawOverlay(hover, active, _x, _y, _s, _mx, _my, _snx, _sny);
	}
	
	static getPreviewValues = function() { return getInputData(8); }
	
	static update = function(frame = CURRENT_FRAME) {
		var _area	 = getInputData(0);
		var _dist	 = getInputData(1);
		var _scat	 = getInputData(2);
		var _amo	 = getInputData(3);
		var _distMap = getInputData(4);
		var _seed	 = getInputData(5);
		var _fix	 = getInputData(6);
		var _fixRef  = getInputData(7);
		
		var _3d = getInputData( 9);
		__temp_3dNorm = getInputData(10);
		__temp_3dPos  = getInputData(11);
		
		inputs[7].setVisible(_fix);
		var pos = [];
		
		random_set_seed(_seed);
		
		if(_fix) {
			var ref = getInputData(8);
			ref = surface_verify(ref, _fixRef[0], _fixRef[1]);
			inputs[8].setValue(ref);
		}
			
		var aBox = area_get_bbox(_area);
			
		if(_dist != 2) {
			pos = [];
			for( var i = 0; i < _amo; i++ ) {
				if(_fix) {
					var p = area_get_random_point([_fixRef[0], _fixRef[1], _fixRef[0], _fixRef[1]], _dist, _scat, i, _amo);
					if(point_in_rectangle(p[0], p[1], aBox[0], aBox[1], aBox[2], aBox[3]))
						array_push(pos, p);
				} else
					pos[i] = area_get_random_point(_area, _dist, _scat, i, _amo);
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
		
		if(_3d)
		pos = array_map(pos, function(value, index) {
			var val = value;
			
			switch(__temp_3dNorm) {
				case 0 : val = [ __temp_3dPos, value[0], value[1] ]; break;
				case 1 : val = [ value[0], __temp_3dPos, value[1] ]; break;
				case 2 : val = [ value[0], value[1], __temp_3dPos ]; break;
			}
			
			return val;
		});
		
		outputs[0].setValue(pos);
	}
	
	static onDrawNode = function(xx, yy, _mx, _my, _s, _hover, _focus) {
		var bbox = drawGetBbox(xx, yy, _s);
		draw_sprite_fit(s_node_scatter_point, 0, bbox.xc, bbox.yc, bbox.w, bbox.h);
	}
}