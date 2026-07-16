function __MK_Tree_Leaf(_root, _pos, _shp, _x, _y, _dir, _sx, _sy, _span) : __MK_Tree_Element(_root) constructor {
	rootPosition = _pos;
	shape        = _shp;
	whorlIndex   = 0;
	
	x            = _x;
	y            = _y;
	gravity      = -90;
	
	startx       = _x;
	starty       = _y;
	
	scale        = 1;
	sx           = _sx;
	sy           = _sy;
	dir          = _dir;
	sp           = _span;
	
	surface      = noone;
	surf_w       = 1;
	surf_h       = 1;
	
	color        = c_white;
	colorE       = undefined;
	colorU       = undefined;
	colorLeaf    = undefined;
	
	growShift    = 0;
	growSpeed    = 1;
	
	resolution   =  0;
	geometry     = undefined;
	geometry1    = undefined;
	geoGrav      = .1;
	geoTwist     =  0;
	geoWigg      =  0;
	geoWiggC     = undefined;
	
	mesh         = undefined;
	drawn        = false;
	
	static recalDir = function() {
		dx = lengthdir_x(sx, dir);
		dy = lengthdir_y(sx, dir);
		
		dsx = lengthdir_x(sy, dir + 90);
		dsy = lengthdir_y(sy, dir + 90);
		
	} recalDir();
	
	static drawOverlay = function(_x, _y, _s) { draw_circle(_x + x * _s, _y + y * _s, 3, false); }
	
	static draw = function() {
		if(scale <= 0) return;
		
		var x0 = x;
		var y0 = y;
		
		var x1 = x + dx * scale;
		var y1 = y + dy * scale;
		
		var x2 = x + dx * sp * scale;
		var y2 = y + dy * sp * scale;
		
		var _cE   = colorE? colorE : color;
		var _cTop = colorU? colorU : _cE;
		var _cBot = _cE;
						
		switch(shape) {
			case MKLEAF_TYPE.Leaf : 
				var _sg   = -sign(dsy);
				var _scsg = scale * _sg;
				
				var _dsx = dsx * _scsg;
				var _dsy = dsy * _scsg;
		
				var c0 = colorLeaf.evalFast(  0 );
				var c2 = colorLeaf.evalFast( .5 );
				var c1 = colorLeaf.evalFast(  1 );
				
				var oc  = colorMultiply(color, c0);
				
				var tc2 = colorMultiply(_cTop, c2);
				var bc2 = colorMultiply(_cBot, c2);
				
				var tc1 = colorMultiply(_cTop, c1);
				var bc1 = colorMultiply(_cBot, c1);
				
				draw_primitive_begin(pr_trianglelist);
					draw_vertex_color(x0,        y0,        oc,  1);
					draw_vertex_color(x1,        y1,        tc1, 1);
					draw_vertex_color(x2 + _dsx, y2 + _dsy, tc2, 1);
					
					draw_vertex_color(x0,        y0,        oc,  1);
					draw_vertex_color(x1,        y1,        bc1, 1);
					draw_vertex_color(x2 - _dsx, y2 - _dsy, bc2, 1);
				draw_primitive_end();
				break;
				
			case MKLEAF_TYPE.Complex_Leaf : 
				if(geometry == undefined) break;
				
				var g0 = geometry;
				var g1 = geometry1;
				
				var ssx = sx * scale;
				var ssy = sy * scale;
				
				var _samp = resolution;
				var ds = ssx / _samp;
				var os = g1 == undefined? g0.get(0) : random_range(g0.get(0), g1.get(0));
				var ns = os;
				var od = dir,         nd = od;
				var ox = x0,          nx = ox;
				var oy = y0,          ny = oy;
				var oc = colorLeaf.evalFast(0), nc = oc;
				var gg = geoGrav / _samp;
				var rr;
				var wd;
				
				draw_primitive_begin(pr_trianglelist);
					for( var i = 1; i <= _samp; i++ ) {
						var _t = i / _samp;
						
						ns = g1 == undefined? g0.get(_t) : random_range(g0.get(_t), g1.get(_t));
						
						wd = random_range(-geoWigg, geoWigg) * (geoWiggC? geoWiggC.get(_t) : 1) * sign(geoWigg);
						nx = ox + lengthdir_x(ds, nd) + lengthdir_x(wd, nd + 90);
						ny = oy + lengthdir_y(ds, nd) + lengthdir_y(wd, nd + 90);
						nd = lerp_angle_direct(nd, gravity, gg) + geoTwist / _samp;
						nc = colorLeaf.evalFast(i / _samp);
						
						var _odx = lengthdir_x(ssy, od + 90);
						var _ody = lengthdir_y(ssy, od + 90);
						
						var _ndx = lengthdir_x(ssy, nd + 90);
						var _ndy = lengthdir_y(ssy, nd + 90);
						
						var x00 = ox + _odx * os;
						var y00 = oy + _ody * os;
						
						var x01 = ox - _odx * os;
						var y01 = oy - _ody * os;
						
						var x10 = nx + _ndx * ns;
						var y10 = ny + _ndy * ns;
						
						var x11 = nx - _ndx * ns;
						var y11 = ny - _ndy * ns;
						
						var occ = colorMultiply(color, oc);
						var ncc = colorMultiply(color, nc);
						
						var otc = colorMultiply(_cTop, oc);
						var ntc = colorMultiply(_cTop, nc);
						
						var obc = colorMultiply(_cBot, oc);
						var nbc = colorMultiply(_cBot, nc);
						
						draw_vertex_color(x00, y00, otc, 1);
						draw_vertex_color( ox,  oy, occ, 1);
						draw_vertex_color( nx,  ny, ncc, 1);
						
						draw_vertex_color(x00, y00, otc, 1);
						draw_vertex_color( nx,  ny, ncc, 1);
						draw_vertex_color(x10, y10, ntc, 1);
						
						//////////////////////////////////////
						
						draw_vertex_color(x01, y01, obc, 1);
						draw_vertex_color( ox,  oy, occ, 1);
						draw_vertex_color( nx,  ny, ncc, 1);
						
						draw_vertex_color(x01, y01, obc, 1);
						draw_vertex_color( nx,  ny, ncc, 1);
						draw_vertex_color(x11, y11, nbc, 1);
						
						od = nd;
						os = ns;
						ox = nx;
						oy = ny;
						oc = nc;
					}
				draw_primitive_end();
				break;
				
			case MKLEAF_TYPE.Line : 
				var _samp = resolution;
				var ds = sx / _samp;
				var od = dir,         nd = od;
				var ox = x0,          nx = ox;
				var oy = y0,          ny = oy;
				var oc = colorMultiply(color, colorLeaf.evalFast(0));
				var nc = oc;
				
				var ismp = 1 / _samp;
				var gg   = geoGrav * ismp;
				
				for( var i = 1; i < _samp; i++ ) {
					nx = ox + lengthdir_x(ds, nd);
					ny = oy + lengthdir_y(ds, nd);
					nd = lerp_angle_direct(nd, gravity, gg);
					nc = colorMultiply(color, colorLeaf.evalFast(i * ismp));
					
					draw_line_round_color(ox, oy, nx, ny, sy, oc, nc);
					
					ox = nx;
					oy = ny;
					oc = nc;
				}
				break;
				
			case MKLEAF_TYPE.Circle : 
				draw_set_circle_precision(16)
				draw_circle_color(x2, y2, sx * scale, color, _cE, false);
				break;
				
			case MKLEAF_TYPE.Surface : 
				var _xx = x + lengthdir_x(surf_h * sy * scale / 2, 90 + dir);
				var _yy = y + lengthdir_y(surf_h * sy * scale / 2, 90 + dir);
				
				draw_surface_ext_safe(surface, _xx, _yy, sx * scale, sy * scale, dir, color); 
				break;
			
			case MKLEAF_TYPE.Mesh : 
				if(mesh == undefined) break;
				
				draw_set_color(colorMultiply(color, colorLeaf.evalFast(0)));
				draw_primitive_begin(pr_trianglelist);
				var _vtx = 0;
				var tris = mesh.triangles;
				var pnts = mesh.points;
				
				var _x = x;
				var _y = y;
				
				var _d  = dir;
				var _dc = dcos(_d);
				var _ds = dsin(_d);
				
				for( var i = 0, n = array_length(tris); i < n; i++ ) {
					var t  = tris[i];
					var p0 = pnts[t[0]];
					var p1 = pnts[t[1]];
					var p2 = pnts[t[2]];
						
				    var _x0 = p0.x * sx, _y0 = p0.y * sy;
				    var _x1 = p1.x * sx, _y1 = p1.y * sy;
				    var _x2 = p2.x * sx, _y2 = p2.y * sy;
					
				    var x0 = _x + (_x0 * _dc - _y0 * _ds), y0 = _y + (_x0 * _ds + _y0 * _dc);
				    var x1 = _x + (_x1 * _dc - _y1 * _ds), y1 = _y + (_x1 * _ds + _y1 * _dc);
				    var x2 = _x + (_x2 * _dc - _y2 * _ds), y2 = _y + (_x2 * _ds + _y2 * _dc);
				    
					draw_vertex(x0, y0);
					draw_vertex(x1, y1);
					draw_vertex(x2, y2);
					
					if(++_vtx > 64) {
						draw_primitive_end();
						draw_primitive_begin(pr_trianglelist);
					}
				}
				
				draw_primitive_end();
				break;
		}
	}
	
	////- Action
	
	static copy = function(_l) {
		gravity    = _l.gravity;
		surface    = _l.surface;
		surf_w     = _l.surf_w;
		surf_h     = _l.surf_h;
		
		color      = _l.color;
		colorE     = _l.colorE;
		colorU     = _l.colorU;
		colorLeaf  = _l.colorLeaf;
		
		growShift  = _l.growShift;
		growSpeed  = _l.growSpeed;
		
		resolution = _l.resolution;
		geometry   = _l.geometry;
		geometry1  = _l.geometry1;
		geoGrav    = _l.geoGrav;
		geoTwist   = _l.geoTwist;
		geoWigg    = _l.geoWigg;
		geoWiggC   = _l.geoWiggC;
		
		mesh       = _l.mesh;
		return self;
	}
	
	static clone = function() /*=>*/ {return new __MK_Tree_Leaf(root, rootPosition, shape, x, y, dir, sx, sy, sp).copy(self)};
	static toString = function() /*=>*/ {return $"[MK Leaf]"};
}

function Node_MK_Tree_Leaf(_x, _y, _group = noone) : Node(_x, _y, _group) constructor {
	name  = "Leaves";
	color = COLORS.node_blend_mktree;
	icon  = THEME.mkTree;
	setDrawIcon();
	setDimension(96, 48);
	
	newInput(5, nodeValueSeed());
	newInput(0, nodeValue_Struct( "Branches", noone)).setVisible(true, true).setCustomData(global.MKTREE_JUNC);
	
	////- =Spawning
	newInput( 1, nodeValue_SliRange( "Position", [.5,1] ));
	newInput(55, nodeValue_Slider(   "Chance",    1     ));
	
		////- =/Scatter
	newInput( 2, nodeValue_Range(    "Amount",   [8,16] ));
	newInput(19, nodeValue_EButton(  "Distribution", 0, [ "Random", "Uniform" ] ))
		.setCurvable(52, CURVE_DEF_01, "Remap", "curved", THEME.mk_tree_curve_branch );
	
		////- =/Offset
	newInput(10, nodeValue_Range( "Offset",  [0,0],   true ))
		.setCurvable(17, CURVE_DEF_11, "Over Branch",  "curved",         THEME.mk_tree_curve_branch )
		.setCurvable(53, CURVE_DEF_11, "Over Whorled", "curved_whorled", THEME.mk_tree_curve_whorled )
	
		////- =/Settings
	newInput(35, nodeValue_Bool(    "Apply to Property Curves", false )).setTooltip("Set the 'Over Branch' property to use 'Position' range or total range.");
		
	////- =Direction
	newInput( 7, nodeValue_Range(   "Spread",  [90,90], true )).setCurvable(16, CURVE_DEF_11, "Over Branch", "curved", THEME.mk_tree_curve_branch );
	
	newInput(51, nodeValue_EButton( "Reflect",       0, [ "Random", "Ordered", "Never" ] ));
	newInput(56, nodeValue_EScroll( "Reflect Order", 0, [ "Even", "Odd", "Random" ] ));
	
		////- =/Gravity
	newInput(27, nodeValue_Range( "Gravity", [0,0],    true  )).setCurvable(28, CURVE_DEF_11, "Over Branch", "curved", THEME.mk_tree_curve_branch );
	newInput(57, nodeValue_Bool(  "Override",          false ))
	newInput(58, nodeValue_Rot(   "Gravity Direction", 0     ))
	
	////- =Grouping
	newInput(15, nodeValue_Range( "Whorled", [0,0], true )).setCurvable(36, CURVE_DEF_11, "Over Branch", "curved", THEME.mk_tree_curve_branch );
	newInput(32, nodeValue_Float( "Whorled Angle",  0    )).setCurvable(33, CURVE_DEF_11, "Over Branch", "curved", THEME.mk_tree_curve_branch );
	newInput(54, nodeValue_Rotation( "Whorled Span", 360 ));
	
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
	newInput(59, nodeValue_EButton(    "Array Selection", 0           )).setChoices([ "Ordered", "Random" ]);
	
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
		
	newInput(48, nodeValue_Range(      "Wiggle",        [0,0], true  ))
		.setCurvable(49, CURVE_DEF_11, "Over Branch",  "curved",         THEME.mk_tree_curve_branch  )
		.setCurvable(50, CURVE_DEF_11, "Over Length",  "curved_length",  THEME.mk_tree_curve_length  )
	
	newInput(41, nodeValue_Mesh(       "Mesh"                        ));
	newInput(30, nodeValue_Int(        "Resolution",     6           ));
	
	////- =Color
	
		////- =/per Branch
	newInput( 4, nodeValue_Gradient( "Random Branch",   gra_white )).setMappableConst(12);
	newInput(20, nodeValue_Gradient( "Along Branch",    gra_white ));
	
		////- =/per Leaf
	newInput( 6, nodeValue_Gradient( "Random Leaf",     gra_white )).setMappableConst(13);
	newInput(34, nodeValue_Gradient( "Along Leaf",      gra_white ));
	
		////- =/Group
	newInput(42, nodeValue_Gradient( "Random Whorled",  gra_white ));
	newInput(47, nodeValue_Gradient( "Along Whorled",   gra_white ));
	
		////- =/Edge
	newInput(14, nodeValue_EButton(  "Render Edge",     0, [ "None", "Override", "Multiply", "Screen" ] ));
	newInput(11, nodeValue_Gradient( "Edge Color",      gra_white )).setMappableConst(25);
	newInput(23, nodeValue_EButton(  "Render Top Edge", 0, [ "None", "Override", "Multiply", "Screen" ] ));
	newInput(24, nodeValue_Gradient( "Top Edge Color",  gra_white )).setMappableConst(26);
	
	////- =Growth
	newInput(22, nodeValue_Range( "Grow Delay", [0,0], true ));
	// 60
	
	newOutput(0, nodeValue_Output("Branches", VALUE_TYPE.struct, noone)).setCustomData(global.MKTREE_JUNC);
	newOutput(1, nodeValue_Output("Leaves",   VALUE_TYPE.struct, noone)).setCustomData(global.MKTREE_LEAVES_JUNC);
	
	input_display_list = [ s_MKFX, 5, 0, 
		[ "Spawning",        false ],  1, 55, 
			[ "/Scatter",    false ],  2, 19, 52, 
			[ "/Offset",      true ], 10, 17, 53, 
			[ "/Settings",    true ], 35, 
			
		[ "Direction",       false ],  7, 16, 51, 56, 
			[ "/Gravity",    false ], 27, 28, 57, 58, 
			
		[ "Grouping",        false ], 15, 36, 32, 33, 54, 
		[ "Shape",           false ],  8,  3, 18, 43,  9, 59, 21, 39, 29, 38, 31, 37, 44, 40, 45, 46, 48, 49, 50, 41, 30, 
		
		[ "Color",           false ], 
			[ "/per Branch", false ],  4, 12, 20, 
			[ "/per Leaf",   false ],  6, 13, 34, 
			[ "/Group",      false ], 42, 47, 
			[ "/Edge",       false ], 14, 11, 25, 23, 24, 26, 
			
		[ "Growth",           true ], 22, 
	];
	
	amountUnitToggle  = button(function() /*=>*/ { inputs[2].toggleAttribute("unit"); })
		.setIcon(THEME.mk_tree_leaf_unit).iconPad()
		.setTooltip(new tooltipSelector("Unit", [ "Fixed Amount", "Leaf Distance" ]), function() /*=>*/ {return inputs[2].attributes.unit});
	
	inputs[2].attributes.unit = VALUE_UNIT.constant;
	inputs[2].getEditWidget().setSideButton(amountUnitToggle);
	
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
			var _seed = inline_context.seed + getInputData(5);
			
			var _tree = getInputData( 0);
			
			var _pos  = getInputData( 1);
			var _chan = getInputData(55);
			var _amou = getInputData( 2);
			var _auni = inputs[2].attributes.unit;
			inputs[2].setName(_auni? "Distance" : "Amount");
			amountUnitToggle.icon_index = _auni;
			
			var _dist = getInputData(19);
			var _disC = getInputData(52), curve_distri = inputs[19].attributes.curved? new curveMap(_disC)  : undefined;
			
			var _clam = getInputData(35);
			
			var _sprd = getInputData( 7);
			
			var _refl = getInputData(51);
			var _refo = getInputData(56);
			
			var _sprC = getInputData(16), curve_spread = inputs[ 7].attributes.curved? new curveMap(_sprC)  : undefined;
			var _grav = getInputData(27);
			var _graC = getInputData(28), curve_garvit = inputs[27].attributes.curved? new curveMap(_graC)  : undefined;
			var _grvO = getInputData(57);
			var _grvD = getInputData(58); 
			
			var _offs = getInputData(10);
			var _offC = getInputData(17), curve_offset = inputs[10].attributes.curved?         new curveMap(_offC)  : undefined;
			var _offW = getInputData(53), curve_offsW  = inputs[10].attributes.curved_whorled? new curveMap(_offW)  : undefined;
			
			var _whor = getInputData(15);
			var _whoC = getInputData(36), curve_whorl  = inputs[15].attributes.curved? new curveMap(_whoC)  : undefined;
			var _whra = getInputData(32); 
			var _whrC = getInputData(33), curve_whorla = inputs[32].attributes.curved? new curveMap(_whrC)  : undefined;
			var _whrS = getInputData(54); 
			
			var _shap = getInputData( 8);
			var _siz  = getInputData( 3);
			var _sizC = getInputData(18), curve_size   = inputs[ 3].attributes.curved?         new curveMap(_sizC)  : undefined;
			var _sizW = getInputData(43), curve_sizeW  = inputs[ 3].attributes.curved_whorled? new curveMap(_sizW)  : undefined;
			
			var _tex      = getInputData( 9);
			var _texArSel = getInputData(59);
			
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
			
			var _gwig = getInputData(48);
			var _gwgC = getInputData(49), curve_geow   = inputs[48].attributes.curved?         new curveMap(_gwgC)  : undefined;
			var _gwgL = getInputData(50), curve_geowL  = inputs[48].attributes.curved_length?  new curveMap(_gwgL)  : undefined;
			
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
			
			var texArray  = is_array(_tex);
			var texArrLen = array_safe_length(_tex);
			
			inputs[58].setVisible(_grvO);
			
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
			inputs[48].setVisible(_shap == MKLEAF_TYPE.Complex_Leaf);
			
			inputs[ 9].setVisible(_shap == MKLEAF_TYPE.Surface, _shap == MKLEAF_TYPE.Surface);
			inputs[59].setVisible(texArray);
			inputs[11].setVisible(_shap != MKLEAF_TYPE.Surface && _edg);
			
			inputs[41].setVisible(_shap == MKLEAF_TYPE.Mesh, _shap == MKLEAF_TYPE.Mesh);
			
			var _geo  = undefined;
			var _geo2 = undefined;
			var _geoWigC = undefined;
			
			if(_shap == MKLEAF_TYPE.Complex_Leaf) {
				_geo = new curveMap(_lgeo, _lres + 1);
				if(_geoSc) _geo2 = new curveMap(_lgeo2, _lres + 1);
			}
			
			var _gDir = _grvO? _grvD : inline_context.gravityDir;
		#endregion
		
		var ox, oy, nx, ny;
		var __p0 = min(_pos[0], _pos[1]);
		var __p1 = max(_pos[0], _pos[1]);
		var _leaves = [];
		
		var tex = texArray? array_safe_get(_tex, 0) : _tex;
		var tw  = surface_get_width_safe(tex);
		var th  = surface_get_height_safe(tex);
		
		_tree = variable_clone(_tree);
		outputs[0].setValue(_tree);
		outputs[1].setValue(_leaves);
		
		var _prng = __p1 - __p0;
		if(__p1 < __p0) return;
		
		var _spawnIndx = 0;
		
		for( var i = 0, n = array_length(_tree); i < n; i++ ) {
			if(random(1) > _chan) continue;
			
			random_set_seed(_seed + i * 100);
			var _br   = _tree[i];
			var _type = _br.mode;
			
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
				
				_positions[j] = curve_distri? curve_distri.get(_p) : _p;
			}
			
			if(_dist == 0) array_sort(_positions, true);
			
			var _sprdB = random_range(_sprd[0], _sprd[1]);
			var _sg = _br.segments;
			var _sn = _type == MK_TREE_TYPE.segment? array_length(_sg) : _amoR;
			var  cc = _cBraM? _cBraSamp.getPixel(round(ox), round(oy)) : _cBra.eval(random(1));
			
			var _refOrd = 0, _ref;
			switch(_refo) {
				case 0 : _refOrd = 0; break;
				case 1 : _refOrd = 1; break;
				case 2 : _refOrd = choose(0,1); break;
			}
			
			for( var j = 1; j < _sn; j++ ) {
				if(_type == MK_TREE_TYPE.segment) {
					var _r0 = _br.segmentRatio[j-1];
					var _r1 = _br.segmentRatio[j  ];
					
					if(_r1 <= _r0) continue;
					if(_r1 < _positions[_posCursor]) continue;
						
					ox = _sg[j-1].x;
					oy = _sg[j-1].y;
					
					nx = _sg[j].x;
					ny = _sg[j].y;
					
					var brnDir = point_direction(ox, oy, nx, ny);
					
				} else if(_type == MK_TREE_TYPE.points) {
					if(_br.pointAmo == 0) break;
					var _pnt;
					
						 if(_dist == 0) _pnt = _br.points[irandom(_br.pointAmo - 1)];
					else if(_dist == 1) _pnt = _br.points[_posCursor % _br.pointAmo];
					var brnDir = _br.rootDirection;
				}
				
				while(_type == MK_TREE_TYPE.points || _positions[_posCursor] <= _r1) {
					var _rPos = _positions[_posCursor];
					var _cPos = _clam? (_prng == 0? 1 : (_rPos - __p0) / _prng) : _rPos;
					
					if(_type == MK_TREE_TYPE.segment) {
						var _rr = (_rPos - _r0) / (_r1 - _r0);
						var _lx = lerp(ox, nx, _rr); 
						var _ly = lerp(oy, ny, _rr); 
						
					} else if(_type == MK_TREE_TYPE.points) {
						var _lx = _pnt[0]; 
						var _ly = _pnt[1]; 
					}
					
					var _sprD = 1;
					switch(_refl) {
						case 0 : _sprD = choose(-1, 1); break;
						case 1 : 
							_ref  = (_posCursor % 2) == _refOrd;
							_sprD = 1 - _ref * 2; 
							break;
					}
					
					var _spra = _sprdB * _sprD * (curve_spread? curve_spread.get(_cPos) : 1);
					var _dr   = brnDir + _spra;
					
					var _ggv  = random_range(_grav[0], _grav[1]);
					var _grv  = _ggv * (curve_garvit? curve_garvit.get(_cPos) : 1);
					_dr = lerp_angle_direct(_dr, _gDir, _grv);
					
					var lss = curve_size? curve_size.get(_cPos) : 1;
					var lsx = random_range(_siz[0], _siz[1]) * lss;
					var lsy = random_range(_siz[2], _siz[3]) * lss;
					var lc  = _cLefM? _cLefSamp.getPixel(round(_lx), round(_ly)) : _cLef.eval(random(1));
					    lc  = colorMultiply(lc, _cOvrBra.eval(_cPos));
					    lc  = colorMultiply(lc, cc);
					var lwc = colorMultiply(lc, _cWhor.evalFast(random(1)));
					    
					var _geg = random_range(_geoG[0], _geoG[1]) * (curve_geog? curve_geog.get(_cPos) : 1);
					var _get = random_range(_gtws[0], _gtws[1]) * (curve_geot? curve_geot.get(_cPos) : 1);
					var _gew = random_range(_gwig[0], _gwig[1]) * (curve_geow? curve_geow.get(_cPos) : 1);
					
					var _off  = random_range(_offs[0], _offs[1]) * (curve_offset? curve_offset.get(_cPos) : 1);
					var _offw = _off * (curve_offsW? curve_offsW.get(0) : 1);
					
					var _llx = _lx + lengthdir_x(_offw, _dr);
					var _lly = _ly + lengthdir_y(_offw, _dr);
					
					var tex  = _tex;
					if(texArray) switch(_texArSel) {
						case 0 : tex = _tex[_spawnIndx % texArrLen]; break;
						case 1 : tex = _tex[irandom(texArrLen - 1)]; break;
					}
					
					var _l = new __MK_Tree_Leaf(_br, _rPos, _shap, _llx, _lly, _dr, lsx, lsy, _lspn);
					    _l.gravity    = _gDir;
					    _l.surface    =  tex;
					    _l.surf_w     =  tw;
					    _l.surf_h     =  th;
					    
					    _l.color      = lwc;
					    _l.colorLeaf  = _cLefAlo;
					    _l.growShift  = random_range(_grow[0], _grow[1]);
					    _l.resolution = _lres;
					    
					    _l.geoGrav    = _geg;
					    _l.geoTwist   = _get;
					    _l.geoWigg    = _gew;
					    _l.geoWiggC   = curve_geowL;
					    _l.mesh       = _mesh;
					     
					if(_shap == MKLEAF_TYPE.Complex_Leaf) {
					    _l.geometry   = _geo;
					    _l.geometry1  = _geo2;
					}
					
					_spawnIndx++;
					
					var _edgCol = _cEdgM? _cEdgSamp.getPixel(round(_lx), round(_ly)) : _edgC.eval(random(1));
					
					switch(_edg) {
						case 1 : _l.colorE = _edgCol;  break;
						case 2 : _l.colorE = colorMultiply( _edgCol, _l.color); break;
						case 3 : _l.colorE = colorScreen(   _edgCol, _l.color); break;
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
						array_push(_br.leaves, _l);
						array_push(_leaves, _l);
						
					} else if(_whorr == 1) {
						var _d2 = brnDir - _spra;
					        _d2 = lerp_angle_direct(_d2, _gDir, _grv);
				        var lwc = colorMultiply(lc,  _cWhor.evalFast(random(1)));
				            lwc = colorMultiply(lwc, _cWhorAlo.evalFast(1));
				            
				        var lsw  = curve_sizeW? curve_sizeW.get(1) : 1;
				        var gegW = _geg * (curve_geogW? curve_geogW.get(1) : 1);
				        var getW = _get * (curve_geotW? curve_geotW.get(1) : 1);
				        var gewW = _gew;
					    
					    var _offw = _off * (curve_offsW? curve_offsW.get(1) : 1);
						var _llx  = _lx + lengthdir_x(_offw, _d2);
						var _lly  = _ly + lengthdir_y(_offw, _d2);
					
						var _l2 = new __MK_Tree_Leaf(_br, _rPos, _shap, _llx, _lly, _d2, lsx * lsw, lsy * lsw, _lspn).copy(_l);
						    _l2.color      = lwc;
						    _l2.geoTwist   = random_range(_gtws[0], _gtws[1]);
						    _l2.geoGrav    = gegW;
					    	_l2.geoTwist   = getW;
					    	_l2.geoWigg    = gewW;
					    	_l2.whorlIndex = 1;
						
						array_push(_br.leaves, _l);  array_push(_leaves, _l);
						array_push(_br.leaves, _l2); array_push(_leaves, _l2);
						
					} else {
						var _whrla = _whra * (curve_whorla? curve_whorla.get(_cPos) : 1);
						var _astep = _whrS / (_whorr + 1);
						
						for( var k = 0; k <= _whorr; k++ ) {
							var _kprog = k / _whorr;
							
							var _d2 = brnDir + _whrla + _astep * k;
							    _d2 = lerp_angle_direct(_d2, _gDir, _grv);
							var lwc = colorMultiply(lc,  _cWhor.evalFast(random(1)));
				            	lwc = colorMultiply(lwc, _cWhorAlo.evalFast(_kprog));
				            
							var lsw  =         curve_sizeW? curve_sizeW.get(_kprog) : 1;
							var gegW = _geg * (curve_geogW? curve_geogW.get(_kprog) : 1);
				        	var getW = _get * (curve_geotW? curve_geotW.get(_kprog) : 1);
							var gewW = _gew;
							
					    	var _offw = _off * (curve_offsW? curve_offsW.get(_kprog) : 1);
							var _llx	= _lx + lengthdir_x(_offw, _d2);
							var _lly	= _ly + lengthdir_y(_offw, _d2);
					
							var _l2 = new __MK_Tree_Leaf(_br, _rPos, _shap, _llx, _lly, _d2, lsx * lsw, lsy * lsw, _lspn).copy(_l);
								_l2.color      = lwc;
							    _l2.geoTwist   = random_range(_gtws[0], _gtws[1]);
							    _l2.geoGrav    = gegW;
							    _l2.geoTwist   = getW;
					    		_l2.geoWigg    = gewW;
					    		_l2.whorlIndex = _kprog;
							    
							array_push(_br.leaves, _l2);  array_push(_leaves, _l2);
						}
					}
					
					_posCursor++;
					if(_posCursor >= _amoR) break;
					if(_type == MK_TREE_TYPE.points) break;
				}
				
				if(_posCursor >= _amoR) break;
			}
		}
		
	}
	
}