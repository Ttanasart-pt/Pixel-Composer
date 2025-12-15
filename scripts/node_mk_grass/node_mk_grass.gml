function Node_MK_Grass(_x, _y, _group = noone) : Node_Processor(_x, _y, _group) constructor {
	name = "MK Grass";
	
	newInput(1, nodeValueSeed());
	newInput(0, nodeValue_Surface("Surface In"));
	
	////- =Source
	onSurfaceSize = function() /*=>*/ {return getDimension()};
	
	newInput(2, nodeValue_Enum_Scroll("Source", 0, [ "Area", "Mask", "Region", "Color Picker" ]));
	newInput(3, nodeValue_Area(       "Area",  DEF_AREA_REF, { onSurfaceSize })).setUnitSimple();
	newInput(4, nodeValue_Surface(    "Mask" ));
	newInput(5, nodeValue_Vec2(       "Picker", [ 0, 0 ] ));
	newInput(6, nodeValue_Slider(     "Picker Threshold", .1 ));
	
	////- =Shape
	shape_types = __enum_array_gen([ "Dense Bush", "V", "Hash", "Line", "W" ], s_node_mk_grass_type, c_white);
	newInput( 7, nodeValue_Enum_Scroll( "Shape",    0, { data: shape_types, horizontal: 2, text_pad: ui(16) } )).getEditWidget().setFilter(false);
	newInput(22, nodeValue_Slider(      "Ratio",   .5     ));
	newInput( 8, nodeValue_Range(       "Size",    [4,4], { linked: true }));
	newInput(17, nodeValue_Slider(      "Spread",   0     ));
	newInput(20, nodeValue_Float(       "Extra",    0     ));
	newInput(21, nodeValue_Range(       "Sway X",  [-4,4] ));
	
	////- =Scatter
	newInput( 9, nodeValue_Slider( "Distribution", .5 ));
	newInput(10, nodeValue_Int(    "Level",         1 ));
	newInput(11, nodeValue_Slider( "Sharpness",    .5 ));
	newInput(14, nodeValue_Float(  "Noise Scale",   1 ));
	newInput(15, nodeValue_Int(    "Noise Detail",  1 ));
	
	////- =Render
	newInput(12, nodeValue_Enum_Scroll( "Render Type",    0, [ "Gradient", "Sample Multiply", "Sample Add" ] ));
	newInput(13, nodeValue_Gradient(    "Colors",         gra_black_white ));
	newInput(16, nodeValue_Slider(      "Color Variance", 0 ));
	
	////- =Ground
	newInput(18, nodeValue_Bool(  "Fill Ground", false));
	newInput(19, nodeValue_Color( "Ground",      ca_black));
	
	// input 23
	
	input_display_list = [ new Inspector_Sprite(s_MKFX), 1, 0, 
		["Source",  false    ],  2,  3,  4,  5,  6, 
		["Shape",   false    ],  7, 22,  8, 17, 20, 21, 
		["Scatter", false    ],  9, 11, 14, 15,
		["Render",  false    ], 12, 13, 16, 
		["Ground",  false, 18], 19, 
	];
	
	newOutput(0, nodeValue_Output("Surface Out", VALUE_TYPE.surface, noone));
	
	temp_surface = [ 0, 0, 0, 0 ];
	
	////- Nodes
	
	static drawOverlay = function(hover, active, _x, _y, _s, _mx, _my, _snx, _sny, _params) { 
		var _src = getSingleValue(2);
		
		switch(_src) {
			case 0 :
				InputDrawOverlay(inputs[3].drawOverlay(w_hoverable, active, _x, _y, _s, _mx, _my, _snx, _sny));
				break;
			
			case 2 :
			case 3 :
				InputDrawOverlay(inputs[5].drawOverlay(w_hoverable, active, _x, _y, _s, _mx, _my, _snx, _sny));
				break;
		}
		
		return w_hovering;
	}
	
	static processData = function(_outSurf, _data, _array_index) {
		#region data
			var _seed     = _data[1];
			var _surf     = _data[0];
			
			var _src      = _data[2];
			var _area     = _data[3];
			var _mask     = _data[4];
			var _pick     = _data[5];
			var _pick_thr = _data[6];
			
			var _shape    = _data[ 7];
			var _dist     = _data[22];
			var _size     = _data[ 8];
			var _spread   = _data[17];
			var _expand   = _data[20];
			var _swayx    = _data[21];
			
			var _dens     = _data[9];
			var _noi_lev  = _data[10];
			var _noi_shp  = _data[11];
			var _sizeSca  = _data[14];
			var _sizeItr  = _data[15];
			
			var _rtype    = _data[12];
			var _color    = _data[13];
			var _color_vr = _data[16];
			var _gnd_fil  = _data[18];
			var _gnd_clr  = _data[19];
			
			inputs[ 8].setVisible(_shape == 0 || _shape == 2 || _shape == 3 || _shape == 4);
			inputs[22].setVisible(_shape != 2);
			inputs[17].setVisible(_shape == 0);
			inputs[16].setVisible(_shape == 0);
			inputs[20].setVisible(_shape == 0);
			inputs[21].setVisible(_shape == 3 || _shape == 4);
			
			inputs[3].setVisible(_src == 0);
			inputs[4].setVisible(_src == 1,   _src == 1);
			inputs[5].setVisible(_src == 2 || _src == 3);
			inputs[6].setVisible(_src == 2 || _src == 3);
		#endregion
			
		random_set_seed(_seed);
		var _dim = surface_get_dimension(_surf);
		temp_surface[0] = surface_verify(temp_surface[0], _dim[0], _dim[1], surface_rgba32float);
		temp_surface[1] = surface_verify(temp_surface[1], _dim[0], _dim[1], surface_rgba32float);
		temp_surface[2] = surface_verify(temp_surface[2], _dim[0], _dim[1], surface_rgba32float);
		temp_surface[3] = surface_verify(temp_surface[3], _dim[0], _dim[1]);
		
		var _gMaskIndex = 0;
		switch(_src) { // Generate Mask
			case 0 : 
				var x0 = _area[0] - _area[2];
				var y0 = _area[1] - _area[3];
				var x1 = _area[0] + _area[2];
				var y1 = _area[1] + _area[3];
				
				surface_set_target(temp_surface[0]);
					DRAW_CLEAR
					draw_set_color(c_white);
					     if(_area[4] == AREA_SHAPE.rectangle) draw_rectangle( x0, y0, x1, y1, false );
					else if(_area[4] == AREA_SHAPE.elipse)    draw_ellipse(   x0, y0, x1, y1, false );
				surface_reset_target();
				
				_gMaskIndex = 0;
				break;
				
			case 1 : 
				surface_set_target(temp_surface[0]);
					DRAW_CLEAR
					draw_surface_safe(_mask); 
				surface_reset_target();
				
				_gMaskIndex = 0;
				break;
			
			case 2 : 
			case 3 : 
				var _itr = _src == 2? max(_dim[0], _dim[1]) / 2 : 1;
				var _bg  = 0;
				
				var _baseColor = surface_getpixel_ext(_surf, _pick[0], _pick[1]);
				
				draw_set_color(c_white);
				surface_set_shader(temp_surface[0], noone); draw_point(_pick[0]-1, _pick[1]-1); surface_reset_shader();
				surface_set_shader(temp_surface[1], noone); draw_point(_pick[0]-1, _pick[1]-1); surface_reset_shader();
				
				repeat(_itr) {
					surface_set_shader(temp_surface[_bg], sh_mk_grass_floodfill);
						shader_set_surface("baseSurface", _surf);
						shader_set_2("dimension", _dim);
						shader_set_c("baseColor", _baseColor);
						shader_set_f("threshold", _pick_thr);
						shader_set_i("region",    _src == 2);
						
						draw_surface_safe(temp_surface[!_bg]);
					surface_reset_shader();
					_bg = !_bg;
				}
				
				_gMaskIndex = !_bg;
				break;
		} // Generate Mask
		
		#region Noise
			surface_set_shader(temp_surface[2], sh_mk_grass_noise);
				shader_set_f("seed",        _seed);
				shader_set_2("dimension",    _dim);
				
				shader_set_3("position",     [0, 0, _seed]);
				shader_set_f("rotation",     0);
				shader_set_2("scale",        [_sizeSca, _sizeSca]);
				shader_set_f("iteration",    _sizeItr);
				shader_set_f("phase",        0);
				shader_set_f("itrScaling",   2);
				shader_set_f("itrAmplitude",.5);
				
				shader_set_f("density",     _dens);
				shader_set_f("sharpness",   _noi_shp);
				
				draw_surface_safe(temp_surface[_gMaskIndex]);
			surface_reset_shader();
		#endregion
		
		#region Grass
			var sh = noone;
		
			switch(_shape) {
				case 0 : sh = sh_mk_grass_grow;      break;
				case 1 : sh = sh_mk_grass_grow_v;    break;
				case 2 : sh = sh_mk_grass_grow_hash; break;
			}
			
			if(sh != noone) {
				surface_set_shader(_outSurf, sh);
				shader_set_surface("grassMask", temp_surface[2]);
				shader_set_f("seed",          _seed);
				shader_set_2("dimension",     _dim);
				shader_set_2("grassSize",     _size);
				shader_set_f("colorVariance", _color_vr);
				shader_set_f("density",       _dens);
				shader_set_f("distribution",  _dist);
				shader_set_f("expand",        _expand);
				
				shader_set_i("renderType",    _rtype);
				shader_set_i("groundFill",    _gnd_fil);
				shader_set_c("groundColor",   _gnd_clr);
				
				_color.shader_submit();
				
				draw_surface_safe(_surf);
				surface_reset_shader();
				
			} else {
				surface_set_shader(temp_surface[3], sh_mk_grass_grow_cvt);
					shader_set_f("seed",      _seed);
					shader_set_f("density",   _dist);
					shader_set_2("dimension", _dim);
					
					draw_surface_safe(temp_surface[2]);
				surface_reset_shader();
				
				var _gSrf = temp_surface[3];
				var _sw   = surface_get_width(_gSrf);
				var _sh   = surface_get_height(_gSrf);
				var _sBuf = buffer_from_surface(_gSrf, false);
				var _sOut = buffer_create(_sw * _sh * (8*7), buffer_fixed, 1);
				
				var _args = buffer_create(1, buffer_grow, 1);
				buffer_write(_args, buffer_u64, buffer_get_address(_sBuf));
				buffer_write(_args, buffer_u64, buffer_get_address(_sOut));
				buffer_write(_args, buffer_f64, _sw);
				buffer_write(_args, buffer_f64, _sh);
				buffer_write(_args, buffer_f64, _seed);
				buffer_write(_args, buffer_f64, _size[0]);
				buffer_write(_args, buffer_f64, _size[1]);
				buffer_write(_args, buffer_f64, _swayx[0]);
				buffer_write(_args, buffer_f64, _swayx[1]);
				
				var _amo  = mk_grass_get_data(buffer_get_address(_args));
				buffer_delete(_sBuf);
				buffer_to_start(_sOut);
				
				surface_set_shader(temp_surface[3], noone);
				switch(_shape) {
					case 3 : 
						repeat(_amo) {
							var px = buffer_read(_sOut, buffer_f64); var py = buffer_read(_sOut, buffer_f64);
							var gx = buffer_read(_sOut, buffer_f64); var gy = buffer_read(_sOut, buffer_f64);
							
							var rr = buffer_read(_sOut, buffer_f64); var gg = buffer_read(_sOut, buffer_f64); var bb = buffer_read(_sOut, buffer_f64);
							
							draw_line_color(px, py, px + gx, py - gy, #000000, #ff0000); 
						}
						break;
						
					case 4 : 
						repeat(_amo) {
							var px = buffer_read(_sOut, buffer_f64); var py = buffer_read(_sOut, buffer_f64);
							var gx = buffer_read(_sOut, buffer_f64); var gy = buffer_read(_sOut, buffer_f64);
							
							var rr = buffer_read(_sOut, buffer_f64); var gg = buffer_read(_sOut, buffer_f64); var bb = buffer_read(_sOut, buffer_f64);
							
							var dx = abs(gx);
							var dy = gy * .7;
							
							random_set_seed(py * _dim[0] + px);
							draw_set_color(make_color_rgb(irandom(255), 0, 0));
							
							draw_line(px,   py, px,        py - gy); 
							draw_line(px,   py, px   - dx, py - dy); 
							draw_line(px-1, py, px-1 + dx, py - dy); 
						}
						break;
						
					case 5 :
						break;
				}
				surface_reset_shader();
				buffer_delete(_sOut);
				
				surface_set_shader(_outSurf, sh_mk_grass_grow_apply);
					shader_set_surface("grassMask",    temp_surface[2]);
					shader_set_surface("grassTexture", temp_surface[3]);
					
					shader_set_f("seed",          _seed);
					shader_set_2("dimension",     _dim);
					shader_set_2("grassSize",     _size);
					shader_set_f("colorVariance", _color_vr);
					shader_set_f("density",       _dens);
					shader_set_f("expand",        _expand);
					
					shader_set_i("renderType",    _rtype);
					shader_set_i("groundFill",    _gnd_fil);
					shader_set_c("groundColor",   _gnd_clr);
				
					_color.shader_submit();
				
					draw_surface_safe(_surf);
				surface_reset_shader();
			}
		#endregion
		
		return _outSurf;
	}
}

/*[cpp]
#include <cstdint>
#include <stdlib.h>

struct pixel {
	uint8_t r;
	uint8_t g;
	uint8_t b;
	uint8_t a;
};

struct mk_grass_parameter {
	void* pixelArrayBuffer;
	void* outputBuffer;
	double width;
	double height;

	double seed;
	double size_min;
	double size_max;
	double sway_min;
	double sway_max;
};

struct mk_grass_pixel{
	double x;
	double y;

	double gx;
	double gy;

	double r;
	double g;
	double b;
};

double random_range(double min, double max) {
	return min + (static_cast<double>(rand()) / RAND_MAX) * (max - min);
}

cfunction double mk_grass_get_data(void* args) {
	mk_grass_parameter* params = (mk_grass_parameter*)args;

	pixel* pixelArray = (pixel*)params->pixelArrayBuffer;
	mk_grass_pixel* outputArray = (mk_grass_pixel*)params->outputBuffer;

	size_t widthInt  = (size_t)params->width;
	size_t heightInt = (size_t)params->height;
	size_t size      = widthInt * heightInt;

	double seed     = params->seed;
	double size_min = params->size_min;
	double size_max = params->size_max;
	double sway_min = params->sway_min;
	double sway_max = params->sway_max;

    int amount = 0;

	for (size_t i = 0; i < size; ++i) {
		if (pixelArray[i].a == 0) continue;

		double g = (double)pixelArray[i].g / 255.0;

		uint16_t x = (uint16_t)(i % widthInt);
		uint16_t y = (uint16_t)(i / widthInt);

		srand((uint32_t)(seed + i * 100));

		outputArray[amount].x  = x;
		outputArray[amount].y  = y;
		outputArray[amount].gx = random_range(sway_min, sway_max) * g;
		outputArray[amount].gy = random_range(size_min, size_max) * g;

		outputArray[amount].r = (double)pixelArray[i].r / 255.0;
		outputArray[amount].g = (double)pixelArray[i].g / 255.0;
		outputArray[amount].b = (double)pixelArray[i].b / 255.0;

	    amount++;
    }
	
    return amount;
}

*/