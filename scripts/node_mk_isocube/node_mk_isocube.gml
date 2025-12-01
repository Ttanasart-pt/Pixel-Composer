function Node_MK_IsoCube(_x, _y, _group = noone) : Node_Processor(_x, _y, _group) constructor {
	name = "MK IsoCube";
	dimension_index = noone;
	
	////- =Output
	newInput( 7, nodeValue_Padding( "Padding", [0,0,0,0] ));
	
	////- =Shape
	newInput( 0, nodeValue_Vec2( "Base",           [8,8]     ));
	newInput( 8, nodeValue_Vec4( "Base Offset",    [0,0,0,0] ));
	newInput(19, nodeValue_Bool( "Base Expand",    true      ));
	
	////- =Depth
	newInput( 1, nodeValue_Int(  "Depth",           6        ));
	newInput( 2, nodeValue_Vec4( "Depth Offsets",  [0,0,0,0] ));
	newInput( 3, nodeValue_Int(  "Depth Ref.",      0        ));
	
	////- =Texture
	newInput( 6, nodeValue_Surface( "Texture Top",   0 ));
	newInput( 4, nodeValue_Surface( "Texture Left",  0 ));
	newInput( 5, nodeValue_Surface( "Texture Right", 0 ));
	
	////- =Colors
	newInput( 9, nodeValue_Color( "Color Top",   ca_white ));
	newInput(10, nodeValue_Color( "Color Left",  ca_white ));
	newInput(11, nodeValue_Color( "Color Right", ca_white ));
	
	////- =Outline
	newInput(12, nodeValue_Bool(  "Outline",           false    ));
	newInput(13, nodeValue_Int(   "Top Thickness",     1        ));
	newInput(14, nodeValue_Color( "Top Color",         ca_white ));
	newInput(15, nodeValue_Int(   "Front Thickness",   1        ));
	newInput(16, nodeValue_Color( "Front Color",       ca_white ));
	newInput(17, nodeValue_Int(   "Outside Thickness", 0        ));
	newInput(18, nodeValue_Color( "Outside Color",     ca_white ));
	// inputs 20
		
	input_display_list = [ new Inspector_Sprite(s_MKFX), 
		[ "Output",  false ], 7, 
		[ "Shape",   false ], 0, 8, 19, 
		[ "Depth",   false ], 1, 2, 3, 
		[ "Texture", false ], 6, 4, 5, 
		[ "Colors",  false ], 9, 10, 11, 
		[ "Outlines", true, 12 ], 13, 14, 15, 16, 17, 18, 
	];
	
	newOutput(0, nodeValue_Output("Surface Out", VALUE_TYPE.surface, noone));
	newOutput(1, nodeValue_Output("Depth",       VALUE_TYPE.surface, noone));
	
	////- Nodes
	
	corner_dragging = 0;
	corner_drag_sv  = [];
	corner_drag_my  = 0;
	
	temp_surface = [ noone ];
	
	function X(_x) { return __x + _x * __s; }
	function Y(_y) { return __y + _y * __s; }
	
	static drawOverlay = function(hover, active, _x, _y, _s, _mx, _my, _snx, _sny, _params) { 
		draw_set_color(COLORS._main_accent);
		
		var _base  = getSingleValue(0);
		var _basOf = getSingleValue(8);
		
		var _dept  = getSingleValue(1);
		var _depOf = getSingleValue(2);
		var _depRf = getSingleValue(3);
		
		var _padd  = getSingleValue(7);
		
		__x = _x + _padd[2] * _s; 
		__y = _y + _padd[1] * _s; 
		__s = _s;
		
		var n  = _base[0];
		var m  = _base[1];
		var d  = _dept;
		var h  = _depRf == 0? _dept : _depRf;
		
		var b0 = _basOf[0];
		var b1 = _basOf[1];
		var b2 = _basOf[2];
		var b3 = _basOf[3];
		
		var b0x = 0;
		var b0y = n / 2 + h;
		
		var b1x = n;
		var b1y = h;
		
		var b2x = m;
		var b2y = (n + m) / 2 + h;
		
		var b3x = n + m;
		var b3y = m / 2 + h;
		
		draw_line_dashed(X(b0x), Y(b0y), X(b1x), Y(b1y));
		draw_line_dashed(X(b1x), Y(b1y), X(b3x), Y(b3y));
		draw_line_dashed(X(b3x), Y(b3y), X(b2x), Y(b2y));
		draw_line_dashed(X(b2x), Y(b2y), X(b0x), Y(b0y));
		
		b0x += + b0                 + b3   
		b0y += - b0/2               + b3/2 
		
		b1x +=               - b2   + b3    
		b1y +=               + b2/2 + b3/2 
		
		b2x += + b0   - b1           
		b2y += - b0/2 - b1/2         
		
		b3x +=        - b1   - b2   
		b3y +=        - b1/2 + b2/2 
		
		var d0 = d + _depOf[0];
		var d1 = d + _depOf[1];
		var d2 = d + _depOf[2];
		var d3 = d + _depOf[3];
		
		var t0x = b0x;
		var t0y = b0y - d0;
		
		var t1x = b1x;
		var t1y = b1y - d1;

		var t2x = b2x;
		var t2y = b2y - d2;
		
		var t3x = b3x;
		var t3y = b3y - d3;
		
		draw_set_color(COLORS._main_accent);
		
		draw_line_dashed(X(b0x), Y(b0y), X(b1x), Y(b1y));
		draw_line_dashed(X(b1x), Y(b1y), X(b3x), Y(b3y));
		draw_line_dashed(X(b3x), Y(b3y), X(b2x), Y(b2y));
		draw_line_dashed(X(b2x), Y(b2y), X(b0x), Y(b0y));
		
		draw_line_dashed(X(t0x), Y(t0y), X(b0x), Y(b0y));
		draw_line_dashed(X(t1x), Y(t1y), X(b1x), Y(b1y));
		draw_line_dashed(X(t3x), Y(t3y), X(b3x), Y(b3y));
		draw_line_dashed(X(t2x), Y(t2y), X(b2x), Y(b2y));
		
		var _hov = 0;
		
		if(hover) {
			if(distance_to_line(_mx, _my, X(t0x), Y(t0y), X(t1x), Y(t1y)) < ui(10)) _hov = 0b0011;
			if(distance_to_line(_mx, _my, X(t1x), Y(t1y), X(t3x), Y(t3y)) < ui(10)) _hov = 0b1010;
			if(distance_to_line(_mx, _my, X(t3x), Y(t3y), X(t2x), Y(t2y)) < ui(10)) _hov = 0b1100;
			if(distance_to_line(_mx, _my, X(t2x), Y(t2y), X(t0x), Y(t0y)) < ui(10)) _hov = 0b0101;
			
			if(point_distance(_mx, _my, X(t0x), Y(t0y)) < ui(10)) _hov = 0b0001;
			if(point_distance(_mx, _my, X(t1x), Y(t1y)) < ui(10)) _hov = 0b0010;
			if(point_distance(_mx, _my, X(t2x), Y(t2y)) < ui(10)) _hov = 0b0100;
			if(point_distance(_mx, _my, X(t3x), Y(t3y)) < ui(10)) _hov = 0b1000;
		}
		
		if(corner_dragging != 0) _hov = corner_dragging;
		
		draw_line_width(X(t0x), Y(t0y), X(t1x), Y(t1y), 2 + (_hov == 0b0011) * 2);
		draw_line_width(X(t1x), Y(t1y), X(t3x), Y(t3y), 2 + (_hov == 0b1010) * 2);
		draw_line_width(X(t3x), Y(t3y), X(t2x), Y(t2y), 2 + (_hov == 0b1100) * 2);
		draw_line_width(X(t2x), Y(t2y), X(t0x), Y(t0y), 2 + (_hov == 0b0101) * 2);
		
		draw_anchor(bool(_hov & 0b0001), X(t0x), Y(t0y), ui(8), 2);
		draw_anchor(bool(_hov & 0b0010), X(t1x), Y(t1y), ui(8), 2);
		draw_anchor(bool(_hov & 0b0100), X(t2x), Y(t2y), ui(8), 2);
		draw_anchor(bool(_hov & 0b1000), X(t3x), Y(t3y), ui(8), 2);
		
		if(corner_dragging == 0) {
			if(_hov != 0 && mouse_lpress(active)) {
				corner_dragging = _hov;
				corner_drag_sv  = [_depOf[0], _depOf[1], _depOf[2], _depOf[3]];
				corner_drag_my  = _my;
			}
			
		} else {
			var _dd = [corner_drag_sv[0], corner_drag_sv[1], corner_drag_sv[2], corner_drag_sv[3]];
			var _dy = (corner_drag_my - _my) / _s;
			
			for( var i = 0; i < 4; i++ ) {
				if((corner_dragging & 1 << i) == 0) continue;
				
				_dd[i] = corner_drag_sv[i] + _dy;
				if(key_mod_press(CTRL)) _dd[i] = round(_dd[i]);
			}
			
			if(inputs[2].setValue(_dd)) UNDO_HOLDING = true;
			
			if(mouse_lrelease()) {
				corner_dragging = 0;
				UNDO_HOLDING    = false;
			}
		}
		
		return _hov;
	}
	
	static draw_rectangle_primitive = function(x0, y0, x1, y1, x2, y2, x3, y3, ox, oy, _surf, _blend) {
		var _alpha = color_get_alpha(_blend);
		
		if(surface_exists(_surf)) 
			draw_primitive_begin_texture(pr_trianglelist, surface_get_texture(_surf));
		else 
			draw_primitive_begin(pr_trianglelist);
		
		draw_vertex_texture_color(x0 + ox, y0 + oy, 0, 1, _blend, _alpha);
		draw_vertex_texture_color(x1 + ox, y1 + oy, 0, 0, _blend, _alpha);
		draw_vertex_texture_color(x2 + ox, y2 + oy, 1, 1, _blend, _alpha);
		
		draw_vertex_texture_color(x1 + ox, y1 + oy, 0, 0, _blend, _alpha);
		draw_vertex_texture_color(x2 + ox, y2 + oy, 1, 1, _blend, _alpha);
		draw_vertex_texture_color(x3 + ox, y3 + oy, 1, 0, _blend, _alpha);
		
		draw_primitive_end();
	}
	
	static draw_rectangle_primitive_color = function(x0, y0, x1, y1, x2, y2, x3, y3, ox, oy, c0, c1, c2, c3) {
		draw_primitive_begin(pr_trianglelist);
		
		draw_vertex_texture_color(x0 + ox, y0 + oy, 0, 1, c0, 1);
		draw_vertex_texture_color(x1 + ox, y1 + oy, 0, 0, c1, 1);
		draw_vertex_texture_color(x2 + ox, y2 + oy, 1, 1, c2, 1);
		
		draw_vertex_texture_color(x1 + ox, y1 + oy, 0, 0, c1, 1);
		draw_vertex_texture_color(x2 + ox, y2 + oy, 1, 1, c2, 1);
		draw_vertex_texture_color(x3 + ox, y3 + oy, 1, 0, c3, 1);
		
		draw_primitive_end();
	}
	
	static processData = function(_outData, _data, _array_index) {
		#region data
			var _padd  = _data[ 7];
			
			var _base  = _data[ 0];
			var _basOf = _data[ 8];
			var _basEx = _data[19];
			
			var _dept  = _data[ 1];
			var _depOf = _data[ 2];
			var _depRf = _data[ 3];
			
			var _texT  = _data[ 6]; 
			var _texL  = _data[ 4];
			var _texR  = _data[ 5]; 
			
			var _colT  = _data[ 9]; 
			var _colL  = _data[10]; 
			var _colR  = _data[11]; 
			
			var _out   = _data[12]; 
			var _outTT = _data[13]; 
			var _outTC = _data[14]; 
			var _outFT = _data[15]; 
			var _outFC = _data[16]; 
			var _outOT = _data[17]; 
			var _outOC = _data[18]; 
			
			if(!is_surface(_texR)) _texR = _texL;
			
			temp_surface[0] = surface_verify(temp_surface[0], 2, 2);
			surface_clear(temp_surface[0], c_white, 1);
			
			if(!is_surface(_texL)) _texL = temp_surface[0];
			if(!is_surface(_texR)) _texR = temp_surface[0];
			if(!is_surface(_texT)) _texT = temp_surface[0];
		#endregion
		
		var n  = _base[0];
		var m  = _base[1];
		var d  = _dept;
		var h  = _depRf == 0? _dept : _depRf;
		
		var b0 = _basOf[0];
		var b1 = _basOf[1];
		var b2 = _basOf[2];
		var b3 = _basOf[3];
		
		var b0x = 0                + b0                 + b3   
		var b0y = n / 2 + h        - b0/2               + b3/2 
		
		var b1x = n                              - b2   + b3    
		var b1y = h                              + b2/2 + b3/2 
		
		var b2x = m                + b0   - b1           
		var b2y = (n + m) / 2 + h  - b0/2 - b1/2         
		
		var b3x = n + m                   - b1   - b2   
		var b3y = m / 2 + h               - b1/2 + b2/2 
		
		var d0 = d + _depOf[0];
		var d1 = d + _depOf[1];
		var d2 = d + _depOf[2];
		var d3 = d + _depOf[3];
		
		var t0x = b0x;
		var t0y = b0y - d0;
		
		var t1x = b1x;
		var t1y = b1y - d1;

		var t2x = b2x;
		var t2y = b2y - d2;
		
		var t3x = b3x;
		var t3y = b3y - d3;
		
		////////////////////////////
		
		var sw = n + m;
		var sh = (n + m) / 2 + h;
		
		var ssw = sw + _padd[0] + _padd[2];
		var ssh = sh + _padd[1] + _padd[3];
		
		var ox = _padd[2];
		var oy = _padd[1];
		
		_outData[0] = surface_verify(_outData[0], ssw, ssh);
		_outData[1] = surface_verify(_outData[1], ssw, ssh);
		
		surface_set_target(_outData[0]);
			DRAW_CLEAR
			
			draw_rectangle_primitive(b0x, b0y, t0x, t0y, b2x, b2y, t2x, t2y, ox, oy, _texL, _colL);
			draw_rectangle_primitive(b2x, b2y, t2x, t2y, b3x, b3y, t3x, t3y, ox, oy, _texR, _colR);
			
			if(_basEx && _base[0] % 2 == 0 && _base[1] % 2 == 0) {
				var _alpha = color_get_alpha(_colT);
				draw_primitive_begin_texture(pr_trianglelist, surface_get_texture(_texT));
				
				draw_vertex_texture_color(t0x + ox, t0y + oy, 0, 1, _colT, _alpha);
				draw_vertex_texture_color(t1x + ox, t1y + oy, 0, 0, _colT, _alpha);
				draw_vertex_texture_color(t2x + ox, t2y + oy, 1, 1, _colT, _alpha);
				
				draw_vertex_texture_color(t0x + ox - 1, t0y + oy, 0, 1, _colT, _alpha);
				draw_vertex_texture_color(t1x + ox - 1, t1y + oy, 0, 0, _colT, _alpha);
				draw_vertex_texture_color(t2x + ox - 1, t2y + oy, 1, 1, _colT, _alpha);
				
				draw_vertex_texture_color(t1x + ox, t1y + oy, 0, 0, _colT, _alpha);
				draw_vertex_texture_color(t2x + ox, t2y + oy, 1, 1, _colT, _alpha);
				draw_vertex_texture_color(t3x + ox, t3y + oy, 1, 0, _colT, _alpha);
				
				draw_vertex_texture_color(t1x + ox + 1, t1y + oy, 0, 0, _colT, _alpha);
				draw_vertex_texture_color(t2x + ox + 1, t2y + oy, 1, 1, _colT, _alpha);
				draw_vertex_texture_color(t3x + ox + 1, t3y + oy, 1, 0, _colT, _alpha);
				
				draw_primitive_end();
				
			} else 
				draw_rectangle_primitive(t0x, t0y, t1x, t1y, t2x, t2y, t3x, t3y, ox, oy, _texT, _colT);
			
			if(_out) {
				gpu_set_blendmode_ext_sepalpha(bm_src_alpha, bm_inv_src_alpha, bm_one, bm_one);
				
				if(_outTT) { // Top
					draw_set_color_alpha(_outTC, _color_get_alpha(_outTC));
					draw_line_round(t0x-1 + ox, t0y-1 + oy, t2x-1 + ox, t2y-1 + oy, _outTT);
					draw_line_round(t3x-1 + ox, t3y-1 + oy, t2x-1 + ox, t2y-1 + oy, _outTT);
				}
				
				if(_outFT) { // Front
					draw_set_color_alpha(_outFC, _color_get_alpha(_outFC));
					draw_line_round(t2x-1 + ox, t2y-1 + oy, b2x-1 + ox, b2y-1 + oy, _outFT);
				}
				
				if(_outOT) { // Outside
					draw_set_color_alpha(_outOC, _color_get_alpha(_outOC));
					draw_line_round(t0x-1 + ox, t0y-1 + oy, t1x-1 + ox, t1y-1 + oy, _outOT);
					draw_line_round(t1x-1 + ox, t1y-1 + oy, t3x-1 + ox, t3y-1 + oy, _outOT);
					draw_line_round(t3x-1 + ox, t3y-1 + oy, b3x-1 + ox, b3y-1 + oy, _outOT);
					draw_line_round(b3x-1 + ox, b3y-1 + oy, b2x-1 + ox, b2y-1 + oy, _outOT);
					draw_line_round(b2x-1 + ox, b2y-1 + oy, b0x-1 + ox, b0y-1 + oy, _outOT);
					draw_line_round(t0x-1 + ox, t0y-1 + oy, b0x-1 + ox, b0y-1 + oy, _outOT);
				}
				
				color_get_alpha(1);
				BLEND_NORMAL
			}
		surface_reset_target();
		
		surface_set_target(_outData[1]);
			draw_clear(c_white);
			
			draw_rectangle_primitive_color(b0x, b0y, t0x, t0y, b2x, b2y, t2x, t2y, ox, oy, c_white, c_black, c_white, c_black);
			draw_rectangle_primitive_color(b2x, b2y, t2x, t2y, b3x, b3y, t3x, t3y, ox, oy, c_white, c_black, c_white, c_black);
			
			if(_basEx && _base[0] % 2 == 0 && _base[1] % 2 == 0) {
				draw_primitive_begin(pr_trianglelist);
				
				draw_vertex_texture_color(t0x + ox, t0y + oy, 0, 1, c_black, 1);
				draw_vertex_texture_color(t1x + ox, t1y + oy, 0, 0, c_black, 1);
				draw_vertex_texture_color(t2x + ox, t2y + oy, 1, 1, c_black, 1);
				
				draw_vertex_texture_color(t0x + ox - 1, t0y + oy, 0, 1, c_black, 1);
				draw_vertex_texture_color(t1x + ox - 1, t1y + oy, 0, 0, c_black, 1);
				draw_vertex_texture_color(t2x + ox - 1, t2y + oy, 1, 1, c_black, 1);
				
				draw_vertex_texture_color(t1x + ox, t1y + oy, 0, 0, c_black, 1);
				draw_vertex_texture_color(t2x + ox, t2y + oy, 1, 1, c_black, 1);
				draw_vertex_texture_color(t3x + ox, t3y + oy, 1, 0, c_black, 1);
				
				draw_vertex_texture_color(t1x + ox + 1, t1y + oy, 0, 0, c_black, 1);
				draw_vertex_texture_color(t2x + ox + 1, t2y + oy, 1, 1, c_black, 1);
				draw_vertex_texture_color(t3x + ox + 1, t3y + oy, 1, 0, c_black, 1);
				
				draw_primitive_end();
				
			} else 
				draw_rectangle_primitive_color(t0x, t0y, t1x, t1y, t2x, t2y, t3x, t3y, ox, oy, 0, 0, 0, 0);
			
		surface_reset_target();
		
		return _outData;
	}
}