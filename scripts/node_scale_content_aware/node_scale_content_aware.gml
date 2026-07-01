function Node_Scale_Content_Aware(_x, _y, _group = noone) : Node_Processor(_x, _y, _group) constructor {
	name = "Content-Aware Scale";
	
	////- =Surface
	newInput( 0, nodeValue_Surface( "Surface In" ));
	
	////- =Scale
	newInput( 2, nodeValue_EButton(   "Type",         0, [ "Multiply", "Scale to Size" ] ));
	newInput( 1, nodeValue_Vec2(      "Scale",       [1,1], true ));
	newInput( 3, nodeValue_Dimension( "Target Size", [1,1], true ));
	
	////- =Algorithm
	newInput( 4, nodeValue_EButton(   "Seam",         0, [ "Minimum", "Maximum" ] ));
	// 5
	
	newOutput(0, nodeValue_Output("Surface Out", VALUE_TYPE.surface, noone));
	
	input_display_list = [ 
		[ "Surface",   false ],  0, 
		[ "Scale",     false ],  2,  1,  3, 
		[ "Algorithm", false ],  4, 
	];
	
	////- Nodes
	
	temp_surface = array_create(6, noone);
	
	static scaleX = function(_outSurf, _surf, _scalX, _seam) {
		var ssw = surface_get_width(_surf);
		var ssh = surface_get_height(_surf);
		
		var sw  = ssw;
		var sh  = ssh;
		
		var scw   = ceil(sw * _scalX);
		var seamW = abs(sw - scw);
		var downW = scw < sw;
		
		var dataW = max(scw, sw);
		var dataH = sh;
		
		var surface   = array_create(dataW * dataH);
		var energy    = array_create(dataW * dataH);
		var accEnergy = array_create(dataW * dataH);
		var prevPx    = array_create(dataW * dataH);
		var seam      = array_create(        dataH);
		
		var buffer   = buffer_create(sw * sh * 4, buffer_fixed, 1);
		buffer_get_surface(buffer, _surf, 0); buffer_to_start(buffer);
		for( var _y = 0; _y < sh; _y++ ) 
		for( var _x = 0; _x < sw; _x++ )
			surface[_y * dataW + _x] = buffer_read(buffer, buffer_u32);
		buffer_delete(buffer);
		
		var swap = false;
		
		repeat(seamW) {
			// Energy map
			for( var _y = 0; _y < sh; _y++ )
			for( var _x = 0; _x < sw; _x++ ) {
				var pxl = _x > 0?    surface[_y * dataW + _x - 1] : 0;
				var pxc =            surface[_y * dataW + _x    ];
				var pxr = _x < sw-1? surface[_y * dataW + _x + 1] : 0;
				
				var grl = (color_get_r(pxl) + color_get_g(pxl) + color_get_b(pxl)) / 3 * color_get_a(pxl) / 255;
				var grc = (color_get_r(pxc) + color_get_g(pxc) + color_get_b(pxc)) / 3 * color_get_a(pxc) / 255;
				var grr = (color_get_r(pxr) + color_get_g(pxr) + color_get_b(pxr)) / 3 * color_get_a(pxr) / 255;
				
				energy[_y * dataW + _x] = abs(grl - grc) + abs(grr - grc);
			}
			
			// Search
			for(var _x = 0; _x < sw; _x++)
				accEnergy[_x] = energy[_x];
			var lastX = -1;
			
			if(_seam == 0) {
				for(var _y = 1; _y < sh; _y++)
				for(var _x = 0; _x < sw; _x++) {
					var minEnergy = 9999999;
					var minPrevX  = _x;
		
					for(var px = _x - 1; px <= _x + 1; px++) {
						if(px < 0 || px >= sw) continue;
						if(accEnergy[(_y - 1) * dataW + px] < minEnergy) {
							minEnergy = accEnergy[(_y - 1) * dataW + px];
							minPrevX  = px;
						}
					}
		
					accEnergy[_y * dataW + _x] = energy[_y * dataW + _x] + minEnergy;
					prevPx[_y * dataW + _x]    = minPrevX;
				}
				
				var minEnergy = 9999999;
				for(var _x = 0; _x < sw; _x++) {
					var an = accEnergy[(sh - 1) * dataW + _x];
					if((swap == 0 && an < minEnergy) || (swap == 1 && an <= minEnergy)) {
						minEnergy = an;
						lastX     = _x;
					}
				}
				
			} else {
				for(var _y = 1; _y < sh; _y++)
				for(var _x = 0; _x < sw; _x++) {
					var maxEnergy = 0;
					var maxPrevX  = _x;
		
					for(var px = _x - 1; px <= _x + 1; px++) {
						if(px < 0 || px >= sw) continue;
						if(accEnergy[(_y - 1) * dataW + px] > maxEnergy) {
							maxEnergy = accEnergy[(_y - 1) * dataW + px];
							maxPrevX  = px;
						}
					}
		
					accEnergy[_y * dataW + _x] = energy[_y * dataW + _x] + maxEnergy;
					prevPx[_y * dataW + _x]    = maxPrevX;
				}
			
				var maxEnergy = 0;
				for(var _x = 0; _x < sw; _x++) {
					var an = accEnergy[(sh - 1) * dataW + _x];
					if((swap == 0 && an > maxEnergy) || (swap == 1 && an >= maxEnergy)) {
						maxEnergy = an;
						lastX     = _x;
					}
				}
				
			}
			
			swap = !swap;
				
			if(lastX < 0) break;
			for(var _y = sh - 1; _y >= 0; _y--) {
				seam[_y] = lastX;
				lastX    = prevPx[_y * dataW + lastX];
			}
			
			// Copy data
			if(downW) {
				for(var _y = 0; _y < sh; _y++) {
					var seamX = seam[_y];
					for(var _x = 0; _x < sw - 1; _x++) {
						if(_x < seamX) surface[_y * dataW + _x] = surface[_y * dataW + _x    ];
						else           surface[_y * dataW + _x] = surface[_y * dataW + _x + 1];
					}
				}
				sw--;
				
			} else {
				for(var _y = 0; _y < sh; _y++) {
					var seamX = seam[_y];
					for(var _x = sw; _x >= 0; _x--) {
						if(_x <= seamX) surface[_y * dataW + _x] = surface[_y * dataW + _x    ];
						else            surface[_y * dataW + _x] = surface[_y * dataW + _x - 1];
					}
				}
				sw++;
			}
			
		}
		
		_outSurf = surface_verify(_outSurf, sw, sh);
		var buffer   = buffer_create(sw * sh * 4, buffer_fixed, 1);
		buffer_to_start(buffer);
		for( var _y = 0; _y < sh; _y++ ) 
		for( var _x = 0; _x < sw; _x++ )
			buffer_write(buffer, buffer_u32, surface[_y * dataW + _x]);
		
		buffer_set_surface(buffer, _outSurf, 0); 
		buffer_delete(buffer);
		
		return _outSurf;
	}
	
	static processData = function(_outSurf, _data, _array_index = 0) { 
		#region data
			var _surf = _data[ 0];
			
			var _type = _data[ 2];
			var _scal = _data[ 1];
			var _targ = _data[ 3];
			
			var _seam = _data[ 4];
			
			inputs[ 1].setVisible(_type == 0);
			inputs[ 3].setVisible(_type == 1);
			
			if(!is_just_surface(_surf)) return _outSurf;
		#endregion
		
		var _sw = surface_get_width(_surf);
		var _sh = surface_get_height(_surf);
		
		if(_type == 0) {
			var _sx = _scal[0];
			var _sy = _scal[1];
			
		} else {
			var _sx = _targ[0] / _sw;
			var _sy = _targ[1] / _sh;
			
		}
		
		var scw = ceil(_sw * _sx);
		var sch = ceil(_sh * _sy);
		
		var useGML = OS != os_windows; 
		    // useGML = true;
		
		if(useGML) {
			temp_surface[3] = scaleX(temp_surface[3], _surf, _sx, _seam);
			
			var sw = surface_get_width(  temp_surface[3] );
			var sh = surface_get_height( temp_surface[3] ); 
			
			temp_surface[4] = surface_verify(temp_surface[4], sh, sw);
			surface_set_shader(temp_surface[4], sh_sample, true, BLEND.over);
				draw_surface_ext(temp_surface[3], sh, 0, 1, 1, -90, c_white, 1);
			surface_reset_shader();
			temp_surface[5] = scaleX(temp_surface[5], temp_surface[4], _sy, _seam);
			
			var sw = surface_get_width(  temp_surface[5] );
			var sh = surface_get_height( temp_surface[5] );
			
			_outSurf = surface_verify(_outSurf, sh, sw);
			surface_set_shader(_outSurf, sh_sample, true, BLEND.over);
				draw_surface_ext(temp_surface[5], 0, sw, 1, 1, 90, c_white, 1);
			surface_reset_shader();
			
			return _outSurf;
		}
		
		var _sbuf = buffer_from_surface(_surf, false);
		var _obuf = buffer_create(scw * sch * 4, buffer_fixed, 1);
		var _args = buffer_create(1, buffer_grow, 1);
		buffer_to_start(_args);
		
		buffer_write(_args, buffer_u64, buffer_get_address(_sbuf));
		buffer_write(_args, buffer_u64, buffer_get_address(_obuf));
		
		buffer_write(_args, buffer_f64, _sw );
		buffer_write(_args, buffer_f64, _sh );
		
		buffer_write(_args, buffer_f64, _sx );
		buffer_write(_args, buffer_f64, _sy );
		
		buffer_write(_args, buffer_f64, _seam );
		
		content_aware_scale(buffer_get_address(_args));
		
		temp_surface[0] = surface_verify(temp_surface[0], scw, sch);
		buffer_set_surface(_obuf, temp_surface[0], 0);
		
		_outSurf = surface_verify(_outSurf, scw, sch);
		
		surface_set_shader(_outSurf, noone, true, BLEND.over);
			draw_surface(temp_surface[0], 0, 0);
		surface_reset_shader();
		
		buffer_delete(_sbuf);
		buffer_delete(_obuf);
		
		return _outSurf;
	}
}

#region CPP
/*[cpp]
#include <cmath>
#include <cstdint>

struct pixel {
	uint8_t r;
	uint8_t g;
	uint8_t b;
	uint8_t a;
};

struct contentAwareArgs {
	void* pixelArrayBuffer;
	void* outputBuffer;

	double surfaceWidth;
	double surfaceHeight;
	
	double xscale;
	double yscale;
	
	double seamType;
};

float grey(pixel p) {
	return (p.r + p.g + p.b) / 3 * (p.a / 255);
}

cfunction double content_aware_scale(void* args) {
	contentAwareArgs* Args = (contentAwareArgs*)args;
	
	pixel* pixels = (pixel*)Args->pixelArrayBuffer;
	pixel* output = (pixel*)Args->outputBuffer;
	
	double width  = Args->surfaceWidth;
	double height = Args->surfaceHeight;
	
	double xscale = Args->xscale;
	double yscale = Args->yscale;
	
	double seamType = Args->seamType;
	
	int iwidth  = (int)width;  // input dim
	int iheight = (int)height;
	
	int swidth  = iwidth;
	int sheight = iheight;
	
	int fwidth  = (int)ceil(width  * xscale); // final dim
	int fheight = (int)ceil(height * yscale);
	
	bool widthDown   = fwidth < iwidth;
	int  widthOff    = widthDown? iwidth - fwidth : fwidth - iwidth;
	int  xwidth      = widthDown? iwidth : fwidth; // max, data dim
	
	bool heightDown  = fheight < iheight;
	int  heightOff   = heightDown? iheight - fheight : fheight - iheight;
	int  xheight     = heightDown? iheight : fheight;
	
	pixel *surface   = new pixel[xwidth * xheight];
	float *energy    = new float[xwidth * xheight];
	float *accEnergy = new float[xwidth * xheight];
	float *prevpx    = new float[xwidth * xheight];
	float *seam      = new float[xwidth + xheight];

	int swap = 0;

	for(int y = 0; y < iheight; y++)
	for(int x = 0; x < iwidth; x++)
		surface[y * xwidth + x] = pixels[y * iwidth + x];
	
	for(int i = 0; i < widthOff; i++) {
		// Energy map
		for (int y = 0; y < sheight; y++)
		for (int x = 0; x < swidth; x++) {
			float pxl = x > 0?          grey(surface[y * xwidth + (x - 1)]) : 0;
			float pxc =                 grey(surface[y * xwidth +  x     ]);
			float pxr = x < swidth - 1? grey(surface[y * xwidth + (x + 1)]) : 0;

			energy[y * xwidth + x] = fabs(pxl - pxc) + fabs(pxr - pxc);
		}

		// Search
		for(int x = 0; x < swidth; x++)
			accEnergy[x] = energy[x];
		float lastX = -1;
		
		if(seamType == 0) {
			for(int y = 1; y < sheight; y++)
			for(int x = 0; x < swidth; x++) {
				float minEnergy = 9999999;
				float minPrevX  = x;
	
				for(int px = x - 1; px <= x + 1; px++) {
					if(px < 0 || px >= swidth) continue;
					if(accEnergy[(y - 1) * xwidth + px] < minEnergy) {
						minEnergy = accEnergy[(y - 1) * xwidth + px];
						minPrevX  = px;
					}
				}
	
				accEnergy[y * xwidth + x] = energy[y * xwidth + x] + minEnergy;
				prevpx[y * xwidth + x]    = minPrevX;
			}
			
			float minEnergy = 9999999;
			for(int x = 0; x < swidth; x++) {
				float an = accEnergy[(sheight - 1) * xwidth + x];
				if((swap == 0 && an < minEnergy) || (swap == 1 && an <= minEnergy)) {
					minEnergy = an;
					lastX     = x;
				}
			}
			
		} else {
			for(int y = 1; y < sheight; y++)
			for(int x = 0; x < swidth; x++) {
				float maxEnergy = 0;
				float maxPrevX  = x;
	
				for(int px = x - 1; px <= x + 1; px++) {
					if(px < 0 || px >= swidth) continue;
					if(accEnergy[(y - 1) * xwidth + px] > maxEnergy) {
						maxEnergy = accEnergy[(y - 1) * xwidth + px];
						maxPrevX  = px;
					}
				}
	
				accEnergy[y * xwidth + x] = energy[y * xwidth + x] + maxEnergy;
				prevpx[y * xwidth + x]    = maxPrevX;
			}
		
			float maxEnergy = 0;
			for(int x = 0; x < swidth; x++) {
				float an = accEnergy[(sheight - 1) * xwidth + x];
				if((swap == 0 && an > maxEnergy) || (swap == 1 && an >= maxEnergy)) {
					maxEnergy = an;
					lastX     = x;
				}
			}
			
		}
		
		swap = swap == 1? 0 : 1;
		
		if(lastX < 0) break;
		for(int y = sheight - 1; y >= 0; y--) {
			seam[y] = lastX;
			lastX   = prevpx[y * xwidth + (int)lastX];
		}

		// Copy data
		if(widthDown) {
			for(int y = 0; y < sheight; y++) {
				int seamX = (int)seam[y];
				for(int x = 0; x < swidth - 1; x++) {
					if(x < seamX) surface[y * xwidth + x] = surface[y * xwidth + x    ];
					else          surface[y * xwidth + x] = surface[y * xwidth + x + 1];
				}
			}
			swidth--;
			
		} else {
			for(int y = 0; y < sheight; y++) {
				int seamX = (int)seam[y];
				for(int x = swidth; x >= 0; x--) {
					if(x <= seamX) surface[y * xwidth + x] = surface[y * xwidth + x    ];
					else           surface[y * xwidth + x] = surface[y * xwidth + x - 1];
				}
			}
			swidth++;
		}
		
	}
	
	swap = 0;
	for(int i = 0; i < heightOff; i++) {
		// Energy map
		for (int y = 0; y < sheight; y++)
		for (int x = 0; x < swidth; x++) {
			float pxl = y > 0?           grey(surface[(y - 1) * xwidth + x]) : 0;
			float pxc =                  grey(surface[ y      * xwidth + x]);
			float pxr = y < sheight - 1? grey(surface[(y + 1) * xwidth + x]) : 0;

			energy[y * xwidth + x] = fabs(pxl - pxc) + fabs(pxr - pxc);
		}

		// Search
		for(int y = 0; y < sheight; y++)
			accEnergy[y * xwidth] = energy[y * xwidth];
		float lastY = -1;

		if(seamType == 0) {
			for(int x = 1; x < swidth; x++)
			for(int y = 0; y < sheight; y++) {
				float minEnergy = 9999999;
				float minPrevY  = y;
	
				for(int py = y - 1; py <= y + 1; py++) {
					if(py < 0 || py >= sheight) continue;
					if(accEnergy[py * xwidth + x - 1] < minEnergy) {
						minEnergy = accEnergy[py * xwidth + x - 1];
						minPrevY  = py;
					}
				}
	
				accEnergy[y * xwidth + x] = energy[y * xwidth + x] + minEnergy;
				prevpx[y * xwidth + x]    = minPrevY;
			}
		
			float minEnergy = 9999999;
			for(int y = 0; y < sheight; y++) {
				float an = accEnergy[y * xwidth + (swidth - 1)];
				if((swap == 0 && an < minEnergy) || (swap == 1 && an <= minEnergy)) {
					minEnergy = an;
					lastY     = y;
				}
			}
			
		} else {
			for(int x = 1; x < swidth; x++)
			for(int y = 0; y < sheight; y++) {
				float maxEnergy = 0;
				float maxPrevY  = y;
	
				for(int py = y - 1; py <= y + 1; py++) {
					if(py < 0 || py >= sheight) continue;
					if(accEnergy[py * xwidth + x - 1] > maxEnergy) {
						maxEnergy = accEnergy[py * xwidth + x - 1];
						maxPrevY  = py;
					}
				}
				
				accEnergy[y * xwidth + x] = energy[y * xwidth + x] + maxEnergy;
				prevpx[y * xwidth + x]    = maxPrevY;
			}
		
			float maxEnergy = 0;
			for(int y = 0; y < sheight; y++) {
				float an = accEnergy[y * xwidth + (swidth - 1)];
				if((swap == 0 && an > maxEnergy) || (swap == 1 && an >= maxEnergy)) {
					maxEnergy = an;
					lastY     = y;
				}
			}
			
		}
		
		swap = swap == 1? 0 : 1;
		
		if(lastY < 0) break;
		for(int x = swidth - 1; x >= 0; x--) {
			seam[x] = lastY;
			lastY   = prevpx[(int)lastY * xwidth + x];
		}
		
		// Copy data
		if(heightDown) {
			for(int x = 0; x < swidth; x++) {
				int seamY = (int)seam[x];
				for(int y = 0; y < sheight - 1; y++) {
					if(y < seamY) surface[y * xwidth + x] = surface[ y      * xwidth + x];
					else          surface[y * xwidth + x] = surface[(y + 1) * xwidth + x];
				}
			}
			sheight--;
			
		} else {
			for(int x = 0; x < swidth; x++) {
				int seamY = (int)seam[x];
				for(int y = sheight; y >= 0; y--) {
					if(y <= seamY) surface[y * xwidth + x] = surface[ y      * xwidth + x];
					else           surface[y * xwidth + x] = surface[(y - 1) * xwidth + x];
				}
			}
			sheight++;
			
		}
		
	}
	
	// Copy to output
	for(int y = 0; y < fheight; y++)
	for(int x = 0; x < fwidth;  x++)
		output[y * fwidth + x] = surface[y * xwidth + x];
	
	delete surface;
	delete energy;
	delete accEnergy;
	delete prevpx;
	delete seam;
	
	return 0;
}
*/
#endregion