function Node_VerletSim_Render(_x, _y, _group = noone) : Node(_x, _y, _group) constructor {
	name = "Render";
	update_on_frame = true;
	
	newInput(0, nodeValue_Mesh( "Mesh" )).setVisible(true, true);
	
	////- =Output
	newInput(1, nodeValue_Dimension());
	
	////- =Render
	newInput(4, nodeValue_Bool(        "Step", true ));
	newInput(3, nodeValue_Enum_Button( "Type", 0, [ "Textured", "Wireframe" ] ));
	newInput(2, nodeValue_Surface(     "Texture" )).setVisible(true, true);
	newInput(5, nodeValue_Color(       "Color", ca_white ));
	// input 6
	
	newOutput(0, nodeValue_Output("Surface Out", VALUE_TYPE.surface, noone));
	
	input_display_list = [ 0, 
		[ "Output", false ], 1, 
		[ "Render", false ], 4, 3, 2, 5, 
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
	
	static update = function() {
		if(!is(inline_context, Node_VerletSim_Inline)) return;
		if(!IS_PLAYING) return;
		
		var _msh = getInputData(0);
		var _dim = getInputData(1);
		
		var _step = getInputData(4); 
		var _type = getInputData(3); 
		var _srf  = getInputData(2); 
		var _clr  = getInputData(5); 
		
		inputs[2].setVisible(_type == 0, _type == 0);
		inputs[5].setVisible(_type == 1);
		var _tex = is_surface(_srf)? surface_get_texture(_srf) : -1;
		
		if(!is(_msh, __verlet_Mesh)) return;
		if(_type == 0 && !is_surface(_srf)) return;
		
		if(_step) inline_context.verletStep(_msh);
		
		var _outSurf = outputs[0].getValue();
		_outSurf = surface_verify(_outSurf, _dim[0], _dim[1]);
		outputs[0].setValue(_outSurf);
		
		surface_set_target(_outSurf);
			DRAW_CLEAR
			
			var _i = 0;
			
			if(_type == 0) {
				draw_primitive_begin_texture(pr_trianglelist, _tex);
				draw_set_color(c_white);
				
				if(_msh.vquads == undefined) {
					for( var i = 0, n = array_length(_msh.vtriangles); i < n; i++ ) {
						_msh.vtriangles[i].submitVertex();
						
						if(++_i >= 32) {
							_i = 0;
							
							draw_primitive_end();
							draw_primitive_begin_texture(pr_trianglelist, _tex);
						}
					}
				} else {
					for( var i = 0, n = array_length(_msh.vquads); i < n; i++ ) {
						_msh.vquads[i].submitVertex();
						
						if(++_i >= 32) {
							_i = 0;
							
							draw_primitive_end();
							draw_primitive_begin_texture(pr_trianglelist, _tex);
						}
					}
				}
					
				draw_primitive_end();
			
			} else if(_type == 1) {
				draw_primitive_begin(pr_linelist); 
				draw_set_color(_clr);
				
				for( var i = 0, n = array_length(_msh.vedges); i < n; i++ ) {
					var e = _msh.vedges[i];
					if(!e.active) continue;
					
					var p0 = e.p0;
					var p1 = e.p1;
					
					draw_vertex(p0.x, p0.y);
					draw_vertex(p1.x, p1.y);
					
					if(++_i >= 32) {
						_i = 0;
						
						draw_primitive_end();
						draw_primitive_begin(pr_linelist);
					}
				}
				draw_primitive_end();
			}
			
		surface_reset_target();
		
	}
	
	
}
