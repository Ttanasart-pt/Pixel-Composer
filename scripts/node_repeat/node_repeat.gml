#region functions
	global.node_repeat_keys = [ "repeat polar", "repeat circular" ];
	
	function Node_create_Repeat(_x, _y, _group = noone, _param = {}) {
		var node = new Node_Repeat(_x, _y, _group);
		node.skipDefault();
		
		var quer = _param[$ "query"]; var query = (is_struct(quer) && quer[$ "type"] == "alias"? quer[$ "value"] : "") ?? "";
		
		switch(query) {
			case "repeat polar" : 
			case "repeat circular" : 
				node.inputs[3].skipDefault().setValue(2);
				node.inputs[5].skipDefault().setValue([0,360]);
				break;
		}
		
		return node;
	}
	
	FN_NODE_CONTEXT_INVOKE {
		addHotkey("Node_Repeat", "Pattern > Toggle", "P", MOD_KEY.none, function() /*=>*/ { GRAPH_FOCUS _n.inputs[3].setValue((_n.inputs[3].getValue() + 1) % 3); });
	});
	
#endregion

function Node_Repeat(_x, _y, _group = noone) : Node_Processor(_x, _y, _group) constructor {
	name = "Repeat";
	dimension_index = 1;
	
	////- =Surfaces
	newInput( 0, nodeValue_Surface(     "Surface In" ));
	newInput(35, nodeValue_EScroll(     "Output Dimension Type", OUTPUT_SCALING.constant, [
        new scrollItem( "Same as input"),
        new scrollItem( "Constant"),
        new scrollItem( "Relative to input").setTooltip("Set dimension as a multiple of input surface."),
        new scrollItem( "Fit content").setTooltip("Automatically set dimension to fit content."),
    ]));
    
	newInput(36, nodeValue_Vec2(        "Relative Dimension", [1,1]     ));
	newInput(37, nodeValue_Padding(     "Padding",            [0,0,0,0] ));
	newInput( 1, nodeValue_Dimension());
	newInput(16, nodeValue_EButton(     "Array Select",        0 )).setChoices([ "Order", "Random", "Spread" ])
		.setTooltip("Whether to select image from an array in order, at random, or spread each image to its own output.");
	newInput(17, nodeValueSeed());
	
	////- =Pattern
	newInput( 3, nodeValue_EScroll(  "Pattern",          0, __enum_array_gen([ "Linear", "Grid", "Circular"], s_node_repeat_axis) ));
	newInput( 9, nodeValue_Vec2(     "Start Position",  [.5,.5] )).setHotkey("G").setUnitSimple();
	newInput(22, nodeValue_Anchor(   "Global Anchor",   [ 0, 0] ));
	newInput(32, nodeValue_Rotation( "Start Rotation",   0      )).setHotkey("R");
	newInput( 2, nodeValue_Int(      "Amount",           2      ));
	newInput(18, nodeValue_Int(      "Column",           4      ));
	newInput( 7, nodeValue_RotRange( "Angle Range",     [0,360] ));
	newInput( 8, nodeValue_Float(    "Radius",          .25     )).setUnitSimple();
	
	////- =Path
	newInput(11, nodeValue_PathNode( "Path",            noone   )).setTooltip("Make each copy follow along path.");
	newInput(12, nodeValue_SliRange( "Path Range",      [0,1]   )).setTooltip("Range of the path to follow.");
	newInput(13, nodeValue_Float(    "Path Shift",       0      ));
	newInput(40, nodeValue_Bool(     "Rotate Along Path", false ));
	
	////- =Position
	newInput( 4, nodeValue_Vec2(       "Shift Position",  [.5,0]     )).setUnitSimple().setCurvable(38, CURVE_DEF_11, "Over Copy");
	newInput(26, nodeValue_EButton(    "Stack",             0,       )).setChoices([ "None", "X", "Y" ]).setTooltip("Place each copy next to each other, taking surface dimension into account.");
	newInput(19, nodeValue_Vec2(       "Shift Column",     [0,.5]    )).setUnitSimple();
	newInput(39, nodeValue_Anchor(     "Anchor"                      ));
	newInput(15, nodeValue_Vec2_Range( "Random Position", [0,0,0,0]  ));
	newInput(44, nodeValue_Float(     "Use Shift as Endpoint", false ));
	
	////- =Rotation
	newInput(33, nodeValue_Rotation( "Base Rotation",     0          ));
	newInput( 5, nodeValue_RotRange( "Repeat Rotation",  [0,0]       ));
	newInput(20, nodeValue_RotRand(  "Random Rotation",  [0,0,0,0,0] ));
	
	////- =Scale
	newInput(29, nodeValue_Bool(       "Uniform Scale",  true     ))
	newInput( 6, nodeValue_Float(      "Scale X",        1,       )).setCurvable(10, CURVE_DEF_11, "Over Copy")
	newInput(41, nodeValue_Float(      "Scale Y",        1,       )).setCurvable(42, CURVE_DEF_11, "Over Copy")
	newInput(21, nodeValue_Vec2_Range( "Random Scale",  [1,1,1,1] ));
	
	////- =Render
	newInput(43, nodeValue_Bool(     "Inverse Draw Order", false  ));
	newInput(34, nodeValue_EScroll(  "Blend Mode",        0, [ "Normal", "Additive", "Maximum" ] ));
	newInput(14, nodeValue_Gradient( "Color Over Copy",   gra_white           )).setMappable(30);
	newInput(23, nodeValue_Gradient( "Random Color",      gra_white           ));
	
	////- =Deprecated
	/* deprecated */ newInput(24, nodeValue_Vec2(     "Animator scale",     [0,0]             ));
	/* deprecated */ newInput(25, nodeValue_Curve(    "Animator falloff",   CURVE_DEF_10      ));
	/* deprecated */ newInput(27, nodeValue_Color(    "Animator blend",     ca_white          ));
	/* deprecated */ newInput(28, nodeValue_Slider(   "Animator alpha",     1                 ));
	// input 45
	
	newOutput(0, nodeValue_Output("Surface Out", VALUE_TYPE.surface, noone));
	
	typeList = [ "Linear Transform", "Blending" ];
	enum_select_mode = __enum_array_gen(["Index", "Area", "Surface"], s_node_repeat_selection_types);
	
	function createNewInput(i = array_length(inputs)) {
		var inAmo = array_length(inputs);
		
		dynamic_input_inspecting = getInputAmount();
		
		////- =Selection
		
		newInput(i+ 1, nodeValue_EScroll(  "Select mode",             0, enum_select_mode ));
		newInput(i+ 9, nodeValue_Area(     "Selection area",          DEF_AREA_REF        )).setUnitSimple();
		newInput(i+10, nodeValue_Float(    "Selection i",             0                   ));
		newInput(i+11, nodeValue_Float(    "Selection range",         2                   ));
		newInput(i+12, nodeValue_Float(    "Selection falloff",       0                   ));
		newInput(i+13, nodeValue_Curve(    "Selection falloff curve", CURVE_DEF_10        ));
		newInput(i+14, nodeValue_Surface(  "Selection surface" ));
		
		////- =Effects
		
		newInput(i+ 0, nodeValue_EScroll(  "Animator type",     0, typeList               ));
		newInput(i+ 2, nodeValue_Vec2(     "Position",         [0,0]                      ));
		newInput(i+ 3, nodeValue_Rotation( "Rotation",          0                         ));
		newInput(i+ 4, nodeValue_Vec2(     "Scale",            [0,0]                      ));
		newInput(i+ 5, nodeValue_EButton(  "Anchor type",       1, [ "Global", "Local" ]  ));
		newInput(i+ 6, nodeValue_Vec2(     "Anchor Position", [.5,.5])).setTooltip("Anchor point for transformation, absolute value for global type, relative for local.");
		newInput(i+ 7, nodeValue_Color(    "Color",             ca_white                  ));
		newInput(i+ 8, nodeValue_Slider(   "Alpha",             0, [ -1, 1, 0.01 ]        ));
		newInput(i+15, nodeValue_Slider(   "Strength",          0, [ -1, 1, 0.01 ]        ));
		
		refreshDynamicDisplay();
		return inputs[i];
	} 
	
	input_display_dynamic = [ 
		["Selection", false], 1, 9, 10, 11, 12, 13, 14, 
		["Effects",   false], 0, 2, 3, 4, 5, 6, 7, 8, 15, 
	];
	
	animator_renderer = new Inspector_Custom_Renderer(function(_x, _y, _w, _m, _hover, _focus) {
		var bs = ui(24);
		var bx = _x + ui(20);
		var by = _y;
		if(buttonInstant(THEME.button_hide_fill, bx, by, bs, bs, _m, _hover, _focus, "", THEME.add_16, 0, COLORS._main_value_positive) == 2) {
			createNewInput();
			triggerRender();
		}
		
		draw_set_text(f_p1, fa_left, fa_center, COLORS._main_text_sub);
		draw_text_add(bx + bx + ui(8), by + bs / 2, "Animators");
		
		var amo = getInputAmount();
		var lh  = ui(28);
		var _h  = ui(12) + lh * amo;
		var yy  = _y + bs + ui(4);
		
		var del_animator = -1;
		draw_sprite_stretched_ext(THEME.ui_panel_bg, 1, _x, yy, _w, _h, COLORS.node_composite_bg_blend, 1);
		if(array_length(current_data) != array_length(inputs)) return _h + ui(32);
		
		for(var i = 0; i < amo; i++) {
			var _x0 = _x + ui(24);
			var _x1 = _x + _w - ui(16);
			var _yy = ui(6) + yy + i * lh + lh / 2;
			
			var _ind  = input_fix_len + i * data_length;
			var _dtyp = current_data[_ind + 0];
			var _styp = current_data[_ind + 1];
			var cc    = i == dynamic_input_inspecting? COLORS._main_icon : COLORS._main_icon;
			var tc    = i == dynamic_input_inspecting? COLORS._main_text_accent : COLORS._main_icon;
			var hov   = _hover && point_in_rectangle(_m[0], _m[1], _x0, _yy - lh / 2, _x1, _yy + lh / 2 - 1);
			
			if(hov && _m[0] < _x1 - ui(32)) {
				tc = COLORS._main_text;
				
				if(mouse_press(mb_left, _focus)) {
					dynamic_input_inspecting = i;
					refreshDynamicDisplay();
				}
			}
			
			draw_sprite_ext(s_node_repeat_selection_types, _styp, _x0 + ui(8), _yy, 1, 1, 0, cc);
			
			draw_set_text(f_p2, fa_left, fa_center, tc);
			draw_text_add(_x0 + ui(28), _yy, typeList[_dtyp]);
			
			var bs = ui(24);
			var bx = _x1 - bs;
			var by = _yy - bs / 2;
			if(buttonInstant(THEME.button_hide_fill, bx, by, bs, bs, _m, _hover, _focus, "", THEME.minus_16, 0, hov? COLORS._main_value_negative : COLORS._main_icon) == 2) 
				del_animator = i;	
		}
		
		if(del_animator > -1) 
			deleteDynamicInput(del_animator);
		
		return _h + ui(32);
	});
	
	b_gridFill = button(function() /*=>*/ {return gridFill()}).setIcon(THEME.fill, 0, COLORS._main_icon).setTooltip("Fill");
	
	input_display_list = [
		[ "Surfaces",  true ],  0, 35, 36, 37,  1, 16, 17,
		[ "Pattern",  false ],  3,  9, 22, 32,  2, 18,  7,  8, 
		[ "Path",      true ], 11, 12, 13, 40, 
		[ "Position", false ],  4, 38, 26, 19, 39, 15, 44, 
		[ "Rotation", false ], 33,  5, 20, 
		[ "Scale",    false ], 29,  6, 10, 41, 42, 21, 
		[ "Render",   false ], 43, 34, 14, 30, 23, 
		new Inspector_Spacer(8, true),
		new Inspector_Spacer(2, false, false),
		animator_renderer, 
	];
	
	setDynamicInput(16, false);
	
	////- Nodes
	
	output_dimension = [];
	surface_atlases  = [];
	grad_sampler = new Surface_sampler();
	anim_sampler = [];
	
	shift_curve  = new curveMap();
	scalex_curve = new curveMap();
	scaley_curve = new curveMap();
	anim_fall_curves = [];
	
	__temp_p   = [0,0];
	__temp_pth = new __vec2P();
	
	enum ATLAS_ARRAY {
		surface,
		x,
		y,
		cx,
		cy,
		sx,
		sy,
		sw,
		sh,
		rot,
		color,
		alpha,
		length, 
	}
	
	attribute_surface_depth();
	attribute_interpolation();
	
	static gridFill = function(index = preview_index) {
		var _iSrf = getInputData(0);
		
		var _dim  = array_safe_get(output_dimension, index, [1,1]);
		var _sdim = [ 1, 1 ];
		
		if(is_array(_iSrf)) {
			for( var i = 0, n = array_length(_iSrf); i < n; i++ ) {
				var _ddim = surface_get_dimension(_iSrf[i]);
				_sdim[0] = max(_sdim[0], _ddim[0]);
				_sdim[1] = max(_sdim[1], _ddim[1]);
			}
			
		} else if(is_surface(_iSrf))
			_sdim = surface_get_dimension(_iSrf);
		
		var _amox = floor(_dim[0] / _sdim[0]);
		var _amoy = floor(_dim[1] / _sdim[1]);
		
		inputs[ 9].setValue([0,0]);
		inputs[ 2].setValue(_amox * _amoy);
		inputs[18].setValue(_amox);
		
		inputs[ 4].setValue([_sdim[0], 0]);
		inputs[19].setValue([0, _sdim[1]]);
	}
	
	static getDimension = function() { return getInputData(1); }
	
	static drawOverlay = function(hover, active, _x, _y, _s, _mx, _my, _params) { 
		PROCESSOR_OVERLAY_CHECK
		
		var _hov = false;
		InputDrawOverlay(inputs[9].hideLabel().drawOverlay(w_hoverable, active, _x, _y, _s, _mx, _my));
		
		var _pat  = current_data[3];
		var _spos = current_data[9];
		
		var px = _x + _spos[0] * _s;
		var py = _y + _spos[1] * _s;
		
		draw_set_color(COLORS._main_accent);
		
		switch(_pat) {
			case 0 : // Linear
				var _rpos = current_data[4];
				var _rx = px + _rpos[0] * _s;
				var _ry = py + _rpos[1] * _s;
				
				draw_line_dashed(px, py, _rx, _ry);
				InputDrawOverlay(inputs[ 4].hideLabel().drawOverlay(w_hoverable, active, px, py, _s, _mx, _my));
				InputDrawOverlay(inputs[33].hideLabel().drawOverlay(w_hoverable, active, px, py, _s, _mx, _my));
				break;
				
			case 1 : // Grid
				var _rpos = current_data[ 4];
				var _cls  = current_data[19];
				var _rx   = px + _rpos[0] * _s;
				var _ry   = py + _rpos[1] * _s;
				var _clx  = px + _cls[0] * _s;
				var _cly  = py + _cls[1] * _s;
				
				draw_line_dashed(px, py,  _rx,  _ry);
				draw_line_dashed(px, py, _clx, _cly);
				
				InputDrawOverlay(inputs[ 4].hideLabel().drawOverlay(w_hoverable, active, px, py, _s, _mx, _my));
				InputDrawOverlay(inputs[19].hideLabel().drawOverlay(w_hoverable, active, px, py, _s, _mx, _my));
				InputDrawOverlay(inputs[33].hideLabel().drawOverlay(w_hoverable, active, px, py, _s, _mx, _my));
				break;
				
			case 2 : // Circular
				var _arad = current_data[ 8];
				var _srot = current_data[32];
				var _rx = px + lengthdir_x(_arad * _s, _srot);
				var _ry = py + lengthdir_y(_arad * _s, _srot);
				
				draw_line_dashed(px, py, _rx, _ry);
				draw_circle_dash(px, py, _arad * _s);
				
				InputDrawOverlay(inputs[ 8].hideLabel().drawOverlay(w_hoverable, active, px, py, _s, _mx, _my, _srot, 1, 1));
				InputDrawOverlay(inputs[32].hideLabel().drawOverlay(w_hoverable, active, px, py, _s, _mx, _my));
				InputDrawOverlay(inputs[33].hideLabel().drawOverlay(w_hoverable, active,_rx,_ry, _s, _mx, _my));
				break;
		}
		
		InputDrawOverlay(inputs[31].hideLabel().drawOverlay(w_hoverable, active, _x, _y, _s, _mx, _my, current_data[1]));
		InputDrawOverlay(inputs[11].hideLabel().drawOverlay(w_hoverable, active, _x, _y, _s, _mx, _my, _params));
		
		var _ani_amo = getInputAmount();
		if(_ani_amo == 0) return w_hovering;
		
		dynamic_input_inspecting = clamp(dynamic_input_inspecting, 0, getInputAmount() - 1);
		var _ind = input_fix_len + dynamic_input_inspecting * data_length;
		
		var _prop = current_data[_ind + 0];
		var _selc = current_data[_ind + 1];
		
		if(_selc == 1) InputDrawOverlay(inputs[_ind + 9].hideLabel().drawOverlay(w_hoverable, active, _x, _y, _s, _mx, _my));
		
		return w_hovering;
	}
	
	static preGetInputs = function() {
		var _arr = getInputSingle(16);
		var _pat = getInputSingle(3);
		
		inputs[ 0].setArrayDepth(_arr != 2);
		
		inputs[ 4].setVisible( _pat == 0 || _pat == 1);
		inputs[ 7].setVisible( _pat == 2);
		inputs[ 8].setVisible( _pat == 2);
		inputs[18].setVisible( _pat == 1);
		inputs[19].setVisible( _pat == 1);
		inputs[26].setVisible( _pat == 0);
		inputs[32].setVisible( _pat == 2);
	}
	
	static processData = function(_outSurf, _data, _array_index) {	
		#region data
			var _iSrf = _data[ 0];
			
			var _dimt = _data[35];
			var _dimc = _data[ 1];
			var _dimr = _data[36];
			var _padd = _data[37];
			
			var _amo  = _data[ 2];
			var _pat  = _data[ 3];
								  
			var _spos = _data[ 9];
			var _fanc = _data[22];
			var _srot = _data[32];
			
			var _rpos = _data[ 4], _rpos_curved = inputs[4].attributes.curved; shift_curve.set(_data[38]);
			var _panc = _data[39];
			var _pran = _data[15];
			var _pshf = _data[44];
			
			var _rsta = _data[26];
			var _rrot = _data[ 5];
			var _rots = _data[33];
			var _rran = _data[20];
			
			var _scaUni = _data[29];
			var _rscaX  = _data[ 6], _rscaX_curved = inputs[ 6].attributes.curved; scalex_curve.set(_data[10]);
			var _rscaY  = _data[41], _rscaY_curved = inputs[41].attributes.curved; scaley_curve.set(_data[42]);
			var _sran   = _data[21];
			
			var _aran = _data[ 7];
			var _arad = _data[ 8];
			
			var _path = _data[11];
			var _prng = _data[12];
			var _prsh = _data[13];
			var _pfol = _data[40];
			
			var _grad         = _data[14];
			var _grad_map     = _data[30];
			var _grad_range   = _data[31];
			var _grad_use_map = inputs[14].attributes.mapped && is_surface(_grad_map)
			var _cran         = _data[23];
			
			var _arr    = _data[16];
			var _sed    = _data[17];
			
			var _col    = _data[18];
			var _cls    = _data[19];
			var _invers = _data[43];
			var _bld_md = _data[34];
			
			inputs[3].getEditWidget().setSideButton(_pat == 1? b_gridFill : noone);
			
			inputs[41].setVisible(!_scaUni);
			inputs[42].setVisible(!_scaUni && _rscaY_curved);
			inputs[ 6].name = _scaUni? "Scale" : "Scale X";
			inputs[10].name = _scaUni? "Scale Over Copy" : "Scale X Over Copy";
			
			var _ani_amo = getInputAmount();
			if(_ani_amo > 0) { // animator visibility
				dynamic_input_inspecting = clamp(dynamic_input_inspecting, 0, getInputAmount() - 1);
				var _ind = input_fix_len + dynamic_input_inspecting * data_length;
				
				var _prop = _data[_ind + 0];
				var _selc = _data[_ind + 1];
				
				inputs[_ind +  2].setVisible(_prop == 0);
				inputs[_ind +  3].setVisible(_prop == 0);
				inputs[_ind +  4].setVisible(_prop == 0);
				inputs[_ind +  5].setVisible(_prop == 0);
				inputs[_ind +  6].setVisible(_prop == 0);
				inputs[_ind +  7].setVisible(_prop == 1);
				inputs[_ind +  8].setVisible(_prop == 1);
				// inputs[_ind + 15].setVisible(_prop == 2);
				
				inputs[_ind +  9].setVisible(_selc == 1);
				inputs[_ind + 11].setVisible(_selc == 0);
				inputs[_ind + 12].setVisible(_selc != 2);
				inputs[_ind + 13].setVisible(_selc != 2);
				inputs[_ind + 14].setVisible(_selc == 2, _selc == 2);
			}
			
			_grad.cache();
			_cran.cache();
			
			if(_grad_use_map) { 
				var _grad_map_w = surface_get_width(_grad_map);
				var _grad_map_h = surface_get_height(_grad_map);
					
				grad_sampler.setSurface(_grad_map);
			}
			
			anim_fall_curves = array_verify_min(anim_fall_curves, _ani_amo);
			anim_sampler     = array_verify(anim_sampler, _ani_amo);
			
			for( var j = 0; j < _ani_amo; j++ ) {
				var _ii = input_fix_len + j * data_length;
				
				if(!is(anim_fall_curves[j], curveMap)) 
					anim_fall_curves[j] = new curveMap();
				anim_fall_curves[j].set(_data[_ii + 13]);
				
				if(!is(anim_sampler[j], Surface_Sampler_Grey))
					anim_sampler[j] = new Surface_Sampler_Grey();
					
				var _an_ssrf = _data[_ii + 14];
				anim_sampler[j].setSurface(_an_ssrf);
				
			}
		#endregion
			
		var _surf, posx, posy, scax, scay, rot, _dim, 
		var _dims        = [];
		var _sdim        = [ 1, 1 ]
		var _surf        = _iSrf;
		var _baseSurface = _surf;
		var _use_array   = is_array(_surf);
		var _arr_length  = _use_array? array_length(_surf) : 1;
		if(_arr_length < 1) return _outSurf;
		
		var minx =  999999, miny =  999999;
		var maxx = -999999, maxy = -999999;
		
		if(is_array(_surf)) {
			for( var i = 0, n = array_length(_surf); i < n; i++ ) {
				var _ddim = surface_get_dimension(_surf[i]);
				_baseSurface = _surf[i];
				_sdim[0] = max(_sdim[0], _ddim[0]);
				_sdim[1] = max(_sdim[1], _ddim[1]);
				_dims[i] = _ddim;
			}
			
		} else if(is_surface(_surf))
			_sdim = surface_get_dimension(_surf);
		
		if(!is_surface(_baseSurface)) return _outSurf;
		
		random_set_seed(_sed);
		
		surface_atlases = array_verify_min(surface_atlases, _amo * ATLAS_ARRAY.length);
		var atlases = surface_atlases;
		var atlas_i = 0;
		var runx = 0;
		var runy = 0;
		
		var _rposx = 0;
		var _rposy = 0;
		
		var _divis = _pshf? 1 / _amo : 1;
		var _st = 1 / _amo;
		var  ii = 0;
		var _i  = 0;
		
		var _prg;
		var cc;
		
		repeat(_amo) {
			var i = ii++;
			
			posx = runx;
			posy = runy;
			
			_prg = i / max(1, _amo - 1);
			rot  = _rots;
			
			var st = i * _st;
			
			switch(_pat) {
				case 0 :
					if(is_path(_path)) {
						var rat = _prsh + _prng[0] + (_prng[1] - _prng[0]) * st;
						if(_prng[1] - _prng[0] == 0) break;
						rat = abs(frac(rat));
						
						var _p = _path.getPointRatio(rat, 0, __temp_pth);
						posx = _p.x;
						posy = _p.y;
						
						if(_pfol) {
							var _p0 = _path.getPointRatio(clamp(rat - _st / 2, 0, .999));
							var _p1 = _path.getPointRatio(clamp(rat + _st / 2, 0, .999));
							
							var _dir = point_direction(_p0.x, _p0.y, _p1.x, _p1.y);
							rot += _dir;
						}
						
					} else {
						posx += _spos[0] + _rposx;
						posy += _spos[1] + _rposy;
						
						var _rpos_sca = _rpos_curved? shift_curve.get(_prg) : 1;
						
						_rposx += _rpos[0] * _rpos_sca * _divis;
						_rposy += _rpos[1] * _rpos_sca * _divis;
					}
					break;
				
				case 1 :
					var row = floor(i / _col);
					var col = safe_mod(i, _col);
					
					posx = _spos[0] + _rpos[0] * col + _cls[0] * row;
					posy = _spos[1] + _rpos[1] * col + _cls[1] * row;
					break;
				
				case 2 :
					var aa = _srot + lerp(_aran[0], _aran[1], st);
					posx = _spos[0] + lengthdir_x(_arad, aa);
					posy = _spos[1] + lengthdir_y(_arad, aa);
					break;
			}
			
			scax =                  _rscaX * (_rscaX_curved? scalex_curve.get(_prg) : 1);
			scay = _scaUni? scax : (_rscaY * (_rscaY_curved? scaley_curve.get(_prg) : 1));
			
			rot += lerp(_rrot[0], _rrot[1], st);
			
			var _surface = _iSrf;
			var _sw  = _sdim[0];
			var _sh  = _sdim[1];
			var _sid = 0;
			
			if(_use_array) {
				switch(_arr) {
					case 0: _sid = safe_mod(i, _arr_length); break;
					case 1: _sid = irandom(_arr_length - 1); break;
				}
				
				_surface = _iSrf[_sid];
				_sw = _dims[_sid][0];
				_sh = _dims[_sid][1];
			}
			
			posx += random_range(_pran[0], _pran[1]);
			posy += random_range(_pran[2], _pran[3]);
			
			rot  += rotation_random_eval(_rran);
			
			scax *= random_range(_sran[0], _sran[1]);
			scay *= random_range(_sran[2], _sran[3]);
			
			var sw = _sw * scax;
			var sh = _sh * scay;
			
			if(i) switch(_rsta) { 
				case 1 : runx += _sw / 2; posx += _sw / 2; break;
				case 2 : runy += _sh / 2; posy += _sh / 2; break;
			}
			
			if(_grad_use_map) {
				var _grad_sx = round(lerp(_grad_range[0], _grad_range[2], _prg) * _grad_map_w);
				var _grad_sy = round(lerp(_grad_range[1], _grad_range[3], _prg) * _grad_map_h);
					
				cc = grad_sampler.getPixel(_grad_sx, _grad_sy);
			} else 
				cc = _grad.evalFast(_prg);
			cc = colorMultiply(cc, _cran.evalFast(random(1)));
			
			minx = min(minx, posx);
			miny = min(miny, posy);
			maxx = max(maxx, posx);
			maxy = max(maxy, posy);
				
			var aa  = _color_get_alpha(cc);
			point_rotate(sw * _panc[0], sh * _panc[1], 0, 0, rot, __temp_p);
			posx -= __temp_p[0];
			posy -= __temp_p[1];
			
			atlas_i++;
			
			atlases[ _i + ATLAS_ARRAY.surface ] = _surface;
			atlases[ _i + ATLAS_ARRAY.x       ] = posx;
			atlases[ _i + ATLAS_ARRAY.y       ] = posy;
			atlases[ _i + ATLAS_ARRAY.cx      ] = posx + sw / 2;
			atlases[ _i + ATLAS_ARRAY.cy      ] = posy + sh / 2;
			atlases[ _i + ATLAS_ARRAY.sx      ] = scax;
			atlases[ _i + ATLAS_ARRAY.sy      ] = scay;
			atlases[ _i + ATLAS_ARRAY.sw      ] = _sw;
			atlases[ _i + ATLAS_ARRAY.sh      ] = _sh;
			atlases[ _i + ATLAS_ARRAY.rot     ] = rot;
			atlases[ _i + ATLAS_ARRAY.color   ] = cc;
			atlases[ _i + ATLAS_ARRAY.alpha   ] = aa;
			_i += ATLAS_ARRAY.length;
			
			if(_rsta == 1)	runx += _sw / 2;
			if(_rsta == 2)	runy += _sh / 2;
			
		}
		
		if(_ani_amo > 0)
		for( var i = 0, n = atlas_i; i < n; i++ ) { // animators
			var _i    = i * ATLAS_ARRAY.length;
			var _surf = atlases[_i + ATLAS_ARRAY.surface];
			
			var _x = atlases[_i + ATLAS_ARRAY.cx];
			var _y = atlases[_i + ATLAS_ARRAY.cy];
			
			var _sw = atlases[_i + ATLAS_ARRAY.sw];
			var _sh = atlases[_i + ATLAS_ARRAY.sh];
			
			for( var j = 0; j < _ani_amo; j++ ) {
				var _ii = input_fix_len + j * data_length;
				
				var _an_prop = _data[_ii + 0];
				var _an_selt = _data[_ii + 1];
				
				var _an_posi = _data[_ii + 2];
				var _an_rota = _data[_ii + 3];
				var _an_scal = _data[_ii + 4];
				var _an_anct = _data[_ii + 5];
				var _an_ancp = _data[_ii + 6];
				var _an_colr = _data[_ii + 7];
				var _an_alph = _data[_ii + 8];
				
				var _an_sare = _data[_ii +  9];
				var _an_sind = _data[_ii + 10];
				var _an_srng = _data[_ii + 11];
				var _an_sfal = _data[_ii + 12];
				var _an_sfcr = _data[_ii + 13];
				var _an_ssrf = _data[_ii + 14];
				// var _an_strn = _data[_ii + 15];
				
				var _inf = 0;
				var _ax = 0, _ay = 0;
				
				if(_an_selt == 0) { // index
					if(i < _an_sind - _an_srng - _an_sfal || i > _an_sind + _an_srng + _an_sfal)
						_inf = 1;
					else if (_an_sfal > 0 && (i < _an_sind - _an_srng || i > _an_sind + _an_srng))
						_inf = clamp(min(abs(i - (_an_sind - _an_srng)), abs(i - (_an_sind + _an_srng))) / _an_sfal, 0, 1);
					else 
						_inf = 0;
					
				} else if(_an_selt == 1) { // area
					_inf = 1 - area_point_in_fallout(_an_sare, _x, _y, _an_sfal);
					
				} else if(_an_selt == 2) { // surface
					if(anim_sampler[j].active) 
						_inf = 1 - anim_sampler[j].getPixel(round(_x), round(_y));
				}
				
				_inf = anim_fall_curves[j].get(_inf);
				if(_inf == 0) continue;
				
				switch(_an_prop) {
					case 0 : // transform
						_x += _inf * _an_posi[0];
						_y += _inf * _an_posi[1];
						
						var _dr = _inf * _an_rota;
						if(_dr != 0) {
							atlases[_i + ATLAS_ARRAY.rot] += _dr;
							
							if(_an_anct == 0) { // global
								_ax = _an_ancp[0];
								_ay = _an_ancp[1];
								
							} else if(_an_anct == 1) { // local
								_ax = _x + _an_ancp[0] * _sw;
								_ay = _y + _an_ancp[1] * _sh;
								
							}
							
							__temp_p = point_rotate(_x, _y, _ax, _ay, _dr, __temp_p);
							_x = __temp_p[0];
							_y = __temp_p[1];
						}
						
						var _dsx = _inf * _an_scal[0];
						var _dsy = _inf * _an_scal[1];
						if(_dsx != 0 || _dsy != 0) {
							if(_an_anct == 0) { // global
								_ax = _an_ancp[0];
								_ay = _an_ancp[1];
								
							} else if(_an_anct == 1) { // local
								_ax = _x + (_an_ancp[0] - .5) * _sw;
								_ay = _y + (_an_ancp[1] - .5) * _sh;
								
							}
							
							atlases[_i + ATLAS_ARRAY.sx] += _inf * _an_scal[0];
							atlases[_i + ATLAS_ARRAY.sy] += _inf * _an_scal[1];
							
							_x += _dsx * (_x - _ax);
							_y += _dsy * (_y - _ay);
						}
						break;
						
					case 1 : 
						atlases[_i + ATLAS_ARRAY.color]  = merge_color(atlases[_i + ATLAS_ARRAY.color], _an_colr, _inf);
						atlases[_i + ATLAS_ARRAY.alpha] += _inf * _an_alph;
						break;
				}
				
			}
			
			var  sw = _sw * atlases[_i + ATLAS_ARRAY.sx];
			var  sh = _sh * atlases[_i + ATLAS_ARRAY.sy];
			var pos = point_rotate(-sw / 2, -sh / 2, 0, 0, atlases[_i + ATLAS_ARRAY.rot], __temp_p);
			
			minx = min(minx, _x + pos[0], _x - pos[0], _x + pos[1], _x - pos[1]);
			miny = min(miny, _y + pos[0], _y - pos[0], _y + pos[1], _y - pos[1]);
			maxx = max(maxx, _x + pos[0], _x - pos[0], _x + pos[1], _x - pos[1]);
			maxy = max(maxy, _y + pos[0], _y - pos[0], _y + pos[1], _y - pos[1]);
			
			atlases[_i + ATLAS_ARRAY.x] = _x + pos[0];
			atlases[_i + ATLAS_ARRAY.y] = _y + pos[1];
		}
		
		////- DIMENSION
		
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
				
				_dim = [ _sdim[0] * _dimr[0], _sdim[1] * _dimr[1] ];
				break;
				
			case OUTPUT_SCALING.scale :
				inputs[37].setVisible(true);
				
				_dim = [ 
					abs(maxx - minx) + _padd[0] + _padd[2], 
					abs(maxy - miny) + _padd[1] + _padd[3] 
				];
				break;
				
		}
		
		output_dimension[_array_index] = [_dim[0], _dim[1]];
		_outSurf = surface_verify(_outSurf, _dim[0], _dim[1]);
		
		var _offset_x = -_fanc[0] * (maxx - minx);
		var _offset_y = -_fanc[1] * (maxy - miny);
		
		////- RENDERING
		
		surface_set_shader(_outSurf);
			     if(_bld_md == 0) { BLEND_ALPHA_MULP }
			else if(_bld_md == 1) { BLEND_ADD        }
			else if(_bld_md == 2) { BLEND_MAX        }
			
			shader_set_interpolation(_baseSurface);
			
			for( var i = 0; i < atlas_i; i++ ) {
				var _ind = _invers? atlas_i - i - 1 : i;
				var _i   = _ind * ATLAS_ARRAY.length;
				
				var _x = atlases[_i + ATLAS_ARRAY.x] + _offset_x;
				var _y = atlases[_i + ATLAS_ARRAY.y] + _offset_y;
				
				var _surf = atlases[_i + ATLAS_ARRAY.surface];
				var _sx   = atlases[_i + ATLAS_ARRAY.sx];
				var _sy   = atlases[_i + ATLAS_ARRAY.sy];
				var _rot  = atlases[_i + ATLAS_ARRAY.rot];
				var _col  = atlases[_i + ATLAS_ARRAY.color];
				var _alp  = atlases[_i + ATLAS_ARRAY.alpha];
				
				if(_dimt == OUTPUT_SCALING.scale) {
					_x += _padd[2] - minx;
					_y += _padd[1] - miny;
				}
				
				draw_surface_ext(_surf, _x, _y, _sx, _sy, _rot, _col, _alp);
			}
			
			BLEND_NORMAL
		surface_reset_shader();
		
		return _outSurf;
	}
	
	////- Serialize
	
	static postDeserialize = function() {
		if(CLONING) return;
		
		if(LOADING_VERSION < 1_20_04_0) {
			load_map.inputs[15] = noone;
			load_map.inputs[20] = noone;
			load_map.inputs[21] = noone;
			load_map.inputs[23] = noone;
			load_map.inputs[24] = noone;
			load_map.inputs[25] = noone;
			load_map.inputs[27] = noone;
			load_map.inputs[28] = noone;
		}
	}
	
}