function Node_Crop_Content(_x, _y, _group = noone) : Node(_x, _y, _group) constructor {
	name = "Crop Content";
	
	newActiveInput(1);
	
	////- =Surfaces
	newInput(0, nodeValue_Surface( "Surface In" )).setArrayDepth(1);
	newInput(2, nodeValue_EScroll( "Array Sizing",  1, [ "Largest, same size", "Independent" ]))
		.setTooltip("Cropping mode for dealing with image array.");
		
	newInput(4, nodeValue_Color( "Background", cola(c_black, 0) ));
	
	////- =Padding
	newInput(3, nodeValue_Padding( "Padding", [0,0,0,0], "Add padding back after crop."));
	// 5
	
	newOutput(0, nodeValue_Output( "Surface Out",   VALUE_TYPE.surface, noone     )).setArrayDepth(1);
	newOutput(1, nodeValue_Output( "Crop distance", VALUE_TYPE.integer, [0,0,0,0] )).setDisplay(VALUE_DISPLAY.padding).setArrayDepth(1);
	newOutput(2, nodeValue_Output( "Atlas",         VALUE_TYPE.atlas,   []        )).setArrayDepth(1);
	
	input_display_list = [ 1,
		[ "Surfaces", false ], 0, 2, 4, 
		[ "Padding",  false ], 3, 
	];
	
	////- Node
	
	attribute_surface_depth();
	
	drag_side = -1;
	drag_mx   = 0;
	drag_my   = 0;
	drag_sv   = 0;
	
	temp_surface = [ noone, noone, noone ];
	
	draw_transforms = [];
	static drawOverlayTransform = function(_node) { return array_safe_get(draw_transforms, preview_index, noone); }
	
	static update = function() { 
		#region data
			var _inSurf	= getInputData(0);
			var _array	= getInputData(2);
			var _bg 	= getInputData(4);
			
			var _padd	= getInputData(3);
		#endregion
		
		var _arr = is_array(_inSurf);
		_array   = _array && _arr;
		
		if(!_arr) _inSurf = [ _inSurf ];
		var _amo = array_length(_inSurf);
		
		var minx = array_create(_amo,  infinity);
		var miny = array_create(_amo,  infinity);
		var maxx = array_create(_amo, -infinity);
		var maxy = array_create(_amo, -infinity);
		var cDep = attrDepth();
		
		var _scaFactor = 4;
		var _maxSurf   = 64;
		
		for( var j = 0; j < _amo; j++ ) {
			var _surf = _inSurf[j];
			var  sw   = surface_get_width_safe(_surf);
			var  sh   = surface_get_height_safe(_surf);
			var _bgs  = _surf;
			var _emp  = false;
			var  bbox = [0,0,1,1];
			
			temp_surface[0] = surface_verify(temp_surface[0], sw, sh);
			
			var _itr = ceil(logn(4, max(sw, sh) / _maxSurf));
			if(_itr > 0) {
				var bg  = 0;
				var ssw = sw;
				var ssh = sh;
				
				temp_surface[1 +!bg] = surface_verify(temp_surface[1 +!bg], ssw, ssh);
				
				surface_set_shader(temp_surface[1 +!bg]);
					draw_surface_safe(_surf);
				surface_reset_shader();
					
				repeat(_itr) {
					ssw = ceil(ssw / _scaFactor);
					ssh = ceil(ssh / _scaFactor);

					temp_surface[1 + bg] = surface_verify(temp_surface[1 + bg], ssw, ssh);
					
					surface_set_shader(temp_surface[1 + bg], sh_crop_conent_downsample);
						shader_set_2("dimension",   [ssw, ssh] );
						shader_set_f("scaleFactor", _scaFactor );
						
						draw_surface_ext(temp_surface[1 + !bg], 0, 0, 1/_scaFactor, 1/_scaFactor, 0, c_white, 1);
					surface_reset_shader();
					
					bg = !bg;
				}
				
				_emp = surface_is_empty(temp_surface[1 + !bg]);
			}
			
			if(!_emp) {
				var _sclr = temp_surface[0];
				surface_set_shader(_sclr, sh_crop_content_replace_color);
					shader_set_c("target", _bg);
					draw_surface_safe(_bgs);
				surface_reset_shader();
				
				bbox = surface_get_bbox(_sclr);
			}
			
			var _minx = bbox[0];
			var _miny = bbox[1];
			var _maxx = bbox[0] + bbox[2];
			var _maxy = bbox[1] + bbox[3];
			
			if(_array) {
				minx[j] = _minx;
				miny[j] = _miny;
				
				maxx[j] = _maxx;
				maxy[j] = _maxy;
				
			} else {
				minx[0] = min(minx[0], _minx);
				miny[0] = min(miny[0], _miny);
				
				maxx[0] = max(maxx[0], _maxx);
				maxy[0] = max(maxy[0], _maxy);
			}
		}
		
		var _outSurfs = outputs[0].getValue();
		
		var resl = [];
		var crop = [];
		var atls = [];
		
		for( var i = 0; i < _amo; i++ ) {
			var _surf = _inSurf[i];
			var _ind  = _array == 0? 0 : i;
			var  sw   = surface_get_width_safe(_surf);
			var  sh   = surface_get_height_safe(_surf);
			
			var resDim = [maxx[_ind] - minx[_ind], maxy[_ind] - miny[_ind]];
			resDim[0] += _padd[PADDING.left] + _padd[PADDING.right];
			resDim[1] += _padd[PADDING.top]  + _padd[PADDING.bottom];
			
			var _out = array_safe_get_fast(_outSurfs, i);
			resl[i] = surface_verify(_out, resDim[0], resDim[1], cDep);
			crop[i] = [ sw - maxx[_ind], miny[_ind], minx[_ind], sh - maxy[_ind] ];
			
			var _sx = -minx[_ind] + _padd[PADDING.left];
			var _sy = -miny[_ind] + _padd[PADDING.top];
			
			surface_set_shader(resl[i], noone);
				draw_surface_safe(_surf, _sx, _sy);
			surface_reset_shader();
			
			atls[i] = new SurfaceAtlas(resl[i], minx[_ind], miny[_ind]);
			draw_transforms[i] = [_sx, _sy, 1, 1, 0];
		}
		
		outputs[0].setValue(_arr? resl : resl[0]);
		outputs[1].setValue(_arr? crop : crop[0]);
		outputs[2].setValue(_arr? atls : atls[0]);
	}
}