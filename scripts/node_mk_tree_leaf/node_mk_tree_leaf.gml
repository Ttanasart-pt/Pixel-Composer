function Node_MK_Tree_Leaf(_x, _y, _group = noone) : Node(_x, _y, _group) constructor {
	name  = "Tree Leaves";
	color = COLORS.node_blend_mktree;
	icon  = THEME.mkTree;
	setDrawIcon(s_node_mk_tree_leaf);
	setDimension(96, 48);
	
	newInput(5, nodeValueSeed());
	newInput(0, nodeValue_Struct("Branches", noone)).setVisible(true, true).setCustomData(global.MKTREE_JUNC);
	
	////- =Leaf
	newInput( 1, nodeValue_Slider_Range( "Leaf Position",   [.5,1] ));
	newInput(35, nodeValue_Bool(    "Apply to Property Curves", false )).setTooltip("Set the 'Over Branch' property to use 'Leaf Position' range or total range.");
	newInput(19, nodeValue_EButton( "Distribution",     0, [ "Random", "Uniform" ] ));
	
	newInput( 2, nodeValue_Range( "Amount",  [8,16]        ));
	newInput( 7, nodeValue_Range( "Spread",  [90,90], true )).setCurvable(16, CURVE_DEF_11, "Over Branch", "curved", THEME.mk_tree_curve_branch );
	newInput(27, nodeValue_Range( "Gravity", [0,0],   true )).setCurvable(28, CURVE_DEF_11, "Over Branch", "curved", THEME.mk_tree_curve_branch );
	newInput(10, nodeValue_Range( "Offset",  [0,0],   true )).setCurvable(17, CURVE_DEF_11, "Over Branch", "curved", THEME.mk_tree_curve_branch );
	
	////- =Grouping
	newInput(15, nodeValue_Range( "Whorled", [0,0],   true )).setCurvable(36, CURVE_DEF_11, "Over Branch", "curved", THEME.mk_tree_curve_branch );
	newInput(32, nodeValue_Float( "Whorled Angle",  0.1    )).setCurvable(33, CURVE_DEF_11, "Over Branch", "curved", THEME.mk_tree_curve_branch );
	
	////- =Shape
	shape_types = [ "Leaf", "Complex Leaf", "Line", "Circle", "Surface", "Mesh" ];
	newInput( 8, nodeValue_EScroll( "Shape", MKLEAF_TYPE.Leaf, shape_types ))
		.setHistory([ shape_types, 
			{ cond: function() /*=>*/ {return LOADING_VERSION < 1_20_02_0}, list: [ "Leaf", "Circle", "Surface", "Line" ] }, 
		]);
	newInput( 3, nodeValue_Vec2_Range( "Size",          [4,4,2,2]     ))
		.setCurvable(18, CURVE_DEF_11, "Over Branch",  "curved",         THEME.mk_tree_curve_branch  )
		.setCurvable(43, CURVE_DEF_11, "Over Whorled", "curved_whorled", THEME.mk_tree_curve_whorled )
		
	newInput( 9, nodeValue_Surface(    "Texture",       noone         ));
	newInput(21, nodeValue_Slider(     "Leaf Span",     .5            ));
	newInput(39, nodeValue_EButton(    "Geometry Type",  0, [ "Single", "Range" ] ));
	newInput(29, nodeValue_Curve(      "Geometry",      CURVE_DEF_01  ));
	newInput(38, nodeValue_Curve(      "Geometry2",     CURVE_DEF_01  ));
	newInput(31, nodeValue_Range(      "Shape Gravity", [.1,.1], true ))
		.setCurvable(37, CURVE_DEF_11, "Over Branch",  "curved",         THEME.mk_tree_curve_branch  )
		.setCurvable(44, CURVE_DEF_11, "Over Whorled", "curved_whorled", THEME.mk_tree_curve_whorled )
		
	newInput(40, nodeValue_Range(      "Twist",         [0,0], true  ))
		.setCurvable(45, CURVE_DEF_11, "Over Branch",  "curved",         THEME.mk_tree_curve_branch  )
		.setCurvable(46, CURVE_DEF_11, "Over Whorled", "curved_whorled", THEME.mk_tree_curve_whorled )
		
	newInput(41, nodeValue_Mesh(       "Mesh"                        ));
	newInput(30, nodeValue_Int(        "Resolution",     6           ));
	
	////- =Color
	newInput( 4, nodeValue_Gradient( "Random Branch",   gra_white )).setMappableConst(12);
	newInput(20, nodeValue_Gradient( "Along Branch",    gra_white ));
	newInput( 6, nodeValue_Gradient( "Random Leaf",     gra_white )).setMappableConst(13);
	newInput(34, nodeValue_Gradient( "Along Leaf",      gra_white ));
	newInput(42, nodeValue_Gradient( "Random Whorled",  gra_white ));
	newInput(47, nodeValue_Gradient( "Along Whorled",   gra_white ));
	
	////- =Edge
	newInput(14, nodeValue_EButton(  "Render Edge",     0, [ "None", "Override", "Multiply", "Screen" ] ));
	newInput(11, nodeValue_Gradient( "Edge Color",      gra_white )).setMappableConst(25);
	newInput(23, nodeValue_EButton(  "Render Top Edge", 0, [ "None", "Override", "Multiply", "Screen" ] ));
	newInput(24, nodeValue_Gradient( "Top Edge Color",  gra_white )).setMappableConst(26);
	
	////- =Growth
	newInput(22, nodeValue_Range( "Grow Delay", [0,0], true ));
	// input 48
	
	newOutput(0, nodeValue_Output("Branches", VALUE_TYPE.struct, noone)).setCustomData(global.MKTREE_JUNC);
	newOutput(1, nodeValue_Output("Leaves",   VALUE_TYPE.struct, noone)).setCustomData(global.MKTREE_LEAVES_JUNC);
	
	input_display_list = [ new Inspector_Sprite(s_MKFX), 5, 0, 
		[ "Leaf",     false ],  1, 35, 19,  2,  7, 16, 27, 28, 10, 17, 
		[ "Grouping", false ], 15, 36, 32, 33, 
		[ "Shape",    false ],  8,  3, 18, 43,  9, 21, 39, 29, 38, 31, 37, 44, 40, 45, 46, 41, 30, 
		[ "Color",    false ],  4, 20, 12,  6, 13, 34, 42, 47, 
			new Inspector_Spacer(ui(4), true, true, ui(6)), 14, 11, 25, 23, 24, 26, 
		[ "Growth",   false ], 22, 
	];
	
	amountUnitToggle  = button(function() /*=>*/ { inputs[2].attributes.unit = !inputs[2].attributes.unit; triggerRender(); })
		.setIcon(THEME.mk_tree_leaf_unit).iconPad()
		.setTooltip(new tooltipSelector("Unit", [ "Fixed Amount", "Leaf Distance" ]), function() /*=>*/ {return inputs[2].attributes.unit});
	
	inputs[2].attributes.unit = VALUE_UNIT.constant;
	inputs[2].getEditWidget().setSideButton(amountUnitToggle);
	
	////- Nodes
	
	static getDimension = function() /*=>*/ {return is(inline_context, Node_MK_Tree_Inline)? inline_context.getDimension() : [1,1]};
	
	static drawOverlay = function(hover, active, _x, _y, _s, _mx, _my, _snx, _sny, _params) { 
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
			var _seed = inline_context.seed + getInputData(5);
			var _gDir = inline_context.gravityDir;
			random_set_seed(_seed);
			
			var _tree = getInputData( 0);
			
			var _amou = getInputData( 2);
			var _auni = inputs[2].attributes.unit;
			inputs[2].setName(_auni? "Distance" : "Amount");
			amountUnitToggle.icon_index = _auni;
			
			var _pos  = getInputData( 1);
			var _clam = getInputData(35);
			var _dist = getInputData(19);
			var _sprd = getInputData( 7);
			var _sprC = getInputData(16), curve_spread = inputs[ 7].attributes.curved? new curveMap(_sprC)  : undefined;
			var _grav = getInputData(27);
			var _graC = getInputData(28), curve_garvit = inputs[27].attributes.curved? new curveMap(_graC)  : undefined;
			var _offs = getInputData(10);
			var _offC = getInputData(17), curve_offset = inputs[10].attributes.curved? new curveMap(_offC)  : undefined;
			
			var _whor = getInputData(15);
			var _whoC = getInputData(36), curve_whorl  = inputs[15].attributes.curved? new curveMap(_whoC)  : undefined;
			var _whra = getInputData(32), 
			var _whrC = getInputData(33), curve_whorla = inputs[32].attributes.curved? new curveMap(_whrC)  : undefined;
			
			var _shap = getInputData( 8);
			var _siz  = getInputData( 3);
			var _sizC = getInputData(18), curve_size   = inputs[ 3].attributes.curved?         new curveMap(_sizC)  : undefined;
			var _sizW = getInputData(43), curve_sizeW  = inputs[ 3].attributes.curved_whorled? new curveMap(_sizW)  : undefined;
			var _tex  = getInputData( 9);
			var _lspn = getInputData(21);
			
			var _geoSc = getInputData(39);
			var _lgeo  = getInputData(29);
			var _lgeo2 = getInputData(38);
			
			var _geoG = getInputData(31);
			var _geGC = getInputData(37), curve_geog   = inputs[31].attributes.curved?         new curveMap(_geGC)  : undefined;
			var _geGW = getInputData(44), curve_geogW  = inputs[31].attributes.curved_whorled? new curveMap(_geGW)  : undefined;
			
			var _gtws = getInputData(40);
			var _gtwC = getInputData(45), curve_geot   = inputs[40].attributes.curved?         new curveMap(_gtwC)  : undefined;
			var _gtwW = getInputData(46), curve_geotW  = inputs[40].attributes.curved_whorled? new curveMap(_gtwW)  : undefined;
			
			var _mesh = getInputData(41); if(!is(_mesh, Mesh)) _mesh = undefined;
			var _lres = getInputData(30);
			
			var _cBra     = getInputData( 4);
			var _cBraMap  = getInputData(12);
			var _cBraM    = inputs[ 4].attributes.mapped && is_surface(_cBraMap), _cBraSamp = _cBraM? new Surface_sampler(_cBraMap) : undefined;
			
			var _cOvrBra  = getInputData(20);
			
			var _cLef     = getInputData( 6);
			var _cLefMap  = getInputData(13);
			var _cLefM    = inputs[ 6].attributes.mapped && is_surface(_cLefMap), _cLefSamp = _cLefM? new Surface_sampler(_cLefMap) : undefined;
			var _cLefAlo  = getInputData(34); _cLefAlo.cache();
			var _cWhor    = getInputData(42); _cWhor.cache();
			var _cWhorAlo = getInputData(47); _cWhorAlo.cache();
			
			var _edg      = getInputData(14);
			var _edgC     = getInputData(11);
			var _cEdgMap  = getInputData(25);
			var _cEdgM    = inputs[11].attributes.mapped && is_surface(_cEdgMap), _cEdgSamp = _cEdgM? new Surface_sampler(_cEdgMap) : undefined;
			
			var _edt      = getInputData(23);
			var _edtC     = getInputData(24); _edtC.cache();
			var _cEdtMap  = getInputData(26);
			var _cEdtM    = inputs[24].attributes.mapped && is_surface(_cEdtMap), _cEdtSamp = _cEdtM? new Surface_sampler(_cEdtMap) : undefined;
			
			var _grow = getInputData(22);
			
			inputs[21].setVisible(_shap == MKLEAF_TYPE.Leaf);
			inputs[23].setVisible(_shap == MKLEAF_TYPE.Leaf);
			inputs[24].setVisible(_shap == MKLEAF_TYPE.Leaf && _edt);
			
			inputs[29].setVisible(_shap == MKLEAF_TYPE.Complex_Leaf);
			inputs[39].setVisible(_shap == MKLEAF_TYPE.Complex_Leaf);
			inputs[38].setVisible(_geoSc && _shap == MKLEAF_TYPE.Complex_Leaf);
			
			inputs[31].setVisible(_shap == MKLEAF_TYPE.Complex_Leaf);
			inputs[30].setVisible(_shap == MKLEAF_TYPE.Complex_Leaf || _shap == MKLEAF_TYPE.Line); 
			inputs[31].setVisible(_shap == MKLEAF_TYPE.Complex_Leaf || _shap == MKLEAF_TYPE.Line); 
			inputs[40].setVisible(_shap == MKLEAF_TYPE.Complex_Leaf);
			
			inputs[ 9].setVisible(_shap == MKLEAF_TYPE.Surface, _shap == MKLEAF_TYPE.Surface);
			inputs[11].setVisible(_shap != MKLEAF_TYPE.Surface && _edg);
			
			inputs[41].setVisible(_shap == MKLEAF_TYPE.Mesh, _shap == MKLEAF_TYPE.Mesh);
			
			var _geo  = undefined;
			var _geo2 = undefined;
			
			if(_shap == MKLEAF_TYPE.Complex_Leaf) {
				_geo = new curveMap(_lgeo, _lres + 1);
				if(_geoSc) _geo2 = new curveMap(_lgeo2, _lres + 1);
			}
			
		#endregion
		
		var ox, oy, nx, ny;
		var __p0 = min(_pos[0], _pos[1]);
		var __p1 = max(_pos[0], _pos[1]);
		var _leaves = [];
		
		var tw = surface_get_width_safe(_tex);
		var th = surface_get_height_safe(_tex);
		
		_tree = variable_clone(_tree);
		outputs[0].setValue(_tree);
		outputs[1].setValue(_leaves);
		
		var _prng = __p1 - __p0;
		if(__p1 < __p0) return;
		
		for( var i = 0, n = array_length(_tree); i < n; i++ ) {
			random_set_seed(_seed + i * 100);
			var _br = _tree[i];
			
			var _amoR = random_range(_amou[0], _amou[1]);
			if(_auni) _amoR = _br.totalLength / _amoR; // density
			_amoR = round(_amoR);
			if(_amoR <= 0) continue;
			
			var _positions = array_create(_amoR);
			var _posCursor = 0;
			
			for( var j = 0; j < _amoR; j++ ) {
				var _p = 0;
				     if(_dist == 0) _p = random_range(__p0, __p1);
				else if(_dist == 1) _p = _amoR == 1? .5 : lerp(__p0, __p1, j / (_amoR - 1));
				_positions[j] = _p;
			}
			
			if(_dist == 0) array_sort(_positions, true);
			
			var _sg = _br.segments;
			var _sn = array_length(_sg);
			var  cc = _cBraM? _cBraSamp.getPixel(round(ox), round(oy)) : _cBra.eval(random(1));
			
			var _sprdB = random_range(_sprd[0], _sprd[1]);
			
			for( var j = 1; j < _sn; j++ ) {
				var _r0 = _br.segmentRatio[j - 1];
				var _r1 = _br.segmentRatio[j    ];
				
				if(_r1 <= _r0) continue;
				if(_r1 < _positions[_posCursor]) continue;
				
				ox = _sg[j-1].x;
				oy = _sg[j-1].y;
				
				nx = _sg[j].x;
				ny = _sg[j].y;
				
				var brnDir = point_direction(ox, oy, nx, ny);
				
				while(_positions[_posCursor] <= _r1) {
					var _rPos = _positions[_posCursor];
					var _cPos = _clam? (_prng == 0? 1 : (_rPos - __p0) / _prng) : _rPos;
					
					var _rr = (_rPos - _r0) / (_r1 - _r0);
					var _lx = lerp(ox, nx, _rr); 
					var _ly = lerp(oy, ny, _rr); 
					
					var _spra = _sprdB * choose(-1, 1) * (curve_spread? curve_spread.get(_cPos) : 1);
					var _dr   = brnDir + _spra;
					
					var _ggv  = random_range(_grav[0], _grav[1]);
					var _grv  = _ggv * (curve_garvit? curve_garvit.get(_cPos) : 1);
					_dr = lerp_angle_direct(_dr, _gDir, _grv);
					
					var _sh = random_range(_offs[0], _offs[1]) * (curve_offset? curve_offset.get(_cPos) : 1);
					_lx += lengthdir_x(_sh, brnDir + 90);
					_ly += lengthdir_y(_sh, brnDir + 90);
					
					var lss = curve_size? curve_size.get(_cPos) : 1;
					var lsx = random_range(_siz[0], _siz[1]) * lss;
					var lsy = random_range(_siz[2], _siz[3]) * lss;
					var lc  = _cLefM? _cLefSamp.getPixel(round(_lx), round(_ly)) : _cLef.eval(random(1));
					    lc  = colorMultiply(lc, _cOvrBra.eval(_cPos));
					    lc  = colorMultiply(lc, cc);
					var lwc = colorMultiply(lc, _cWhor.evalFast(random(1)));
					    
					var _geg = random_range(_geoG[0], _geoG[1]) * (curve_geog? curve_geog.get(_cPos) : 1);
					var _get = random_range(_gtws[0], _gtws[1]) * (curve_geot? curve_geot.get(_cPos) : 1);
					
					var _l = new __MK_Tree_Leaf(_rPos, _shap, _lx, _ly, _dr, lsx, lsy, _lspn);
					    _l.gravity    = _gDir;
					    _l.surface    = _tex;
					    _l.surf_w     =  tw;
					    _l.surf_h     =  th;
					    
					    _l.color      = lwc;
					    _l.colorLeaf  = _cLefAlo;
					    _l.growShift  = random_range(_grow[0], _grow[1]);
					    _l.geoGrav    = _geg;
					    _l.geoTwist   = _get;
					    _l.resolution = _lres;
					    _l.mesh       = _mesh;
					     
				   if(_shap == MKLEAF_TYPE.Complex_Leaf) {
					    _l.geometry   = _geo;
					    _l.geometry1  = _geo2;
				   }
					
					if(_edg == 0) {
						_l.colorE = _l.color;
						
					} else {
						var _edgCol = _cEdgM? _cEdgSamp.getPixel(round(_lx), round(_ly)) : _edgC.eval(random(1));
						
						switch(_edg) {
							case 1 : _l.colorE = _edgCol;  break;
							case 2 : _l.colorE = colorMultiply( _edgCol, _l.color); break;
							case 3 : _l.colorE = colorScreen(   _edgCol, _l.color); break;
						}
					}
					
					if(_edt == 0) {
						_l.colorU = undefined;
						
					} else {
						var _edtCol = _cEdtM? _cEdtSamp.getPixel(round(_lx), round(_ly)) : _edtC.evalFast(random(1));
						
						switch(_edt) {
							case 1 : _l.colorU = _edtCol; break;
							case 2 : _l.colorU = colorMultiply( _edtCol, _l.color); break;
							case 3 : _l.colorU = colorScreen(   _edtCol, _l.color); break;
						}
					}
					
					var _whorr = random_range(_whor[0], _whor[1]) * (curve_whorl? curve_whorl.get(_cPos) : 1);
					    _whorr = round(_whorr);
					
					if(_whorr <= 0) {
						array_push(_br.leaves, _l);  array_push(_leaves, _l);
						
					} else if(_whorr == 1) {
						var _d2 = brnDir - _spra;
					        _d2 = lerp_angle_direct(_d2, _gDir, _grv);
				        var lwc = colorMultiply(lc,  _cWhor.evalFast(random(1)));
				            lwc = colorMultiply(lwc, _cWhorAlo.evalFast(1));
				            
				        var lsw  = curve_sizeW? curve_sizeW.get(1) : 1;
				        var gegW = _geg * (curve_geogW? curve_geogW.get(1) : 1);
				        var getW = _get * (curve_geotW? curve_geotW.get(1) : 1);
					    
						var _l2 = new __MK_Tree_Leaf(_rPos, _shap, _lx, _ly, _d2, lsx * lsw, lsy * lsw, _lspn).copy(_l);
						    _l2.color    = lwc;
						    _l2.geoTwist = random_range(_gtws[0], _gtws[1]);
						    _l2.geoGrav  = gegW;
					    	_l2.geoTwist = getW;
						
						array_push(_br.leaves, _l);  array_push(_leaves, _l);
						array_push(_br.leaves, _l2); array_push(_leaves, _l2);
						
					} else {
						var _whrla = _whra * (curve_whorla? curve_whorla.get(_cPos) : 1);
						var _astep = 360 / (_whorr + 1);
						
						for( var k = 0; k <= _whorr; k++ ) {
							var _kprog = k / _whorr;
							
							var _d2 = brnDir + _whrla + _astep * k;
							    _d2 = lerp_angle_direct(_d2, _gDir, _grv);
							var lwc = colorMultiply(lc,  _cWhor.evalFast(random(1)));
				            	lwc = colorMultiply(lwc, _cWhorAlo.evalFast(_kprog));
				            
							var lsw  =         curve_sizeW? curve_sizeW.get(_kprog) : 1;
							var gegW = _geg * (curve_geogW? curve_geogW.get(_kprog) : 1);
				        	var getW = _get * (curve_geotW? curve_geotW.get(_kprog) : 1);
							
							var _l2 = new __MK_Tree_Leaf(_rPos, _shap, _lx, _ly, _d2, lsx * lsw, lsy * lsw, _lspn).copy(_l);
								_l2.color    = lwc;
							    _l2.geoTwist = random_range(_gtws[0], _gtws[1]);
							    _l2.geoGrav  = gegW;
							    _l2.geoTwist = getW;
							    
							array_push(_br.leaves, _l2);  array_push(_leaves, _l2);
						}
					}
					
					_posCursor++;
					if(_posCursor >= _amoR) break;
				}
				
				if(_posCursor >= _amoR) break;
			}
		}
		
	}
	
}