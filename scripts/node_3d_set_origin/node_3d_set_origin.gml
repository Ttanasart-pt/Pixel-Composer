function Node_3D_Set_Origin(_x, _y, _group = noone) : Node_3D(_x, _y, _group) constructor {
	name  = "3D Set Origin";
	gizmo = new __3dGizmoAxis(.2, COLORS._main_accent);
	
	newInput(0, nodeValue_D3Mesh( "Mesh" ));
	
	////- =Origin
	newInput(1, nodeValue_EScroll( "Type",  1, [ "Fixed World Point", "Mesh Center" ] ));
	newInput(2, nodeValue_Vec3(    "Point", [0,0,0] ));
	
	newOutput(0, nodeValue_Output( "Scene", VALUE_TYPE.d3Mesh, noone ));
	
	inputs_display_list = [ 0, 
		[ "Origin", false ], 1, 2,  
	]
	
	static processData = function(_output, _data, _array_index = 0, _frame = CURRENT_FRAME) {
		#region data
			var _mesh = _data[0];
			
			var _type = _data[1];
			var _pont = _data[2];
			
			inputs[2].setVisible(_type == 0);
		#endregion
		
		if(!is(_mesh, __3dInstance)) return _output;
		if(!is(_output, __3dTransformed)) 
			_output = new __3dTransformed();
		_output.object = _mesh;
		
		var ox = 0;
		var oy = 0;
		var oz = 0;
		
		var px = _mesh.transform.position.x;
		var py = _mesh.transform.position.y;
		var pz = _mesh.transform.position.z;
		
		switch(_type) {
			case 0 :	
				ox = _pont[0];
				oy = _pont[1];
				oz = _pont[2];
				break;
				
			case 1: 
				var _vbs = _mesh.VB;
				var oo  = 0;
				
				if(_mesh.VF != global.VF_POS_NORM_TEX_COL) break;
				
				var _format_s = global.VF_POS_NORM_TEX_COL_size;
					
				for( var i = 0, n = array_length(_vbs); i < n; i++ ) {
					var _vb = _vbs[i];
					
					var _buffer   = buffer_create_from_vertex_buffer(_vb, buffer_fixed, 1);
					var _buffer_s = buffer_get_size(_buffer);
					var _vertex_s = floor(_buffer_s / _format_s);
					
					buffer_to_start(_buffer);
					
					repeat(_vertex_s) {
						var _px = buffer_read(_buffer, buffer_f32);
						var _py = buffer_read(_buffer, buffer_f32);
						var _pz = buffer_read(_buffer, buffer_f32);
						
						var _nx = buffer_read(_buffer, buffer_f32);
						var _ny = buffer_read(_buffer, buffer_f32);
						var _nz = buffer_read(_buffer, buffer_f32);
						
						var _u  = buffer_read(_buffer, buffer_f32);
						var _v  = buffer_read(_buffer, buffer_f32);
						
						var _r  = buffer_read(_buffer, buffer_s8);
						var _g  = buffer_read(_buffer, buffer_s8);
						var _b  = buffer_read(_buffer, buffer_s8);
						var _a  = buffer_read(_buffer, buffer_s8);
						
						var _bx = buffer_read(_buffer, buffer_f32);
						var _by = buffer_read(_buffer, buffer_f32);
						var _bz = buffer_read(_buffer, buffer_f32);
						
						ox += _px;
						oy += _py;
						oz += _pz;
						oo++;
					}
					
					buffer_delete(_buffer);
				}
				
				if(oo > 0) { 
					ox /= oo;
					oy /= oo;
					oz /= oo;
				}
				break;
		}
		
		_output.transform.position.set(	ox-px, oy-py, oz-pz );
		_output.transform.anchor.set(	ox,    oy,    oz    );
		_output.transform.applyMatrix();
		
		if(_array_index == preview_index) {
			gizmo.transform.position.set(	ox-px, oy-py, oz-pz );
			gizmo.transform.applyMatrix();
		}
		
		return _output;
	}
	
	////- Preview
	
	static getPreviewObjects		= function() { return [ getPreviewObject(), gizmo ]; }
	static getPreviewObjectOutline  = function() { return [ getPreviewObject(), gizmo ]; }
}