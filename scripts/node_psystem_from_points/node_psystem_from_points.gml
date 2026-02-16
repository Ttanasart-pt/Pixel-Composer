function Node_pSystem_from_Points(_x, _y, _group = noone) : Node(_x, _y, _group) constructor {
	name  = "From Points";
	icon  = THEME.vfx;
	color = COLORS.node_blend_vfx;
	setDrawIcon(s_node_psystem_from_points);
	setDimension(96, 0);
	
	////- =Spawn
	newInput( 0, nodeValue_Vec2( "Points Data", [0,0] )).setVisible(true, true).setArrayDepth(1);
	
	////- =Indexing
	newInput( 1, nodeValue_Float( "Index Start", 0 ));
	newInput( 2, nodeValue_Float( "Index Step",  1 ));
	// input 3
	
	newOutput(0, nodeValue_Output("Particles",  VALUE_TYPE.particle, noone ));
	
	input_display_list = [ 
		[ "Spawn",    false ], 0, 
		[ "Indexing", false ], 1, 2, 
	];
	
	////- Nodes
	
	static getDimension = function() { return is(inline_context, Node_pSystem_Inline)? inline_context.dimension : DEF_SURF; }
	
	static drawOverlay = function(hover, active, _x, _y, _s, _mx, _my, _params) {
		var _parts = outputs[0].getValue();
		if(!is(_parts, pSystem_Particles)) return;
		
		_parts.drawOverlay(hover, active, _x, _y, _s, _mx, _my, _params);
	}
	
	static update = function(_frame = CURRENT_FRAME) {
		#region data
			var _points  = getInputData( 0);
			
			var _idStart = getInputData( 1);
			var _idStep  = getInputData( 2);
			
			var _parts  = outputs[0].getValue();
		#endregion	
		
		if(!is_array(_points) || array_empty(_points)) return;
		if(!is_array(_points[0])) _points = [_points];
		
		var pamo = array_length(_points);
		
		if(!is(_parts, pSystem_Particles))
			_parts = new pSystem_Particles().init(pamo);
		else 
			_parts.verify(pamo);
		_parts.maxCursor = pamo;
			
		var b = _parts.buffer;
		var o = 0;
		
		buffer_to_start(b);
		for( var i = 0; i < pamo; i++ ) {
			var pp = _points[i];
			var px = pp[0];
			var py = pp[1];
			
			buffer_write_at( b, o + PSYSTEM_OFF.active, buffer_bool, true );
			buffer_write_at( b, o + PSYSTEM_OFF.stat,   buffer_bool, true );
			buffer_write_at( b, o + PSYSTEM_OFF.sindex, buffer_u32,  i    );
			
			buffer_write_at( b, o + PSYSTEM_OFF.life,   buffer_f64,  _idStart );
			buffer_write_at( b, o + PSYSTEM_OFF.mlife,  buffer_f64,  _idStep  );
			
			buffer_write_at( b, o + PSYSTEM_OFF.posx,   buffer_f64,  px   );
			buffer_write_at( b, o + PSYSTEM_OFF.posy,   buffer_f64,  py   );
			
			buffer_write_at( b, o + PSYSTEM_OFF.scax,   buffer_f64,  1    );
			buffer_write_at( b, o + PSYSTEM_OFF.scay,   buffer_f64,  1    );
			
			buffer_write_at( b, o + PSYSTEM_OFF.pospx,   buffer_f64, px   );
			buffer_write_at( b, o + PSYSTEM_OFF.pospy,   buffer_f64, py   );
			
			buffer_write_at( b, o + PSYSTEM_OFF.velx,   buffer_f64,  0    );
			buffer_write_at( b, o + PSYSTEM_OFF.vely,   buffer_f64,  0    );
			
			buffer_write_at( b, o + PSYSTEM_OFF.blnr,   buffer_u8,   255  );
			buffer_write_at( b, o + PSYSTEM_OFF.blng,   buffer_u8,   255  );
			buffer_write_at( b, o + PSYSTEM_OFF.blnb,   buffer_u8,   255  );
			buffer_write_at( b, o + PSYSTEM_OFF.blna,   buffer_u8,   255  );
			
			o += global.pSystem_data_length;
		}
			
		outputs[0].setValue(_parts);
	}
	
	static cleanUp = function() {
		var _parts = outputs[0].getValue();
		if(is(_parts, pSystem_Particles))
			_parts.free();
	}
}
