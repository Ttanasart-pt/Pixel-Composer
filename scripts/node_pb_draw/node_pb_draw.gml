function Node_PB_Draw(_x, _y, _group = noone) : Node_Processor(_x, _y, _group) constructor {
	name = "PB Draw";
	preview_channel = 1;
	
	newInput(0, nodeValue_Pbbox("Base PBBOX", self, new __pbBox()));
	inputs[0].editWidget = noone;
	
	newInput(1, nodeValue_Pbbox("PBBOX", self, new __pbBox()));
	
	newInput(2, nodeValue_f("PBBOX Left",   self, 0));
	newInput(3, nodeValue_f("PBBOX Top",    self, 0));
	newInput(4, nodeValue_f("PBBOX Right",  self, 0));
	newInput(5, nodeValue_f("PBBOX Bottom", self, 0));
	newInput(6, nodeValue_f("PBBOX Width",  self, 0));
	newInput(7, nodeValue_f("PBBOX Height", self, 0));
	
	newInput( 8, nodeValue_b(  "Fill",              self, true));
	newInput( 9, nodeValue_c(  "Color",             self, cola(c_white))).setInternalName("Fill Color");
	
	newInput(10, nodeValue_b(  "Stroke",            self, false));
	newInput(11, nodeValue_i(  "Thickness",         self, 1));
	newInput(12, nodeValue_c(  "Color",             self, cola(c_white))).setInternalName("Stroke Color");
	newInput(13, nodeValue_eb( "Position",          self, 0, array_create(3, THEME.stroke_position) ));
	newInput(14, nodeValue_eb( "Corner",            self, 0, array_create(2, THEME.stroke_profile)  ));
	
	newInput(15, nodeValue_es( "Pattern",           self, 0, [ "Solid", "Stripe X", "Stripe Y", "Checker", "Dotted" ] )).setInternalName("Fill Pattern");
	newInput(16, nodeValue_c(  "Pattern Color",     self, cola(c_white))).setInternalName("Fill Pattern Color");
	newInput(17, nodeValue_s(  "Pattern Intensity", self, 1)).setInternalName("Fill Pattern Intensity");
	newInput(18, nodeValue_2(  "Pattern Scale",     self, [1,1])).setInternalName("Fill Pattern Scale");
	
	newInput(19, nodeValue_es( "Pattern",           self, 0, [ "Solid", "Stripe X", "Stripe Y", "Checker", "Layered" ] )).setInternalName("Stroke Pattern");
	newInput(20, nodeValue_c(  "Pattern Color",     self, cola(c_white))).setInternalName("Stroke Pattern Color");
	newInput(21, nodeValue_s(  "Pattern Intensity", self, 1)).setInternalName("Stroke Pattern Intensity");
	newInput(22, nodeValue_2(  "Pattern Scale",     self, [1,1])).setInternalName("Stroke Pattern Scale");
	
	newInput(23, nodeValue_b(  "Corner",            self, false));
	newInput(24, nodeValue_i(  "Radius",            self, 1));
	newInput(25, nodeValue_c(  "Color",             self, cola(c_white))).setInternalName("Corner Color");
	newInput(26, nodeValue_es( "Apply",             self, 0, [ "Fill", "Stroke" ] )).setInternalName("Corner Effect");
	
	newInput(27, nodeValue_b(  "Highlight",         self, false));
	newInput(28, nodeValue_i(  "Width",             self, [ 0, 0, 0, 0 ])).setDisplay(VALUE_DISPLAY.padding).setInternalName("Highlight Width");
	newInput(29, nodeValue_c(  "Color Left",        self, cola(c_white))).setInternalName("Corner Color");
	newInput(30, nodeValue_c(  "Color Right",       self, cola(c_white))).setInternalName("Corner Color");
	newInput(31, nodeValue_c(  "Color Top",         self, cola(c_white))).setInternalName("Corner Color");
	newInput(32, nodeValue_c(  "Color Bottom",      self, cola(c_white))).setInternalName("Corner Color");
	
	newInput(33, nodeValue_b(  "Subtract",          self, false));
	
	////////////////////////////////////////////////////////////////////////////////
	
	newOutput(0, nodeValue_Output("PBBOX", self, VALUE_TYPE.pbBox, noone));
	
	newOutput(1, nodeValue_Output("Surface Out", self, VALUE_TYPE.surface, noone));
	
	var _sep = new Inspector_Spacer(ui(4), true, true, ui(4));
	
	pbi = array_length(inputs);
	
	input_display_list = [
		["Layout",         false], 0, 1, 
		["Layout Override", true], 2, 3, 4, 5, 6, 7, 
	]
	
	input_display_shape_index = array_length(input_display_list);
	
	array_append(input_display_list, [
		["Fill",     false,  8], 9, _sep, 15, 18, 16, 17, 
		["Stroke",   false, 10], 11, 13, 14, 12, _sep, 19, 22, 20, 21, 
		["Corner",    true, 23], 24, 25, 26, 33, 
		["Highlight", true, 27], 28, 29, 30, 31, 32, 
	]);
	
	temp_surfaces = [ 0 ];
	
	static drawOverlay = function(hover, active, _x, _y, _s, _mx, _my, _snx, _sny) {
		var _pbase = getSingleValue(0);
		var _pbbox = getSingleValue(1);
		
		if(is(_pbase, __pbBox)) {
			draw_set_color(COLORS._main_icon);
			_pbase.drawOverlayBBOX(hover, active, _x, _y, _s, _mx, _my, _snx, _sny, self);
		}
		
		if(is(_pbbox, __pbBox)) _pbbox.drawOverlay(hover, active, _x, _y, _s, _mx, _my, _snx, _sny, self);
	}
	
	static getBBOX = function(_data) {
		var _dim   = group.dimension;
		var _pbase = _data[0];
		var _pbbox = _data[1];
		
		if(inputs[0].value_from == noone) _pbase.base_bbox = [ 0, 0, _dim[0], _dim[1] ];
		if(inputs[2].value_from != noone || inputs[2].is_anim) _pbbox.anchor_l = _data[2];
		if(inputs[3].value_from != noone || inputs[3].is_anim) _pbbox.anchor_t = _data[3];
		if(inputs[4].value_from != noone || inputs[4].is_anim) _pbbox.anchor_r = _data[4];
		if(inputs[5].value_from != noone || inputs[5].is_anim) _pbbox.anchor_b = _data[5];
		if(inputs[6].value_from != noone || inputs[6].is_anim) _pbbox.anchor_w = _data[6];
		if(inputs[7].value_from != noone || inputs[7].is_anim) _pbbox.anchor_h = _data[7];
		
		_pbbox.base_bbox = is(_pbase, __pbBox)? _pbase.getBBOX() : [ 0, 0, _dim[0], _dim[1] ];
		return _pbbox.getBBOX();
	}
	
	static pbDrawSurface = function(_data, _bbox) {}
	
	static processData = function(_outSurf, _data, _output_index, _array_index) {
		var _dim = group.dimension;
		_outSurf         = surface_verify(_outSurf, _dim[0], _dim[1]);
		temp_surfaces[0] = surface_verify(temp_surfaces[0], _dim[0], _dim[1]);
		
		var _pbbox = _data[1];
		var _bbox  = getBBOX(_data);
		
		var _fil     = _data[8];
		var _fil_col = _data[9];
		
		var _fil_pat     = _data[15];
		var _fil_pat_col = _data[16]; inputs[16].setVisible(_fil_pat);
		var _fil_pat_int = _data[17]; inputs[17].setVisible(_fil_pat);
		var _fil_pat_sca = _data[18]; inputs[18].setVisible(_fil_pat);
		
		var _stk     = _data[10];
		var _stk_thk = _data[11];
		var _stk_col = _data[12];
		var _stk_pos = _data[13];
		var _stk_cor = _data[14];
		
		var _stk_pat     = _data[19];
		var _stk_pat_col = _data[20]; inputs[20].setVisible(_stk_pat);
		var _stk_pat_int = _data[21]; inputs[21].setVisible(_stk_pat);
		var _stk_pat_sca = _data[22]; inputs[22].setVisible(_stk_pat);
		
		var _crn     = _data[23];
		var _crn_rad = _data[24];
		var _crn_col = _data[25];
		var _crn_eff = _data[26];
		var _crn_sub = _data[33];
		
		var _hig     = _data[27];
		var _hig_wid = _data[28];
		var _hig_l   = _data[29];
		var _hig_r   = _data[30];
		var _hig_t   = _data[31];
		var _hig_b   = _data[32];
		
		var _draws = temp_surfaces[0];
		
		surface_set_shader(_draws, noone);
			draw_set_color(c_white);
			pbDrawSurface(_data, _bbox);
		surface_reset_shader();
		
		surface_set_shader(_outSurf, sh_pb_draw);
			shader_set_2("dimension",            _dim         );
			
			shader_set_i("fill",                 _fil         );
			shader_set_c("fill_color",           _fil_col     );
			shader_set_i("fill_pattern",         _fil_pat     );
			shader_set_2("fill_pattern_scale",   _fil_pat_sca );
			shader_set_c("fill_pattern_color",   _fil_pat_col );
			shader_set_f("fill_pattern_inten",   _fil_pat_int );
			
			shader_set_i("stroke",               _stk         );
			shader_set_f("stroke_thickness",     _stk_thk     );
			shader_set_c("stroke_color",         _stk_col     );
			shader_set_i("stroke_position",      _stk_thk <= 1? 1 : _stk_pos );
			shader_set_i("stroke_corner",        _stk_cor     );
			shader_set_i("stroke_pattern",       _stk_pat     );
			shader_set_2("stroke_pattern_scale", _stk_pat_sca );
			shader_set_c("stroke_pattern_color", _stk_pat_col );
			shader_set_f("stroke_pattern_inten", _stk_pat_int );
			
			shader_set_i("corner",               _crn         );
			shader_set_f("corner_radius",        _crn_rad     );
			shader_set_c("corner_color",         _crn_col     );
			shader_set_i("corner_effect",        _crn_eff     );
			shader_set_i("corner_subtract",      _crn_sub     );
			
			shader_set_i("highlight",            _hig         );
			shader_set_4("highlight_width",      _hig_wid     );
			shader_set_c("highlight_l",          _hig_l       );
			shader_set_c("highlight_r",          _hig_r       );
			shader_set_c("highlight_t",          _hig_t       );
			shader_set_c("highlight_b",          _hig_b       );
			
			draw_surface_safe(_draws);
		surface_reset_shader();
		
		return [ _pbbox, _outSurf ];
	}
	
	////- Serialize
	
	static doSerialize = function(_map) {
		_map.pbi_base_length = pbi;
	}
	
	static postDeserialize = function() {
		var _tlen = struct_try_get(load_map, "pbi_base_length", pbi);
		
		for( var i = _tlen; i < pbi; i++ )
			array_insert(load_map.inputs, i, noone);
	}
}