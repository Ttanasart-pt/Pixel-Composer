function Node_MK_Blast_Flame(_x, _y, _group = noone) : Node(_x, _y, _group) constructor {
	name  = "Flame Ball";
	color = COLORS.node_blend_mkblast;
	icon  = THEME.mkBlast;
	update_on_frame = true;
	setDrawIcon(s_node_mk_blast_flame);
	setDimension(96, 48);
	
	newInput( 0, nodeValueSeed());
	
	////- =Settings
	newInput(19, nodeValue_Curve( "Group Intpolation", CURVE_DEF_01 ));
	newInput(20, nodeValue_Curve( "Anim Intpolation",  CURVE_DEF_01 ));
	
	////- =Spawning
	newInput( 1, nodeValue_Float( "Amount",  3    ));
	newInput( 2, nodeValue_Range( "Frame",  [0,0] ));
	
		////- =/Lifespan
	newInput( 3, nodeValue_Range( "Lifespan",  [6,8] )).setMappableRange(40, "Group Varience", THEME.mk_blast_group);
		
		////- =/Source
	newInput( 4, nodeValue_Vec2( "Position", [.5,.5]  )).setUnitSimple();
	newInput( 5, nodeValue_Vec2( "Area",     [.0,.0]  )).setUnitSimple();
	newInput( 6, nodeValue_Vec2( "Radius",   [.1,.15] )).setUnitSimple().setMappableRange(41, "Group Varience", THEME.mk_blast_group);
		
		////- =/Group
	newInput( 7, nodeValue_Range(    "Group Size", [6,9]     ));
	newInput(10, nodeValue_RotRange( "Angle Span", [360,360] ));
	
	////- =Movement
	newInput(38, nodeValue_EScroll( "Type",       0, [ "Increment", "Fix Curve" ]  ));
	newInput(11, nodeValue_Range(   "Speed",     [.2,.6]            )).setMappableRange( 9, "Group Varience", THEME.mk_blast_group);
	newInput(39, nodeValue_Curve(   "Movemenet Curve", CURVE_DEF_01 ));
	newInput(24, nodeValue_Range(   "Friction",  [0,0]              )).setMappableRange(42, "Group Varience", THEME.mk_blast_group);;
	newInput(12, nodeValue_RotRand( "Direction", [0,0,0,0,0]        ));
	newInput(22, nodeValue_Range(   "Gravity",   [0,0]              ));
	
	////- =Rotation
	newInput(26, nodeValue_Range(   "Rotate",      [0,0] )).setMappableRange( 8, "Group Varience", THEME.mk_blast_group);
	newInput(27, nodeValue_Bool(    "Flip Rotate", false ));
	
	////- =Size
	newInput(13, nodeValue_Range(   "Size",        [6,10]  )).setMappableRange(43, "Group Varience", THEME.mk_blast_group);
	newInput(28, nodeValue_Range(   "Spawn Size",  [.5,.5] ));
	
	////- =Spiral
	newInput(32, nodeValue_Bool(    "Spiral Use", false   ));
	newInput(34, nodeValue_Range(   "Phase",      [0,0]   ));
	newInput(29, nodeValue_Range(   "Size",       [4,4]   ));
	newInput(30, nodeValue_Range(   "Intensity",  [.5,.5] ));
	newInput(33, nodeValue_Range(   "Rotation",   [5,5]   ));
	newInput(31, nodeValue_Bool(    "Multiply",   true    ));
	
	////- =Decay
	newInput(25, nodeValue_Bool(    "Do Decay",     true  ));
	newInput(14, nodeValue_Range(   "Decay Offset", [4,6] )).setMappableRange(44, "Group Varience", THEME.mk_blast_group);
	
	////- =Render
	newInput(21, nodeValue_Surface( "Texture" ));
	
		////- =/Shape
	newInput(23, nodeValue_EScroll( "Shape", 0, [ "Circle", "Arrow", "Line", "Path" ] ));
	newInput(35, nodeValue_Range(   "Arrow Offset", [0,0] ));
	newInput(46, nodeValue_PathNode("Path"                ));
	newInput(47, nodeValue_Int(     "Path Sample",   8    ));
	newInput(36, nodeValue_Range(   "Thickness",    [2,2] )).setMappableRange(45, "Group Varience", THEME.mk_blast_group);
	newInput(37, nodeValue_Curve(   "Shape",        CURVE_DEF_11 ));
	
		////- =/Color
	newInput(17, nodeValue_Gradient( "Color", gra_black_white ));
	newInput(18, nodeValue_Range(    "Level", [0,1]  ));
	
		////- =/Perspective
	newInput(15, nodeValue_Vec2(  "View Origin", [.5,.5] )).setUnitSimple();
	newInput(16, nodeValue_Range( "Perspective", [2,2]   ));
	// 48
	
	newOutput( 0, nodeValue_Output( "Blast", VALUE_TYPE.struct, [] )).setCustomData(global.MKBLAST_JUNC);
	
	input_display_list = [ s_MKFX, 0,  
		[ "Settings",          true ], 19, 20, 
		[ "Spawning",         false ],  1,  2, 
			[ "/Lifespan",    false ],  3, 
			[ "/Source",      false ],  4,  5,  6,
			[ "/Group",       false ],  7, 10, 
			
		[ "Movement",         false ], 38, 11, 39, 24, 12, 22, 
		[ "Rotation",         false ], 26, 27, 
		[ "Size",             false ], 13, 28, 
		[ "Spiral",        true, 32 ], 34, 29, 30, 33, 31, 
		[ "Decay",         true, 25 ], 14, 
			
		[ "Render",           false ], 21, 
			[ "/Shape",       false ], 23, 35, 46, 47, 36, 37, 
			[ "/Color",       false ], 17, 18, 
			[ "/Perspective", false ], 15, 16, 
	];
	
	insertMapDisplay();
	
	////- Nodes
	
	static getDimension = function() /*=>*/ {return is(inline_context, Node_MK_Blast_Inline)? inline_context.getDimension() : DEF_SURF};
	
	static drawOverlay = function(hover, active, _x, _y, _s, _mx, _my, _params) { 
		InputDrawOverlay(inputs[ 4].drawOverlay(w_hoverable, active, _x, _y, _s, _mx, _my));
		InputDrawOverlay(inputs[15].drawOverlay(w_hoverable, active, _x, _y, _s, _mx, _my, 1));
	}
	
	static update = function(_frame = CURRENT_FRAME) { 
		#region data 
			var _dim     = getDimension();
			var _seed    = inline_context.seed + getInputData(0);
			var _gDir    = inline_context.gravityDir;
			
			var _grInt   = getInputData(19), curve_grInt = new curveMap(_grInt);
			var _anInt   = getInputData(20), curve_anInt = new curveMap(_anInt);
			
			var _amoun   = getInputData( 1);
			var _spwFrm  = getInputData( 2);
			
			var _life    = getInputData( 3), _lifeRand = getInputData(40);
			
			var _orig    = getInputData( 4);
			var _area    = getInputData( 5);
			var _radd    = getInputData( 6), _raddRand = getInputData(41);
			
			var _group   = getInputData( 7);
			var _grpSpn  = getInputData(10);
			
			var _rotat   = getInputData(26), _grpAng   = getInputData( 8);
			var _rotaFl  = getInputData(27);
			
			var _size    = getInputData(13), _sizeRand = getInputData(43);
			var _sizeRat = getInputData(28);
			
			var _spiUse  = getInputData(32);
			var _spiPhs  = getInputData(34);
			var _spiSiz  = getInputData(29);
			var _spiInt  = getInputData(30);
			var _spiRot  = getInputData(33);
			var _spiMul  = getInputData(31);
			
			var _ddecay  = getInputData(25);
			var _decay   = getInputData(14), _decayRand = getInputData(44);
			
			var _mtype   = getInputData(38);
			var _mcurv   = getInputData(39), _moveCurve = new curveMap(_mcurv, 32);
			var _speed   = getInputData(11), _grpSpd    = getInputData( 9);
			var _frict   = getInputData(24), _frictRand = getInputData(42);
			
			var _dirr    = getInputData(12);
			var _gravity = getInputData(22);
			
			var _text    = getInputData(21);
			
			var _shape   = getInputData(23);
			var _arrowO  = getInputData(35);
			var _path    = getInputData(46);
			var _pathD   = getInputData(47);
			var _lineW   = getInputData(36), _linewRand = getInputData(45);
			var _lineS   = getInputData(37), _lineData  = new curveMap(_lineS, 32);
			
			var _color   = getInputData(17);
			var _level   = getInputData(18);
			
			var _vorig   = getInputData(15);
			var _persp   = getInputData(16);
			
			random_set_seed(_seed);
			
			inputs[39].setVisible(_mtype == 1);
			inputs[24].setVisible(_mtype == 0);
			
			inputs[35].setVisible(_shape == 1);
			
			inputs[46].setVisible(_shape == 3, _shape == 3);
			inputs[47].setVisible(_shape == 3);
			inputs[36].setVisible(_shape == 2 || _shape == 3);
			inputs[37].setVisible(_shape == 2 || _shape == 3);
		#endregion
		
		var _pathData = [];
		if(_shape == 3 && is_path(_path)) {
			_pathData = array_create(_pathD);
			var _siz = 1 / (_pathD - 1);
			var __p  = new __vec2();
			
			for( var i = 0; i < _pathD; i++ ) {
				__p = _path.getPointRatio(i * _siz, 0, __p);
				_pathData[i] = [__p.x, __p.y]
			}
		}
		
		var _flameLayer = [];
		for( var a = 0; a < _amoun; a++ ) {
			var _prg = a / (_amoun - 1);
			_prg = curve_grInt.get(_prg);
			
			var _spd = random_range(_speed[0], _speed[1]);
			var _dir = rotation_random_eval(_dirr);
			
			var _spFrm = irandom_range(_spwFrm[0], _spwFrm[1]);
			
			var _lifeT = lerp(_life[1],  _life[0],    _prg);
			var _rad   = lerp(_radd[1],  _radd[0],    _prg);
			
			var _spd   = lerp(_speed[1], _speed[0],   _prg);
			var _fric  = lerp(_frict[1], _frict[0],   _prg);
			
			var _siz   = lerp(_size[1],  _size[0],    _prg);
			
			var _gro   = lerp(_group[1],  _group[0],  _prg);
			var _groSp = lerp(_grpSpn[1], _grpSpn[0], _prg);
			
			var _pers  = lerp(_persp[0],  _persp[1],  _prg);
			var _arwo  = lerp(_arrowO[0], _arrowO[1], _prg);
			var _lith  = lerp(_lineW[0],  _lineW[1],  _prg);
			
			var _dec   = lerp(_decay[0],  _decay[1],  _prg);
			
			var _spirSize = _spiUse? lerp(_spiSiz[0], _spiSiz[1],  _prg) : 0;
			
			    _dir   -= _groSp / 2;
			var _grAng  = _groSp  / _gro;
			var _grAsp  = random_range(_grpAng[0], _grpAng[1]) / _gro;
			
			var _layer  = new MKBlast_Layer();
			_layer.colorize  = _color;
			
			for( var g = 0; g < _gro; g++ ) {
				var _flm = new MKBlast_Ball();
				var pDir = _dir + g * _grAng + random_range(-_grAsp, _grAsp);
				
				var _rrad = _rad  + random_range(_raddRand[0], _raddRand[1]);
				var ox = _orig[0] + random_range(-_area[0], _area[0]) + lengthdir_x(_rrad, pDir);
				var oy = _orig[1] + random_range(-_area[1], _area[1]) + lengthdir_y(_rrad, pDir);
				
				_flm.texture = _text;
					
				_flm.origin    = _vorig;
				_flm.originDim = _dim;
				
				_flm.sx = ox;
				_flm.sy = oy;
				
				_flm.life      = _frame - _spFrm;
				_flm.lifeTotal = _lifeT + random_range(_lifeRand[0], _lifeRand[1]);
				
				_flm.moveType  = _mtype;
				_flm.moveCurve = _moveCurve;
				_flm.speed     = _spd  + random_range(_grpSpd[0], _grpSpd[1]);
				_flm.friction  = _fric + random_range(_frictRand[0], _frictRand[1]);
				_flm.direction = pDir;
				
				_flm.gravity    = random_range(_gravity[0], _gravity[1]);
				_flm.gravityDir = _gDir;
				
				_flm.rotate     = random_range(_rotat[0], _rotat[1]);
				if(_rotaFl && choose(0,1)) _flm.rotate = -_flm.rotate;
				
				var _ssiz = _siz + random_range(_sizeRand[0], _sizeRand[1]);
				_flm.size[0]    = _ssiz * random_range(_sizeRat[0], _sizeRat[1]);
				_flm.size[1]    = _ssiz;
				_flm.shape      = _shape;
				_flm.pathData   = _pathData;
				
				_flm.arrowSize     = _arwo;
				_flm.lineThickness = _lith + random_range(_linewRand[0], _linewRand[1]);
				_flm.lineShape     = _lineData.map;
				
				_flm.doDecay    = _ddecay;
				_flm.decay      = _dec + random_range(_decayRand[0], _decayRand[1]);
				
				_flm.spiralSize      = _spirSize;
				_flm.spiralPhase     = random_range(_spiPhs[0], _spiPhs[1]);
				_flm.spiralIntensity = random_range(_spiInt[0], _spiInt[1]);
				_flm.spiralRotation  = random_range(_spiRot[0], _spiRot[1]);
				_flm.spiralMultiply  = _spiMul;
				
				_flm.perspective = _pers;
				_flm.animCurve   = curve_anInt;
				
				_flm.level       = _level;
				
				_flm.step();
				
				array_push(_layer.flames, _flm);
			}
			
			array_push(_flameLayer, _layer);
		}
		
		outputs[0].setValue(_flameLayer);
	} 
}

function MKBlast_Ball() : MKBlast_Element() constructor {
	blastRatio      = 0;
	
	radiusBlast     = .4;
	
	moveType        = 0;
	moveCurve       = undefined;

	normal          = [0,0];
	discard         = false;
	
	texture         = undefined;
	shape           = 0;
	
	doDecay         = true;
	decay           = 6;
	
	rotate          = 0;
	
	spiralSize      = 0;
	spiralIntensity = 0;
	spiralRotation  = 0;
	spiralPhase     = 0;
	spiralMultiply  = 1;

	arrowSize       = 0;
	lineThickness   = 2;
	lineShape       = [1];
	pathData        = [];
	
	static step = function() {
		var _life = max(life / lifeTotal, 0);
		var _blas = max((life - decay) / lifeTotal, 0);
		
		if(animCurve) _life = animCurve.get(_life);
		
		lifeRatio   = _life;
		blastRatio  = _blas;
		
		// Movement
		if(moveType == 1 && moveCurve != undefined) {
			var _tDist = speed * lifeTotal;
			var _cDist = moveCurve.get(clamp(_life, 0, 1)) * _tDist;
			
			x = sx + lengthdir_x(_cDist, direction);
			y = sy + lengthdir_y(_cDist, direction);
			
		} else {
			var _dist = (speed + max(0, speed - friction * life)) / 2 * life;
			x = sx + lengthdir_x(_dist, direction);
			y = sy + lengthdir_y(_dist, direction);
		}
		
		// Gravity
		x += lengthdir_x(gravity, gravityDir) * sqr(max(0, life));
		y += lengthdir_y(gravity, gravityDir) * sqr(max(0, life));
	}
	
	static draw = function(_x = 0, _y = 0, _r = 0, _s = 1) {
		var rad = lerp(size[0], size[1], lifeRatio);
		var ro  = rad * _s;
		if(life < 0 || ro <= 0) return;
		
		var ars = ro * arrowSize;
		
		var xx = _x + x * _s;
		var yy = _y + y * _s;
		
		normal[0] = (x - origin[0]) / originDim[0] * perspective;
		normal[1] = (y - origin[1]) / originDim[1] * perspective;
		
		angle = direction + lifeRatio * rotate;
		
		var blastRad = max(0, blastRatio) * radiusBlast;
		
		BLEND_MAX
		shader_set(sh_mk_blast_flameball);
			shader_set_i( "shapeIndex",   shape     );
			
			shader_set_f( "innerRad",     doDecay? blastRad : 0 );
			shader_set_2( "origin",       normal    );
			shader_set_i( "discardBlack", discard   );
			shader_set_f( "rotation",     angle     );
			
			shader_set_f( "spiralSize",      spiralSize      );
			shader_set_f( "spiralPhase",     spiralPhase     );
			shader_set_f( "spiralIntensity", spiralIntensity );
			shader_set_f( "spiralRotation",  spiralRotation * life  );
			shader_set_i( "spiralMultiply",  spiralMultiply  );
			
			shader_set_i( "useTexture", is_surface(texture) );
			if(is_surface(texture)) shader_set_s("texture", texture);
			
			shader_set_2("level",    level);
			
			var cc = c_white;
			var aa = doDecay? 1 : 1 - clamp((life - decay) / lifeTotal, 0, 1);
			
			switch(shape) {
				case 0 : // Circle
					draw_sprite_ext(s_fx_pixel2, 0, xx, yy, ro, ro, 0, cc, aa); 
					break;
				
				case 1 : // Arrow
					var xc = xx + lengthdir_x(ars, angle + 180);
					var yc = yy + lengthdir_y(ars, angle + 180);
					
					var x0 = xx + lengthdir_x(ro, angle +   0);
					var y0 = yy + lengthdir_y(ro, angle +   0);
					
					var x1 = xx + lengthdir_x(ro, angle + 135);
					var y1 = yy + lengthdir_y(ro, angle + 135);
					
					var x2 = xx + lengthdir_x(ro, angle - 135);
					var y2 = yy + lengthdir_y(ro, angle - 135);
					
					draw_primitive_begin(pr_trianglelist);
						draw_vertex_texture_color(xc, yc, .5, .5, cc, aa);
						draw_vertex_texture_color(x0, y0,  1,  0, cc, aa);
						draw_vertex_texture_color(x1, y1,  0,  0, cc, aa);
						
						draw_vertex_texture_color(xc, yc, .5, .5, cc, aa);
						draw_vertex_texture_color(x0, y0,  1,  1, cc, aa);
						draw_vertex_texture_color(x2, y2,  0,  1, cc, aa);
					draw_primitive_end();
					break;
				
				case 2 : // Line
					shader_set_f_array("lineShape", lineShape);
					shader_set_2("textureRange", [0,1]);
					
					var x0 = xx + lengthdir_x(ro, angle);
					var y0 = yy + lengthdir_y(ro, angle);
					
					var x1 = xx + lengthdir_x(ro, angle + 180);
					var y1 = yy + lengthdir_y(ro, angle + 180);
					
					var dx = lengthdir_x(lineThickness / 2, angle + 90);
					var dy = lengthdir_y(lineThickness / 2, angle + 90);
					
					var _x0 = x0 + dx, _y0 = y0 + dy;
					var _x1 = x0 - dx, _y1 = y0 - dy;
					var _x2 = x1 + dx, _y2 = y1 + dy;
					var _x3 = x1 - dx, _y3 = y1 - dy;
					
					draw_primitive_begin(pr_trianglelist);
						draw_vertex_texture_color(_x0, _y0, 0, 0, cc, 1);
						draw_vertex_texture_color(_x1, _y1, 0, 1, cc, 1);
						draw_vertex_texture_color(_x2, _y2, 1, 0, cc, 1);
						
						draw_vertex_texture_color(_x1, _y1, 0, 1, cc, 1);
						draw_vertex_texture_color(_x2, _y2, 1, 0, cc, 1);
						draw_vertex_texture_color(_x3, _y3, 1, 1, cc, 1);
					draw_primitive_end();
					break;
					
				case 3 : // Path
					if(array_length(pathData) < 2) break;
					shader_set_f_array("lineShape", lineShape);
					
					var len = array_length(pathData);
					var ox = pathData[0][0];
					var oy = pathData[0][1];
					var nx = pathData[1][0];
					var ny = pathData[1][1];
					var od = point_direction(ox, oy, nx, ny);
					var nd;
					
					var rcos  = cos(angle);
					var rsin  = sin(angle);
					var trans = [
						 lifeRatio * rcos,  lifeRatio * rsin, 0, 0, 
						 lifeRatio * rsin, -lifeRatio * rcos, 0, 0, 
						                0,                 0, 1, 0, 
						               xx,                yy, 0, 1
					];
					
					var stl = 1 / (len - 1);
					
					matrix_set(matrix_world, trans);
					for( var i = 1; i < len; i++ ) {
						nx = pathData[i][0];
						ny = pathData[i][1];
						nd = point_direction(ox, oy, nx, ny);
						
						shader_set_2("textureRange", [(i-1) * stl, i * stl]);
						draw_primitive_begin(pr_trianglelist);
						draw_line_width2_angle(ox, oy, nx, ny, lineThickness, lineThickness, od+90, nd+90, cc, cc);
						draw_primitive_end();
						
						ox = nx;
						oy = ny;
						od = nd;
					}
					matrix_set(matrix_world, MATRIX_IDENTITY);
					
					break;
			}
		shader_reset();
		BLEND_NORMAL
		
	}
}
