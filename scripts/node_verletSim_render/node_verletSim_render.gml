function Node_VerletSim_Render(_x, _y, _group = noone) : Node(_x, _y, _group) constructor {
	name  = "Render";
	color = COLORS.node_blend_verlet;
	icon  = THEME.verletSim;
	update_on_frame = true;
	parameters.inline_draw_output = true;
	
	////- =Mesh
	newInput( 0, nodeValue_Mesh( "Mesh" )).setCustomData(global.VERLET_MESH_JUNC).setVisible(true, true);
	
	////- =Output
	newInput( 1, nodeValue_Dimension());
	
	////- =Simulation
	newInput( 4, nodeValue_Bool( "Step", true ));
	
	////- =Render
	newInput( 3, nodeValue_EButton( "Type", 0, [ "Textured", "Wireframe" ] ));
	newInput( 2, nodeValue_Surface( "Texture" )).setVisible(true, true);
	newInput( 5, nodeValue_Color(   "Color",        ca_white ));
	newInput( 7, nodeValue_Bool(    "Invert Order", false    ));
	
	////- =Effect
	newInput( 6, nodeValue_Slider( "Trim", 1 ));
	// input 8
	
	newOutput(0, nodeValue_Output("Surface Out", VALUE_TYPE.surface, noone));
	
	input_display_list = [ 
		[ "Mesh",       false ],  0, 
		[ "Simulation", false ],  4, 
		[ "Render",     false ],  3,  2,  5,  7, 
		[ "Effect",     false ],  6, 
	];
	
	////- Nodes
	
	attribute_interpolation(true);
	
	static getDimension = function() /*=>*/ {return is(inline_context, Node_VerletSim_Inline)? inline_context.getDimension() : DEF_SURF};
	
	static drawOverlay = function(hover, active, _x, _y, _s, _mx, _my, _params) { 
		var mesh = getInputData(0);
		if(is(mesh, __verlet_Mesh)) {
			draw_set_color(COLORS._main_icon);
			mesh.drawRendered(_x, _y, _s);
		}
		
		return w_hovering;
	}
	
	static update = function() {
		if(!is(inline_context, Node_VerletSim_Inline)) return;
		
		#region data
			var _msh  = getInputData( 0);
			var _dim  = getDimension();
			
			var _step = getInputData( 4); 
			
			var _type = getInputData( 3); 
			var _srf  = getInputData( 2); 
			var _clr  = getInputData( 5); 
			var _inv  = getInputData( 7); 
			
			var _trim = getInputData( 6); 
			
			inputs[2].setVisible(_type == 0, _type == 0);
			inputs[5].setVisible(_type == 1);
		#endregion
		
		if(!is(_msh, __verlet_Mesh)) return;
		
		var _tex = is_surface(_srf)? surface_get_texture(_srf) : -1;
		if(IS_PLAYING && _step) inline_context.verletStep(_msh);
		
		var _outSurf = outputs[0].getValue();
		_outSurf = surface_verify(_outSurf, _dim[0], _dim[1]);
		outputs[0].setValue(_outSurf);
		
		surface_set_target(_outSurf);
			DRAW_CLEAR
			gpu_set_texfilter(getAttribute("interpolate") > 1);
			
			var _i = 0;
			
			switch(_type) {
				case 0 :
					draw_primitive_begin_texture(pr_trianglelist, _tex);
					draw_set_color(c_white);
					
					if(_msh.vquads == undefined) {
						var _tamo = array_length(_msh.vtriangles);
						var _lamo = _tamo * _trim;
						
						for( var i = 0; i < _lamo; i++ ) {
							var _ind = _inv? _tamo - 1 - i : i;
							_msh.vtriangles[_ind].submitVertex();
							
							if(++_i >= 128) {
								_i = 0;
								draw_primitive_end();
								draw_primitive_begin_texture(pr_trianglelist, _tex);
							}
						}
						
					} else {
						var _tamo = array_length(_msh.vquads);
						var _lamo = _tamo * _trim;
						
						for( var i = 0; i < _lamo; i++ ) {
							var _ind = _inv? _tamo - 1 - i : i;
							_msh.vquads[_ind].submitVertex();
							
							if(++_i >= 128) {
								_i = 0;
								draw_primitive_end();
								draw_primitive_begin_texture(pr_trianglelist, _tex);
							}
						}
					}
						
					draw_primitive_end();
					break;
				
				case 1 : 
					draw_primitive_begin(pr_linelist); 
					draw_set_color(_clr);
					
					var _tamo = array_length(_msh.vedges);
					var _lamo = _tamo * _trim;
						
					for( var i = 0; i < _lamo; i++ ) {
						var _ind = _inv? _tamo - 1 - i : i;
						var e = _msh.vedges[_ind];
						if(!e.active) continue;
						
						var p0 = e.p0;
						var p1 = e.p1;
						
						draw_vertex(p0.x, p0.y);
						draw_vertex(p1.x, p1.y);
						
						if(++_i >= 128) {
							_i = 0;
							draw_primitive_end();
							draw_primitive_begin(pr_linelist);
						}
					}
					draw_primitive_end();
					break;
			}
			
			gpu_set_texfilter(false);
		surface_reset_target();
		
	}
	
	
}
