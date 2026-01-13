#region
	FN_NODE_CONTEXT_INVOKE {
		addHotkey("Node_Seperate_Shape", "Ignore blank > Toggle", "I", MOD_KEY.none, function() /*=>*/ { GRAPH_FOCUS _n.inputs[4].setValue((_n.inputs[4].getValue() + 1) % 2); });
		addHotkey("Node_Seperate_Shape", "Mode > Toggle",         "M", MOD_KEY.none, function() /*=>*/ { GRAPH_FOCUS _n.inputs[5].setValue((_n.inputs[5].getValue() + 1) % 2); });
		addHotkey("Node_Seperate_Shape", "Crop > Toggle",         "C", MOD_KEY.none, function() /*=>*/ { GRAPH_FOCUS _n.inputs[6].setValue((_n.inputs[6].getValue() + 1) % 2); });
	});
#endregion

function Node_Seperate_Shape(_x, _y, _group = noone) : Node_Processor(_x, _y, _group) constructor {
	name = "Separate Shape";
	
	////- =Shape
	newInput(0, nodeValue_Surface( "Surface In" ));
	newInput(5, nodeValue_EButton( "Mode",          0, [ "Greyscale", "Alpha" ] ))
	newInput(1, nodeValue_Slider(  "Tolerance",    .2, { range: [ 0, 1, 0.01 ], update_stat: SLIDER_UPDATE.release }));
	newInput(4, nodeValue_Bool(    "Ignore blank", true, "Skip empty shapes."));
	
	////- =Output
	newInput(2, nodeValue_Bool(  "Override color", false    ));
	newInput(3, nodeValue_Color( "Color",          ca_white ));
	newInput(6, nodeValue_Bool(  "Crop",           true     ))
	// inputs 7
		
	newOutput(0, nodeValue_Output("Surface Out", VALUE_TYPE.surface, noone));
	newOutput(1, nodeValue_Output("Atlas", VALUE_TYPE.atlas, []));
	
	input_display_list = [
		[ "Shape",  false ], 0, 5, 1, 4,
		[ "Output", false ], 2, 3, 6, 
	]
	
	////- Node
	
	temp_surface   = [ noone, noone ];
	
	insp1button = button(function() /*=>*/ {return triggerRender()}).setTooltip(__txt("Separate Shape"))
		.setIcon(THEME.sequence_control, 1, COLORS._main_value_positive).iconPad(ui(6)).setBaseSprite(THEME.button_hide_fill);
	
	static processData = function(_outData, _data, _array_index = 0) { 
		#region data
			var _inSurf = _data[0];
			var _mode   = _data[5];
			var _thres  = _data[1];
			var _ignore = _data[4];
			
			var _ovr    = _data[2];
			var _ovrclr = _data[3];
			var _crop   = _data[6];
			
			if(!is_surface(_inSurf)) return _outData;
		#endregion
		
		var ww = surface_get_width_safe(_inSurf);
		var hh = surface_get_height_safe(_inSurf);
		
		for(var i = 0; i < 2; i++) temp_surface[i] = surface_verify(temp_surface[i], ww, hh, surface_rgba32float);
		
		#region region indexing
			surface_set_shader(temp_surface[1], sh_seperate_shape_index);
				shader_set_i("mode",      _mode);
				shader_set_i("ignore",    _ignore);
				shader_set_f("dimension", ww, hh);
				
				draw_sprite_stretched(s_fx_pixel, 0, 0, 0, ww, hh);
			surface_reset_shader();
			
			shader_set(sh_seperate_shape_ite);
				shader_set_i("mode",      _mode);
				shader_set_i("ignore",    _ignore);
				shader_set_f("dimension", ww, hh);
				shader_set_f("threshold", _thres);
				shader_set_surface("map", _inSurf);
			shader_reset();
		
			var res_index = 0, iteration = ww + hh;
			for(var i = 0; i <= iteration; i++) {
				var bg = i % 2;
				var fg = !bg;
				
				surface_set_shader(temp_surface[bg], sh_seperate_shape_ite,, BLEND.over);
					draw_surface_safe(temp_surface[fg]);
				surface_reset_shader();
			
				res_index = bg;
			}
		#endregion
		
		#region count and match color
			var i = 0, pxc = ww * hh;
			var reg = ds_map_create();
			
			var b = buffer_create(pxc * 16, buffer_fixed, 1);
			buffer_get_surface(b, temp_surface[res_index], 0);
			buffer_seek(b, buffer_seek_start, 0);
			
			repeat(pxc) {
				var _r = buffer_read(b, buffer_f32);
				var _g = buffer_read(b, buffer_f32);
				var _b = buffer_read(b, buffer_f32);
				var _a = buffer_read(b, buffer_f32);
				
				if(_r == 0 && _g == 0 && _b == 0 && _a == 0) continue;
				
				reg[? _g * ww + _r] = [ _r, _g, _b, _a ];
			}
			
			var px = ds_map_size(reg);
			if(px == 0) return;
		#endregion
		
		#region extract region
			var _val   = surface_array_verify(_outData[0], px);
			var _atlas = array_verify(_outData[1], px);
			
			var key    = ds_map_keys_to_array(reg);
			var _ind   = 0;
			
			for(var i = 0; i < px; i++) {
				var _k  = key[i];
				var _cc = reg[? _k];
				
				var min_x = _crop? round(_cc[0]) : 0;
				var min_y = _crop? round(_cc[1]) : 0;
				var max_x = _crop? round(_cc[2]) : ww;
				var max_y = _crop? round(_cc[3]) : hh;
				
				var _sw = _crop? max_x - min_x + 1 : ww;
				var _sh = _crop? max_y - min_y + 1 : hh;
				
				if(_sw <= 1 || _sh <= 1) continue;
				
				_val[_ind] = surface_verify(_val[_ind], _sw, _sh);
				
				surface_set_shader(_val[_ind], sh_seperate_shape_sep);
					shader_set_s( "original",  _inSurf );
					shader_set_f( "color",     _cc     );
					shader_set_i( "override",  _ovr    );
					shader_set_c( "overColor", _ovrclr );
					
					draw_surface_safe(temp_surface[res_index], -min_x, -min_y);
				surface_reset_shader();
				
				_atlas[_ind] = new SurfaceAtlas(_val[_ind], min_x, min_y).setOriginalSurface(_inSurf);
				_ind++;
			}
			
			array_resize(_val,   _ind);
			array_resize(_atlas, _ind);
			
			ds_map_destroy(reg);
			
		#endregion
		
		_outData[0] = _val;
		_outData[1] = _atlas;
		
		return _outData;
	}
}