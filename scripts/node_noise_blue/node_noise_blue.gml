function Node_Noise_Blue(_x, _y, _group = noone) : Node(_x, _y, _group) constructor {
	name = "Blue Noise";
	
	newInput( 1, nodeValueSeed()).setPieMenu();
	
	////- =Output
	newInput( 0, nodeValue_Dimension());
	newInput( 2, nodeValue_Surface("Mask"));
	
	////- =Noise
	newInput( 6, nodeValue_Slider( "Threshold",  .9 )).setPieMenu();
	newInput( 3, nodeValue_Int(    "Iteration",  32 )).setPieMenu();
	newInput( 4, nodeValue_Float(  "Radius",      8 )).setUnitSimple(false).setPieMenu();
	newInput( 5, nodeValue_Float(  "Sigma",     1.9 )).setPieMenu();
	
	////- =Performance
	newInput( 7, nodeValue_Int(    "Patch Size", -1 ));
	// 8
	
	newOutput(0, nodeValue_Output("Surface Out", VALUE_TYPE.surface, noone));
	
	input_display_list = [  1, 
		[ "Output", false ],  0,  2, 
		[ "Noise",  false ],  6,  3,  4,  5,
		[ "Performance", false ], 7, 
	];
	
	////- Node
	
	attributes.workers = 4;
	array_push(attributeEditors, Node_Attribute( "Threads", function() /*=>*/ {return attributes.workers}, function() /*=>*/ {return textBox_Number(function(v) /*=>*/ {return setAttribute("workers", v, 1)})} ));
	
	attribute_surface_depth();
	
	temp_surface = [ noone, noone, noone, noone ];
	_outBuff     = 0;
	
	processing   = 0;
	processItr   = 0;
	outSurf      = noone;
	
	generator    = blue_noise_generator_init();
	
	curr_sed = 0;
	curr_dx  = 0;
	curr_dy  = 0;
	curr_thr = 0;
	curr_itr = 0;
	curr_rad = 0;
	curr_sig = 0;
	curr_pat = 0;
	
	static generateNoiseInit = function() {
		_patchSize = min(_pat, _dim[0], _dim[1]);
		_patchDim  = [_patchSize, _patchSize];
		_patchCol  = ceil(_dim[0] / _patchSize); 
		_patchRow  = ceil(_dim[1] / _patchSize); 
		_patchAmo  = _patchCol * _patchRow;
		_patchInd  = 0;
		_patchPix  = _patchSize * _patchSize;
		
		processItr = _patchAmo;
		outSurf    = surface_verify(outSurf, _dim[0], _dim[1]);
		processing = true;
		
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
	}
	
	static generateNoiseItr = function() {
		var _noise  = temp_surface[1];
		var _energy = temp_surface[0];
		var _order  = temp_surface[2];
		var _output = temp_surface[3];
		
		surface_clear(_order);
		random_set_seed(_sed);
		
		////- =Initial Binary
		
		surface_set_shader(_noise, sh_noise_blue_initial);
			shader_set_f( "seed",      _sed );
			draw_empty();
		surface_reset_shader();
		
		surface_set_shader(_energy, sh_noise_blue_energy);
			shader_set_i( "inverted", false );
		surface_reset_shader();
		
		repeat(_itr) {
			surface_set_target(_energy);
			shader_set(sh_noise_blue_energy);
				draw_surface(_noise, 0, 0);
			shader_reset();
			surface_reset_target();
			
			var vc = surface_get_min_max(_energy);
			surface_set_target(_noise);
				draw_point_color(vc[4], vc[5], c_black);
				draw_point_color(vc[2], vc[3], c_white);
			surface_reset_target();
		}
		
		surface_set_target(_output);
			draw_surface(_noise, 0, 0);
		surface_reset_target();
		
		////- =Order white
		
		var _wht = surface_get_white(_noise);
		
		var _ord = _wht;
		repeat(_wht) {
			surface_set_target(_energy);
			shader_set(sh_noise_blue_energy);
				draw_surface(_output, 0, 0);
			shader_reset();
			surface_reset_target();
			
			var vc = surface_get_min_max(_energy);
			surface_set_target(_output);
				draw_point_color(vc[4], vc[5], c_black);
			surface_reset_target();
			
			surface_set_target(_order);
				draw_point_color(vc[4], vc[5], make_color_grey(_ord / _patchPix));
			surface_reset_target();
			_ord--;
		}
		
		////- =Order black
		
		var _ord = _wht + 1;
		repeat(_patchPix / 2 - _wht) {
			surface_set_target(_energy);
			shader_set(sh_noise_blue_energy);
				draw_surface(_noise, 0, 0);
			shader_reset();
			surface_reset_target();
			
			var vc = surface_get_min_max(_energy, irandom(_patchPix));
			surface_set_target(_noise);
				draw_point_color(vc[2], vc[3], c_white);
			surface_reset_target();
			
			surface_set_target(_order);
				draw_point_color(vc[2], vc[3], make_color_grey(_ord / _patchPix));
			surface_reset_target();
			_ord++;
		}
		
		////- =Fil gaps
		
		surface_set_shader(_energy, sh_noise_blue_energy);
			shader_set_i( "inverted",  true );
		surface_reset_shader();
		
		repeat(_patchPix / 2) {
			surface_set_target(_energy);
			shader_set(sh_noise_blue_energy);
				draw_surface(_noise, 0, 0);
			shader_reset();
			surface_reset_target();
			
			var vc = surface_get_min_max(_energy);
			surface_set_target(_noise);
				draw_point_color(vc[2], vc[3], c_white);
			surface_reset_target();
			
			surface_set_target(_order);
				draw_point_color(vc[2], vc[3], make_color_grey(_ord / _patchPix));
			surface_reset_target();
			
			_ord++;
		}
		
		////- =Draw patch
		
		var px =      (_patchInd % _patchCol) * _patchSize;
		var py = floor(_patchInd / _patchCol) * _patchSize;
		surface_set_target(outSurf);
			draw_surface(_order, px, py);
		surface_reset_target();
		
		_patchInd++;
		_sed++;
	}
	
	static step = function() {
		if(processing) PANEL_GRAPH.refreshDraw();
	}
	
	static update = function() {
		#region data
			_sed = getInputData( 1);
			
			_dim = getInputData( 0);
			
			_thr = getInputData( 6);
			_itr = getInputData( 3);
			_rad = getInputData( 4);
			_sig = getInputData( 5);
			
			_pat = getInputData( 7);
		
			var _update = false;
			if(_sed    != curr_sed) _update = true;
			if(_dim[0] != curr_dx)  _update = true;
			if(_dim[1] != curr_dy)  _update = true;
			if(_thr    != curr_thr) _update = true;
			if(_itr    != curr_itr) _update = true;
			if(_rad    != curr_rad) _update = true;
			if(_sig    != curr_sig) _update = true;
			if(_pat    != curr_pat) _update = true;
			if(!_update) return;
			
			curr_sed = _sed;
			curr_dx  = _dim[0];
			curr_dy  = _dim[1];
			curr_thr = _thr;
			curr_itr = _itr;
			curr_rad = _rad;
			curr_sig = _sig;
			curr_pat = _pat;
		#endregion
		
		var _siz        = min(_dim[0], _dim[1]);
		var _outSurf    = outputs[0].getValue();
		    _outSurf    = surface_verify(_outSurf, _siz, _siz);
		outputs[0].setValue(_outSurf);
		
		temp_surface[0] = surface_verify(temp_surface[0], _siz, _siz, surface_r32float);
		_outBuff        = buffer_verify(_outBuff, _siz * _siz * 4, buffer_grow);
		
		var _patch = _pat <= 0? _siz : _pat;
		    _patch = power(2, floor(log2(_patch)));
		
		var g = generator;
		
		blue_noise_set_seed(g, _sed);
		
		blue_noise_set_size(g, _siz, _patch);
		blue_noise_set_radius(g, _rad);
		
		blue_noise_set_threshold(g, _thr);
		blue_noise_set_iteration(g, _itr);
		blue_noise_set_sigma(g, _sig);
		
		blue_noise_set_workers(g, attributes.workers);
		processing = true;
		
		asyncCall(blue_noise_generate(g, buffer_get_address(_outBuff)), function(_param, _res) /*=>*/ {
			processing = false;
			
			var _outSurf = outputs[0].getValue();
			buffer_set_surface(_outBuff, temp_surface[0], 0);
			surface_set_shader(_outSurf, sh_draw_r32);
				draw_surface(temp_surface[0], 0, 0);
			surface_reset_shader();
			
			render_time = get_timer() - render_timer;
			PANEL_GRAPH.refreshDraw();
			
			triggerRender(false);
		});
		
		// print(white, blue_noise_get_minx(g), blue_noise_get_miny(g), "|", blue_noise_get_maxx(g), blue_noise_get_maxy(g));
		// generateNoiseInit();
	}
	
	////- Draw
	
	static onDrawNode = function(xx, yy, _mx, _my, _s, _hover, _focus) {
		if(processing) draw_sprite_ui(THEME.loading, 0, xx + w*_s/2, yy + h*_s/2, _s, _s, current_time/2, COLORS._main_icon, 1);
	}
	
}

/*[cpp] blue_noise
//init RegisterCallbacks
#include <vector>
#include <cstdlib>
#include <cmath>
#include <cstdint>
#include <algorithm>
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

struct BlockInfo {
    double min_val = std::numeric_limits<double>::max();
    double max_val = std::numeric_limits<double>::lowest();
    int min_x = 0, min_y = 0;
    int max_x = 0, max_y = 0;
};

struct BlueNoise_Generator {
    int size;
    int pixels;
    
    int seed;
    int radius;
    int iteration;
    int workers;
    int patchSize;
    
    double threshold;
    double sigma;
    double sigma2;
    double totalWeight;

    float* out = nullptr;
    
    std::vector<float> noise;
    std::vector<float> output;
    
    std::vector<float> energy;
    std::vector<float> energyAcc;
    std::vector<float> order;
    std::vector<float> weights;
    
    double min_x, min_y, max_x, max_y;
    double min_val, max_val;
    
    int BLOCK_SIZE     = 16;
    int blocks_per_row = 1;
    int total_blocks   = 1;
    
    std::vector<BlockInfo> blocks;

    int generator_id;
    bool generating = false;
    bool stop_generate = false;
    
    void energy_calculate_block(const std::vector<float>& noise, int bx, int by) {
        int bind = by * blocks_per_row + bx;
        BlockInfo& block = blocks[bind];

        block.min_val = std::numeric_limits<double>::max();
        block.max_val = std::numeric_limits<double>::lowest();

        int start_x = bx * BLOCK_SIZE;
        int start_y = by * BLOCK_SIZE;
        int end_x = std::min(start_x + BLOCK_SIZE, patchSize);
        int end_y = std::min(start_y + BLOCK_SIZE, patchSize);
        
        for(int y = start_y; y < end_y; y++)
        for(int x = start_x; x < end_x; x++) {
            int ind = y * patchSize + x;
            if(noise[ind] == 0 && energy[ind] < block.min_val) {
                block.min_val = energy[ind];
                block.min_x = x;
                block.min_y = y;
            }
            if(noise[ind] == 1 && energy[ind] > block.max_val) {
                block.max_val = energy[ind];
                block.max_x = x;
                block.max_y = y;
            }
        }
    }

    void energy_calculate_block_all(const std::vector<float>& noise) {
        for(int by = 0; by < blocks_per_row; by++)
        for(int bx = 0; bx < blocks_per_row; bx++)
            energy_calculate_block(noise, bx, by);
    }

    void energy_calculate_block_ranges(const std::vector<float>& noise, int x, int y) {
        int min_bx = std::max(0, (x - radius) / BLOCK_SIZE);
        int max_bx = std::min(blocks_per_row - 1, (x + radius) / BLOCK_SIZE);
        int min_by = std::max(0, (y - radius) / BLOCK_SIZE);
        int max_by = std::min(blocks_per_row - 1, (y + radius) / BLOCK_SIZE);

        for(int by = min_by; by <= max_by; by++)
        for(int bx = min_bx; bx <= max_bx; bx++)
            energy_calculate_block(noise, bx, by);
    }

    void energy_calculate_range(const std::vector<float>& noise) {
        min_val = std::numeric_limits<float>::max();
        max_val = std::numeric_limits<float>::lowest();
        min_x = min_y = max_x = max_y = 0;

        for(const auto& block : blocks) {
            if(block.min_val < min_val) {
                min_val = block.min_val;
                min_x = block.min_x;
                min_y = block.min_y;
            }

            if(block.max_val > max_val) {
                max_val = block.max_val;
                max_x = block.max_x;
                max_y = block.max_y;
            }
        }
    }

    void energy_calculate(const std::vector<float>& noise) {
        min_val = std::numeric_limits<float>::max();
        max_val = std::numeric_limits<float>::lowest();
        min_x = min_y = max_x = max_y = 0;

        for(int y = 0; y < patchSize; y++)
        for(int x = 0; x < patchSize; x++) {
            int idx = y * patchSize + x;
            double e = 0.;
            int windex = 0;
            
            for(int dy = -radius; dy <= radius; dy++)
            for(int dx = -radius; dx <= radius; dx++) {
                int nx = (x + dx) & (patchSize - 1);
                int ny = (y + dy) & (patchSize - 1);

                e += noise[ny * patchSize + nx] * weights[windex++];
            }
            
            energyAcc[idx] = e;
            energy[idx] = e / totalWeight;
        }

        energy_calculate_block_all(noise);
    }

    void energy_update(std::vector<float>& noise, int x, int y, double value) {
        double oldVal = noise[y * patchSize + x];
        if(oldVal == value) return;

        double delta = value - oldVal;
        noise[y * patchSize + x] = value;

        int windex = 0;
        for(int dy = -radius; dy <= radius; dy++)
        for(int dx = -radius; dx <= radius; dx++) {
            int nx = (x + dx) & (patchSize - 1);
            int ny = (y + dy) & (patchSize - 1);
            
            double idx = ny * patchSize + nx;
            double wei = weights[windex++];
            
            energyAcc[idx] += delta * wei;
            energy[idx]     = energyAcc[idx] / totalWeight;
        }

        energy_calculate_block_ranges(noise, x, y);
    }

    double set_seed(double s)       { seed      = static_cast<int>(s);  return 0; }
    double set_radius(double r)     { radius    = static_cast<int>(r);  return 0; }
    double set_iteration(double it) { iteration = static_cast<int>(it); return 0; }
    double set_threshold(double t)  { threshold = t;                    return 0; }
    double set_sigma(double s)      { sigma     = s; sigma2 = 2. * sigma * sigma; return 0; }
    double set_workers(double w)    { workers   = static_cast<int>(w);  return 0; }

    double get_minx() { return min_x; }
    double get_miny() { return min_y; }
    double get_maxx() { return max_x; }
    double get_maxy() { return max_y; }
    double get_total_weight() { return totalWeight; }

    double set_size(double s, double patch) {    
        size      = static_cast<int>(s);
        patchSize = static_cast<int>(patch);
        return 0;
    }

    void generate_patch(int _seed, int px, int py) {
        std::srand(static_cast<unsigned int>(_seed));
        
        for(int i = 0; i < pixels; i++) 
            noise[i] = static_cast<double>(std::rand()) / RAND_MAX > threshold? 1 : 0;

        ////- =Initial Binary
        
        if(stop_generate) return;
        energy_calculate(noise);
        for(int i = 1; i < iteration; i++) {
            energy_update(noise, min_x, min_y, 1.);
            energy_update(noise, max_x, max_y, 0.);
            
            energy_calculate_range(noise);
        }

        for(int i = 0; i < pixels; i++)
            output[i] = noise[i];

        ////- =Order white
            
        if(stop_generate) return;
        int white_count = 0;
        for(int i = 0; i < pixels; i++)
            if(noise[i] == 1) white_count++;

        double ord = (double)white_count;

        energy_calculate(output);
        for(int i = 0; i < white_count; i++) {
            order[max_y * patchSize + max_x] = ord / pixels;
            
            energy_update(output, max_x, max_y, 0.);
            energy_calculate_range(output);
            ord--;
        }

        ////- =Order black

        if(stop_generate) return;
        ord = (double)white_count + 1.;
        int black_count = pixels / 2 - white_count;
        
        energy_calculate(noise);
        for(int i = 0; i < black_count; i++) {
            order[min_y * patchSize + min_x] = ord / pixels;
            
            energy_update(noise, min_x, min_y, 1.);
            energy_calculate_range(noise);
            ord++;
        }

        ////- =Fil gaps

        if(stop_generate) return;
        int gap_count = pixels / 2;
        
        energy_calculate(noise);
        for(int i = 0; i < gap_count; i++) {
            order[min_y * patchSize + min_x] = ord / pixels;
            
            energy_update(noise, min_x, min_y, 1.);
            energy_calculate_range(noise);
            ord++;
        }

        if(stop_generate) return;
        for(int yp = 0; yp < patchSize; yp++)
        for(int xp = 0; xp < patchSize; xp++) {
            int ppx = px + xp;
            int ppy = py + yp;
            if(ppx >= size || ppy >= size) continue;

            int ind = ppy * size + ppx;
            int pid = yp * patchSize + xp;
            out[ind] = static_cast<float>(order[pid]);
        }

    }

    int generate_all() {
        int _seed  = seed;
        int patchW = std::ceil(static_cast<double>(size) / patchSize);
        int patchH = std::ceil(static_cast<double>(size) / patchSize);

        for(int py = 0; py < patchH; py++)
        for(int px = 0; px < patchW; px++) {
            if(stop_generate) break;
            generate_patch(_seed++, px * patchSize, py * patchSize);
        }

        generating = false;
        asyncCall(generator_id, 70, "blue_noise_generate_complete", 200.0, "Blue Noise Completed");
        return 0;
    }

    int generate(void* _output, int genid) {
        if(generating) {
            stop_generate = true;
            while(generating) std::this_thread::sleep_for(std::chrono::milliseconds(1));
        }

        out          = static_cast<float*>(_output);
        generator_id = genid;
        pixels       = patchSize * patchSize;

        noise.resize(pixels);
        energy.resize(pixels);
        energyAcc.resize(pixels);
        output.resize(pixels);
        order.resize(pixels);

        BLOCK_SIZE     = std::clamp(patchSize / 4, 1, 16);
        blocks_per_row = patchSize / BLOCK_SIZE;
        total_blocks   = blocks_per_row * blocks_per_row;
        blocks.resize(total_blocks);

        ////- =Precal
        weights.resize((2 * radius + 1) * (2 * radius + 1));

        totalWeight = 0.;
        int windex = 0;
        for(int dx = -radius; dx <= radius; dx++)
        for(int dy = -radius; dy <= radius; dy++) {
            double w = std::exp(-(dx*dx + dy*dy) / sigma2);

            weights[windex++] = w;
            totalWeight += w;
        }

        ////- =Generate
        generating = true;
        stop_generate = false;
        std::thread(&BlueNoise_Generator::generate_all, this).detach();
        
        return 0;
    }

};

#define GEN_INDEX int i = static_cast<int>(x); if(i < 0 || i >= static_cast<int>(generators.size())) return -1; BlueNoise_Generator& generator = generators[i];

std::vector<BlueNoise_Generator> generators;

cfunction double blue_noise_generator_init() { 
    generators.emplace_back();
    return static_cast<double>(generators.size() - 1);
}

cfunction double blue_noise_set_seed(double x, double seed) {               GEN_INDEX generator.set_seed(seed);           return 0; }
cfunction double blue_noise_set_radius(double x, double radius) {           GEN_INDEX generator.set_radius(radius);       return 0; }
cfunction double blue_noise_set_iteration(double x, double iteration) {     GEN_INDEX generator.set_iteration(iteration); return 0; }
cfunction double blue_noise_set_threshold(double x, double threshold) {     GEN_INDEX generator.set_threshold(threshold); return 0; }
cfunction double blue_noise_set_sigma(double x, double sigma) {             GEN_INDEX generator.set_sigma(sigma);         return 0; }
cfunction double blue_noise_set_workers(double x, double workers) {         GEN_INDEX generator.set_workers(workers);     return 0; }
cfunction double blue_noise_set_size(double x, double size, double patch) { GEN_INDEX generator.set_size(size, patch);    return 0; }

cfunction double blue_noise_get_minx(double x) {                            GEN_INDEX return generator.get_minx();                  }
cfunction double blue_noise_get_miny(double x) {                            GEN_INDEX return generator.get_miny();                  }
cfunction double blue_noise_get_maxx(double x) {                            GEN_INDEX return generator.get_maxx();                  }
cfunction double blue_noise_get_maxy(double x) {                            GEN_INDEX return generator.get_maxy();                  }
cfunction double blue_noise_get_total_weight(double x) {                    GEN_INDEX return generator.get_total_weight();          }

cfunction double blue_noise_generate(double x, void* output) {              GEN_INDEX generator.generate(output, x);      return x; }


*/