function Node_pSystem_Wrap(_x, _y, _group = noone) : Node(_x, _y, _group) constructor {
	name  = "Wrap";
	icon  = THEME.vfx;
	color = COLORS.node_blend_vfx;
	setDrawIcon(s_node_psystem_transform);
	
	setDimension(96, 0);
	update_on_frame = true;
	
	newInput( 2, nodeValueSeed());
	
	////- =Particles
	newInput( 0, nodeValue_Particle( "Particles" ));
	newInput( 1, nodeValue_Buffer(   "Mask"      ));
	
	////- =Wrap
	newInput( 3, nodeValue_Toggle( "Wrap", 0, [ "X", "Y" ] ));
	// 4
	
	newOutput(0, nodeValue_Output("Particles", VALUE_TYPE.particle, noone ));
	
	input_display_list = [  
		[ "Particles",   false ], 0, 1, 
		[ "Wrap",        false ], 3, 
	];
	
	////- Nodes
	
	static drawOverlay = function(hover, active, _x, _y, _s, _mx, _my, _snx, _sny, _params) {
		var _parts = getInputData(0);
		if(!is(_parts, pSystem_Particles)) return;
		
		_parts.drawOverlay(hover, active, _x, _y, _s, _mx, _my, _snx, _sny, _params);
	}
	
	static update = function(_frame = CURRENT_FRAME) {
		var _parts = getInputData(0);
		var _masks = getInputData(1), use_mask = _masks != noone;
		
		if(!is(_parts, pSystem_Particles)) return;
		if(use_mask) buffer_to_start(_masks);
		outputs[0].setValue(_parts);
		
		var _dim  = getDimension();
		var _wrap = getInputData(3);
		
		var wx = _wrap & 0b01;
		var wy = _wrap & 0b10;
		var bx = _dim[0];
		var by = _dim[1];
		
		var _partAmo  = _parts.maxCursor;
		var _partBuff = _parts.buffer;
		var _off = 0;
		
		repeat(_partAmo) {
			var _start = _off;
			buffer_seek(_partBuff, buffer_seek_start, _start);
			_off += global.pSystem_data_length;
			
			var _mask   = use_mask? buffer_read(_masks, buffer_f32) : 1; if(_mask <= 0) continue;
			var _act    = buffer_read_at( _partBuff, _start + PSYSTEM_OFF.active, buffer_bool );
			if(!_act) continue;
			
			var _px = buffer_read_at( _partBuff, _start + PSYSTEM_OFF.posx, buffer_f64  );
			var _py = buffer_read_at( _partBuff, _start + PSYSTEM_OFF.posy, buffer_f64  );
			
			if(wx) {
				if(_px < 0)  _px += bx;
				if(_px > bx) _px -= bx;
			}
			
			if(wy) {
				if(_py < 0)  _py += by;
				if(_py > by) _py -= by;
			}
			
			buffer_write_at( _partBuff, _start + PSYSTEM_OFF.posx, buffer_f64, _px );
			buffer_write_at( _partBuff, _start + PSYSTEM_OFF.posy, buffer_f64, _py );
		}
		
	}
}