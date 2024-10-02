global.node_repeat_keys = [ "repeat polar", "repeat circular" ];

function Node_create_Repeat(_x, _y, _group = noone, _param = {}) {
	var _node = new Node_Repeat(_x, _y, _group).skipDefault();
	var query = struct_try_get(_param, "query", "");
	
	switch(query) {
		case "repeat polar" : 
		case "repeat circular" : 
			_node.inputs[3].setValue(2);
			_node.inputs[9].unit.setMode(VALUE_UNIT.reference);
			_node.inputs[9].setValueDirect([ 0.5, 0.5 ]);
			break;
	}
	
	return _node;
} 

function Node_Repeat(_x, _y, _group = noone) : Node_Processor(_x, _y, _group) constructor {
	name = "Repeat";
	dimension_index = 1;
	
	newInput(0, nodeValue_Surface("Surface in", self));
	
	newInput(1, nodeValue_Dimension(self));
	
	newInput(2, nodeValue_Int("Amount", self, 2))
		.rejectArray();
	
	newInput(3, nodeValue_Enum_Scroll("Pattern", self,  0, [ new scrollItem("Linear",   s_node_repeat_axis, 0), 
												             new scrollItem("Grid",     s_node_repeat_axis, 1), 
												             new scrollItem("Circular", s_node_repeat_axis, 2), ]));
	
	newInput(4, nodeValue_Vec2("Shift position", self, [ DEF_SURF_W / 2, 0 ]))
		.setUnitRef(function() { return getDimension(); });
	
	newInput(5, nodeValue_Rotation_Range("Repeat rotation", self, [0, 0]));
	
	newInput(6, nodeValue_Float("Scale multiply", self, 1));
	
	newInput(7, nodeValue_Rotation_Range("Angle range", self, [0, 360]));
	
	newInput(8, nodeValue_Float("Radius", self, 1));
		
	newInput(9, nodeValue_Vec2("Start position", self, [0, 0]))
		.setUnitRef(function(index) { return getInputData(1); });
		
	newInput(10, nodeValue("Scale over copy", self, CONNECT_TYPE.input, VALUE_TYPE.curve, CURVE_DEF_11 ));
	
	newInput(11, nodeValue_PathNode("Path", self, noone, "Make each copy follow along path." ))
		.setVisible(true, true);
	
	newInput(12, nodeValue_Slider_Range("Path range", self, [0, 1]))
		.setTooltip("Range of the path to follow.");
	
	newInput(13, nodeValue_Float("Path shift", self, 0));
	
	newInput(14, nodeValue_Gradient("Color over copy", self, new gradientObject(cola(c_white))))
		.setMappable(30);
		
	newInput(15, nodeValue("Alpha over copy", self, CONNECT_TYPE.input, VALUE_TYPE.curve, CURVE_DEF_11 ));
	
	newInput(16, nodeValue_Enum_Button("Array select", self, 0, [ "Order", "Random", "Spread" ]))
		.setTooltip("Whether to select image from an array in order, at random, or spread each image to its own output.");
	
	newInput(17, nodeValue_Int("Seed", self, seed_random(6)))
		.setDisplay(VALUE_DISPLAY._default, { side_button : button(function() { randomize(); inputs[17].setValue(seed_random(6)); }).setIcon(THEME.icon_random, 0, COLORS._main_icon) });
	
	newInput(18, nodeValue_Int("Column", self, 4));
	
	newInput(19, nodeValue_Vec2("Column shift", self, [0, DEF_SURF_H / 2]))
		.setUnitRef(function() { return getDimension(); });
	
	/* deprecated */ newInput(20, nodeValue_Float("Animator midpoint", self, 0.5))                                          
		               .setDisplay(VALUE_DISPLAY.slider, { range: [-1, 2, 0.01] });
	
	/* deprecated */ newInput(21, nodeValue_Float("Animator range", self, 0.1))                                             
		               .setDisplay(VALUE_DISPLAY.slider);
	
	/* deprecated */ newInput(22, nodeValue_Vec2("Animator position", self, [ 0, 0 ]));                                     
	
	/* deprecated */ newInput(23, nodeValue_Rotation("Animator rotation", self, 0));                                        
		
	/* deprecated */ newInput(24, nodeValue_Vec2("Animator scale", self, [ 0, 0 ]));                                        
		
	/* deprecated */ newInput(25, nodeValue("Animator falloff", self, CONNECT_TYPE.input, VALUE_TYPE.curve, CURVE_DEF_10)); 
	 
	newInput(26, nodeValue_Enum_Button("Stack", self,  0, [ "None", "X", "Y" ]))
		.setTooltip("Place each copy next to each other, taking surface dimension into account.");
	
	/* deprecated */ newInput(27, nodeValue_Color("Animator blend", self, cola(c_white)));                                  
	
	/* deprecated */ newInput(28, nodeValue_Float("Animator alpha", self, 1))                                               
		               .setDisplay(VALUE_DISPLAY.slider);
	
	/* deprecated */ newInput(29, nodeValue_Bool("Animator", self, false))                                                  
	
	//////////////////////////////////////////////////////////////////////////////////////////////////
	
	newInput(30, nodeValueMap("Gradient map", self));
	
	newInput(31, nodeValueGradientRange("Gradient map range", self, inputs[14]));
	
	//////////////////////////////////////////////////////////////////////////////////////////////////
	
	newInput(32, nodeValue_Rotation("Start rotation", self, 0));
		
	newInput(33, nodeValue_Rotation("Rotation", self, 0));
		
	newInput(34, nodeValue_Enum_Scroll("Blend Mode", self,  0, [ "Normal", "Additive", "Maximum" ]));
	
	newInput(35, nodeValue_Enum_Scroll("Output dimension type", self, OUTPUT_SCALING.constant, [
																			new scrollItem("Same as input"),
																			new scrollItem("Constant"),
																			new scrollItem("Relative to input").setTooltip("Set dimension as a multiple of input surface."),
																			new scrollItem("Fit content").setTooltip("Automatically set dimension to fit content."),
																		]));
	
	newInput(36, nodeValue_Vec2("Relative dimension", self, [ 1, 1 ]));
	
	newInput(37, nodeValue_Padding("Padding", self, [ 0, 0, 0, 0 ]));
	
	newOutput(0, nodeValue_Output("Surface out", self, VALUE_TYPE.surface, noone));
	
	input_display_list = [
		["Surfaces",	 true],	0, 35, 36, 37, 1, 16, 17,
		["Pattern",		false],	3, 9, 32, 2, 18, 7, 8, 
		["Path",		 true],	11, 12, 13, 
		["Position",	false],	4, 26, 19, 
		["Rotation",	false],	33, 5, 
		["Scale",		false],	6, 10, 
		["Render",		false],	34, 14, 30, 
		//["Animator",	 true, 29],	20, 21, 25, 22, 23, 24, 27, 
	];
	
	attribute_surface_depth();
	attribute_interpolation();
	
	static drawOverlay = function(hover, active, _x, _y, _s, _mx, _my, _snx, _sny) {
		PROCESSOR_OVERLAY_CHECK
		
		var _hov = false;
		var  hv  = inputs[9].drawOverlay(hover, active, _x, _y, _s, _mx, _my, _snx, _sny); active &= !hv; _hov |= hv;
		
		var _pat  = current_data[3];
		var _spos = current_data[9];
		
		var px = _x + _spos[0] * _s;
		var py = _y + _spos[1] * _s;
		
		if(_pat == 0 || _pat == 1) { var hv = inputs[4].drawOverlay(hover, active, px, py, _s, _mx, _my, _snx, _sny); active &= !hv; _hov |= hv; }
		else if(_pat == 2)         { var hv = inputs[8].drawOverlay(hover, active, px, py, _s, _mx, _my, _snx, _sny); active &= !hv; _hov |= hv; }
		
		var hv = inputs[31].drawOverlay(hover, active, _x, _y, _s, _mx, _my, _snx, _sny, current_data[1]); active &= !hv; _hov |= hv;
		
		return _hov;
	}
	
	static preGetInputs = function() {
		var _arr = getSingleValue(16);
		var _pat = getSingleValue(3);
		
		inputs[ 0].setArrayDepth(_arr != 2);
		
		inputs[ 4].setVisible( _pat == 0 || _pat == 1);
		inputs[ 7].setVisible( _pat == 2);
		inputs[ 8].setVisible( _pat == 2);
		inputs[18].setVisible( _pat == 1);
		inputs[19].setVisible( _pat == 1);
		inputs[26].setVisible( _pat == 0);
		inputs[32].setVisible( _pat == 2);
		
		inputs[14].mappableStep();
	}
	
	static processData = function(_outSurf, _data, _output_index, _array_index) {	
		
		var _iSrf = _data[ 0];
		
		var _dimt = _data[35];
		var _dimc = _data[ 1];
		var _dims = _data[36];
		var _padd = _data[37];
		
		var _amo  = _data[ 2];
		var _pat  = _data[ 3];
							  
		var _spos = _data[ 9];
		var _srot = _data[32];
		
		var _rpos = _data[ 4];
		var _rsta = _data[26];
		var _rrot = _data[ 5];
		var _rots = _data[33];
		var _rsca = _data[ 6];
		var _msca = _data[10];
		
		var _aran = _data[ 7];
		var _arad = _data[ 8];
		
		var _path = _data[11];
		var _prng = _data[12];
		var _prsh = _data[13];
		
		var _grad       = _data[14];
		var _grad_map   = _data[30];
		var _grad_range = _data[31];
		
		var _arr = _data[16];
		var _sed = _data[17];
		
		var _col = _data[18];
		var _cls = _data[19];
		
		var _bld_md = _data[34];
		
		var _surf, runx, runy, posx, posy, scax, scay, rot;
		var _dim;
		
		var _surf = _iSrf, _sdim = [ 1, 1 ];
		
		var minx =  999999, miny =  999999;
		var maxx = -999999, maxy = -999999;
		
		if(is_array(_surf)) {
			for( var i = 0, n = array_length(_surf); i < n; i++ ) {
				var _ddim = surface_get_dimension(_surf[i]);
				_sdim[0] = max(_sdim[0], _ddim[0]);
				_sdim[1] = max(_sdim[1], _ddim[1]);
			}
			
		} else if(is_surface(_surf))
			_sdim = surface_get_dimension(_surf);
		
		random_set_seed(_sed);
		
		var atlases = array_create(_amo, 0);
		var atlas_i = 0;
		runx = 0;
		runy = 0;
		
		for( var i = 0; i < _amo; i++ ) {
			posx = runx;
			posy = runy;
			
			if(_pat == 0) {
				if(_path == noone || !variable_struct_exists(_path, "getPointRatio")) {
					posx += _spos[0] + _rpos[0] * i;
					posy += _spos[1] + _rpos[1] * i;
				} else {
					var rat = _prsh + _prng[0] + (_prng[1] - _prng[0]) * i / _amo;
					if(_prng[1] - _prng[0] == 0) break;
					rat = abs(frac(rat));
					
					var _p = _path.getPointRatio(rat);
					posx = _p.x;
					posy = _p.y;
				}
			} else if(_pat == 1) {
				var row = floor(i / _col);
				var col = safe_mod(i, _col);
				
				posx = _spos[0] + _rpos[0] * col + _cls[0] * row;
				posy = _spos[1] + _rpos[1] * col + _cls[1] * row;
				
			} else if(_pat == 2) {
				var aa = _srot + lerp(_aran[0], _aran[1], i / _amo);
				posx = _spos[0] + lengthdir_x(_arad, aa);
				posy = _spos[1] + lengthdir_y(_arad, aa);
			}
			
			scax = eval_curve_x(_msca, i / (_amo - 1)) * _rsca;
			scay = scax;
			rot = _rots + _rrot[0] + (_rrot[1] - _rrot[0]) * i / _amo;
			
			var _surf = _iSrf;
			if(is_array(_iSrf)) {
				var _sid = 0;
				
				     if(_arr == 0) _sid = safe_mod(i, array_length(_iSrf));
				else if(_arr == 1) _sid = irandom(array_length(_iSrf) - 1);
				
				_surf = array_safe_get_fast(_iSrf, _sid);
			}
			
			if(!is_surface(_surf)) continue;
			
			var _sw = surface_get_width_safe(_surf);
			var _sh = surface_get_height_safe(_surf);
			var sw = _sw * scax;
			var sh = _sh * scay;
			
			if(i) {
				if(_rsta == 1) { 
					runx += _sw / 2;
					posx += _sw / 2;
				}
				if(_rsta == 2) { 
					runy += _sh / 2;
					posy += _sh / 2;
				}
			}
			
			var pos = point_rotate(-sw / 2, -sh / 2, 0, 0, rot);
			var cc  = evaluate_gradient_map(i / (_amo - 1), _grad, _grad_map, _grad_range, inputs[14]);
			var aa  = _color_get_alpha(cc);
			
			////////////////////////////////////////// animator system goes here...
			
			minx = min(minx, posx + pos[0], posx - pos[0], posx + pos[1], posx - pos[1]);
			miny = min(miny, posy + pos[0], posy - pos[0], posy + pos[1], posy - pos[1]);
			maxx = max(maxx, posx + pos[0], posx - pos[0], posx + pos[1], posx - pos[1]);
			maxy = max(maxy, posy + pos[0], posy - pos[0], posy + pos[1], posy - pos[1]);
			
			atlases[atlas_i++] = {
				surface : _surf, 
				x       : posx + pos[0], 
				y       : posy + pos[1], 
				sx      : scax, 
				sy      : scay, 
				rot     : rot, 
				color   : cc, 
				alpha   : aa
			};
			
			if(_rsta == 1)	runx += _sw / 2;
			if(_rsta == 2)	runy += _sh / 2;
		}
		
		array_resize(atlases, atlas_i);
		inputs[ 1].setVisible(false);
		inputs[36].setVisible(false);
		inputs[37].setVisible(false);
			
		switch(_dimt) {
			case OUTPUT_SCALING.same_as_input :
				_dim = _sdim;
				break;
				
			case OUTPUT_SCALING.constant :
				inputs[ 1].setVisible(true);

				_dim = _dimc;
				break;
				
			case OUTPUT_SCALING.relative :
				inputs[36].setVisible(true);
				
				_dim = [ _sdim[0] * _dims[0], _sdim[1] * _dims[1] ];
				break;
				
			case OUTPUT_SCALING.scale :
				inputs[37].setVisible(true);
				
				_dim = [ 
					abs(maxx - minx) + _padd[0] + _padd[2], 
					abs(maxy - miny) + _padd[1] + _padd[3] 
				];
				break;
				
		}
		
		_outSurf = surface_verify(_outSurf, _dim[0], _dim[1]);
		var _x, _y;
		
		surface_set_shader(_outSurf);
			     if(_bld_md == 0) { BLEND_ALPHA_MULP }
			else if(_bld_md == 1) { BLEND_ADD        }
			else if(_bld_md == 2) { BLEND_MAX        }
			
			for( var i = 0, n = array_length(atlases); i < n; i++ ) {
				var _a = atlases[i];
				
				shader_set_interpolation(_a.surface);
				var _x = _a.x;
				var _y = _a.y;
				
				if(_dimt == OUTPUT_SCALING.scale) {
					_x += _padd[2] - minx;
					_y += _padd[1] - miny;
				}
				
				draw_surface_ext_safe(_a.surface, _x, _y, _a.sx, _a.sy, _a.rot, _a.color, _a.alpha);
			}
			
			BLEND_NORMAL
		surface_reset_shader();
		
		return _outSurf;
	}
}