function Node_VerletSim_Render(_x, _y, _group = noone) : Node(_x, _y, _group) constructor {
	name = "Render";
	update_on_frame = true;
	
	newInput(0, nodeValue_Mesh( "Mesh" )).setVisible(true, true);
	
	////- =Output
	newInput(1, nodeValue_Dimension());
	
	////- =Texture
	newInput(2, nodeValue_Surface( "Texture" )).setVisible(true, true);
	// input 3
	
	newOutput(0, nodeValue_Output("Surface Out", VALUE_TYPE.surface, noone));
	
	input_display_list = [ 0, 
		[ "Output",  false ], 1, 
		[ "Texture", false ], 2, 
	];
	
	////- Nodes
	
	static drawOverlay = function(hover, active, _x, _y, _s, _mx, _my, _snx, _sny) {
		
		var mesh = getInputData(0);
		if(is(mesh, __verlet_Mesh)) {
			draw_set_color(COLORS._main_icon);
			mesh.draw(_x, _y, _s);
		}
		
		return w_hovering;
	}
	
	static step = function() {}
	
	static update = function() {
		if(!is(inline_context, Node_VerletSim_Inline)) return;
		
		var _msh = getInputData(0);
		var _dim = getInputData(1);
		var _srf = getInputData(2); 
		
		var _tex = is_surface(_srf)? surface_get_texture(_srf) : -1;
		
		if(!is(_msh, __verlet_Mesh)) return;
		inline_context.verletStep(_msh);
		
		var _outSurf = outputs[0].getValue();
		_outSurf = surface_verify(_outSurf, _dim[0], _dim[1]);
		outputs[0].setValue(_outSurf);
		
		surface_set_target(_outSurf);
			DRAW_CLEAR
			
			var _i = 0;
			
			if(is_surface(_srf)) draw_primitive_begin_texture(pr_trianglelist, _tex);
			else draw_primitive_begin(pr_trianglelist); 
			draw_set_color(c_white);
			
			for( var i = 0, n = array_length(_msh.triangles); i < n; i++ ) {
				var t = _msh.triangles[i];
				
				var p0 = _msh.points[t[0]];
				var p1 = _msh.points[t[1]];
				var p2 = _msh.points[t[2]];
				
				draw_vertex_texture(p0.x, p0.y, p0.u, p0.v);
				draw_vertex_texture(p1.x, p1.y, p1.u, p1.v);
				draw_vertex_texture(p2.x, p2.y, p2.u, p2.v);
				
				if(++_i >= 32) {
					_i = 0;
					draw_primitive_end();
					if(is_surface(_srf)) draw_primitive_begin_texture(pr_trianglelist, _tex);
					else draw_primitive_begin(pr_trianglelist); 
				}
			}
			draw_primitive_end();
			
		surface_reset_target();
		
	}
	
	
}
