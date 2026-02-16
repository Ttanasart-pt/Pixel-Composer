#region
	FN_NODE_CONTEXT_INVOKE {
		addHotkey("Node_Scatter_Points", "Distribution > Toggle", "D", MOD_KEY.none, function() /*=>*/ { GRAPH_FOCUS _n.inputs[1].setValue((_n.inputs[1].getValue() + 1) % 3); });
		addHotkey("Node_Scatter_Points", "Scatter > Toggle",      "S", MOD_KEY.none, function() /*=>*/ { GRAPH_FOCUS _n.inputs[2].setValue((_n.inputs[2].getValue() + 1) % 2); });
		addHotkey("Node_Scatter_Points", "3D > Toggle",           "3", MOD_KEY.none, function() /*=>*/ { GRAPH_FOCUS _n.inputs[9].setValue((_n.inputs[9].getValue() + 1) % 2); });
	});
#endregion

function Node_Scatter_Points(_x, _y, _group = noone) : Node_Processor(_x, _y, _group) constructor {
	name  = "Scatter Points";
	color = COLORS.node_blend_number;
	setDrawIcon(s_node_scatter_points);
	setDimension(96, 48);
	
	dimension_index = -1;
	
	////- =Base
	newInput(5, nodeValueSeed()).rejectArray();
	newInput(6, nodeValue_Bool( "Fixed Position",      false, "Fix point position, and only select point in the area."));
	newInput(7, nodeValue_Vec2( "Reference Dimension", DEF_SURF ));
	
	////- =Scatter
	onSurfaceSize = function() /*=>*/ {return DEF_SURF}; 
	newInput( 0, nodeValue_Area(    "Point area",   DEF_AREA_REF, { onSurfaceSize } )).setHotkey("A").setUnitSimple();
	newInput( 1, nodeValue_EButton( "Distribution", 0, [ "Area", "Border", "Map" ]  )).rejectArray();
	newInput( 4, nodeValue_Surface( "Distribution Map" ));
	
	newInput( 2, nodeValue_EButton( "Scatter",  1, [ "Uniform", "Random", "Poisson", "Golden Spiral" ] )).rejectArray();
	newInput( 3, nodeValue_Int(     "Amount",   2 ));
	newInput(12, nodeValue_Float(   "Distance", 8 )).setValidator(VV_min(0));
	
	////- =3D
	newInput( 8, nodeValue_Surface( "Reference Value"       ));
	newInput( 9, nodeValue_Bool(    "Output 3D",      false ));
	newInput(10, nodeValue_EButton( "Normal",         0, [ "X", "Y", "Z" ] ));
	newInput(11, nodeValue_Float(   "Plane Position", 0 ));
	// inputs 13
	
	newOutput(0, nodeValue_Output("Points", VALUE_TYPE.float, [ 0, 0 ])).setDisplay(VALUE_DISPLAY.vector);
	
	input_display_list = [ 
		[ "Base",    false    ],  5,  6,  7, 
		[ "Scatter", false    ],  0,  1,  4,  2,  3, 12, 
		[ "3D",       true, 9 ], 10, 11
	];
	
	////- Nodes
	
	static drawOverlay = function(hover, active, _x, _y, _s, _mx, _my, _params) { 
		InputDrawOverlay(inputs[0].drawOverlay(w_hoverable, active, _x, _y, _s, _mx, _my));
		return w_hovering;
	}
	
	static processData = function(_outData, _data, _array_index) {
		#region data
			var _seed	 = _data[5];
			var _fix	 = _data[6];
			var _fixRef  = _data[7];
			
			var _area	 = _data[ 0];
			var _dist	 = _data[ 1];
			var _distMap = _data[ 4];
			var _scat	 = _data[ 2];
			var _amo	 = _data[ 3];
			var poisDist = _data[12];
			
			var _3d       = _data[ 9];
			__temp_3dNorm = _data[10];
			__temp_3dPos  = _data[11];
			
			inputs[ 2].setVisible(_dist != 2);
			inputs[ 4].setVisible(_dist == 2, _dist == 2);
			inputs[ 7].setVisible(_fix);
			
			inputs[ 3].setVisible(_scat != 2);
			inputs[12].setVisible(_scat == 2);
		#endregion
		
		if(_amo <= 0) return [];
		
		random_set_seed(_seed);
		
		var aBox = area_get_bbox(_area);
		var pos  = [];
			
		var _fixArea = [ _fixRef[0] / 2, _fixRef[1] / 2, 
	                     _fixRef[0] / 2, _fixRef[1] / 2, 0 ];
	                 
		if(_dist != 2) {
			switch(_scat) {
				case 0 :
				case 1 :
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
					break;
					
				case 2 :
					if(_fix) {
						var pnts = area_get_random_point_poisson_c(_fixArea, poisDist, _seed);
						
						for( var i = 0, n = array_length(pnts); i < n; i++ ) {
							var p = pnts[i];
							if(point_in_rectangle(p[0], p[1], aBox[0], aBox[1], aBox[2], aBox[3]))
								array_push(pos, p);
						} 
						
					} else 
						pos = area_get_random_point_poisson_c(_area, poisDist, _seed);
					break;
					
				case 3 : 
					if(_amo <= 1) break;
					
					pos = array_create(_amo);
					var phi = (1 + sqrt(5)) / 2; // golden ratio
					var cx  = _area[0];
					var cy  = _area[1];
					var cw  = _area[2];
					var ch  = _area[3];
					
					for( var i = 0; i < _amo; i++ ) {
        				var _r = sqrt(i / (_amo - 1));
						var _a = radtodeg(2 * pi * i / phi);
						
						var _x = cx + lengthdir_x(_r * cw, _a);
						var _y = cy + lengthdir_y(_r * ch, _a);
						
						pos[i] = [_x, _y];
					}
					break;
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
		
		if(_3d) pos = array_map(pos, function(v, i) /*=>*/ {
			var val = v;
			
			switch(__temp_3dNorm) {
				case 0 : val = [ __temp_3dPos, v[0], v[1] ]; break;
				case 1 : val = [ v[0], __temp_3dPos, v[1] ]; break;
				case 2 : val = [ v[0], v[1], __temp_3dPos ]; break;
			}
			
			return val;
		});
		
		return pos;
	}
	
}