function Node_Project_Ground(_x, _y, _group = noone) : Node_Processor(_x, _y, _group) constructor {
	name = "Drop to Ground";
	
	////- =Ground
	newInput( 0, nodeValue_Surface( "Ground"       )).setRequired();
	
	////- =Rendering
	newInput( 1, nodeValue_EScroll( "Draw Ground", 1, ["None", "Above", "Under"] ));
	
	////- =Objects
	newInput( 2, nodeValue_Bool(    "Rotate", true ));
	// 
	
	newOutput(0, nodeValue_Output("Surface Out", VALUE_TYPE.surface, noone));
	
	function createNewInput(index = array_length(inputs)) {
		var inAmo = array_length(inputs);
		
		newInput(index+0, nodeValue_Surface(  "Object"   )).setVisible(true, true);
		newInput(index+1, nodeValue_Vec2(     "Position", [.5,.5] )).setUnitSimple();
		newInput(index+2, nodeValue_Float(    "Ground Offset", 0  ));
		// 3
		
		postCreateNewInput(index);
		refreshDynamicDisplay();
		return inputs[index];
	} 
	
	input_display_list = [ 
		[ "Ground",    false ],  0, 
		[ "Rendering", false ],  1, 
		[ "Objects",   false ],  2, -2, 
	];
	
	input_display_dynamic = [ 0, 1, 2, ];
	
	setDynamicInput(3);
	
	////- Nodes
	
	attribute_interpolation(true, true);
	
	temp_surface = [noone, noone, noone];
	temp_buff    = buffer_create(1, buffer_grow, 1);
	
	static drawOverlay = function(hover, active, _x, _y, _s, _mx, _my, _params) { 
		var _amo = getInputAmount();
		
		for( var i = 0; i < _amo; i++ ) {
			var _ind  = input_fix_len + i * data_length;
			drawOverlayInput(inputs[_ind+1].drawOverlay(w_hoverable, active, _x, _y, _s, _mx, _my));
		}
	}
	
	static processData = function(_outSurf, _data, _array_index = 0) { 
		#region data
			var _ground  = _data[ 0];
			
			var _drawGr  = _data[ 1];
			
			var _rotate  = _data[ 2];
			
			if(!is_surface(_ground)) return _outSurf; 
		#endregion
		
		var _amo = getInputAmount();
		var _dim = surface_get_dimension(_ground);
		
		_outSurf = surface_verify(_outSurf, _dim[0], _dim[1]);
		temp_surface[0] = surface_verify(temp_surface[0], _dim[0], _dim[1]);
		temp_surface[1] = surface_verify(temp_surface[1], _dim[0], 1, surface_r16float);
		
		surface_set_shader(_outSurf, sh_sample, true, BLEND.normal);
			shader_set_interpolation(_ground);
			if(_drawGr == 2) {
				shader_set_interpolation_surface(_ground);
				draw_surface(_ground, 0, 0);
			}
		surface_reset_shader();
		
		var po = [0,0];
		var objectTrans = [];
		
		for( var i = 0; i < _amo; i++ ) {
			var _ind  = input_fix_len + i * data_length;
			var _surf = _data[_ind+0];
			var _posi = _data[_ind+1];
			var _offs = _data[_ind+2];
			if(!is_surface(_surf)) continue;
			
			var bbox = surface_get_bbox(_surf);
			var minx = bbox[0];
			var miny = bbox[1];
			var conw = bbox[2];
			var conh = bbox[3];
			
			temp_surface[2] = surface_verify(temp_surface[2], conw, conh);
			surface_set_shader(temp_surface[2]);
				draw_surface(_surf, -minx, -miny);
			surface_reset_shader();
			
			var px = _posi[0] - conw / 2;
			var py = _posi[1] - conh / 2;
			
			surface_set_shader(temp_surface[0], sh_project_ground_filter);
				shader_set_i( "filter", 0 );
				draw_surface(_ground, 0, 0);
				
				shader_set_i( "filter", 1 );
				draw_surface(temp_surface[2], px, py);
			surface_reset_shader();
			
			surface_set_shader(temp_surface[1], sh_project_ground_drop);
				shader_set_s( "content",   temp_surface[0] );
				shader_set_i( "axis",      0               );
				shader_set_2( "dimension", _dim            );
				
				draw_empty();
			surface_reset_shader();
			
			buffer_get_surface(temp_buff, temp_surface[1], 0);
			buffer_to_start(temp_buff);
			
			var _gapDist = [];
			var _minDist = infinity;
			
			var soli = false;
			var xmin = 0;
			var xmax = 0;
			
			for( var j = 0; j < _dim[0]; j++ ) {
				var dd = buffer_read(temp_buff, buffer_f16);
				
				if(!soli) xmin = j;
				_gapDist[j] = dd;
				
				if(dd < 0) continue;
				
				_minDist = min(_minDist, dd);
				soli = true;
				xmax = j;
			}
			
			_gapDist = array_copy_trim(_gapDist, -1);
			var _rot = 0;
			
			if(_minDist < infinity) {
				if(_rotate) {
					var dat  = heightRegress(_gapDist);
					// print("_gapDist", _gapDist) print("dat", dat)
					
					_minDist = dat.offset;
					_rot     = -dat.angle;
				}
				
				py += _minDist;
			}
			
			surface_set_shader(_outSurf, sh_sample, false, BLEND.normal);
				var dx = px;
				var dy = py;
				
				var ax = conw/2;
				var ay = conh + _offs;
				
				dx += ax;
				dy += ay;
				
				po  = point_rotate(-ax, -ay, 0, 0, _rot, po);
				
				dx += po[0];
				dy += po[1];
				
				shader_set_interpolation_surface(temp_surface[2]);
				draw_surface_ext(temp_surface[2], dx, dy, 1, 1, _rot, c_white, 1);
			surface_reset_shader();
			
			// surface_set_target(_outSurf);
			// 	draw_point_color(px + conw/2 - 1, py + conh - 1, c_red);
			// surface_reset_target();
			
		}
		
		surface_set_shader(_outSurf, sh_sample, false, BLEND.normal);
			shader_set_interpolation(_ground);
			if(_drawGr == 1) {
				shader_set_interpolation_surface(_ground);
				draw_surface(_ground, 0, 0);
			}
		surface_reset_shader();
		
		return _outSurf; 
	}
	
	function heightRegress(heights) {
	    var n = array_length(heights);
	    if (n == 0) return { offset: 0,          angle: 0 };
	    if (n == 1) return { offset: heights[0], angle: 0 };
			
	    var meanX = (n - 1) / 2;
	    var hull  = array_create(n);
	    var h     = 0;
	    
	    for (var i = 0; i < n; i++) {
	        while (h >= 2) {
	            var a = hull[h - 2], b = hull[h - 1];
	            var cross = (b - a) * (heights[i] - heights[a]) - (heights[b] - heights[a]) * (i - a);
	            if (cross <= 0) h--;
	            else break;
	        }
	        
	        hull[h++] = i;
	    }
	
	    var k = 0;
	    while (k < h - 2 && hull[k + 1] < meanX) k++;
	
	    var x0 = hull[k], x1 = hull[k + 1];
	    var slope  = (heights[x1] - heights[x0]) / (x1 - x0);
	    var offset = heights[x0] + slope * (meanX - x0);
	
	    return { offset: offset, angle: darctan(slope) };
	}
}