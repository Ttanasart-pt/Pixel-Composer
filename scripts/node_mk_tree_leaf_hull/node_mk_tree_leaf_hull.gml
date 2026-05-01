function __MK_Tree_Leaf_Hull(_root) : __MK_Tree_Element(_root) constructor {
	vb      = undefined;
	texture = -1;
	
	static drawOverlay = function(_x,_y,_s) /*=>*/ {
		
	}
	
	static draw = function() /*=>*/ {
		if(vb != undefined) 
			vertex_submit(vb, pr_trianglelist, texture);
	}
	
}

function Node_MK_Tree_Leaf_Hull(_x, _y, _group = noone) : Node(_x, _y, _group) constructor {
	name  = "Leaves Hull";
	color = COLORS.node_blend_mktree;
	icon  = THEME.mkTree;
	setDrawIcon(s_node_mk_tree_leaf_hull);
	setDimension(96, 48);
	
	newInput( 1, nodeValueSeed());
	newInput( 0, nodeValue_Struct( "Branches", noone )).setVisible(true, true).setCustomData(global.MKTREE_JUNC);
	
	////- =Spawning
	newInput( 2, nodeValue_Slider( "Chance",   1     ));
	
	////- =Convex Hull
	newInput( 3, nodeValue_Bool(     "Collpase Array", false       ));
	newInput( 4, nodeValue_SliRange( "Trim Path",      [0,1]       ));
	newInput( 5, nodeValue_Range(    "Expands",        [0,0], true ))
		.setCurvable(12, CURVE_DEF_11, "Over Length", "curved", THEME.mk_tree_curve_length );
	
	////- =Color
	
		////- =/per Branch
	newInput( 6, nodeValue_Gradient( "Random Branch",   gra_white )).setMappableConst(7);
	newInput( 8, nodeValue_Gradient( "Along Branch",    gra_white ));
	
		////- =/per Leaf
	newInput( 9, nodeValue_Gradient( "Random Leaf",     gra_white )).setMappableConst(10);
	newInput(11, nodeValue_Gradient( "Along Leaf",      gra_white ));
	// 13
	
	newOutput(0, nodeValue_Output("Branches", VALUE_TYPE.struct, noone)).setCustomData(global.MKTREE_JUNC);
	newOutput(1, nodeValue_Output("Leaves",   VALUE_TYPE.struct, noone)).setCustomData(global.MKTREE_LEAVES_JUNC);
	
	input_display_list = [ new Inspector_Sprite(s_MKFX), 1, 0, 
		[ "Spawning",     false ],  2, 
		[ "Convex Hull",  false ],  3,  4,  5, 12, 
		[ "Color",        false ], 
			[ "/per Branch", false ],  6,  7,  8, 
			// [ "/per Leaf",   false ],  9, 10, 11, 
	];
	
	////- Nodes
	
	static getDimension = function() /*=>*/ {return is(inline_context, Node_MK_Tree_Inline)? inline_context.getDimension() : DEF_SURF};
	
	static drawOverlay = function(hover, active, _x, _y, _s, _mx, _my, _params) { 
		var _resT = outputs[0].getValue();
		if(is_array(_resT)) 
		for( var i = 0, n = array_length(_resT); i < n; i++ ) {
			var _t = _resT[i];
			if(is(_t, __MK_Tree)) _t.drawOverlay(_x, _y, _s);
		}
	}
	
	static update = function() {
		if(!is(inline_context, Node_MK_Tree_Inline)) return;
		
		#region data
			var _seed = inline_context.seed + getInputData(1);
			var _gDir = inline_context.gravityDir;
			
			var _tree = getInputData( 0);
			
			var _chan = getInputData( 2);
			
			var _coll = getInputData( 3);
			var _trim = getInputData( 4);
			
			var _expn = getInputData( 5);
			var _expC = getInputData(12),  curve_expn  = inputs[ 5].attributes.curved? new curveMap(_expC)  : undefined;
			
			var _cBra     = getInputData( 6);
			var _cBraMap  = getInputData( 7);
			var _cBraM    = inputs[ 6].attributes.mapped && is_surface(_cBraMap), _cBraSamp = _cBraM? new Surface_sampler(_cBraMap) : undefined;
			var _cOvrBra  = getInputData( 8);
			
			var _cLef     = getInputData( 9);
			var _cLefMap  = getInputData(10);
			var _cLefM    = inputs[ 9].attributes.mapped && is_surface(_cLefMap), _cLefSamp = _cLefM? new Surface_sampler(_cLefMap) : undefined;
			var _cLefAlo  = getInputData(11); _cLefAlo.cache();
			
			random_set_seed(_seed);
		#endregion
		
		if(array_invalid(_tree)) return;
		var _leaves = [];
		_tree = variable_clone(_tree);
		outputs[0].setValue(_tree);
		outputs[1].setValue(_leaves);
		
		var _x, _y, _u, _v, _c, _a;
		
		if(_coll) {
			var lps = [];
			for( var i = 0, n = array_length(_tree); i < n; i++ ) {
				if(random(1) > _chan) continue;
				
				var _tr = _tree[i];
				var len = array_length(_tr.segments);
				var st = round(_trim[0] * len);
				var ed = round(_trim[1] * len);
				var ll = ed - st;
				if(ll < 3) continue;
				
				for( var j = st; j < ed; j++ ) {
					var _sg = _tr.segments[j];
					array_push(lps, new __vec2(_sg.x, _sg.y));
				}
			}
			
			var ox = lps[0].x;
			var oy = lps[0].y;
			
			var _exp = random_range(_expn[0], _expn[1]);
			
			// var _tris = delaunay_triangulation_c(lps);
			var _hull = polygon_point_get_convex_hull(lps, _exp);
			var _poly = polygon_triangulate(_hull);
			var _tris = _poly[0];
			
			var  cc = _cBraM? _cBraSamp.getPixel(round(ox), round(oy)) : _cBra.eval(random(1));
			var  aa = color_get_alpha(cc);
			
			var _vb = vertex_create_buffer();
			vertex_begin(_vb, FORMAT_2PCT)
				for( var j = 0, m = array_length(_tris); j < m; j++ ) {
					var _tri = _tris[j];
					
					var t0 = _tri[0]; vertex_add_2pct(_vb, t0.x, t0.y, 0, 0, cc, aa);
					var t1 = _tri[1]; vertex_add_2pct(_vb, t1.x, t1.y, 0, 0, cc, aa);
					var t2 = _tri[2]; vertex_add_2pct(_vb, t2.x, t2.y, 0, 0, cc, aa);
				}
			vertex_end(_vb);
				
			var _l  = new __MK_Tree_Leaf_Hull(_tr);
			_l.vb = _vb;
			
			array_push(_tree[0].root.leaves, _l);
			array_push(_leaves, _l);
			
		} else {
			for( var i = 0, n = array_length(_tree); i < n; i++ ) {
				if(random(1) > _chan) continue;
				
				var _tr = _tree[i];
				var _rp = _tr.rootPosition;
				
				var len = array_length(_tr.segments);
				var st = round(_trim[0] * len);
				var ed = round(_trim[1] * len);
				var ll = ed - st;
				if(ll < 3) continue;
				
				var lps = array_create(ll);
				for( var j = st; j < ed; j++ ) {
					var _sg = _tr.segments[j];
					lps[j-st] = new __vec2(_sg.x, _sg.y);
				}
				
				var ox = lps[0].x;
				var oy = lps[0].y;
					
				var _exp = random_range(_expn[0], _expn[1]) * (curve_expn? curve_expn.get(_rp) : 1);
				
				var _hull = polygon_point_get_convex_hull(lps, _exp);
				var _poly = polygon_triangulate(_hull);
				var _tris = _poly[0];
				
				var  cc = _cBraM? _cBraSamp.getPixel(round(ox), round(oy)) : _cBra.eval(random(1));
				     cc = colorMultiply(cc, _cOvrBra.eval(_rp));
				var  aa = color_get_alpha(cc);
				
				var _vb = vertex_create_buffer();
				vertex_begin(_vb, FORMAT_2PCT)
					for( var j = 0, m = array_length(_tris); j < m; j++ ) {
						var _tri = _tris[j];
						
						var t0 = _tri[0]; vertex_add_2pct(_vb, t0.x, t0.y, 0, 0, cc, aa);
						var t1 = _tri[1]; vertex_add_2pct(_vb, t1.x, t1.y, 0, 0, cc, aa);
						var t2 = _tri[2]; vertex_add_2pct(_vb, t2.x, t2.y, 0, 0, cc, aa);
					}
				vertex_end(_vb);
					
				var _l  = new __MK_Tree_Leaf_Hull(_tr);
				_l.vb = _vb;
				
				array_push(_tr.leaves, _l);
				array_push(_leaves, _l);
			}
		}
	}
}