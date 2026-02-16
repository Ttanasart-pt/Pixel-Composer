function Node_pSystem_3D_Clone(_x, _y, _group = noone) : Node_3D(_x, _y, _group) constructor {
	name  = "Clone";
	icon  = THEME.vfx;
	color = COLORS.node_blend_vfx;
	setDrawIcon(s_node_psystem_3d_destroy);
	
	setDimension(96, 0);
	update_on_frame = true;
	
	newInput( 2, nodeValueSeed());
	
	////- =Particles
	newInput( 0, nodeValue_Particle( "Particles" ));
	newInput( 1, nodeValue_Buffer(   "Mask"      ));
	
	// 2
	
	newOutput(0, nodeValue_Output("Original", VALUE_TYPE.particle, noone )).setVisible(false);
	newOutput(1, nodeValue_Output("Cloned",   VALUE_TYPE.particle, noone ));
	
	input_display_list = [ 2, 
		[ "Particles", false ], 0, 1, 
	];
	
	////- Nodes
	
	partPool = undefined;
	
	static drawOverlay = function(hover, active, _x, _y, _s, _mx, _my, _params) {
		var _parts = getInputData(0);
		if(!is(_parts, pSystem_Particles)) return;
		
		_parts.drawOverlay(hover, active, _x, _y, _s, _mx, _my, _params);
	}
	
	static getDimension = function() { return is(inline_context, Node_pSystem_Inline)? inline_context.dimension : DEF_SURF; }
	
	static reset = function() {
		if(partPool != undefined) {
			partPool.free();
			partPool = undefined;
		}
	}
	
	static update = function(_frame = CURRENT_FRAME) { 
		var _data = inputs_data;
		
		var _parts = getInputData(0);
		var _masks = getInputData(1), use_mask = _masks != noone;
		
		if(!is(_parts, pSystem_Particles)) return;
		if(use_mask) buffer_to_start(_masks);
		
		var _seed = getInputData( 2);
		
		var _poolSize = _parts.poolSize;
		var _partAmo  = _parts.maxCursor;
		var _partBuff = _parts.buffer;
		
		if(partPool == undefined) 
			partPool = _parts.clone();
		else {
			partPool.poolSize  = _parts.poolSize;
			partPool.cursor    = _parts.cursor;
			partPool.maxCursor = _parts.maxCursor;
			
			var _bufSize = buffer_get_size(_parts.buffer);
			buffer_copy(_parts.buffer, 0, _bufSize, partPool.buffer, 0);
		}
		
		outputs[0].setValue(_parts);
		outputs[1].setValue(partPool);
	}
	
}