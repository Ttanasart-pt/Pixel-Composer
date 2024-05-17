function Node_Scatter_Points(_x, _y, _group = noone) : Node(_x, _y, _group) constructor {
	name  = "Scatter Points";
	color = COLORS.node_blend_number;
	
	setDimension(96, 48);
	
	onSurfaceSize = function() { return getInputData(7, DEF_SURF); };
	inputs[| 0] = nodeValue("Point area", self,   JUNCTION_CONNECT.input, VALUE_TYPE.float, DEF_AREA_REF )
		.setUnitRef(onSurfaceSize, VALUE_UNIT.reference)
		.setDisplay(VALUE_DISPLAY.area, { onSurfaceSize });
	
	inputs[| 1] = nodeValue("Point distribution", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, 0)
		.setDisplay(VALUE_DISPLAY.enum_button, [ "Area", "Border", "Map" ])
		.rejectArray();
	
	inputs[| 2] = nodeValue("Scatter", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, 1)
		.setDisplay(VALUE_DISPLAY.enum_button, [ "Uniform", "Random" ])
		.rejectArray();
	
	inputs[| 3] = nodeValue("Point amount", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, 2, "Amount of particle spawn in that frame.")
		.rejectArray();
	
	inputs[| 4] = nodeValue("Distribution map", self, JUNCTION_CONNECT.input, VALUE_TYPE.surface, noone)
		.rejectArray();
	
	inputs[| 5] = nodeValue("Seed", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, seed_random(6))
		.setDisplay(VALUE_DISPLAY._default, { side_button : button(function() { inputs[| 5].setValue(seed_random(6)); }).setIcon(THEME.icon_random, 0, COLORS._main_icon) })
		.rejectArray();
	
	inputs[| 6] = nodeValue("Fixed position", self, JUNCTION_CONNECT.input, VALUE_TYPE.boolean, false, "Fix point position, and only select point in the area.");
	
	inputs[| 7] = nodeValue("Reference dimension", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, DEF_SURF)
		.setDisplay(VALUE_DISPLAY.vector);
	
	inputs[| 8] = nodeValue("Reference value", self, JUNCTION_CONNECT.input, VALUE_TYPE.surface, noone);
	
	inputs[| 9] = nodeValue("Output 3D", self, JUNCTION_CONNECT.input, VALUE_TYPE.boolean, false);
	
	inputs[| 10] = nodeValue("Normal", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, 0)
		.setDisplay(VALUE_DISPLAY.enum_button, [ "X", "Y", "Z" ]);
	
	inputs[| 11] = nodeValue("Plane position", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, 0);
	
	input_display_list = [ 
		["Base",	false], 5, 6, 7, 
		["Scatter",	false], 0, 1, 4, 2, 3, 
		["3D",		 true, 9], 10, 11
	];
	
	outputs[| 0] = nodeValue("Points", self, JUNCTION_CONNECT.output, VALUE_TYPE.float, [ ])
		.setDisplay(VALUE_DISPLAY.vector);
	
	static step = function() { #region
		var _dist = getInputData(1);
		
		inputs[| 2].setVisible(_dist != 2);
		inputs[| 4].setVisible(_dist == 2, _dist == 2);
	} #endregion
	
	static drawOverlay = function(hover, active, _x, _y, _s, _mx, _my, _snx, _sny) { #region
		inputs[| 0].drawOverlay(hover, active, _x, _y, _s, _mx, _my, _snx, _sny);
	} #endregion
	
	static getPreviewValues = function() { return inputs[| 8].getValue(); }
	
	static update = function(frame = CURRENT_FRAME) { #region
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
		
		inputs[| 7].setVisible(_fix);
		var pos = [];
		
		random_set_seed(_seed);
		
		if(_fix) {
			var ref = getInputData(8);
			ref = surface_verify(ref, _fixRef[0], _fixRef[1]);
			inputs[| 8].setValue(ref);
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
		
		outputs[| 0].setValue(pos);
	} #endregion
	
	static onDrawNode = function(xx, yy, _mx, _my, _s, _hover, _focus) { #region
		var bbox = drawGetBbox(xx, yy, _s);
		draw_sprite_fit(s_node_scatter_point, 0, bbox.xc, bbox.yc, bbox.w, bbox.h);
	} #endregion
}