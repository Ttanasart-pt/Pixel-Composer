function Node_FLIP_Fill(_x, _y, _group = noone) : Node(_x, _y, _group) constructor {
	name  = "Fill";
	color = COLORS.node_blend_fluid;
	icon  = THEME.fluid_sim;
	
	manual_ungroupable = false;
	
	newInput( 0, nodeValue_Fdomain( "Domain" )).setVisible(true, true);
	newInput( 5, nodeValueSeed());
	
	////- =Fill
	spawner_shapes = [ new scrollItem( "Rectangle", s_node_shape_rectangle, 0 ), "Surface" ];
	newInput( 1, nodeValue_EScroll( "Spawn Shape",  0, spawner_shapes   ));
	newInput( 2, nodeValue_Surface( "Spawn Surface"                     ));
	newInput( 3, nodeValue_Area(    "Spawn Area",   DEF_AREA_REF, false )).setUnitSimple();
	newInput( 4, nodeValue_Slider(  "Density",      .5, [0,4,.01]       ));
	// 6
	
	newOutput(0, nodeValue_Output("Domain", VALUE_TYPE.fdomain, noone ));
	
	input_display_list = [ 0, 5, 
		[ "Fill", false ],  1,  2,  3,  4, 
	];
	
	////- Node
	
	point_cache = [];
	
	static getDimension = function() { var d = getInputData(0); return instance_exists(d)? d.getSize() : [ 1, 1 ]; }
	
	static drawOverlay = function(hover, active, _x, _y, _s, _mx, _my, _params) { 
		var _shp = getInputData(1);
		
		if(_shp == 0) InputDrawOverlay(inputs[3].drawOverlay(w_hoverable, active, _x,  _y, _s, _mx, _my));
		
		return w_hovering;
	}
	
	static update = function(frame = CURRENT_FRAME) {
		#region data
			var domain = getInputData( 0);
			var _seed  = getInputData( 5);
			outputs[0].setValue(domain);
			
			var _shape = getInputData( 1);
			var _surf  = getInputData( 2);
			var _area  = getInputData( 3);
			var _dens  = getInputData( 4); 
			
			inputs[ 2].setVisible(_shape == 1, _shape == 1);
			inputs[ 3].setVisible(_shape == 0);
		#endregion
			
		if(!instance_exists(domain)) return;
		if(!IS_FIRST_FRAME) return;
		
		if(_shape == 1 && !is_surface(_surf)) return;
		
		var _psize = domain.particleSize;
		    _dens  = max(.001, _dens / _psize);
		
		var ax0 = _area[0] - _area[2];
		var ay0 = _area[1] - _area[3];
		var ax1 = _area[0] + _area[2];
		var ay1 = _area[1] + _area[3];
		
		var _amo   = 0;
		var _buffP = undefined;
		var _buffV = undefined;
		
		switch(_shape) {
			case 0 : 
				var _row = ceil((ay1 - ay0) * _dens);
				var _col = ceil((ax1 - ax0) * _dens);
				var _amo = _row * _col;
				
				var _buffP = buffer_create(_amo * 2 * 8, buffer_fixed, 8); buffer_seek(_buffP, buffer_seek_start, 0);
				var _buffV = buffer_create(_amo * 2 * 8, buffer_fixed, 8); buffer_seek(_buffV, buffer_seek_start, 0);
				
				for( var i = 0; i < _row; i++ )
				for( var j = 0; j < _col; j++ ) {
					var _x = lerp(ax0, ax1, j / (_col - 1));
					var _y = lerp(ay0, ay1, i / (_row - 1));
					
					buffer_write(_buffP, buffer_f64, clamp(_x + _psize, 0, domain.width));
					buffer_write(_buffP, buffer_f64, clamp(_y + _psize, 0, domain.height));
					
					buffer_write(_buffV, buffer_f64, 0);
					buffer_write(_buffV, buffer_f64, 0);
				}
				
				break;
				
			case 1 : 
				var _buff = new Surface_Sampler_Grey(_surf);
				var _b = _buff.buffer;
				var _s = buffer_get_size(_b) / 2;
				var _i = 0;
				
				var _sw = surface_get_width(_surf);
				var _sh = surface_get_height(_surf);
				var _amo = 0;
				
				var _pxS = max(1, ceil(1 / _dens));
				
				var _buffP = buffer_create(0, buffer_grow, 8); buffer_seek(_buffP, buffer_seek_start, 0);
				var _buffV = buffer_create(0, buffer_grow, 8); buffer_seek(_buffV, buffer_seek_start, 0);
				
				buffer_to_start(_b);
				while(_i < _s) {
					var g = buffer_read(_b, buffer_f16);
					if(g > .5) {
						var _x = _i % _sw;
						var _y = floor(_i / _sw);
						
						buffer_write(_buffP, buffer_f64, clamp(_x + _psize, 0, domain.width));
						buffer_write(_buffP, buffer_f64, clamp(_y + _psize, 0, domain.height));
						
						buffer_write(_buffV, buffer_f64, 0);
						buffer_write(_buffV, buffer_f64, 0);
						
						_amo++;
					}
					
					buffer_seek(_b, buffer_seek_relative, _pxS * 2 - 2);
					_i += _pxS;
				}
				
				_buff.free();
				break;
		}
		
		if(_amo) {
			domain.numParticles += _amo;
			FLIP_spawnParticles(domain.domain, buffer_get_address(_buffP), buffer_get_address(_buffV), _amo);
		}
		
		buffer_delete_safe(_buffP);
		buffer_delete_safe(_buffV);
	}
	
	static onDrawNode = function(xx, yy, _mx, _my, _s, _hover, _focus) {
		var bbox   = draw_bbox;
		var _shape = getInputData(1);
		var _surf  = getInputData(2);
		
		var ss = max(0, min(bbox.w, bbox.h) / 2 - 16 * _s);
		draw_set_color(c_white);
		switch(_shape) {
			case 0 : draw_rectangle(bbox.xc - ss, bbox.yc - ss, bbox.xc + ss, bbox.yc + ss, false); break;
			case 1 : draw_surface_bbox(_surf, bbox); break;
		}
	}
	
	static getPreviewValues = function() { 
		var domain = getInputData(0); 
		return instance_exists(domain)? domain.domain_preview : noone; 
	}
	
}