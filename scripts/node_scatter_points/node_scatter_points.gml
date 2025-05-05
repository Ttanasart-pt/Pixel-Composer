#region
	FN_NODE_CONTEXT_INVOKE {
		addHotkey("Node_Scatter_Points", "Distribution > Toggle", "D", MOD_KEY.none, function() /*=>*/ { PANEL_GRAPH_FOCUS_STR _n.inputs[1].setValue((_n.inputs[1].getValue() + 1) % 3); });
		addHotkey("Node_Scatter_Points", "Scatter > Toggle",      "S", MOD_KEY.none, function() /*=>*/ { PANEL_GRAPH_FOCUS_STR _n.inputs[2].setValue((_n.inputs[2].getValue() + 1) % 2); });
		addHotkey("Node_Scatter_Points", "3D > Toggle",           "3", MOD_KEY.none, function() /*=>*/ { PANEL_GRAPH_FOCUS_STR _n.inputs[9].setValue((_n.inputs[9].getValue() + 1) % 2); });
	});
#endregion

function Node_Scatter_Points(_x, _y, _group = noone) : Node(_x, _y, _group) constructor {
	name  = "Scatter Points";
	color = COLORS.node_blend_number;
	setDimension(96, 48);
	
	////- Base
	
	newInput(5, nodeValueSeed(self)).rejectArray();
	newInput(6, nodeValue_Bool( "Fixed Position",      self, false, "Fix point position, and only select point in the area."));
	newInput(7, nodeValue_Vec2( "Reference Dimension", self, DEF_SURF));
	
	////- Scatter
	
	onSurfaceSize = function() /*=>*/ {return DEF_SURF}; 
	newInput( 0, nodeValue_Area(        "Point area",       self, DEF_AREA_REF, { onSurfaceSize } )).setUnitRef(onSurfaceSize, VALUE_UNIT.reference);
	newInput( 1, nodeValue_Enum_Button( "Distribution",     self, 0, [ "Area", "Border", "Map" ])).rejectArray();
	newInput( 4, nodeValue_Surface(     "Distribution Map", self)).rejectArray();
	newInput( 2, nodeValue_Enum_Button( "Scatter",          self, 1, [ "Uniform", "Random", "Poisson" ])).rejectArray();
	newInput( 3, nodeValue_Int(         "Amount",           self, 2, "Amount of particle spawn in that frame.")).rejectArray();
	newInput(12, nodeValue_Float(       "Distance",         self, 8)).setValidator(VV_min(0));
	
	////- 3D
	
	newInput( 8, nodeValue_Surface(     "Reference Value", self));
	newInput( 9, nodeValue_Bool(        "Output 3D",       self, false));
	newInput(10, nodeValue_Enum_Button( "Normal",          self, 0, [ "X", "Y", "Z" ]));
	newInput(11, nodeValue_Float(       "Plane Position",  self, 0));
	
	// inputs 13
	
	input_display_list = [ 
		["Base",	false], 5, 6, 7, 
		["Scatter",	false], 0, 1, 4, 2, 3, 12, 
		["3D",		 true, 9], 10, 11
	];
	
	newOutput(0, nodeValue_Output("Points", self, VALUE_TYPE.float, [ 0, 0 ]))
		.setDisplay(VALUE_DISPLAY.vector);
	
	static drawOverlay = function(hover, active, _x, _y, _s, _mx, _my, _snx, _sny) {
		var hv = inputs[0].drawOverlay(w_hoverable, active, _x, _y, _s, _mx, _my, _snx, _sny); OVERLAY_HV
	}
	
	static update = function(frame = CURRENT_FRAME) {
		var _area	 = getInputData(0);
		var _dist	 = getInputData(1);
		var _scat	 = getInputData(2);
		var _amo	 = getInputData(3);
		var _distMap = getInputData(4);
		var _seed	 = getInputData(5);
		var _fix	 = getInputData(6);
		var _fixRef  = getInputData(7);
		var poisDist = getInputData(12);
		
		var _3d = getInputData( 9);
		__temp_3dNorm = getInputData(10);
		__temp_3dPos  = getInputData(11);
		
		inputs[ 2].setVisible(_dist != 2);
		inputs[ 4].setVisible(_dist == 2, _dist == 2);
		inputs[ 7].setVisible(_fix);
		
		inputs[ 3].setVisible(_scat != 2);
		inputs[12].setVisible(_scat == 2);
		var pos = [];
		
		random_set_seed(_seed);
		
		if(_fix) {
			var ref = getInputData(8);
			ref = surface_verify(ref, _fixRef[0], _fixRef[1]);
			inputs[8].setValue(ref);
		}
			
		var aBox = area_get_bbox(_area);
		pos = [];
			
		if(_scat == 2) {
			pos = area_get_random_point_poisson_c(_area, poisDist, _seed);
			
		} else if(_dist != 2) {
			var _fixArea = [_fixRef[0] / 2, _fixRef[1] / 2, _fixRef[0] / 2, _fixRef[1] / 2, 0];
			
			if(_fix) {
				for( var i = 0; i < _amo; i++ ) {
					var p = area_get_random_point(_fixArea, _dist, _scat, i, _amo, _seed + i * pi);
					if(point_in_rectangle(p[0], p[1], aBox[0], aBox[1], aBox[2], aBox[3]))
						array_push(pos, p);
				} 
				
			} else {
				for( var i = 0; i < _amo; i++ )
					pos[i] = area_get_random_point(_area, _dist, _scat, i, _amo, _seed + i * pi);
			}
			
		} else {
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
		draw_sprite_fit(s_node_scatter_points, 0, bbox.xc, bbox.yc, bbox.w, bbox.h);
	}
}