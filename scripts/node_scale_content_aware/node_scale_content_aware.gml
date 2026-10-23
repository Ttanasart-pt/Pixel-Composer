function Node_Scale_Content_Aware(_x, _y, _group = noone) : Node_Processor(_x, _y, _group) constructor {
	name = "Content-Aware Scale";
	
	newActiveInput(6);
	
	////- =Surface
	newInput( 0, nodeValue_Surface( "Surface In" )).setRequired();
	
	////- =Scale
	newInput( 2, nodeValue_EButton(   "Type",         0, [ "Multiply", "Scale to Size" ] ));
	newInput( 1, nodeValue_Vec2(      "Scale",       [1,1], true ));
	newInput( 3, nodeValue_Dimension( "Target Size", [1,1], true ));
	
	////- =Algorithm
	newInput( 4, nodeValue_EButton(   "Seam",         0, [ "Minimum", "Maximum" ] ));
	newInput( 5, nodeValue_Bool(      "Async",    false ));
	// 7
	
	newOutput(0, nodeValue_Output("Surface Out", VALUE_TYPE.surface, noone));
	
	input_display_list = [ 6, 
		[ "Surface",   false ],  0, 
		[ "Scale",     false ],  2,  1,  3, 
		[ "Algorithm", false ],  4,  
	];
	
	////- Nodes
	
	temp_surface = array_create(6, noone);
	generator    = content_aware_init();
	
	surfaceBuffer = undefined;
	outputBuffer  = undefined;
	
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
			var _asyn = _data[ 5];
			
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
		if(scw < 1 || sch < 1) return _outSurf;
		
		var useGML = false;//OS != os_windows; 
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
		
		surfaceBuffer = buffer_from_surface(_surf, false);
		outputBuffer  = buffer_create(scw * sch * 4, buffer_fixed, 1);
		var g = generator;
		
		content_aware_setBuffer(    g, buffer_get_address(surfaceBuffer), buffer_get_address(outputBuffer));
		content_aware_setDimension( g, _sw, _sh );
		content_aware_setScale(     g, _sx, _sy );
		content_aware_setSeamType(  g, _seam    );
		// content_aware_setAsync(     g, _asyn    );
		
		temp_surface[0] = surface_verify(temp_surface[0], scw, sch);
		_outSurf = surface_verify(_outSurf, scw, sch);
		
		content_aware_scale(g);
		buffer_set_surface(outputBuffer, temp_surface[0], 0);
		
		surface_set_shader(_outSurf, noone, true, BLEND.over);
			draw_surface(temp_surface[0], 0, 0);
		surface_reset_shader();
		
		buffer_delete_safe(surfaceBuffer);
		buffer_delete_safe(outputBuffer);
		
		return _outSurf;
	}
	
}

#region CPP
/*[cpp]
//init RegisterCallbacks
#include <vector>
#include <cmath>
#include <cstdint>
#include <cstring>
#include <thread>

typedef void (*CreateAsyncEventFn)(int ds_map_id, int event_type);
typedef int  (*DSMapCreateFn)(int _num, ...);
typedef bool (*DSMapAddStringFn)(int _index, const char* _key, const char* _value);
typedef bool (*DSMapAddDoubleFn)(int _index, const char* _key, double _value);

CreateAsyncEventFn CreateAsyncEvent = nullptr;
DSMapCreateFn      DSMapCreate      = nullptr;
DSMapAddStringFn   DSMapAddString   = nullptr;
DSMapAddDoubleFn   DSMapAddDouble   = nullptr;

cfunction void RegisterCallbacks( char* arg1, char* arg2, char* arg3, char* arg4 ) {
    CreateAsyncEvent = reinterpret_cast<CreateAsyncEventFn>(arg1);
    DSMapCreate      = reinterpret_cast<DSMapCreateFn>(arg2);
    DSMapAddDouble   = reinterpret_cast<DSMapAddDoubleFn>(arg3);
    DSMapAddString   = reinterpret_cast<DSMapAddStringFn>(arg4);
}

int asyncCall(int event_id_val, int event_type, char* type, double status, char* message) {
    int async_map = DSMapCreate(0);
    if (async_map < 0) return -2;

    bool ok = true;
    ok &= DSMapAddString( async_map, "type",     type         );
    ok &= DSMapAddDouble( async_map, "status",   status       );
    ok &= DSMapAddDouble( async_map, "listener", event_id_val );
    ok &= DSMapAddString( async_map, "message",  message      );
    if (!ok) return -3;

    CreateAsyncEvent(async_map, event_type);
    return 0;
}

struct pixel { uint8_t r; uint8_t g; uint8_t b; uint8_t a; };
float grey(pixel p) { return (p.r + p.g + p.b) / 3 * (p.a / 255); }

struct contentAwareArgs {
	pixel* pixelArrayBuffer;
	pixel* outputBuffer;

	double surfaceWidth;
	double surfaceHeight;
	
	double xscale;
	double yscale;
	
	double seamType;

	int generator_id;

	bool async      = false;
	bool running    = false;
	bool force_stop = false;
	
	pixel *surface;
	float *energy;
	float *accEnergy;
	float *prevpx;
	float *seam;

	void setBuffer(void* pb, void* ob)    { pixelArrayBuffer = (pixel*)pb; outputBuffer  = (pixel*)ob; return; }
	void setDimension(double w, double h) { surfaceWidth     = w;          surfaceHeight = h;          return; }
	void setScale(double xs, double ys)   { xscale   = xs; yscale = ys; return; }
	void setSeamType(double st)           { seamType = st;              return; }

	void setAsync(double a) { async = a > 0.; return; }

	void scale(double id) {
		generator_id = id;

		if(!async) { scaling_wrap(); return; }
		if(running) {
			force_stop = true;
			while(running) std::this_thread::sleep_for(std::chrono::milliseconds(1));
		}

		running    = true;
		force_stop = false;
		std::thread(&contentAwareArgs::scaling_wrap, this).detach();
	}

	void scaling_wrap() {
		scaling();
		free();
		running = false;
	}

	void scaling() {
		pixel* pixels = pixelArrayBuffer;
		pixel* output = outputBuffer;
		
		double width  = surfaceWidth;
		double height = surfaceHeight;
		
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
		
		surface   = new pixel[xwidth * xheight];
		energy    = new float[xwidth * xheight];
		accEnergy = new float[xwidth * xheight];
		prevpx    = new float[xwidth * xheight];
		seam      = new float[xwidth + xheight];

		int swap = 0;

		for(int y = 0; y < iheight; y++)
		for(int x = 0; x < iwidth; x++)
			surface[y * xwidth + x] = pixels[y * iwidth + x];
		
		for(int i = 0; i < widthOff; i++) {
			if(force_stop) return;

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
					if(force_stop) return;

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
					if(force_stop) return;

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
						if(force_stop) return;
						if(x < seamX) surface[y * xwidth + x] = surface[y * xwidth + x    ];
						else          surface[y * xwidth + x] = surface[y * xwidth + x + 1];
					}
				}
				swidth--;
				
			} else {
				for(int y = 0; y < sheight; y++) {
					int seamX = (int)seam[y];
					for(int x = swidth; x >= 0; x--) {
						if(force_stop) return;
						if(x <= seamX) surface[y * xwidth + x] = surface[y * xwidth + x    ];
						else           surface[y * xwidth + x] = surface[y * xwidth + x - 1];
					}
				}
				swidth++;
			}
			
		}
		
		swap = 0;
		for(int i = 0; i < heightOff; i++) {
			if(force_stop) return;

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
					if(force_stop) return;

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
					if(force_stop) return;

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
						if(force_stop) return;
						if(y < seamY) surface[y * xwidth + x] = surface[ y      * xwidth + x];
						else          surface[y * xwidth + x] = surface[(y + 1) * xwidth + x];
					}
				}
				sheight--;
				
			} else {
				for(int x = 0; x < swidth; x++) {
					int seamY = (int)seam[x];
					for(int y = sheight; y >= 0; y--) {
						if(force_stop) return;
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
		
		if(async) asyncCall(generator_id, 70, "content_aware_scale_complete", 200.0, "Content-Aware Completed");
		return;
	}

	void free() {
		delete surface;
		delete energy;
		delete accEnergy;
		delete prevpx;
		delete seam;
	}

	void stop() {
		if(!running) return;

		force_stop = true;
		while(running) std::this_thread::sleep_for(std::chrono::milliseconds(1));

		asyncCall(generator_id, 70, "content_aware_stop", 200.0, "Content-Aware Stopped");
	}
};

#define INDEX int i = static_cast<int>(x); if(i < 0 || i >= static_cast<int>(generators.size())) return -1; contentAwareArgs& generator = generators[i];
std::vector<contentAwareArgs> generators;

cfunction double content_aware_init() { generators.emplace_back(); return static_cast<double>(generators.size() - 1); }

cfunction double content_aware_setBuffer(double x, void* pb, void* ob) {    INDEX generator.setBuffer(pb, ob);  return 0.; }
cfunction double content_aware_setDimension(double x, double w, double h) { INDEX generator.setDimension(w, h); return 0.; }
cfunction double content_aware_setScale(double x, double xs, double ys) {   INDEX generator.setScale(xs, ys);   return 0.; }
cfunction double content_aware_setSeamType(double x, double st) {           INDEX generator.setSeamType(st);    return 0.; }
cfunction double content_aware_setAsync(double x, double a) {               INDEX generator.setAsync(a);        return 0.; }

cfunction double content_aware_scale(double x) { INDEX generator.scale(x); return 0; }
cfunction double content_aware_stop(double x)  { INDEX generator.stop(); return 0.; }
*/
#endregion