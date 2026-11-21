function Node_Mesh_Fill(_x, _y, _group = noone) : Node_Processor(_x, _y, _group) constructor {
	name = "Fill Mesh";
	
	newInput(12, nodeValue_Seed());
	
	////- =Output
	newInput( 1, nodeValue_Dimension());
	
	////- =Mesh
	newInput( 0, nodeValue_Mesh( "Mesh" )).setVisible(true, true).setRequired();
	newInput(14, nodeValue_Bool( "Quad", false ));
	
	////- =Rendering
	
		////- =/Fill
	newInput(10, nodeValue_Bool(     "Draw Fill",    true      ));
	newInput( 2, nodeValue_Color(    "Color",        ca_white  ));
	newInput(11, nodeValue_Gradient( "Random Color", gra_white )).addShift(13);
	
		////- =/Texture
	newInput( 5, nodeValue_Surface( "Texture" ));
	newInput( 6, nodeValue_EButton( "Mapping", 0, [ "Direct", "Mid Point", "Mesh UV" ] ));
	
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
		[ "Mesh",         false    ],  0, 14, 
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
			var _quad  = _data[14];
			
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
		var _qud = _mesh.quads;
		
		var _alph = _color_get_a(_colr);
		
		surface_set_target(_outSurf);
		if(_bgUse) draw_clear_alpha(_bgCol, _color_get_a(_bgCol));
		else DRAW_CLEAR
		
		if(_filD) {
			draw_primitive_begin_texture(pr_trianglelist, surface_get_texture_safe(_text));
			if(_quad && _qud != undefined) {
				for( var i = 0, n = array_length(_qud); i < n; i++ ) {
					var _grc = _grad.evalFast(pfract(random(1) + _grdSh));
					var _col = colorMultiply(_colr, _grc);
					
					var t0 = _tri[_qud[i][0]];
					var p0 = _pnt[t0[0]];
					var p1 = _pnt[t0[1]];
					var p2 = _pnt[t0[2]];
					
					var t1 = _tri[_qud[i][1]];
					var q0 = _pnt[t1[0]];
					var q1 = _pnt[t1[1]];
					var q2 = _pnt[t1[2]];
					
					var cx = (p0.x + p1.x + p2.x + q0.x + q1.x + q2.x) / 6 / _dim[0];
					var cy = (p0.y + p1.y + p2.y + q0.y + q1.y + q2.y) / 6 / _dim[1];
							
					switch(_txMap) {
						case 0 : 
							var u0 = p0.x / _dim[0], v0 = p0.y / _dim[1];
							var u1 = p1.x / _dim[0], v1 = p1.y / _dim[1];
							var u2 = p2.x / _dim[0], v2 = p2.y / _dim[1];
							break;
						
						case 1 : 
							var u0 = cx, v0 = cy;
							var u1 = cx, v1 = cy;
							var u2 = cx, v2 = cy;
							break;
							
						case 2 : 
							var u0 = p0[$ "u"] ?? 0, v0 = p0[$ "v"] ?? 0;
							var u1 = p1[$ "u"] ?? 0, v1 = p1[$ "v"] ?? 0;
							var u2 = p2[$ "u"] ?? 0, v2 = p2[$ "v"] ?? 0;
							break;
					}
					
					draw_vertex_texture_color(p0.x, p0.y, u0, v0, _col, _alph);
					draw_vertex_texture_color(p1.x, p1.y, u1, v1, _col, _alph);
					draw_vertex_texture_color(p2.x, p2.y, u2, v2, _col, _alph);
					
					switch(_txMap) {
						case 0 :
							var u0 = q0.x / _dim[0], v0 = q0.y / _dim[1];
							var u1 = q1.x / _dim[0], v1 = q1.y / _dim[1];
							var u2 = q2.x / _dim[0], v2 = q2.y / _dim[1];
							break;
						
						case 1 :
							var u0 = cx, v0 = cy;
							var u1 = cx, v1 = cy;
							var u2 = cx, v2 = cy;
							break;
						
						case 2 : 
							var u0 = q0[$ "u"] ?? 0, v0 = q0[$ "v"] ?? 0;
							var u1 = q1[$ "u"] ?? 0, v1 = q1[$ "v"] ?? 0;
							var u2 = q2[$ "u"] ?? 0, v2 = q2[$ "v"] ?? 0;
							break;
					}
					
					draw_vertex_texture_color(q0.x, q0.y, u0, v0, _col, _alph);
					draw_vertex_texture_color(q1.x, q1.y, u1, v1, _col, _alph);
					draw_vertex_texture_color(q2.x, q2.y, u2, v2, _col, _alph);
				}
				
			} else {
				for( var i = 0, n = array_length(_tri); i < n; i++ ) {
					var t  = _tri[i];
					var p0 = _pnt[t[0]];
					var p1 = _pnt[t[1]];
					var p2 = _pnt[t[2]];
					
					switch(_txMap) {
						case 0 :
							var u0 = p0.x / _dim[0], v0 = p0.y / _dim[1];
							var u1 = p1.x / _dim[0], v1 = p1.y / _dim[1];
							var u2 = p2.x / _dim[0], v2 = p2.y / _dim[1];
							break;
						
						case 1 : 
							var cx = (p0.x + p1.x + p2.x) / 3 / _dim[0];
							var cy = (p0.y + p1.y + p2.y) / 3 / _dim[1];
							
							var u0 = cx, v0 = cy;
							var u1 = cx, v1 = cy;
							var u2 = cx, v2 = cy;
							break;
							
						case 2 : 
							var u0 = p0[$ "u"] ?? 0, v0 = p0[$ "v"] ?? 0;
							var u1 = p1[$ "u"] ?? 0, v1 = p1[$ "v"] ?? 0;
							var u2 = p2[$ "u"] ?? 0, v2 = p2[$ "v"] ?? 0;
							break;
					}
					
					var _grc = _grad.evalFast(pfract(random(1) + _grdSh));
					var _col = colorMultiply(_colr, _grc);
					
					draw_vertex_texture_color(p0.x, p0.y, u0, v0, _col, _alph);
					draw_vertex_texture_color(p1.x, p1.y, u1, v1, _col, _alph);
					draw_vertex_texture_color(p2.x, p2.y, u2, v2, _col, _alph);
				}
			}
			draw_primitive_end();
		}
		
		if(_outD) {
			var _outA = _color_get_a(_outC);
			
			draw_set_color_alpha(_outC, _outA);
			if(_quad && _qud != undefined) {
				for( var i = 0, n = array_length(_qud); i < n; i++ ) {
					var t0 = _tri[_qud[i][0]];
					var t1 = _tri[_qud[i][1]];
					
					var p0 = _pnt[t0[0]];
					var p1 = _pnt[t0[1]];
					var p2 = _pnt[t0[2]];
					var p3;
					
					var q0 = _pnt[t1[0]];
					var q1 = _pnt[t1[1]];
					var q2 = _pnt[t1[2]];
					
					var s0, s1, s2, s3;
					
					     if(!q0.equal(p0) && !q0.equal(p1) && !q0.equal(p2)) { s0 = p0; s1 = p1; s2 = p2; s3 = q0; }
					else if(!q1.equal(p0) && !q1.equal(p1) && !q1.equal(p2)) { s0 = p0; s1 = p1; s2 = p2; s3 = q1; }
					else if(!q2.equal(p0) && !q2.equal(p1) && !q2.equal(p2)) { s0 = p0; s1 = p1; s2 = p2; s3 = q2; }
					
					cx = (s0.x + s1.x + s2.x + s3.x) / 4;
					cy = (s0.y + s1.y + s2.y + s3.y) / 4;
					
					var verts = [
					    { x: s0.x, y: s0.y },
					    { x: s1.x, y: s1.y },
					    { x: s2.x, y: s2.y },
					    { x: s3.x, y: s3.y }
					];
					
					array_sort(verts, function(a, b) /*=>*/ {
					    var angle_a = arctan2(a.y - cy, a.x - cx);
					    var angle_b = arctan2(b.y - cy, b.x - cx);
					    return angle_a - angle_b;
					});

					var v0 = verts[0];
					var v1 = verts[1];
					var v2 = verts[2];
					var v3 = verts[3];

					if(_outT == 1) {
						draw_line(v0.x-1, v0.y-1, v1.x-1, v1.y-1);
						draw_line(v1.x-1, v1.y-1, v2.x-1, v2.y-1);
						draw_line(v2.x-1, v2.y-1, v3.x-1, v3.y-1);
						draw_line(v3.x-1, v3.y-1, v0.x-1, v0.y-1);
						
					} else {
						draw_line_round(v0.x-1, v0.y-1, v1.x-1, v1.y-1, _outT);
						draw_line_round(v1.x-1, v1.y-1, v2.x-1, v2.y-1, _outT);
						draw_line_round(v2.x-1, v2.y-1, v3.x-1, v3.y-1, _outT);
						draw_line_round(v3.x-1, v3.y-1, v0.x-1, v0.y-1, _outT);
						
					}
				}
				
			} else {
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
			}
			draw_set_alpha(1);
		}
		
		surface_reset_target();
		
		return _outSurf; 
	}
}