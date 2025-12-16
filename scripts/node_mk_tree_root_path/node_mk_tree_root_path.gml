function Node_MK_Tree_Path_Root(_x, _y, _group = noone) : Node(_x, _y, _group) constructor {
	name  = "Tree Trunk Path";
	color = COLORS.node_blend_mktree;
	icon  = THEME.mkTree;
	setDrawIcon(s_node_mk_tree_path_root);
	setDimension(96, 48);
	
	newInput( 0, nodeValueSeed());
	
	////- =Path
	newInput( 1, nodeValue_PathNode( "Path",   noone ));
	newInput( 2, nodeValue_Int(      "Sample", 8     ));
	
	////- =Direction
	newInput( 8, nodeValue_Range(  "Wiggle",   [0,0] )).setCurvable(10, CURVE_DEF_11);
	newInput( 9, nodeValue_Range(  "Gravity",  [0,0] ));
	
	////- =Spiral
	newInput(11, nodeValue_Range(  "Frequency", [4,4], true ));
	newInput(12, nodeValue_Range(  "Phase",     [0,0], true ));
	newInput(13, nodeValue_Range(  "Wave",      [0,0], true )).setCurvable(14, CURVE_DEF_11);
	newInput(15, nodeValue_Range(  "Curl",      [0,0], true )).setCurvable(16, CURVE_DEF_11);
	
	////- =Rendering
	newInput( 3, nodeValue_Range(       "Thickness",       [4,4], true )).setCurvable(4, CURVE_DEF_11);
	newInput( 5, nodeValue_Gradient(    "Base Color",      gra_white ));
	newInput(17, nodeValue_Enum_Button( "Length Blending",  0, [ "None", "Override", "Multiply", "Screen" ] ));
	newInput(18, nodeValue_Gradient(    "Length Color",    gra_white ));
	newInput( 6, nodeValue_Enum_Button( "Edge Blending",    0, [ "None", "Override", "Multiply", "Screen" ] ));
	newInput( 7, nodeValue_Gradient(    "L Edge Color",    gra_white ));
	newInput(19, nodeValue_Gradient(    "R Edge Color",    gra_white ));
	newInput(20, nodeValue_Surface(     "Texture" ));
	// input 21
	
	newOutput(0, nodeValue_Output("Trunk", VALUE_TYPE.struct, noone)).setCustomData(global.MKTREE_JUNC);
	
	input_display_list = [ new Inspector_Sprite(s_MKFX), 0, 
		[ "Path",      false ], 1, 2, 
		[ "Direction", false ], 8, 10, 
		[ "Spiral",    false ], 11, 12, 13, 14, 15, 16, 
		[ "Render",    false ], 3, 4, 5, 17, 18, 6, 7, 19, 20, 
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
		
		InputDrawOverlay(inputs[1].drawOverlay(hover, active, _x, _y, _s, _mx, _my, _snx, _sny, _params));
	}
	
	static update = function() {
		if(!is(inline_context, Node_MK_Tree_Inline)) return;
		
		#region data
			var _seed = inline_context.seed + getInputData(0);
			
			var _path = getInputData(1);
			var _samp = getInputData(2);
			
			var _wigg = getInputData( 8);
			var _wigC = getInputData(10),    curve_wiggle = inputs[ 8].attributes.curved? new curveMap(_wigC)  : undefined;
			
			var _sprS = getInputData(11);
			var _sprP = getInputData(12);
			var _wav  = getInputData(13);
			var _wavC = getInputData(14),    curve_wave  = inputs[13].attributes.curved? new curveMap(_wavC)  : undefined;
			
			var _cur  = getInputData(15);
			var _curC = getInputData(16),    curve_curl  = inputs[15].attributes.curved? new curveMap(_curC)  : undefined;
			
			var _thck     = getInputData( 3);
			var _thckC    = getInputData( 4), curve_thick  = inputs[ 3].attributes.curved? new curveMap(_thckC)  : undefined;
			var _baseGrad = getInputData( 5);
			var _lenc     = getInputData(17);
			var _lencGrad = getInputData(18); inputs[18].setVisible(_lenc > 0);
			var _edge     = getInputData( 6);
			var _edgeLGrd = getInputData( 7); inputs[ 7].setVisible(_edge > 0);
			var _edgeRGrd = getInputData(19); inputs[19].setVisible(_edge > 0);
			var _tex      = getInputData(20);
			
		#endregion
		
		if(!is_path(_path)) return;
		random_set_seed(_seed);
		
		var pamo = _path.getLineCount();
		var tres = [];
		var _p   = new __vec2P();
		
		for( var t = 0; t < pamo; t++ ) {
			var _t = new __MK_Tree();
			
			_p = _path.getPointRatio(0, t, _p);
			var nx, ny, dx, dy;
			var ox = _p.x, oy = _p.y;
			var px = ox,   py = oy;
			
			var _thick = random_range(_thck[0], _thck[1]);
			var _spirS = random_range(_sprS[0], _sprS[1]);
			var _spirP = random_range(_sprP[0], _sprP[1]);
			
			var _wavA = random_range(_wav[0], _wav[1]);
			var _curA = random_range(_cur[0], _cur[1]);
			
			_t.x = px; _t.y = py;
			_t.segments[0] = new __MK_Tree_Segment(ox, oy, _thick * (curve_thick? curve_thick.get(0) : 1));
			
			for( var i = 1; i <= _samp; i++ ) {
				var _rat = i / _samp;
				_p = _path.getPointRatio(_rat, t, _p);
				
				nx = _p.x;    
				ny = _p.y;
				
				px = nx;
				py = ny;
				
				var _dir = point_direction(ox, oy, nx, ny);
				
				var _w = random_range(_wigg[0], _wigg[1]) * (curve_wiggle? curve_wiggle.get(_rat) : 1);
				if(_w != 0) {
					px += lengthdir_x(_w, _dir + 90);
					py += lengthdir_y(_w, _dir + 90);
				}
				
				var _wv = _wavA * (curve_wave? curve_wave.get(_rat) : 1);
				if(_wv != 0) {
					var _wLen = cos(_spirP + _rat * pi * _spirS) * _wv;
					px += lengthdir_x(_wLen, _dir + 90);
					py += lengthdir_y(_wLen, _dir + 90);
				}
				
				var _crl = _curA * (curve_curl? curve_curl.get(_rat) : 1);
				if(_crl != 0) {
					var _cLen = sin(_spirP + _rat * pi * _spirS) * _crl;
					px += lengthdir_x(_cLen, _dir);
					py += lengthdir_y(_cLen, _dir);
				}
				
				_t.segments[i] = new __MK_Tree_Segment(px, py, _thick * (curve_thick? curve_thick.get(_rat) : 1));
				
				ox = nx; oy = ny;
			}
			
			
			for( var i = 0; i <= _samp; i++ ) {
				var _rat = i / _samp;
				var _sg  = _t.segments[i];
				var _cc  = _baseGrad.eval(random(1));
				
				switch(_lenc) {
					case 0 : _sg.color = _cc;                                            break;
					case 1 : _sg.color = _lencGrad.eval(random(1));                      break;
					case 2 : _sg.color = colorMultiply( _lencGrad.eval(random(1)), _cc); break;
					case 3 : _sg.color = colorScreen(   _lencGrad.eval(random(1)), _cc); break;
				}
				
				switch(_edge) {
					case 0 : _sg.colorEdgeL = _sg.color;                 
					         _sg.colorEdgeR = _sg.color;                                            break;
					         
					case 1 : _sg.colorEdgeL = _edgeLGrd.eval(random(1)); 
					         _sg.colorEdgeR = _edgeRGrd.eval(random(1));                            break;
					         
					case 2 : _sg.colorEdgeL = colorMultiply( _edgeLGrd.eval(random(1)), _sg.color); 
					         _sg.colorEdgeR = colorMultiply( _edgeRGrd.eval(random(1)), _sg.color); break;
					         
					case 3 : _sg.colorEdgeL = colorScreen(   _edgeLGrd.eval(random(1)), _sg.color); 
					         _sg.colorEdgeR = colorScreen(   _edgeRGrd.eval(random(1)), _sg.color); break;
				}
				
				_sg.colorEdgeL = merge_color(_sg.color, _sg.colorEdgeL, _color_get_alpha(_sg.colorEdgeL));
				_sg.colorEdgeR = merge_color(_sg.color, _sg.colorEdgeR, _color_get_alpha(_sg.colorEdgeR));
				
			}
			
			_t.texture = _tex;
			_t.amount  = array_length(_samp) + 1;
			_t.getLength();
			
			array_push(tres, _t);
		}
		
		outputs[0].setValue(tres);
	}
}