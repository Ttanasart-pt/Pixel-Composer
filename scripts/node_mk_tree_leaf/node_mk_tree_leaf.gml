function Node_MK_Tree_Leaf(_x, _y, _group = noone) : Node(_x, _y, _group) constructor {
	name  = "Tree Leaves";
	color = COLORS.node_blend_mktree;
	icon  = THEME.mkTree;
	setDrawIcon(s_node_mk_tree_leaf);
	setDimension(96, 48);
	
	newInput(5, nodeValueSeed());
	newInput(0, nodeValue_Struct("Branches", noone)).setVisible(true, true).setCustomData(global.MKTREE_JUNC);
	
	////- =Leaf
	newInput( 1, nodeValue_Slider_Range( "Leaf Position", [.5,1] ));
	newInput(19, nodeValue_Enum_Button(  "Distribution",     0, [ "Random", "Uniform" ] ));
	
	newInput( 2, nodeValue_Range( "Amount",  [8,16]        ));
	newInput( 7, nodeValue_Range( "Spread",  [90,90], true )).setCurvable(16, CURVE_DEF_11, "Over Branch");
	newInput(27, nodeValue_Range( "Gravity", [0,0],   true )).setCurvable(28, CURVE_DEF_11, "Over Branch");
	newInput(10, nodeValue_Range( "Offset",  [0,0],   true )).setCurvable(17, CURVE_DEF_11, "Over Branch");
	newInput(15, nodeValue_Int(   "Whorled",  0            ));
	
	////- =Shape
	shape_types = [ "Leaf", "Complex Leaf", "Line", "Circle", "Surface" ];
	newInput( 8, nodeValue_EScroll( "Shape", MKLEAF_TYPE.Leaf, shape_types ))
		.setHistory([ shape_types, 
			{ cond: function() /*=>*/ {return LOADING_VERSION < 1_20_02_0}, list: [ "Leaf", "Circle", "Surface", "Line" ] }, 
		]);
	newInput( 3, nodeValue_Vec2_Range(  "Size",          [4,4,2,2]    )).setCurvable(18, CURVE_DEF_11, "Over Branch");
	newInput( 9, nodeValue_Surface(     "Texture",       noone        ));
	newInput(21, nodeValue_Slider(      "Leaf Span",     .5           ));
	newInput(29, nodeValue_Curve(       "Geometry",      CURVE_DEF_01 ));
	newInput(31, nodeValue_Float(       "Shape Gravity", .1           ));
	newInput(30, nodeValue_Int(         "Resolution",     6           ));
	
	////- =Color
	newInput( 4, nodeValue_Gradient(    "Color Per Branch",  gra_white )).setMappableConst(12);
	newInput(20, nodeValue_Gradient(    "Color Over Branch", gra_white ));
	newInput( 6, nodeValue_Gradient(    "Color Per Leaf",    gra_white )).setMappableConst(13);
	
	////- =Edge
	newInput(14, nodeValue_Enum_Button( "Render Edge",       0, [ "None", "Override", "Multiply", "Screen" ] ));
	newInput(11, nodeValue_Gradient(    "Edge Color",        gra_white )).setMappableConst(25);
	newInput(23, nodeValue_Enum_Button( "Render Top Edge",   0, [ "None", "Override", "Multiply", "Screen" ] ));
	newInput(24, nodeValue_Gradient(    "Top Edge Color",    gra_white )).setMappableConst(26);
	
	////- =Growth
	newInput(22, nodeValue_Range( "Grow Delay", [0,0], true ));
	// input 32
	
	newOutput(0, nodeValue_Output("Branches", VALUE_TYPE.struct, noone)).setCustomData(global.MKTREE_JUNC);
	
	input_display_list = [ new Inspector_Sprite(s_MKFX), 5, 0, 
		[ "Leaf",   false ],  1, 19,  2,  7, 16, 27, 28, 10, 17, 15, 
		[ "Shape",  false ],  8,  3, 18,  9, 21, 29, 31, 30, 
		[ "Color",  false ],  4, 20, 12,  6, 13, new Inspector_Spacer(ui(4), true, true, ui(6)), 14, 11, 25, 23, 24, 26, 
		[ "Growth", false ], 22, 
	];
	
	amountUnitToggle = button(function() /*=>*/ {
		inputs[2].attributes.unit = !inputs[2].attributes.unit;
		triggerRender();
	}).setIcon(THEME.mk_tree_leaf_unit).iconPad();
	
	inputs[2].attributes.unit = VALUE_UNIT.constant;
	inputs[2].editWidget.setSideButton(amountUnitToggle);
	
	////- Nodes
	
	static getDimension = function() /*=>*/ {return is(inline_context, Node_MK_Tree_Inline)? inline_context.dimension : [1,1]};
	
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
			var _dist = getInputData(19);
			var _sprd = getInputData( 7);
			var _sprC = getInputData(16), curve_spread = inputs[ 7].attributes.curved? new curveMap(_sprC)  : undefined;
			var _grav = getInputData(27);
			var _graC = getInputData(28), curve_garvit = inputs[27].attributes.curved? new curveMap(_graC)  : undefined;
			var _offs = getInputData(10);
			var _offC = getInputData(17), curve_offset = inputs[10].attributes.curved? new curveMap(_offC)  : undefined;
			var _whor = getInputData(15);
			
			var _shap = getInputData( 8);
			var _siz  = getInputData( 3);
			var _sizC = getInputData(18), curve_size   = inputs[ 3].attributes.curved? new curveMap(_sizC)  : undefined;
			var _tex  = getInputData( 9);
			var _lspn = getInputData(21);
			var _lgeo = getInputData(29);
			var _geoG = getInputData(31);
			var _lres = getInputData(30);
			
			var _cBra     = getInputData( 4);
			var _cBraMap  = getInputData(12);
			var _cBraM    = inputs[ 4].attributes.mapped && is_surface(_cBraMap), _cBraSamp = _cBraM? new Surface_sampler(_cBraMap) : undefined;
			
			var _cOvrBra  = getInputData(20);
			
			var _cLef     = getInputData( 6);
			var _cLefMap  = getInputData(13);
			var _cLefM    = inputs[ 6].attributes.mapped && is_surface(_cLefMap), _cLefSamp = _cLefM? new Surface_sampler(_cLefMap) : undefined;
			
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
			inputs[31].setVisible(_shap == MKLEAF_TYPE.Complex_Leaf);
			inputs[30].setVisible(_shap == MKLEAF_TYPE.Complex_Leaf);
			
			inputs[ 9].setVisible(_shap == MKLEAF_TYPE.Surface, _shap == MKLEAF_TYPE.Surface);
			inputs[11].setVisible(_shap != MKLEAF_TYPE.Surface && _edg);
			
			var _geo = [];
			if(_shap == MKLEAF_TYPE.Complex_Leaf) {
				_geo = array_create(_lres + 1);
				for( var i = 0; i <= _lres; i++ )
					_geo[i] = eval_curve_x(_lgeo, i/_lres);
			}
		#endregion
		
		var ox, oy, nx, ny;
		var _pst = min(_pos[0], _pos[1]);
		var _ped = max(_pos[0], _pos[1]);
		var _prn = _ped - _pst;
		
		_tree = variable_clone(_tree);
		
		for( var i = 0, n = array_length(_tree); i < n; i++ ) {
			random_set_seed(_seed + i * 100);
			
			var _br = _tree[i];
			var _sg = _br.segments;
			var _sn = array_length(_sg);
			
			var _amoR = random_range(_amou[0], _amou[1]);
			if(_auni) _amoR = _br.totalLength / _amoR; // density
			
			var _amo  = _amoR / _sn;
			var _amf  = floor(_amo);
			var _aml  = frac(_amo);
			var ox    = _sg[0].x;
			var oy    = _sg[0].y;
			var cc    = _cBraM? _cBraSamp.getPixel(round(ox), round(oy)) : _cBra.eval(random(1));
			
			var _sprdB    = random_range(_sprd[0], _sprd[1]);
			var _uniSpace = _prn / max(1, _amoR - 1); 
			var _uniRun   = _pst;
			
			for( var j = 1; j < _sn; j++ ) {
				var _r0 = _br.segmentRatio[j-1];
				var _r1 = _br.segmentRatio[j];
				var rng = _r1 - _r0;
				
				var _rSt = max(_r0, _pst);
				var _rEd = min(_r1, _ped);
				
				nx = _sg[j].x;
				ny = _sg[j].y;
				
				if(_rEd <= _rSt) { ox = nx; oy = ny; continue; }
				
				var _sSt = (_rSt - _r0) / rng;
				var _sEd = (_rEd - _r0) / rng;
				
				if(_dist == 0) {
					var amoSeg = _amf + (random(1) < _aml);
					
				} else if(_dist == 1) {
					var amoSeg = ceil(rng / _uniSpace) + 1;
					if(_uniRun > _r1) { ox = nx; oy = ny; continue; }
				}
				
				var brnDir = point_direction(ox, oy, nx, ny);
				
				repeat(amoSeg) {
					if(_dist == 0) {
						var _rr = random_range(_sSt, _sEd);
						
					} else if(_dist == 1) {
						var _rr = (_uniRun - _r0) / rng;
						_uniRun += _uniSpace;
					}
						
					_rr = clamp(_rr, 0, 1);
					var _rBrn  = lerp(_r0, _r1, _rr);
					var _rBrns = (_rBrn - _pst) / _prn;
					
					var _lx = lerp(ox, nx, _rr); 
					var _ly = lerp(oy, ny, _rr); 
					
					var _spra = _sprdB * choose(-1, 1) * (curve_spread? curve_spread.get(_rBrns) : 1);
					var _dr   = brnDir + _spra;
					
					var _ggv  = random_range(_grav[0], _grav[1]);
					var _grv  = _ggv * (curve_garvit? curve_garvit.get(_rBrns) : 1);
					    _grv  = clamp(_grv, 0, 1);
					_dr = lerp_angle_direct(_dr, _gDir, _grv);
					
					var _sh = random_range(_offs[0], _offs[1]) * (curve_offset? curve_offset.get(_rBrns) : 1);
					_lx += lengthdir_x(_sh, brnDir + 90);
					_ly += lengthdir_y(_sh, brnDir + 90);
					
					var lss = curve_size? curve_size.get(_rBrns) : 1;
					var lsx = random_range(_siz[0], _siz[1]) * lss;
					var lsy = random_range(_siz[2], _siz[3]) * lss;
					var lc  = _cLefM? _cLefSamp.getPixel(round(_lx), round(_ly)) : _cLef.eval(random(1));
					    lc  = colorMultiply(lc, _cOvrBra.eval(_rBrns));
					
					var _l = new __MK_Tree_Leaf(_rBrn, _shap, _lx, _ly, _dr, lsx, lsy, _lspn);
					    _l.surface   = _tex;
					    _l.color     = colorMultiply(cc, lc);
					    _l.growShift = random_range(_grow[0], _grow[1]);
					    _l.geometry  = _geo;
					    _l.geoGrav   = _geoG;
					
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
					
					array_push(_br.leaves, _l);
					
					if(_whor > 0) {
						var _astep = 360 / _whor;
						for( var k = 0; k < _whor; k++ ) {
							var _d2 = brnDir + _spra + _astep * k;
							    _d2 = lerp_angle_direct(_d2, _gDir, _grv);
							
							var _l2 = new __MK_Tree_Leaf(_rBrn, _shap, _lx, _ly, _d2, lsx, lsy, _lspn).copy(_l);
							array_push(_br.leaves, _l2);
						}
					}
					
					if(_dist == 1 && _uniRun > _r1) break;
				}
				
				ox = nx;
				oy = ny;
			}
		}
		
		outputs[0].setValue(_tree);
	}
	
}