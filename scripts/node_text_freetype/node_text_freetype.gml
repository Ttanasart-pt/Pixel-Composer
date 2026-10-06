function Node_Text_FreeType(_x, _y, _group = noone) : Node_Processor(_x, _y, _group) constructor {
	name = "Draw Variable Text";
	
	////- Text
	newInput( 2, nodeValue_Text(    "Text" ));
	newInput(11, nodeValue_EScroll( "Change Case", 0, [ "None", "Lowercase", "Uppercase", "Titlecase" ] ));
	
	////- Output
	newInput( 4, nodeValue_EScroll(  "Dimension Type", 1, [ "Fixed", "Dynamic" ]));
	newInput( 0, nodeValue_Dimension());
	newInput( 5, nodeValue_Vec2(     "Offset",    [0,0]      ));
	newInput( 6, nodeValue_IPadding( "Padding",   [0,0,0,0]  ));
	
	////- Font
	newInput( 1, nodeValue_Font(  "Font", array_safe_get(FONT_INTERNAL, 0, "") )).setVisible(true, false);
	newInput( 3, nodeValue_Float( "Size",          16    ));
	
		////- =/Font Settings
	newInput( 7, nodeValue_Bool(  "Anti-Aliasing", false ));
	
		////- =/Letter Settings
	newInput(12, nodeValue_Float( "Letter Spacing", 0 ));
	
	////- =Alignment
	newInput( 8, nodeValue_EButton( "H Align", 0, array_create(3, THEME.inspector_text_halign) ));
	newInput( 9, nodeValue_EButton( "V Align", 0, array_create(3, THEME.inspector_text_valign) ));
	
	////- Rendering
	newInput(10, nodeValue_Color(  "Color", ca_white ));
	// 13
	
	newOutput(0, nodeValue_Output("Surface Out", VALUE_TYPE.surface, noone));
	
	input_display_list = [ 
		[ "Text",           false ],  2, 11, 
		[ "Output",          true ],  4,  0,  5,  6,  
		[ "Font",           false ],  1,  3, 
			[ "/Settings",   true ],  7, 
			[ "/Lettering", false ], 12, 
			
		[ "Alignment",      false ],  8,  9, 
		[ "Rendering",      false ], 10, 
		[ "Variables",      false ],  
	];
	
	function createNewInput(index = array_length(inputs), _def = 0, _range = [0,1,.01]) {
		var inp = newInput(index, nodeValue_Slider( "Value", _def, _range ));
		array_push(input_display_list, index);
		return inp;
	} 
	
	setDynamicInput( 1, false );
	
	////- Nodes
	
	temp_surface  = [ noone ];
	output_buffer = buffer_create(1, buffer_grow, 1);
	bbox_buffer   = buffer_create(1, buffer_grow, 4);
	
	curr_font      = undefined;
	font_var_count = 0;
	
	static updateFont = function(_font) {
		if(_font == curr_font) return;
		curr_font = _font;
		
		font_var_count = freeType_Font_getVariableCount();
		if(!LOADING && font_var_count != getInputAmount()) {
			array_resize(inputs, input_fix_len);
			input_display_list = array_clone(input_display_list_raw);
			
			for( var i = 0; i < font_var_count; i++ ) {
				var _def  = freeType_Font_getVariableDef(i);
				createNewInput(array_length(inputs), _def);
			}
		}
		
		for( var i = 0; i < font_var_count; i++ ) {
			var _name = freeType_Font_getVariableName(i);
			var _min  = freeType_Font_getVariableMin(i);
			var _max  = freeType_Font_getVariableMax(i);
			var _def  = freeType_Font_getVariableDef(i);
			
			var _inp = inputs[input_fix_len + i];
			var _sli = _inp.getEditWidget();
			
			_inp.setName(_name, true);
			_sli.slide_range = [_min, _max, (_max - _min) / 25];
		}
	}
	
	static processData = function(_outSurf, _data, _array_index = 0) { 
		#region data
			var _text  = _data[ 2];
			var _case  = _data[11];
			
			var _type  = _data[ 4];
			var _dim   = _data[ 0];
			var _offs  = _data[ 5];
			var _padd  = _data[ 6];
			
			var _font  = _data[ 1];
			var _size  = _data[ 3];
			
			var _aa    = _data[ 7];
			
			var _lspac = _data[12];
			
			var _hali  = _data[ 8];
			var _vali  = _data[ 9];
			
			var _colr  = _data[10];
			
			inputs[ 0].setVisible(_type == 0);
			inputs[ 6].setVisible(_type == 1);
		#endregion
		
		#region modify text
			switch(_case) {
		        case 1 : _text = string_lower(_text);     break;
		        case 2 : _text = string_upper(_text);     break;
		        case 3 : _text = string_titlecase(_text); break;
		    }
		#endregion
			
		if(!file_exists_empty(_font) || _text == "") return _outSurf;
			
		freeType_setFont(_font, _size);
		freeType_setFontAA(_aa);
		freeType_setFontSpacing(_lspac);
		freeType_setText(_text);
		
		freeType_fontStart();
		freeType_Font_getVariableData();
		updateFont(_font);
		
		for( var i = 0; i < font_var_count; i++ ) {
			var _inp = input_fix_len + i;
			var _nam = inputs[_inp].name;
			var _val = _data[_inp];
			
			freeType_Font_setVariable(i, _val);
		}
		
		freeType_GetTextBBox(buffer_get_address(bbox_buffer));
		var tw = buffer_peek(bbox_buffer, 0, buffer_u16);
		var th = buffer_peek(bbox_buffer, 2, buffer_u16);
		
		temp_surface[0] = surface_verify(temp_surface[0], tw, th);
		output_buffer   = buffer_verify(output_buffer, tw * th * 4, buffer_grow, 1);
		buffer_clear(output_buffer);
		
		freeType_setCanvas(buffer_get_address(output_buffer), tw, th);
		freeType_Render(0, th);
		freeType_fontEnd();
		
		buffer_set_surface(output_buffer, temp_surface[0], 0);
		
		var ww = _type == 0? _dim[0] : tw + _padd[0] + _padd[2];
		var hh = _type == 0? _dim[1] : th + _padd[1] + _padd[3];
		
		var dx = 0;
		var dy = 0;
		
		if(_type == 1) {
			dx += _padd[2];
			dy += _padd[1];
			
		} else {
			switch(_hali) {
				case 0 : break;
				case 1 : dx = ww/2 - tw/2; break;
				case 2 : dx = ww - tw;     break;
			}
			
			switch(_vali) {
				case 0 : break;
				case 1 : dy = hh/2 - th/2; break;
				case 2 : dy = hh - th;     break;
			}
		}
		
		dx += _offs[0];
		dy += _offs[1];
		
		_outSurf = surface_verify(_outSurf, ww, hh);
		surface_set_shader(_outSurf, sh_text_freetype_render);
			draw_surface_ext(temp_surface[0], dx, dy, 1, 1, 0, _colr, _color_get_a(_colr));
		surface_reset_shader();
		
		return _outSurf; 
	}
}