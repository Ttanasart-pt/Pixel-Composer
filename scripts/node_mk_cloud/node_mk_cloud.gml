function Node_MK_Cloud(_x, _y, _group = noone) : Node_Processor(_x, _y, _group) constructor {
	name = "MK Cloud";
	
	////- =Seed
	newInput( 1, nodeValueSeed());
	newInput(57, nodeValue_Bool(   "Positional",     false      ));
	
	////- =Output
	newInput( 0, nodeValue_Dimension());
	
	////- =Cloud
	newInput(31, nodeValue_EString( "Shape", "Circle", [ "Circle", "Leaf", "Surface" ] ));
	newInput(49, nodeValue_Surface( "Cloud Mask"      ));
	newInput(50, nodeValue_Int(     "Attempt", 8      ));
	
	newInput(12, nodeValue_Int(   "Layers",    2      ));
	newInput( 2, nodeValue_Int(   "Amount",    32     ))
		.setCurvable(15, CURVE_DEF_01, "Over Layer", "curved", THEME.mk_cloud_curve_layer )
	
		////- =/Transform
	newInput(11, nodeValue_Vec2(  "Position",       [.5,.5] )).setUnitSimple()
	newInput(28, nodeValue_Vec2(  "Position Shift", [0,0]   )).setUnitSimple()
	newInput( 3, nodeValue_Vec2(  "Size",           [.3,.3] )).setUnitSimple()
		.setCurvable(14, CURVE_DEF_01, "Over Layer", "curved", THEME.mk_cloud_curve_layer )
	
	////- =Puff
	newInput(54, nodeValue_EScroll(  "Shape", 0, [ 
		new scrollItem( "Circle",    s_node_shape_circle    ),
		new scrollItem( "Rectangle", s_node_shape_rectangle ),
		new scrollItem( "Diamond",   s_node_shape_diamond   ),
		new scrollItem( "Star",      s_node_shape_diamond   ),
		"Surface"
	] ));
	newInput(62, nodeValue_Surface( "Puff Surface" ));
	
	newInput( 4, nodeValue_Range(    "Puff Size",     [4,8]   ))
		.setCurvable( 6, CURVE_DEF_01, "Over Distance", "curved" )
		.setCurvable(18, CURVE_DEF_11, "Over Layer",    "curved_layer", THEME.mk_cloud_curve_layer )
	newInput(51, nodeValue_Vec2(     "Aspect",        [1,1]   ));
	newInput(52, nodeValue_RotRange( "Angle",         [0,0]   ));
	
		////- =/Subtract
	newInput(45, nodeValue_Bool(   "Use Subtract",     false      ));
	newInput(46, nodeValue_Slider( "Subtract Chance",  .5         ));
	newInput(47, nodeValue_Range(  "Size Padding",    [2,2], true ));
	newInput(48, nodeValue_Float(  "Offset",           4          ));
		
	////- =Base
	newInput( 9, nodeValue_Bool(   "Use Base",      true   ));
	newInput(61, nodeValue_Slider( "Chance",         1     ));
	newInput( 8, nodeValue_Float(  "Base Position", .8     ));
	newInput(10, nodeValue_Float(  "Base Spread",    1     ));
	newInput(13, nodeValue_Float(  "Base Shift",     1     ));
	
		////- =/Compress
	newInput(29, nodeValue_Bool(  "Scale",         true   ));
	newInput(19, nodeValue_Float( "Shift Scale",   32     ));
	newInput(34, nodeValue_Float( "Shift Stretch",  0     ));
	
	////- =Shading
	newInput(35, nodeValue_Bool(     "Use Shade",        true              ));
	newInput( 5, nodeValue_Range(    "Inner Radius",  [.6,.8]              ))
		.setCurvable(16, CURVE_DEF_11, "Over Layer", "curved", THEME.mk_cloud_curve_layer )
		
	newInput( 7, nodeValue_Rotation( "Direction",        135               ));
	newInput(17, nodeValue_Rotation( "Distance",         1                 ));
	
		////- =/Rendering
	newInput(56, nodeValue_EScroll(  "Blend Mode",       1, [ "Override", "Multiply", "Additive", "Subtract" ] ));
	newInput(33, nodeValue_Bool(     "Soft Shade",       false             ));
	newInput(25, nodeValue_Color(    "Color",            cola(c_ltgray, 1) ));
	
	////- =Rim
	newInput(63, nodeValue_Bool(     "Use Rim",          false             ));
	newInput(64, nodeValue_Rotation( "Direction",        135               ));
	newInput(65, nodeValue_Slider(   "Span",            .5                 ));
	newInput(66, nodeValue_Slider(   "Width",           .25                ));
	newInput(67, nodeValue_Color(    "Color",            ca_white          ));
	newInput(68, nodeValue_Float(    "Intensity",       .5                 ));
	
	////- =Spiral
	newInput(20, nodeValue_Bool(     "Use Spiral",       false             ));
	newInput(41, nodeValue_Slider(   "Chance",            1                ));
	newInput(21, nodeValue_Float(    "Spiral Amount",     1                ));
	newInput(23, nodeValue_RotRange( "Spiral Phase",     [0,360]           ));
	newInput(27, nodeValue_EScroll(  "Spiral Flip",       0, [ "CCW", "CW", "Random" ] ));
	newInput(22, nodeValue_Slider(   "Spiral Thickness", .4                ));
	
		////- =/Rendering
	newInput(55, nodeValue_EScroll(  "Blend Mode",       1, [ "Override", "Multiply", "Additive", "Subtract" ] ));
	newInput(26, nodeValue_Color(    "Color",            cola(c_ltgray, 1) ));
	newInput(30, nodeValue_Bool(     "Blend With Shade", true              ));
	
	////- =Layer Effect
	
		////- =/Outline
	newInput(42, nodeValue_Bool(     "Layer Outline", false    ));
	newInput(60, nodeValue_EButton(  "Side",          0, [ "Outside", "Inside" ] ));
	newInput(43, nodeValue_Float(    "Thickness",     1        ));
	newInput(44, nodeValue_Color(    "Color",         ca_white ));
	
		////- =/Shadow
	newInput(36, nodeValue_Bool(     "Layer Shadow", false    ));
	newInput(58, nodeValue_EScroll(  "Type",         0, [ "Drop", "Direction" ] ));
	newInput(37, nodeValue_Float(    "Radius",       4        ))
		.setCurvable(40, CURVE_DEF_11, "Over Layer", "curved", THEME.mk_cloud_curve_layer )
		
	newInput(59, nodeValue_Rotation( "Direction",  -45        ));
	newInput(38, nodeValue_Float(    "Strength",    .1        ));
	newInput(39, nodeValue_Color(    "Color",        ca_black ));
	
	////- =Rendering
	newInput(32, nodeValue_EScroll(  "Blend Mode",   0, [ "Normal", "Maximum", "Additive" ] ));
	newInput(24, nodeValue_Gradient( "Color",        gra_white ));
	newInput(53, nodeValue_Surface(  "Color Sampler"           ));
	// 69
	
	newOutput( 0, nodeValue_Output( "Surface Out", VALUE_TYPE.surface, noone ));
	
	input_display_list = [ s_MKFX, 
		[ "Seed",           false     ],  1, 57, 
		[ "Output",         false     ],  0, 
		[ "Cloud",          false     ], 31, 49, 50, 12,  2, 15, 
			[ "/Transform", false     ], 11, 28,  3, 14, 
			
		[ "Puff",           false     ], 54, 62,  4,  6, 18, 51, 52, 
			[ "/Subtract",  false, 45 ], 46, 47, 48, 
		
		[ "Base",            true, 9  ], 61,  8, 10, 13, 
			[ "/Compress",  false     ], 29, 19, 34, 
		
		[ "Rim Light",       true, 63 ], 64, 65, 66, 67, 68, 
			
		[ "Shading",         true, 35 ],  5, 16,  7, 17, 
			[ "/Rendering", false     ], 56, 33, 25, 
			
		[ "Spiral",          true, 20 ], 41, 21, 23, 27, 22, 
			[ "/Rendering", false     ], 55, 26, 30,
			
		[ "Layer Effect",    true,    ], 
			[ "/Outline",   false, 42 ], 60, 43, 44, 
			[ "/Shadow",    false, 36 ], 58, 37, 40, 59, 38, 39, 
		
		[ "Rendering",      false,    ], 32, 24, 53, 
	];
	
	////- Nodes
	
	attribute_surface_depth();
	
	temp_surface = array_create(5, noone);
	cloud_map    = [];
	colorSampler = new Surface_sampler();
	
	static drawOverlay = function(hover, active, _x, _y, _s, _mx, _my, _params) { 
		drawOverlayInput(inputs[11].drawOverlay(hover, active, _x, _y, _s, _mx, _my));
	}
	
	static processData = function(_outData, _data, _array_index = 0) { 
		#region data
			var seed    = _data[ 1];
			var seedPos = _data[57];
			
			var _dim    = _data[ 0];
			
			var _shape  = _data[31];
			var _shMap  = _data[49];
			var _attmp  = _data[50];
			
			var _layer  = _data[12];
			var _amou   = _data[ 2];
			var _amouC  = _data[15], _amouCurve = inputs[ 2].attributes.curved? new curveMap(_amouC) : undefined;
			
			var _pos    = _data[11];
			var _posL   = _data[28];
			var _size   = _data[ 3];
			var _sizeC  = _data[14], _sizeCurve = inputs[ 3].attributes.curved? new curveMap(_sizeC) : undefined;
			
			var _pshap  = _data[54];
			var _psurf  = _data[62];
			var _aspct  = _data[51];
			var _angle  = _data[52];
			var _radi   = _data[ 4];
			var _radiC  = _data[ 6], _radiCurve  = inputs[ 4].attributes.curved?       new curveMap(_radiC) : undefined;
			var _radiL  = _data[18], _radiCurveL = inputs[ 4].attributes.curved_layer? new curveMap(_radiL) : undefined;
			
			var _subUse = _data[45];
			var _subCha = _data[46];
			var _subPad = _data[47];
			var _subShf = _data[48];
			
			var _utrim  = _data[ 9];
			var _trmCh  = _data[61];
			var _trimY  = _data[ 8];
			var _trmSp  = _data[10];
			var _trmSh  = _data[13];
			var _trmS   = _data[29];
			var _trmSc  = _data[19];
			var _trmSt  = _data[34];
			
			var _rimUse = _data[63];
			var _rimDir = _data[64];
			var _rimSpa = _data[65];
			var _rimWid = _data[66];
			var _rimCol = _data[67];
			var _rimInt = _data[68];
			
			var _inuse  = _data[35];
			var _inrad  = _data[ 5];
			var _inrdC  = _data[16], _inrdCurve = inputs[ 5].attributes.curved? new curveMap(_inrdC) : undefined;
			var _indir  = _data[ 7];
			var _indis  = _data[17];
			
			var _inbld  = _data[56];
			var _inshd  = _data[33];
			var _incol  = _data[25];
			
			var _spUse  = _data[20];
			var _spCha  = _data[41];
			var _spAmo  = _data[21];
			var _spPha  = _data[23];
			var _spFlp  = _data[27];
			var _spThk  = _data[22];
			
			var _spbld  = _data[55];
			var _spcol  = _data[26];
			var _spshd  = _data[30];
			
			var _outl       = _data[42];
			var _outlSide   = _data[60];
			var _outlThk    = _data[43];
			var _outlCol    = _data[44];
			
			var _shadow     = _data[36];
			var _shadowType = _data[58];
			var _shadowRad  = _data[37];
			var _shadowRadC = _data[40], _shadRadCurve = inputs[37].attributes.curved? new curveMap(_shadowRadC) : undefined;
			var _shadowDir  = _data[59];
			var _shadowStr  = _data[38];
			var _shadowCol  = _data[39];
			
			var _blend = _data[32];
			var _color = _data[24]; _color.cache();
			var _csamp = _data[53];
			
			var _surfType = _shape == "Surface";
			inputs[49].setVisible(_surfType, _surfType);
			inputs[50].setVisible(_surfType);
			
			inputs[62].setVisible(_pshap == 4, _pshap == 4);
			
			inputs[37].setVisible(_shadowType == 0);
			inputs[59].setVisible(_shadowType == 1);
			
			colorSampler.setSurface(_csamp);
		#endregion
		
		random_set_seed(seed);
		draw_set_circle_precision(32);
			
		var ww = _dim[0];
		var hh = _dim[1];
		
		var s2 = sqrt(2);
		
		for( var i = 0, n = array_length(temp_surface); i < n; i++ ) {
			temp_surface[i] = surface_verify(temp_surface[i], ww, hh);
			surface_clear(temp_surface[i]);
		}
			
		_outData = surface_verify(_outData, ww, hh, attrDepth());
		
		if(_surfType) {
			if(!is_surface(_shMap)) return _outData;
			
			var _sMapW = surface_get_width(_shMap);
			var _sMapH = surface_get_height(_shMap);
			
			var _sAmount = _layer * _amou;
			cloud_map = get_points_from_dist(_shMap, _sAmount, seed, _attmp, cloud_map);
			cloud_map = array_filter(cloud_map, function(v,i) /*=>*/ { return v[0] != undefined && v[1] != undefined; })
			
			_sAmount = array_length(cloud_map);
			if(_sAmount <= 0) {
				surface_clear(_outData);
				return;
			}
		}
		
		var u_color         = shader_get_uniform( sh_mk_cloud_puff, "color"       );
		var u_scale         = shader_get_uniform( sh_mk_cloud_puff, "scale"       );
		
		var u_innerRadius   = shader_get_uniform( sh_mk_cloud_puff, "innerRadius" );
		
		var u_spiralUse     = shader_get_uniform( sh_mk_cloud_puff, "spiralUse"   );
		var u_spiralFlip    = shader_get_uniform( sh_mk_cloud_puff, "spiralFlip"  );
		var u_spiralPhase   = shader_get_uniform( sh_mk_cloud_puff, "spiralPhase" );
		
		shader_set(sh_mk_cloud_puff);
			shader_set_i( "shape",         _pshap );
			shader_set_s( "surface",       _psurf );
			
			shader_set_i( "innerUse",      _inuse );
			shader_set_f( "innerAngle",    _indir );
			shader_set_f( "innerDistance", _indis );
			
			shader_set_i( "innerBlend",    _inbld );
			shader_set_c( "innerColor",    _incol );
			shader_set_i( "innerShade",    _inshd );
			
			shader_set_i( "spiralUse",     _spUse );
			shader_set_f( "spiral",        _spAmo );
			shader_set_f( "spiralThick",   _spThk );
			
			shader_set_i( "spiralBlend",   _spbld );
			shader_set_c( "spiralColor",   _spcol );
			shader_set_i( "spiralShade",   _spshd );
			
			shader_set_i( "rimUse",        _rimUse );
			shader_set_f( "rimDirect",     _rimDir );
			shader_set_f( "rimSpan",       _rimSpa );
			shader_set_f( "rimWidth",      _rimWid );
			shader_set_c( "rimColor",      _rimCol );
			shader_set_f( "rimInten",      _rimInt );
		shader_reset();
		
		surface_set_target(_outData);
			DRAW_CLEAR
			
			var cx, cy;
			var _x, _y, _irad;
			var ty = undefined;
			var _indx = 0;
			
			for( var i = 0; i < _layer; i++ ) {
				surface_set_shader([temp_surface[0], temp_surface[1]], sh_mk_cloud_puff, true, BLEND.normal);
				
				var _layeri = 1 - i / _layer;
				_irad = 0;
				
				cx = _pos[0] + _posL[0] * i;
				cy = _pos[1] + _posL[1] * i;
				ty = ty ?? cy + _trimY * _size[1];
			    
				var _lsizes = _sizeCurve? _sizeCurve.get(_layeri) : _layeri;
				var _lsizex = _size[0] * _lsizes;
				var _lsizey = _size[1] * _lsizes;
				
				var _lamou  = _amou * (_amouCurve? _amouCurve.get(_layeri) : _layeri);
				var _linrad = _inrdCurve?  _inrdCurve.get(_layeri)  : 1;
				var _lrad   = _radiCurveL? _radiCurveL.get(_layeri) : 1;
				
				var _lcolr  = _color.evalFast(_layeri);
				var _valid  = true;
				
				shader_set_uniform_f_array( u_color, colToVec4(_lcolr) );
				
				repeat(_lamou) {
					switch(_shape) {
						case "Circle" :
							_irad = sqrt(random(1));
							
							var _dir  = random_range(0, 360);
							_x = cx + lengthdir_x(round(_lsizex * _irad), _dir);
							_y = cy + lengthdir_y(round(_lsizey * _irad), _dir);
							break;
							
						case "Leaf" : 
							var _xx = (random(1)) * choose(-1, 1);
							var _yy = random_range(-1, 1) * smoothstep(1. - abs(_xx));
							
							_x    = cx + _xx * _lsizex;
							_y    = cy + _yy * _lsizey;
							_irad = abs(_xx);
							break;
							
						case "Surface":
							var _pp = cloud_map[_indx];
							_indx = (_indx + 1) % _sAmount;
							if(_pp[0] == undefined || _pp[1] == undefined) _valid = false;
							
							_x    = (_pp[0] ?? 0) * _sMapW;
							_y    = (_pp[1] ?? 0) * _sMapH;
							_irad = 1 - (_pp[2] ?? 0);
							break;
						
						default : _valid = false; break;
					}
					
					if(!_valid) continue;
					
					if(seedPos) random_set_seed(seed + (_y * ww + _x) * 1000);
					
					var _ro  = lerp(_radi[0], _radi[1], _radiCurve? _radiCurve.get(1 - _irad) : 1 - _irad);
					    _ro *= _lrad;
					
					var _sx = _aspct[0];
					var _sy = _aspct[1];
					
					if(_utrim && random(1) <= _trmCh) {
						var ox  = _x;
						var ddx = _x - ((cx - _lsizex) + _lsizex * _trmSh);
						var ddy = max(0, _y - (ty - _ro));
						
						var dx  = ddy * ddx / _lsizex * _trmSp;
						
						var str = clamp(1 - (abs(dx) / _trmSc), 0, 1);
						var nro = _trmS? _ro * str : _ro;
						
						_x += dx;
						_y -= max(0, _y - (ty - nro));
						_ro = nro;
						
						var _compScal = (ddy / _trmSc) * _trmSt;
						_sx += _compScal;
						_sy -= _compScal;
						
						_y += _ro * _compScal;
					}
					
					_x  = round(_x);
					_y  = round(_y);
					
					if(colorSampler.active) {
						var _pufCol = colorMultiply(_lcolr, colorSampler.getPixel(_x, _y));
						shader_set_uniform_f_array( u_color, colToVec4(_pufCol) );
					}
					
					if(_spUse) shader_set_uniform_i( u_spiralUse, random(1) <= _spCha );
					shader_set_uniform_f( u_innerRadius, random_range(_inrad[0], _inrad[1]) * _linrad );
					shader_set_uniform_f( u_spiralPhase, random_range(_spPha[0], _spPha[1])           );
					shader_set_uniform_i( u_spiralFlip,  _spFlp == 2? choose(0,1) : _spFlp            );
					
					var rsx = _ro * _sx;
					var rsy = _ro * _sy;
					
					var dsx = ceil(rsx);
					var dsy = ceil(rsy);
					shader_set_uniform_f( u_scale, rsx / dsx, rsy / dsy);
					
					var _subPadd = random_range(_subPad[0], _subPad[1]);
					if(_subUse && random(1) <= _subCha) {
						gpu_set_colorwriteenable(0,0,0,1);
						BLEND_SUBTRACT
						draw_sprite_stretched(s_fx_pixel, 0, 
							_x - dsx + random_range(-_subShf, _subShf) - _subPadd, 
							_y - dsy + random_range(-_subShf, _subShf) - _subPadd, 
							dsx * 2 + _subPadd * 2, dsy * 2 + _subPadd * 2);
						gpu_set_colorwriteenable(1,1,1,1);
					}
					
					switch(_blend) { 
						case 0: BLEND_NORMAL; break; 
						case 1: BLEND_MAX;    break;
						case 2: BLEND_ADD;    break;
					}
					
					var _ang = random_range(_angle[0], _angle[1]);
					draw_sprite_ext(s_fx_pixel2, 0, _x, _y, dsx, dsy, _ang);
				}
				
				surface_reset_shader();
				
				BLEND_NORMAL
				
				var _cloudLayer = temp_surface[0];
				gpu_set_colorwriteenable(1,1,1,1);
				
				if(_outl) {
					surface_set_shader(temp_surface[2], sh_mk_cloud_outline);
					shader_set_2( "dimension", _dim     );
					
					shader_set_i( "side",      _outlSide );
					shader_set_f( "thickness", _outlThk  );
					shader_set_c( "color",     _outlCol  );
					draw_surface(_cloudLayer, 0, 0);
					surface_reset_shader();
					
					_cloudLayer = temp_surface[2];
				}
				
				if(i && _shadow) {
					surface_set_shader(temp_surface[3], sh_mk_cloud_shadow);
					shader_set_2( "dimension", _dim        );
					
					shader_set_i( "type",      _shadowType );
					shader_set_f( "radius",    _shadowRad * (_shadRadCurve? _shadRadCurve.get(_layeri) : 1) );
					shader_set_f( "direction", _shadowDir  );
					shader_set_f( "strength",  _shadowStr  );
					shader_set_c( "color",     _shadowCol  );
					draw_surface(_cloudLayer, 0, 0);
					surface_reset_shader();
					
					_cloudLayer = temp_surface[3];
					gpu_set_colorwriteenable(1,1,1,0);
				}
				
				// printSurface($"_cloudLayer{i}", _cloudLayer)
				draw_surface(_cloudLayer, 0, 0);
				
				if(_blend == 1) {
					gpu_set_colorwriteenable(1,1,1,0);
					draw_surface(temp_surface[1], 0, 0);
				}
				
				gpu_set_colorwriteenable(1,1,1,1);
			}
			
			BLEND_NORMAL
		surface_reset_target();
		
		return _outData;
	}
}