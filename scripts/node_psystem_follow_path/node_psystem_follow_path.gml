function Node_pSystem_Follow_Path(_x, _y, _group = noone) : Node(_x, _y, _group) constructor {
	name  = "Follow Path";
	icon  = THEME.vfx;
	color = COLORS.node_blend_vfx;
	node_draw_icon = s_node_psystem_follow_path;
	
	setDimension(96, 0);
	update_on_frame = true;
	
	newInput( 2, nodeValueSeed());
	
	////- =Particles
	newInput( 0, nodeValue_Particle( "Particles" ));
	newInput( 1, nodeValue_Buffer(   "Mask"      ));
	
	////- =Path
	newInput( 3, nodeValue_PathNode(   "Path"    ));
	newInput( 4, nodeValue_Vec2_Range( "Path Range",     [0,0,1,1]    ));
	newInput( 5, nodeValue_Curve(      "Path Influence", CURVE_DEF_11 ));
	
	////- =Apply
	newInput( 6, nodeValue_Bool(  "Use Start Position", true ));
	newInput( 7, nodeValue_Range( "Stride", [.1,.1],    true )).setCurvable( 8, CURVE_DEF_11, "Over Lifespan");
	newInput( 9, nodeValue_Range( "Spiral", [ 0, 0],    true )).setCurvable(10, CURVE_DEF_11, "Over Lifespan");
	// 11
	
	newOutput(0, nodeValue_Output("Particles", VALUE_TYPE.particle, noone ));
	
	input_display_list = [ 2, 
		[ "Particles", false ], 0, 1, 
		[ "Path",      false ], 3, 4, 5, 
		[ "Apply",     false ], 6, 7, 8, 9, 10, 
	];
	
	////- Nodes
	
	curve_devi = undefined;
	curve_stri = undefined;
	curve_spri = undefined;
	__p = new __vec2P();
	
	static drawOverlay = function(hover, active, _x, _y, _s, _mx, _my, _snx, _sny, _params) {
		var _parts = getInputData(0);
		var _path  = getInputData(3);
		
		if(!is_path(_path)) return;
		if(!is(_parts, pSystem_Particles)) return;
		
		_parts.drawOverlay(hover, active, _x, _y, _s, _mx, _my, _snx, _sny, _params);
		
		if(has(_path, "drawOverlay"))
			InputDrawOverlay(_path.drawOverlay(hover, active, _x, _y, _s, _mx, _my, _snx, _sny, _params));
	}
	
	static reset = function() {
		curve_devi = new curveMap(getInputData( 5));
		curve_stri = new curveMap(getInputData( 8));
		curve_spri = new curveMap(getInputData(10));
	}
	
	static update = function(_frame = CURRENT_FRAME) {
		var _parts = getInputData(0);
		var _masks = getInputData(1), use_mask = _masks != noone;
		
		if(!is(_parts, pSystem_Particles)) return;
		if(use_mask) buffer_to_start(_masks);
		outputs[0].setValue(_parts);
		
		var _seed = getInputData( 2);
		var _path = getInputData( 3);
		var _rang = getInputData( 4);
		
		var _star = getInputData( 6);
		var _stri = getInputData( 7), _stri_curved = inputs[7].attributes.curved && curve_stri != undefined;
		var _spri = getInputData( 9), _spri_curved = inputs[9].attributes.curved && curve_spri != undefined;
		
		inputs[ 7].setVisible(!_star);
		inputs[ 8].setVisible(!_star);
		inputs[ 9].setVisible( _star);
		inputs[10].setVisible( _star);
		
		var _partAmo  = _parts.maxCursor;
		var _partBuff = _parts.buffer;
		var _off = 0;
		
		if(curve_devi == undefined || !is_path(_path)) return;
		
		repeat(_partAmo) {
			var _start = _off;
			buffer_seek(_partBuff, buffer_seek_start, _start);
			_off += global.pSystem_data_length;
				
			var _mask   = use_mask? buffer_read(_masks, buffer_f32) : 1; if(_mask <= 0) continue;
			var _act    = buffer_read_at( _partBuff, _start + PSYSTEM_OFF.active, buffer_bool );
			var _spwnId = buffer_read_at( _partBuff, _start + PSYSTEM_OFF.sindex, buffer_u32  );
			if(!_act) continue;
			
			var _px     = buffer_read_at( _partBuff, _start + PSYSTEM_OFF.posx,   buffer_f64  );
			var _py     = buffer_read_at( _partBuff, _start + PSYSTEM_OFF.posy,   buffer_f64  );
			
			var _psx    = buffer_read_at( _partBuff, _start + PSYSTEM_OFF.possx,  buffer_f64  );
			var _psy    = buffer_read_at( _partBuff, _start + PSYSTEM_OFF.possy,  buffer_f64  );
			
			var _lif    = buffer_read_at( _partBuff, _start + PSYSTEM_OFF.life,   buffer_f64  );
			var _lifMax = buffer_read_at( _partBuff, _start + PSYSTEM_OFF.mlife,  buffer_f64  );
			
			var rat = _lif / (_lifMax - 1);
			random_set_seed(_seed + _spwnId);
			
			var _st = random_range(_rang[0], _rang[1]);
			var _ed = random_range(_rang[2], _rang[3]);
			var _path_rat = lerp(_st, _ed, rat);
			var _path_dev = curve_devi.get(rat) * _mask;
			
			if(_star) {
				var _dirr = point_direction( 0, 0, _psx, _psy );
				var _diss = point_distance(  0, 0, _psx, _psy );
				
				var _spri_mod = _spri_curved? curve_spri.get(rat) : 1;
				var _spri_cur = random_range(_spri[0], _spri[1]) * _spri_mod;
				
				_dirr += _lif * _spri_cur;
				
				var _ppx = lengthdir_x(_diss, _dirr);
				var _ppy = lengthdir_y(_diss, _dirr);
				
				__p = _path.getPointRatio(_path_rat, 0, __p);
				_px = __p.x + _ppx * _path_dev;
				_py = __p.y + _ppy * _path_dev;
				
			} else {
				var _stri_mod = _stri_curved? curve_stri.get(rat) : 1;
				var _stri_cur = random_range(_stri[0], _stri[1]) * _stri_mod;
				
				__p = _path.getPointRatio(_path_rat - _stri_cur / 2, 0, __p);
				var _x0 = __p.x;
				var _y0 = __p.y;
				
				__p = _path.getPointRatio(_path_rat + _stri_cur / 2, 0, __p);
				var _x1 = __p.x;
				var _y1 = __p.y;
				
				_px += (_x1 - _x0) * _path_dev;
				_py += (_y1 - _y0) * _path_dev;
			}
			
			buffer_write_at( _partBuff, _start + PSYSTEM_OFF.posx, buffer_f64, _px );
			buffer_write_at( _partBuff, _start + PSYSTEM_OFF.posy, buffer_f64, _py );
		}
		
	}
	
}