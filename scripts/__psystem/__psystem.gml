#region global
	globalvar PSYSTEM_OFF; PSYSTEM_OFF = {};
	
	PSYSTEM_OFF.active =   0;   // buffer_bool : Active             : 1
	PSYSTEM_OFF._res   =   1;   // buffer_bool : _reserved          : 1
	PSYSTEM_OFF.dflag  =   2;   // buffer_u16  : Draw Flag          : 2
	PSYSTEM_OFF.sindex =   4;   // buffer_u32  : Spawn Index        : 4

	PSYSTEM_OFF.posx   =   8;   // buffer_f64  : Position X         : 8
	PSYSTEM_OFF.posy   =  16;   // buffer_f64  : Position Y         : 8
	PSYSTEM_OFF.posz   =  24;   // buffer_f64  : Position Z         : 8

	PSYSTEM_OFF.scax   =  32;   // buffer_f64  : Scale X            : 8
	PSYSTEM_OFF.scay   =  40;   // buffer_f64  : Scale Y            : 8
	PSYSTEM_OFF.scaz   =  48;   // buffer_f64  : Scale Z            : 8
	
	PSYSTEM_OFF.rotx   =  56;   // buffer_f64  : Rotation X         : 8
	PSYSTEM_OFF.roty   =  64;   // buffer_f64  : Rotation Y         : 8
	PSYSTEM_OFF.rotz   =  72;   // buffer_f64  : Rotation Z         : 8

	PSYSTEM_OFF.life   =  80;   // buffer_f64  : Life               : 8
	PSYSTEM_OFF.mlife  =  88;   // buffer_f64  : Max Life           : 8

	PSYSTEM_OFF.surf   =  96;   // buffer_f64  : Surface            : 8
	PSYSTEM_OFF.blnr   = 104;   // buffer_u8   : Blend Red          : 1
	PSYSTEM_OFF.blng   = 105;   // buffer_u8   : Blend Green        : 1
	PSYSTEM_OFF.blnb   = 106;   // buffer_u8   : Blend Blue         : 1
	PSYSTEM_OFF.blna   = 107;   // buffer_u8   : Blend Alpha        : 1

	PSYSTEM_OFF.blnsr  = 108;   // buffer_u8   : Blend Start Red    : 1
	PSYSTEM_OFF.blnsg  = 109;   // buffer_u8   : Blend Start Green  : 1
	PSYSTEM_OFF.blnsb  = 110;   // buffer_u8   : Blend Start Blue   : 1
	PSYSTEM_OFF.blnsa  = 111;   // buffer_u8   : Blend Start Alpha  : 1

	PSYSTEM_OFF.possx  = 112;   // buffer_f64  : Position Start X   : 8
	PSYSTEM_OFF.possy  = 120;   // buffer_f64  : Position Start Y   : 8
	PSYSTEM_OFF.possz  = 128;   // buffer_f64  : Position Start Z   : 8

	PSYSTEM_OFF.pospx  = 136;   // buffer_f64  : Position Prev X    : 8
	PSYSTEM_OFF.pospy  = 144;   // buffer_f64  : Position Prev Y    : 8
	PSYSTEM_OFF.pospz  = 152;   // buffer_f64  : Position Prev Z    : 8

	PSYSTEM_OFF.velx   = 160;   // buffer_f64  : Velocity X         : 8
	PSYSTEM_OFF.vely   = 168;   // buffer_f64  : Velocity Y         : 8
	PSYSTEM_OFF.velz   = 176;   // buffer_f64  : Velocity Z         : 8

	PSYSTEM_OFF.dposx  = 184;   // buffer_f64  : Draw Position X    : 8
	PSYSTEM_OFF.dposy  = 192;   // buffer_f64  : Draw Position Y    : 8
	PSYSTEM_OFF.dposz  = 200;   // buffer_f64  : Draw Position Z    : 8

	PSYSTEM_OFF.dscax  = 208;   // buffer_f64  : Draw Scale X       : 8
	PSYSTEM_OFF.dscay  = 216;   // buffer_f64  : Draw Scale Y       : 8
	PSYSTEM_OFF.dscaz  = 224;   // buffer_f64  : Draw Scale Z       : 8
	
	PSYSTEM_OFF.drotx  = 232;   // buffer_f64  : Draw Rotation X    : 8
	PSYSTEM_OFF.droty  = 240;   // buffer_f64  : Draw Rotation Y    : 8
	PSYSTEM_OFF.drotz  = 248;   // buffer_f64  : Draw Rotation Z    : 8

	global.pSystem_data_length = 256;
	global.pSystem_trig_length = 8*3 + 8*3; // px, py, pz, vx, vy, vz
	
	function pSystem_Particles() constructor {
		poolSize  = 1024;
		cursor    = 0;
		maxCursor = 0;
		buffer    = undefined;
		
		static init = function(_poolSize = 1024) {
			poolSize = _poolSize;
			cursor   = 0;
			
			var _poolbSize = global.pSystem_data_length * poolSize;
			buffer = buffer_create(_poolbSize, buffer_fixed, 1);
			buffer_clear(buffer);
		}
		
		static drawOverlay = function(hover, active, _x, _y, _s, _mx, _my, _snx, _sny, _params) {
			var _partBuff = buffer;
			var _partAmo  = maxCursor;
			var _off = 0;
			
			draw_set_color(COLORS._main_accent);
			
			repeat(_partAmo) {
				var _start = _off;
				buffer_seek(_partBuff, buffer_seek_start, _start);
				_off += global.pSystem_data_length;
				
				var _act = buffer_read_at( _partBuff, _start + PSYSTEM_OFF.active, buffer_bool );
				if(!_act) continue;
				
				var _px = buffer_read_at( _partBuff, _start + PSYSTEM_OFF.posx,   buffer_f64  );
				var _py = buffer_read_at( _partBuff, _start + PSYSTEM_OFF.posy,   buffer_f64  );
				var __x = _x + _px * _s;
				var __y = _y + _py * _s;
				
				draw_line(__x - 4, __y, __x + 4, __y);
				draw_line(__x, __y - 4, __x, __y + 4);
			}
			
		}
		
		static free = function() {
			buffer_delete_safe(buffer);
		}
		
		static clone = function() {
			var _n = new pSystem_Particles();
			
			_n.poolSize  = poolSize;
			_n.cursor    = cursor;
			_n.maxCursor = maxCursor;
			_n.buffer    = buffer_clone(buffer);
			
			return _n;
		}
	}
#endregion

/*[cpp] pSystem_main.h
#include <cstdint>

struct Particle {
	bool active;
	uint32_t flag;
	int spawnIndex;
	
	double x;
	double y;
	double z;
	
	double sx;
	double sy;
	double sz;

	double rx;
	double ry;
	double rz;
	
	double life;
	double lifeMax;
	
	double  surfaceIndex;
	uint8_t blendR;
	uint8_t blendG;
	uint8_t blendB;
	uint8_t blendA;
	
	uint8_t draw_blendR;
	uint8_t draw_blendG;
	uint8_t draw_blendB;
	uint8_t draw_blendA;
	
	double x_start;
	double y_start;
	double z_start;
	
	double x_prev;
	double y_prev;
	double z_prev;
	
	double vx;
	double vy;
	double vz;
	
	double draw_x;
	double draw_y;
	double draw_z;
	
	double draw_sx;
	double draw_sy;
	double draw_sz;
	
	double draw_rx;
	double draw_ry;
	double draw_rz;
};
*/