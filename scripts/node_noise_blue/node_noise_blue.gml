function Node_Noise_Blue(_x, _y, _group = noone) : Node_Processor(_x, _y, _group) constructor {
	name = "Blue Noise";
	
	////- =Output
	newInput(0, nodeValue_Dimension());
	newInput(2, nodeValue_Surface("Mask"));
	
	////- =Noise
	newInput(1, nodeValueSeed());
	newInput(6, nodeValue_Slider( "Threshold",  .1 ));
	newInput(3, nodeValue_Int(    "Iteration",  32 ));
	newInput(4, nodeValue_Float(  "Radius",    .25 )).setUnitSimple();
	newInput(5, nodeValue_Float(  "Sigma",     1.9 ));
	
	////- =Performance
	newInput(7, nodeValue_Int(    "Patch Size", 32 ));
	// 8
	
	newOutput(0, nodeValue_Output("Surface Out", VALUE_TYPE.surface, noone));
	
	input_display_list = [
		[ "Output",      false ], 0, 2, 
		[ "Noise",       false ], 1, 6, 3, 4, 5,
		[ "Performance", false ], 7, 
	];
	
	////- Node
	
	attribute_surface_depth();
	
	temp_surface = [ noone, noone, noone, noone ];
	
	static processData = function(_outSurf, _data, _array_index) {
		#region data
			var _dim = _data[0];
			
			var _sed = _data[1];
			var _thr = _data[6];
			var _itr = _data[3];
			var _rad = _data[4];
			var _sig = _data[5];
			
			var _pat = _data[7];
		#endregion
		
		surface_clear(_outSurf);
		var _patchSize = min(_pat, _dim[0], _dim[1]);
		var _patchDim  = [_patchSize, _patchSize];
		var _patchCol  = ceil(_dim[0] / _patchSize); 
		var _patchRow  = ceil(_dim[1] / _patchSize); 
		var _patchAmo  = _patchCol * _patchRow;
		var _patchInd  = 0;
		var _patchPix  = _patchSize * _patchSize;
		
		for( var i = 0, n = array_length(temp_surface); i < n; i++ ) {
			temp_surface[i] = surface_verify(temp_surface[i], _patchSize, _patchSize);
			surface_clear(temp_surface[i]);
		}
		
		shader_set(sh_noise_blue_initial);
			shader_set_2( "dimension", _patchDim );
			shader_set_f( "threshold", _thr );
		shader_reset();
		
		shader_set(sh_noise_blue_energy);
			shader_set_2( "dimension", _patchDim );
			shader_set_i( "radius",    _rad );
			shader_set_f( "sigma",     _sig );
		shader_reset();
		
		repeat(_patchAmo) {
			surface_clear(temp_surface[2]);
			random_set_seed(_sed);
			
			////- =Initial Binary
			
			surface_set_shader(temp_surface[1], sh_noise_blue_initial);
				shader_set_f( "seed",      _sed );
				draw_empty();
			surface_reset_shader();
			
			surface_set_shader(temp_surface[0], sh_noise_blue_energy);
				shader_set_i( "inverted", false );
			surface_reset_shader();
			
			repeat(_itr) {
				surface_set_target(temp_surface[0]);
				shader_set(sh_noise_blue_energy);
					draw_surface(temp_surface[1], 0, 0);
				shader_reset();
				surface_reset_target();
				
				var vc = surface_get_min_max(temp_surface[0]);
				surface_set_target(temp_surface[1]);
					draw_point_color(vc[4], vc[5], c_black);
					draw_point_color(vc[2], vc[3], c_white);
				surface_reset_target();
			}
			
			surface_set_target(temp_surface[3]);
				draw_surface(temp_surface[1], 0, 0);
			surface_reset_target();
			
			////- =Order white
			
			var _wht = surface_get_white(temp_surface[1]);
			
			var _ord = _wht;
			repeat(_wht) {
				surface_set_target(temp_surface[0]);
				shader_set(sh_noise_blue_energy);
					draw_surface(temp_surface[3], 0, 0);
				shader_reset();
				surface_reset_target();
				
				var vc = surface_get_min_max(temp_surface[0]);
				surface_set_target(temp_surface[3]);
					draw_point_color(vc[4], vc[5], c_black);
				surface_reset_target();
				
				surface_set_target(temp_surface[2]);
					draw_point_color(vc[4], vc[5], make_color_grey(_ord / _patchPix));
				surface_reset_target();
				_ord--;
			}
			
			////- =Order black
			
			var _ord = _wht + 1;
			repeat(_patchPix / 2 - _wht) {
				surface_set_target(temp_surface[0]);
				shader_set(sh_noise_blue_energy);
					draw_surface(temp_surface[1], 0, 0);
				shader_reset();
				surface_reset_target();
				
				var vc = surface_get_min_max(temp_surface[0], irandom(_patchPix));
				surface_set_target(temp_surface[1]);
					draw_point_color(vc[2], vc[3], c_white);
				surface_reset_target();
				
				surface_set_target(temp_surface[2]);
					draw_point_color(vc[2], vc[3], make_color_grey(_ord / _patchPix));
				surface_reset_target();
				_ord++;
			}
			
			////- =Fil gaps
			
			surface_set_shader(temp_surface[0], sh_noise_blue_energy);
				shader_set_i( "inverted",  true );
			surface_reset_shader();
			
			repeat(_patchPix / 2) {
				surface_set_target(temp_surface[0]);
				shader_set(sh_noise_blue_energy);
					draw_surface(temp_surface[1], 0, 0);
				shader_reset();
				surface_reset_target();
				
				var vc = surface_get_min_max(temp_surface[0]);
				surface_set_target(temp_surface[1]);
					draw_point_color(vc[2], vc[3], c_white);
				surface_reset_target();
				
				surface_set_target(temp_surface[2]);
					draw_point_color(vc[2], vc[3], make_color_grey(_ord / _patchPix));
				surface_reset_target();
				
				_ord++;
			}
			
			////- =Draw patch
			
			var px =      (_patchInd % _patchCol) * _patchSize;
			var py = floor(_patchInd / _patchCol) * _patchSize;
			surface_set_target(_outSurf);
				draw_surface(temp_surface[2], px, py);
			surface_reset_target();
			
			_patchInd++;
			_sed++;
		}
		
		_outSurf = mask_apply_empty(_outSurf, _data[input_mask_index]);
		return _outSurf;
	}
}