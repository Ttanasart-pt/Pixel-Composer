function Node_Mesh_Fill(_x, _y, _group = noone) : Node_Processor(_x, _y, _group) constructor {
	name = "Fill Mesh";
	
	newInput(12, nodeValue_Seed());
	
	////- =Output
	newInput( 1, nodeValue_Dimension());
	
	////- =Mesh
	newInput( 0, nodeValue_Mesh( "Mesh" )).setVisible(true, true).setRequired();
	
	////- =Rendering
	
		////- =/Fill
	newInput(10, nodeValue_Bool(     "Draw Fill",    true      ));
	newInput( 2, nodeValue_Color(    "Color",        ca_white  ));
	newInput(11, nodeValue_Gradient( "Random Color", gra_white )).addShift(13);
	
		////- =/Texture
	newInput( 5, nodeValue_Surface( "Texture" ));
	newInput( 6, nodeValue_EButton( "Mapping", 0, [ "Direct", "Mesh UV" ] ));
	
		////- =/Outline
	newInput( 7, nodeValue_Bool(  "Draw Outline", false    ));
	newInput( 8, nodeValue_Float( "Thickness",    1        ));
	newInput( 9, nodeValue_Color( "Color",        ca_white ));
	
		////- =/BG
	newInput( 3, nodeValue_Bool(  "Use Background", false    ));
	newInput( 4, nodeValue_Color( "Color",          ca_black ));
	// 14
	
	newOutput(0, nodeValue_Output("Surface Out", VALUE_TYPE.surface, noone));
	
	input_display_list = [ 12, 
		[ "Output",       false    ],  1,
		[ "Mesh",         false    ],  0, 
		[ "Rendering",    false    ],  
			[ "/Fill",    false,10 ],  2, [11, true], 13, -1, 
			[ "/Texture", false    ],  5,  6, 
			[ "/Outline", false, 7 ],  8,  9, 
			[ "/BG",      false, 3 ],  4, 
	];
	
	////- Nodes
	
	static drawOverlay = function(hover, active, _x, _y, _s, _mx, _my, _params) { 
		var mesh = inputs[0].getValue();
		if(mesh != noone) {
			draw_set_color(COLORS._main_icon);
			mesh.draw(_x, _y, _s);
		}
	}
	
	static processData = function(_outSurf, _data, _array_index = 0) { 
		#region data
			var _seed  = _data[12];
			
			var _dim   = _data[ 1];
			
			var _mesh  = _data[ 0];
			
			var _filD  = _data[10];
			var _colr  = _data[ 2];
			var _grad  = _data[11]; _grad.cache();
			var _grdSh = _data[13];
			
			var _text  = _data[ 5], useTex = is_surface(_text);
			var _txMap = _data[ 6];
			
			var _outD  = _data[ 7];
			var _outT  = _data[ 8];
			var _outC  = _data[ 9];
			
			var _bgUse = _data[ 3];
			var _bgCol = _data[ 4];
			
		#endregion
		
		if(!is(_mesh, Mesh)) return _outSurf; 
		
		random_set_seed(_seed);
		
		var _pnt = _mesh.points;
		var _tri = _mesh.triangles;
		
		var _alph = _color_get_a(_colr);
		
		surface_set_target(_outSurf);
		if(_bgUse) draw_clear_alpha(_bgCol, _color_get_a(_bgCol));
		else DRAW_CLEAR
		
		if(_filD) {
			draw_primitive_begin_texture(pr_trianglelist, surface_get_texture_safe(_text));
			for( var i = 0, n = array_length(_tri); i < n; i++ ) {
				var t  = _tri[i];
				var p0 = _pnt[t[0]];
				var p1 = _pnt[t[1]];
				var p2 = _pnt[t[2]];
				
				if(_txMap == 0) {
					var u0 = p0.x / _dim[0], v0 = p0.y / _dim[1];
					var u1 = p1.x / _dim[0], v1 = p1.y / _dim[1];
					var u2 = p2.x / _dim[0], v2 = p2.y / _dim[1];
					
				} else {
					var u0 = p0[$ "u"] ?? 0, v0 = p0[$ "v"] ?? 0;
					var u1 = p1[$ "u"] ?? 0, v1 = p1[$ "v"] ?? 0;
					var u2 = p2[$ "u"] ?? 0, v2 = p2[$ "v"] ?? 0;
				}
				
				var _grc = _grad.evalFast(pfract(random(1) + _grdSh));
				var _col = colorMultiply(_colr, _grc);
				
				draw_vertex_texture_color(p0.x, p0.y, u0, v0, _col, _alph);
				draw_vertex_texture_color(p1.x, p1.y, u1, v1, _col, _alph);
				draw_vertex_texture_color(p2.x, p2.y, u2, v2, _col, _alph);
			}
			draw_primitive_end();
		}
		
		if(_outD) {
			var _outA = _color_get_a(_outC);
			
			draw_set_color_alpha(_outC, _outA);
			for( var i = 0, n = array_length(_tri); i < n; i++ ) {
				var t  = _tri[i];
				var p0 = _pnt[t[0]];
				var p1 = _pnt[t[1]];
				var p2 = _pnt[t[2]];
				
				if(_outT == 1) {
					draw_line(p0.x-1, p0.y-1, p1.x-1, p1.y-1);
					draw_line(p0.x-1, p0.y-1, p2.x-1, p2.y-1);
					draw_line(p2.x-1, p2.y-1, p1.x-1, p1.y-1);
					
				} else {
					draw_line_round(p0.x-1, p0.y-1, p1.x-1, p1.y-1, _outT);
					draw_line_round(p0.x-1, p0.y-1, p2.x-1, p2.y-1, _outT);
					draw_line_round(p2.x-1, p2.y-1, p1.x-1, p1.y-1, _outT);
					
				}
			}
			draw_set_alpha(1);
		}
		
		surface_reset_target();
		
		return _outSurf; 
	}
}