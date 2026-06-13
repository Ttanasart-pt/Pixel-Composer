function Node_MK_Tree_Bush(_x, _y, _group = noone) : Node(_x, _y, _group) constructor {
	name  = "Bush";
	color = COLORS.node_blend_mktree;
	icon  = THEME.mkTree;
	parameters.inline_draw_input = true;
	setDrawIcon();
	setDimension(96, 48);
	
	newInput( 1, nodeValueSeed());
	
	////- =Spawning
	newInput( 0, nodeValue_Area( "Area", DEF_AREA_REF, false )).setUnitSimple();
	
	////- =Bush
	newInput( 2, nodeValue_EButton( "Scatter",   1, [ "Grid", "Random", "Poisson" ] )).rejectArray();
	newInput( 6, nodeValue_IVec2(   "Grid",     [4,4] ));
	newInput( 3, nodeValue_Int(     "Amount",    32   ));
	newInput( 4, nodeValue_Float(   "Distance",   8   )).setValidator(VV_min(0));
	newInput( 5, nodeValue_Surface( "Sampler"         ));
	
	////- =Leaf
	newInput( 7, nodeValue_Rot(     "Rotation",  90   ));
	// input 8
	
	newOutput(0, nodeValue_Output( "Bush", VALUE_TYPE.struct, noone)).setCustomData(global.MKTREE_JUNC);
	
	input_display_list = [ s_MKFX, 1,
		[ "Spawning", false ],  0, 
		[ "Bush",     false ],  2,  6,  3,  4,  5,  
		[ "Leaf",     false ],  7, 
	];
	
	////- Nodes
	
	bush_sampler = new Surface_Sampler_Grey();
	
	static getDimension = function() /*=>*/ {return is(inline_context, Node_MK_Tree_Inline)? inline_context.getDimension() : DEF_SURF};
	
	static drawOverlay = function(hover, active, _x, _y, _s, _mx, _my, _params) { 
		var _resT = outputs[0].getValue();
		if(is_array(_resT)) 
		for( var i = 0, n = array_length(_resT); i < n; i++ ) {
			var _t = _resT[i];
			if(is(_t, __MK_Tree)) _t.drawOverlay(_x, _y, _s);
		}
		
		InputDrawOverlay(inputs[0].drawOverlay(w_hoverable, active, _x, _y, _s, _mx, _my));
	}
	
	static update = function() {
		if(!is(inline_context, Node_MK_Tree_Inline)) return;
		
		#region data
			var _seed = inline_context.seed + getInputData(1);
			
			var _area = getInputData( 0);
			
			var _dist = getInputData( 2);
			var _grid = getInputData( 6);
			var _amo  = getInputData( 3);
			var _dis  = getInputData( 4);
			var _samp = getInputData( 5);
			
			var _ang  = getInputData( 7);
			
			inputs[ 6].setVisible(_dist == 0);
			inputs[ 3].setVisible(_dist == 1);
			inputs[ 4].setVisible(_dist == 2);
		#endregion
		
		var _x0 = _area[0] - _area[2];
		var _y0 = _area[1] - _area[3];
		var _x1 = _area[0] + _area[2];
		var _y1 = _area[1] + _area[3];
		
		var _bush    = new __MK_Tree();
		_bush.rootDirection = _ang;
		_bush.mode   = MK_TREE_TYPE.points;
		_bush.points = [];
		
		random_set_seed(_seed);
		bush_sampler.setSurface(_samp)
		
		switch(_dist) {
			case 0 : // grid
				var grH = _grid[1];
				var grW = _grid[0];
				
				var sth = 1 / max(1, grH - 1);
				var stw = 1 / max(1, grW - 1);
				
				for( var i = 0; i < grH; i++ ) 
				for( var j = 0; j < grW; j++ ) {
					array_push(_bush.points, [ 
						lerp(_x0, _x1, j * stw), 
						lerp(_y0, _y1, i * sth) 
					]);
				}
				break;
				
			case 1 : // random
				repeat(_amo) {
					array_push(_bush.points, [ 
						random_range(_x0, _x1), 
						random_range(_y0, _y1) 
					]);
				}
				break;
				
			case 2 : // poisson
				var _pos = area_get_random_point_poisson_c(_area, _dis, _seed);
				_bush.points = _pos;
				break;
				
		}
		
		if(bush_sampler.active) {
			var _filt = [];
			for( var i = 0, n = array_length(_bush.points); i < n; i++ ) {
				var _p = _bush.points[i];
				var _s = bush_sampler.getPixelDirectClamp(round(_p[0]), round(_p[1]));
				if(random(1) < _s) array_push(_filt, _p);
			}
			
			_bush.points = _filt;
		}
		
		_bush.pointAmo = array_length(_bush.points);
		outputs[0].setValue([_bush]);
	}
	
}