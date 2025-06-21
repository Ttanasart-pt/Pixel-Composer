#region
	FN_NODE_CONTEXT_INVOKE {
		
	});
#endregion

function Node_Scatter_Point_Lattice(_x, _y, _group = noone) : Node_Processor(_x, _y, _group) constructor {
	name  = "Lattice Point";
	color = COLORS.node_blend_number;
	setDimension(96, 48);
	
	////- =Base
	
	newInput(0, nodeValueSeed()).rejectArray();
	
	////- =Scatter
	
	onSurfaceSize = function() /*=>*/ {return DEF_SURF}; 
	newInput( 1, nodeValue_Area(  "Point area",   DEF_AREA_REF, { onSurfaceSize, useShape : false } )).setUnitRef(onSurfaceSize, VALUE_UNIT.reference);
	newInput( 2, nodeValue_IVec2( "Subdivision",  [2, 2] ));
	// inputs 3
	
	input_display_list = [ 
		["Lattice", false], 1, 2, 
	];
	
	newOutput(0, nodeValue_Output("Points", VALUE_TYPE.float, [ 0, 0 ])).setDisplay(VALUE_DISPLAY.vector);
	
	////- Nodes
	
	static drawOverlay = function(hover, active, _x, _y, _s, _mx, _my, _snx, _sny) {
		var _area = getSingleValue(1);
		var _subd = getSingleValue(2);
		
		var subx = max(_subd[0], 1);
		var suby = max(_subd[1], 1);
		
		var x0 = _x + (_area[0] - _area[2]) * _s, x1 = _x + (_area[0] + _area[2]) * _s;
		var y0 = _y + (_area[1] - _area[3]) * _s, y1 = _y + (_area[1] + _area[3]) * _s;
		
		draw_set_color(COLORS._main_icon);
		for( var i = 1; i < subx; i++ ) {
			var xx = lerp(x0, x1, i / subx);
			draw_line(xx, y0, xx, y1);
		}
		
		for( var i = 1; i < suby; i++ ) {
			var yy = lerp(y0, y1, i / suby);
			draw_line(x0, yy, x1, yy);
		}
		
		InputDrawOverlay(inputs[1].drawOverlay(w_hoverable, active, _x, _y, _s, _mx, _my, _snx, _sny));
		return w_hovering;
	}
	
	static processData = function(_outData, _data, _array_index) {
		#region data
			var _seed = _data[0];
			var _area = _data[1];
			var _subd = _data[2];
		#endregion
		
		random_set_seed(_seed);
		
		var subx = max(_subd[0] + 1, 2);
		var suby = max(_subd[1] + 1, 2);
		
		var amo = subx * suby;
		var pos = array_create(amo);
		
		var x0 = _area[0] - _area[2], x1 = _area[0] + _area[2];
		var y0 = _area[1] - _area[3], y1 = _area[1] + _area[3];
		
		var ww = x1 - x0;
		var hh = y1 - y0;
		
		for( var i = 0; i < amo; i++ ) {
			var _i   = i;
			var _row = floor(_i / subx);
			
			    _i  -= _row * subx;
			var _col = _i;
			
			var _x = lerp(x0, x1, _col / (subx - 1));
			var _y = lerp(y0, y1, _row / (suby - 1));
			
			pos[i] = [ _x, _y ];
		}
		
		return pos;
	}
	
	static onDrawNode = function(xx, yy, _mx, _my, _s, _hover, _focus) {
		var bbox = drawGetBbox(xx, yy, _s);
		draw_sprite_bbox_uniform(s_node_scatter_point_lattice, 0, bbox);
	}
	
}