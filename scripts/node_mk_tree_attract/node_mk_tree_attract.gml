function Node_MK_Tree_Attract(_x, _y, _group = noone) : Node(_x, _y, _group) constructor {
	name  = "Tree Attract";
	color = COLORS.node_blend_mktree;
	icon  = THEME.mkTree;
	setDimension(96, 48);
	
	newInput( 1, nodeValueSeed());
	newInput( 0, nodeValue_Struct("Tree", noone)).setVisible(true, true).setCustomData(global.MKTREE_JUNC);
	
	////- =Attractor
	newInput( 2, nodeValue_Area(   "Area",          DEF_AREA_REF )).setUnitRef(function(i) /*=>*/ {return getDimension()}, VALUE_UNIT.reference);
	newInput( 3, nodeValue_Float(  "Falloff",       0            ));
	newInput( 4, nodeValue_Curve(  "Falloff Curve", CURVE_DEF_01 ));
	
	////- =Effect
	newInput( 6, nodeValue_Enum_Scroll( "Mode",  0, [ "Propagate", "Direct" ] ));
	newInput( 5, nodeValue_Slider(  "Strength",  .2 ));
	// input 6
	
	newOutput(0, nodeValue_Output("Tree", VALUE_TYPE.struct, noone)).setCustomData(global.MKTREE_JUNC);
	
	input_display_list = [ new Inspector_Sprite(s_MKFX), 1, 0, 
		[ "Area",   false ], 2, 3, 4, 
		[ "Effect", false ], 6, 5, 
	];
	
	////- Nodes
	
	static getDimension = function() /*=>*/ {return is(inline_context, Node_MK_Tree_Inline)? inline_context.dimension : [1,1]};
	
	static drawOverlay = function(hover, active, _x, _y, _s, _mx, _my, _snx, _sny, _params) { 
		var _resT = outputs[0].getValue();
		if(is_array(_resT)) 
		for( var i = 0, n = array_length(_resT); i < n; i++ ) {
			var _t = _resT[i];
			if(is(_t, __MK_Tree)) _t.drawOverlay(_x, _y, _s);
		}
		
		var _fall = getInputData(3);
		
		InputDrawOverlay(inputs[2].drawOverlay(w_hoverable, active, _x, _y, _s, _mx, _my, _snx, _sny));
		inputs[2].drawOverlayFallOff(_x, _y, _s, _fall);
	}
	
	static update = function() {
		if(!is(inline_context, Node_MK_Tree_Inline)) return;
		
		var _seed = inline_context.seed + getInputData(1);
		random_set_seed(_seed);
		
		var _tree = getInputData(0);
		    _tree = variable_clone(_tree);
		
		var _area = getInputData(2);
		var _fall = getInputData(3);
		var _falC = getInputData(4);
		
		var _mode = getInputData(6);
		var _str  = getInputData(5);
		
		var cx = _area[0];
		var cy = _area[1];
		var ox, oy, nx, ny;
		
		for( var i = 0, n = array_length(_tree); i < n; i++ ) {
			var _tr   = _tree[i];
			var _segs = _tr.segments;
			var _lens = _tr.segmentLengths;
			
			switch(_mode) {
				case 0 : 
					var _angs = [0];
			
					for( var j = 1, m = array_length(_segs); j < m; j++ ) {
						ox = _segs[j-1].x;
						oy = _segs[j-1].y;
						
						nx = _segs[j].x;
						ny = _segs[j].y;
						
						_angs[j] = point_direction(ox, oy, nx, ny);
					}
					
					var _aa = _angs[0];
					for( var j = 1, m = array_length(_segs); j < m; j++ ) {
						ox = _segs[j-1].x;
						oy = _segs[j-1].y;
				
						nx = ox + lengthdir_x(_lens[j], _angs[j]);
						ny = oy + lengthdir_y(_lens[j], _angs[j]);
						
						var _inf = area_get_point_influence(_area, _fall, _falC, nx, ny);
						    _inf = clamp(_inf * _str, 0, 1);
						
					    _inf = _inf * _inf * _inf;
						_aa = lerp_angle_direct(_aa, point_direction(ox, oy, cx, cy), _inf) + angle_difference(_angs[j], _angs[j-1]);
						
						_segs[j].x = ox + lengthdir_x(_lens[j], _aa);
						_segs[j].y = oy + lengthdir_y(_lens[j], _aa);
					}
					break;
					
				case 1 : 
					for( var j = 1, m = array_length(_segs); j < m; j++ ) {
						nx = _segs[j].x;
						ny = _segs[j].y;
						
						var _inf  = area_get_point_influence(_area, _fall, _falC, nx, ny);
						    _inf *= _str;
						
						_segs[j].x = lerp(nx, cx, _inf);
						_segs[j].y = lerp(ny, cy, _inf);
					}
					break;
			}
			
			_tr.getLength();
		}
		
		outputs[0].setValue(_tree);
	}
	
	static onDrawNode = function(xx, yy, _mx, _my, _s, _hover, _focus) {
		var bbox = drawGetBbox(xx, yy, _s);
		draw_sprite_bbox_uniform(s_node_mk_tree_attract, 0, bbox);
	}
}