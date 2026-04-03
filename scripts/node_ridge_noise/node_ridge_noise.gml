#region
	FN_NODE_CONTEXT_INVOKE {
		addHotkey("Node_Ridge_Noise", "Mode > Toggle", "M", MOD_KEY.none, function() /*=>*/ { GRAPH_FOCUS _n.inputs[4].setValue((_n.inputs[4].getValue() + 1) % 2); });
	});
#endregion

function Node_Ridge_Noise(_x, _y, _group = noone) : Node_Processor(_x, _y, _group) constructor {
	name   = "Ridge Noise";
	
	////- =Output
	newInput( 0, nodeValue_Dimension())
	newInput( 8, nodeValue_Surface(  "UV Map"     ));
	newInput( 9, nodeValue_Slider(   "UV Mix", 1  ));
	newInput( 7, nodeValue_Surface(  "Mask"       ));
	
	////- =Noise
	newInput( 5, nodeValueSeed());
	newInput(10, nodeValue_Surface(  "Heightmap"         ));
	newInput( 4, nodeValue_EButton(  "Mode",           0, [ "Hexagon", "Star" ]));
	newInput(11, nodeValue_Float(    "Ridge Scale",    32 ));
	newInput(15, nodeValue_Rotation( "Ridge Rotation", 0  ));
	newInput(16, nodeValue_Slider(   "Ridge Contrast",.5  ));
	newInput(13, nodeValue_Float(    "Cell Scale",     4  ));
	newInput(12, nodeValue_Float(    "Blending",       4  ));
	
	////- =Transform
	newInput( 1, nodeValue_Vec2(     "Position",  [0,0] )).setHotkey("G").setUnitSimple();
	newInput( 3, nodeValue_Rotation( "Rotation",   0    )).setHotkey("R");
	newInput( 2, nodeValue_Vec2(     "Scale",     [2,2] )).setHotkey("S");
	
	////- =Transform
	newInput( 6, nodeValue_Int(   "Iteration",   1   ));
	newInput(14, nodeValue_Float( "Itr. Factor", 1.5 ));
	// input 17
	
	newOutput(0, nodeValue_Output("Surface Out", VALUE_TYPE.surface, noone));
	
	input_display_list = [ 
		[ "Output",     true ],  0,  8,  9,  7, 
		[ "Noise",     false ],  5, 10, 11, 15, 16, 13, 12, 
		[ "Transform", false ],  1,  3,  2, 
		[ "Iteration", false ],  6, 14, 
	];
	
	////- Nodes
	
	attribute_surface_depth();
	attribute_oversample();
	
	temp_surface = [ noone, noone, noone ];
	surface_blur_init();
	
	static drawOverlay = function(hover, active, _x, _y, _s, _mx, _my, _params) { 
		var _pos = getInputSingle(1);
		var  px  = _x + _pos[0] * _s;
		var  py  = _y + _pos[1] * _s;
		
		InputDrawOverlay(inputs[ 1].drawOverlay(w_hoverable, active, _x, _y, _s, _mx, _my));
		InputDrawOverlay(inputs[ 3].drawOverlay(w_hoverable, active, px, py, _s, _mx, _my));
		// InputDrawOverlay(inputs[ 2].drawOverlay(w_hoverable, active, px, py, _s, _mx, _my));

		return w_hovering;
	}
	
	static processData = function(_outSurf, _data, _array_index = 0) { 
		#region data
			var _dim   = _data[ 0];
			
			var _sed   = _data[ 5];
			var _hgh   = _data[10];
			var _mod   = _data[ 4];
			var _rdsca = _data[11];
			var _rdrot = _data[15];
			var _rdcon = _data[16];
			
			var _clsca = _data[13];
			var _blurr = _data[12];
			
			var _pos   = _data[ 1];
			var _rot   = _data[ 3];
			var _sca   = _data[ 2];
			
			var _itr   = _data[ 6];
			var _ifac  = _data[14];
			
			var _dep = attrDepth();
			var _ovr = getAttribute("oversample");
		#endregion
		
		_outSurf = surface_verify(_outSurf, _dim[0], _dim[1], _dep);
		for( var i = 0, n = array_length(temp_surface); i < n; i++ ) {
			temp_surface[i] = surface_verify(temp_surface[i], _dim[0], _dim[1], _dep);
			surface_clear(temp_surface[i]);
		}
		
		shader_set(sh_noise_ridge);
			shader_set_uv(_data[8], _data[9]);
			shader_set_2("dimension", _dim  );
			shader_set_f("seed",      _sed  );
			
			shader_set_2("position",  _pos  );
			shader_set_f("rotation",  _rot  );
			
			shader_set_i("mode",      _mod  );
		shader_reset();
		
		var bg = 0;
		var scale  = [_sca[0], _sca[1]];
		var ampli  = _itr < 1? 1 : power(2, _itr) / (power(2, _itr + 1) - 1);
		var blurr  = _blurr;
		var ridSca = _rdsca;
		var celSca = _clsca;
		
		if(is_surface(_hgh)) {
			surface_set_shader(temp_surface[1]);
				draw_surface_stretched_safe(_hgh, 0, 0, _dim[0], _dim[1]);
			surface_reset_shader();
			
		} else {
			surface_set_shader(temp_surface[1], sh_noise_ridge_init);
				shader_set_uv(_data[8], _data[9]);
				shader_set_2("dimension", _dim  );
				shader_set_f("seed",      _sed  );
				
				shader_set_2("position",  _pos  );
				shader_set_f("rotation",  _rot  );
				shader_set_2("scale",     scale );
				shader_set_f("amplitude", ampli );
				
				draw_empty();
			surface_reset_shader();
		}
		
		repeat(_itr) {
			surface_set_shader(temp_surface[bg], sh_noise_ridge);
				shader_set_2("scale",         scale  );
				shader_set_f("amplitude",     ampli  );
				shader_set_f("ridgeAngle",    _rdrot );
				shader_set_f("ridgeScale",    ridSca );
				shader_set_f("ridgeContrast", _rdcon );
				
				shader_set_f("cellScale",  celSca );
				
				draw_surface(temp_surface[!bg], 0, 0);
			surface_reset_shader();
			
			if(blurr > 1) {
				var args = new blur_gauss_args(temp_surface[bg], blurr, _ovr).setBG(true, c_black);
				var blur = surface_apply_gaussian(args);
				
				surface_set_shader(temp_surface[bg], noone, true, BLEND.over);
					draw_surface(blur, 0, 0);
				surface_reset_shader();
			}
			
			scale[0] *= _ifac;
			scale[1] *= _ifac;
			ampli    /= _ifac;
			blurr    /= _ifac;
			ridSca   /= _ifac;
			
			bg = !bg;
		}
		
		surface_set_shader(_outSurf, noone, true, BLEND.over);
			draw_surface(temp_surface[!bg], 0, 0);
		surface_reset_shader();
		
		_outSurf = mask_apply_empty(_outSurf, _data[7]);
		return _outSurf; 
	}
}