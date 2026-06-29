function Node_Scale_Content_Aware(_x, _y, _group = noone) : Node_Processor(_x, _y, _group) constructor {
	name = "Content-Aware Scale";
	
	////- =Surface
	newInput( 0, nodeValue_Surface( "Surface In" ));
	
	////- =Scale
	newInput( 1, nodeValue_Vec2( "Scale", [1,1], true ));
	// 2
	
	newOutput(0, nodeValue_Output("Surface Out", VALUE_TYPE.surface, noone));
	
	input_display_list = [ 
		[ "Surface", false ],  0, 
		[ "Scale",   false ],  1, 
	];
	
	////- Nodes
	
	temp_surface = array_create(6, noone);
	
	static scaleX = function(_outSurf, _surf, _scalX) {
		var ssw = surface_get_width(_surf);
		var ssh = surface_get_height(_surf);
		
		var sw  = ssw;
		var sh  = ssh;
		
		var scw = ceil(sw * min(1, _scalX));
		if(scw < 1) return _outSurf;
		
		temp_surface[0] = surface_verify(temp_surface[0], sw, sh, surface_r8unorm);
		surface_set_shader(temp_surface[0], sh_scale_content_aware_grey, true, BLEND.over);
			draw_surface(_surf, 0, 0);
		surface_reset_shader();
		
		temp_surface[1] = surface_verify(temp_surface[1], sw, sh, surface_rgba16float);
		surface_set_shader(temp_surface[1], sh_scale_content_aware_coord, true, BLEND.over);
			draw_empty();
		surface_reset_shader();
		
		var buffer  = buffer_create(sw * sh + 1, buffer_fixed, 1);
		var buffer2 = buffer_create(sw * sh + 1, buffer_fixed, 1);
		buffer_get_surface(buffer, temp_surface[0], 0);
		
		var bCoord  = buffer_create(sw * sh * 8, buffer_fixed, 1);
		var bCoord2 = buffer_create(sw * sh * 8, buffer_fixed, 1);
		buffer_get_surface(bCoord, temp_surface[1], 0);
		
		var buffm    = buffer_create(sw * sh * 4, buffer_fixed, 1);
		var buffSeam = buffer_create(sw * sh * 4, buffer_fixed, 1);
		var buffPx   = buffer_create(sw * sh * 4, buffer_fixed, 1);
		
		var swap = false;
		
		var seam  = array_create(sh);
		var seamW = sw - scw;
		repeat(seamW) {
			buffer_to_start(buffer);
			buffer_to_start(buffSeam);
			buffer_to_start(buffPx);
			buffer_to_start(buffm);
			
			// Energy map
			for( var _y = 0; _y < sh; _y++ )
			for( var _x = 0; _x < sw; _x++ ) {
				var pxl = _x > 0?    buffer_peek(buffer, _y * sw + _x - 1, buffer_u8) : 0;
				var pxc =            buffer_peek(buffer, _y * sw + _x,     buffer_u8);
				var pxr = _x < sw-1? buffer_peek(buffer, _y * sw + _x + 1, buffer_u8) : 0;
				
				buffer_write(buffm, buffer_f32, abs(pxl - pxc) + abs(pxr - pxc));
			}
			
			// Search
			buffer_to_start(buffm);
			for(var _x = 0; _x < sw; _x++) {
				buffer_write(buffSeam, buffer_f32, buffer_read(buffm, buffer_f32));
				buffer_write(buffPx,   buffer_f32, _x);
			}
			
			for(var _y = 1; _y < sh; _y++)
			for(var _x = 0; _x < sw; _x++) {
				var minPrev = infinity;
				var minPreX = _x;

				for(var _px = max(0, _x - 1); _px <= min(sw - 1, _x + 1); _px++) {
					var prev = buffer_peek(buffSeam, ((_y - 1) * sw + _px) * 4, buffer_f32);
					if(prev < minPrev) {
						minPrev = prev;
						minPreX = _px;
					}
				}

				var energy = buffer_read(buffm, buffer_f32);
				buffer_write(buffSeam, buffer_f32, energy + minPrev);
				buffer_write(buffPx,   buffer_f32, minPreX);
			}
			
			var minEnergy = infinity;
			var lastX     = noone;

			if(swap) {
				for(var _x = 0; _x < sw; _x++) {
					var energy = buffer_peek(buffSeam, ((sh - 1) * sw + _x) * 4, buffer_f32);
					if(energy < minEnergy) {
						minEnergy = energy;
						lastX     = _x;
					}
				}
				
			} else {
				for(var _x = 0; _x < sw; _x++) {
					var energy = buffer_peek(buffSeam, ((sh - 1) * sw + _x) * 4, buffer_f32);
					if(energy <= minEnergy) {
						minEnergy = energy;
						lastX     = _x;
					}
				}
				
			}
			
			swap = !swap;
			
			if(lastX != noone)
			for(var _y = sh - 1; _y >= 0; _y--) {
				seam[_y] = lastX;
				lastX = buffer_peek(buffPx, (_y * sw + lastX) * 4, buffer_f32);
			}
			
			// Copy data
			buffer_to_start(buffer);
			buffer_to_start(buffer2);
			
			for( var _y = 0; _y < sh; _y++ )
			for( var _x = 0; _x < sw; _x++ ) {
				var bv = buffer_read(buffer, buffer_u8);
				if(_x == seam[_y]) continue;
				
				buffer_write(buffer2, buffer_u8, bv);
			}
			
			var _b  = buffer;
			buffer  = buffer2;
			buffer2 = _b;
			
			buffer_to_start(bCoord);
			buffer_to_start(bCoord2);
			
			for( var _y = 0; _y < sh; _y++ )
			for( var _x = 0; _x < sw; _x++ ) {
				var bx = buffer_read(bCoord, buffer_f16);
				var by = buffer_read(bCoord, buffer_f16);
				var _  = buffer_read(bCoord, buffer_f16);
				var _  = buffer_read(bCoord, buffer_f16);
				if(_x == seam[_y]) continue;
				
				buffer_write(bCoord2, buffer_f16, bx);
				buffer_write(bCoord2, buffer_f16, by);
				buffer_write(bCoord2, buffer_f16, 0 );
				buffer_write(bCoord2, buffer_f16, 1 );
			}
			
			var _b  = bCoord;
			bCoord  = bCoord2;
			bCoord2 = _b;
			
			sw--;
		}
		
		buffer_delete(buffm);
		buffer_delete(buffSeam);
		buffer_delete(buffPx);
		
		temp_surface[2] = surface_verify(temp_surface[2], scw, sh, surface_rgba16float);
		buffer_set_surface(bCoord, temp_surface[2], 0);
		
		_outSurf = surface_verify(_outSurf, scw, sh);
		surface_set_shader(_outSurf, sh_scale_content_aware_map);
			shader_set_s("coordSurf", temp_surface[2]);
			shader_set_s("oriSurf",   _surf);
			
			draw_empty();
		surface_reset_shader();
		
		buffer_delete(buffer);
		buffer_delete(bCoord);
		
		return _outSurf;
	}
	
	static processData = function(_outSurf, _data, _array_index = 0) { 
		#region data
			var _surf = _data[ 0];
			
			var _scal = _data[ 1];
			
			if(!is_just_surface(_surf)) return _outSurf;
		#endregion
		
		if(OS != os_windows) {
			temp_surface[3] = scaleX(temp_surface[3], _surf, _scal[0]);
			
			var sw = surface_get_width(  temp_surface[3] );
			var sh = surface_get_height( temp_surface[3] ); 
			
			temp_surface[4] = surface_verify(temp_surface[4], sh, sw);
			surface_set_shader(temp_surface[4], sh_sample, true, BLEND.over);
				draw_surface_ext(temp_surface[3], sh, 0, 1, 1, -90, c_white, 1);
			surface_reset_shader();
			temp_surface[5] = scaleX(temp_surface[5], temp_surface[4], _scal[1]);
			
			var sw = surface_get_width(  temp_surface[5] );
			var sh = surface_get_height( temp_surface[5] );
			
			_outSurf = surface_verify(_outSurf, sh, sw);
			surface_set_shader(_outSurf, sh_sample, true, BLEND.over);
				draw_surface_ext(temp_surface[5], 0, sw, 1, 1, 90, c_white, 1);
			surface_reset_shader();
			
			return _outSurf;
		}
		
		var _sw = surface_get_width(_surf);
		var _sh = surface_get_height(_surf);
		
		var _sx = clamp(_scal[0], 0, 1);
		var _sy = clamp(_scal[1], 0, 1);
		
		var scw = ceil(_sw * _sx);
		var sch = ceil(_sh * _sy);
		
		var _sbuf = buffer_from_surface(_surf, false);
		var _obuf = buffer_create(_sw * _sh * 4, buffer_fixed, 1);
		var _args = buffer_create(1, buffer_grow, 1);
		buffer_to_start(_args);
		
		buffer_write(_args, buffer_u64, buffer_get_address(_sbuf));
		buffer_write(_args, buffer_u64, buffer_get_address(_obuf));
		
		buffer_write(_args, buffer_f64, _sw );
		buffer_write(_args, buffer_f64, _sh );
		
		buffer_write(_args, buffer_f64, _sx );
		buffer_write(_args, buffer_f64, _sy );
		
		content_aware_scale(buffer_get_address(_args));
		
		temp_surface[0] = surface_verify(temp_surface[0], _sw, _sh);
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

	int swidth  = (int)width;
	int sheight = (int)height;
	
	int iwidth  = swidth;
	int iheight = sheight;
	
	int scaledWidth  = (int)ceil(width  * xscale);
	int scaledHeight = (int)ceil(height * yscale);
	
	pixel *surface   = new pixel[iwidth * iheight];
	float *energy    = new float[iwidth * iheight];
	float *accEnergy = new float[iwidth * iheight];
	float *prevpx    = new float[iwidth * iheight];
	float *seam      = new float[iwidth + iheight];

	int swap = 0;

	for(int y = 0; y < sheight; y++)
	for(int x = 0; x < swidth; x++)
		surface[y * swidth + x] = pixels[y * swidth + x];
	
	int widthOff = swidth - scaledWidth;
	for(int i = 0; i < widthOff; i++) {
		// Energy map
		for (int y = 0; y < iheight; y++)
		for (int x = 0; x < iwidth; x++) {
			float pxl = x > 0?          grey(surface[y * swidth + (x - 1)]) : 0;
			float pxc =                 grey(surface[y * swidth +  x     ]);
			float pxr = x < iwidth - 1? grey(surface[y * swidth + (x + 1)]) : 0;

			energy[y * swidth + x] = fabs(pxl - pxc) + fabs(pxr - pxc);
		}

		// Search
		for(int x = 0; x < iwidth; x++)
			accEnergy[x] = energy[x];

		for(int y = 1; y < iheight; y++)
		for(int x = 0; x < iwidth; x++) {
			float minEnergy = 9999999;
			float minPrevX  = x;

			for(int px = x - 1; px <= x + 1; px++) {
				if(px < 0 || px >= iwidth) continue;
				if(accEnergy[(y - 1) * swidth + px] < minEnergy) {
					minEnergy = accEnergy[(y - 1) * swidth + px];
					minPrevX  = px;
				}
			}

			accEnergy[y * swidth + x] = energy[y * swidth + x] + minEnergy;
			prevpx[y * swidth + x]    = minPrevX;
		}
		
		float minEnergy = 9999999;
		float lastX     = -1;
		
		for(int x = 0; x < iwidth; x++) {
			float an = accEnergy[(iheight - 1) * swidth + x];
			if((swap == 0 && an < minEnergy) || (swap == 1 && an <= minEnergy)) {
				minEnergy = an;
				lastX     = x;
			}
		}
		
		swap = swap == 1? 0 : 1;
		
		if(lastX < 0) break;
		for(int y = iheight - 1; y >= 0; y--) {
			seam[y] = lastX;
			lastX   = prevpx[y * swidth + (int)lastX];
		}

		// Copy data
		for(int y = 0; y < iheight; y++) {
			int seamX = (int)seam[y];
			for(int x = 0; x < iwidth - 1; x++) {
				if(x < seamX) surface[y * swidth + x] = surface[y * swidth + x    ];
				else          surface[y * swidth + x] = surface[y * swidth + x + 1];
			}
		}

		iwidth--;
	}
	
	swap = 0;
	int heightOff = sheight - scaledHeight;
	for(int i = 0; i < heightOff; i++) {
		// Energy map
		for (int y = 0; y < iheight; y++)
		for (int x = 0; x < iwidth; x++) {
			float pxl = y > 0?           grey(surface[(y - 1) * swidth + x]) : 0;
			float pxc =                  grey(surface[ y      * swidth + x]);
			float pxr = y < iheight - 1? grey(surface[(y + 1) * swidth + x]) : 0;

			energy[y * swidth + x] = fabs(pxl - pxc) + fabs(pxr - pxc);
		}

		// Search
		for(int y = 0; y < iheight; y++)
			accEnergy[y * swidth] = energy[y * swidth];

		for(int x = 1; x < iwidth; x++)
		for(int y = 0; y < iheight; y++) {
			float minEnergy = 9999999;
			float minPrevY  = y;

			for(int py = y - 1; py <= y + 1; py++) {
				if(py < 0 || py >= iheight) continue;
				if(accEnergy[py * swidth + x - 1] < minEnergy) {
					minEnergy = accEnergy[py * swidth + x - 1];
					minPrevY  = py;
				}
			}

			accEnergy[y * swidth + x] = energy[y * swidth + x] + minEnergy;
			prevpx[y * swidth + x]    = minPrevY;
		}

		float minEnergy = 9999999;
		float lastY     = -1;

		for(int y = 0; y < iheight; y++) {
			float an = accEnergy[y * swidth + (iwidth - 1)];
			if((swap == 0 && an < minEnergy) || (swap == 1 && an <= minEnergy)) {
				minEnergy = an;
				lastY     = y;
			}
		}
		
		swap = swap == 1? 0 : 1;
		
		if(lastY < 0) break;
		for(int x = iwidth - 1; x >= 0; x--) {
			seam[x] = lastY;
			lastY   = prevpx[(int)lastY * swidth + x];
		}

		// Copy data
		for(int x = 0; x < iwidth; x++) {
			int seamY = (int)seam[x];
			for(int y = 0; y < iheight - 1; y++) {
				if(y < seamY) surface[y * swidth + x] = surface[ y      * swidth + x];
				else          surface[y * swidth + x] = surface[(y + 1) * swidth + x];
			}
		}
		
		iheight--;
	}
	
	// Copy to output
	for(int y = 0; y < sheight; y++)
	for(int x = 0; x < swidth;  x++)
		output[y * swidth + x] = surface[y * swidth + x];
	
	delete surface;
	delete energy;
	delete accEnergy;
	delete prevpx;
	delete seam;
	
	return 0;
}
*/
#endregion