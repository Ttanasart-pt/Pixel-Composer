function Node_Gradient_from_Surface(_x, _y, _group = noone) : Node_Processor(_x, _y, _group) constructor {
	name = "Gradient from Surface";
	draw_preview_junction = false;
	setDimension(96, 48);
	
	////- Surface
	newInput( 0, nodeValue_Surface("Surface In")).setRequired();
	
	////- Sampling
	newInput( 1, nodeValue_EScroll( "Type",    0, [ "Linear", "Path" ] ));
	newInput( 2, nodeValue_Vec2(    "Point 1", [0,.5] )).setUnitSimple();
	newInput( 3, nodeValue_Vec2(    "Point 2", [1,.5] )).setUnitSimple();
	newInput( 4, nodeValue_Path(    "Path"            ));
	newInput( 5, nodeValue_Int(     "Resolution", 8   ));
	newInput( 7, nodeValue_Bool(    "Remove Repeat", false ));
	
	////- Gradient
	newInput( 6, nodeValue_EButton( "Interpolation", 1,  ["None","RGB","HSV","OKLAB","sRGB"] ));
	// 8
	
	newOutput(0, nodeValue_Output("Gradient Out", VALUE_TYPE.gradient, new gradientObject()));
	
	input_display_list = [ 
		[ "Surface",  false ],  0,
		[ "Sampling", false ],  1,  2,  3,  4,  5,  7, 
		[ "Gradient", false ],  6,
	];
	
	////- Nodes
	
	static getDimension           = function() /*=>*/ {return surface_get_dimension(getInputData(0))}; 
	static getPreviewValues       = function() /*=>*/ {return getInputData(0)}; 
	static getGraphPreviewSurface = function() /*=>*/ {return getInputData(0)}; 
	
	static drawOverlay = function(hover, active, _x, _y, _s, _mx, _my, _params) { 
		var _type = getInputSingle( 1);
		
		switch(_type) {
			case 0 :
				var _pnt1 = getInputSingle( 2);
				var _pnt2 = getInputSingle( 3);
				
				var _p0x = _x + _pnt1[0] * _s;
				var _p0y = _y + _pnt1[1] * _s;
				
				var _p1x = _x + _pnt2[0] * _s;
				var _p1y = _y + _pnt2[1] * _s;
				
				draw_set_color(COLORS._main_accent);
				draw_line_dashed(_p0x, _p0y, _p1x, _p1y);
				
				drawOverlayInput(inputs[ 2].drawOverlay(hover, active, _x, _y, _s, _mx, _my, 1));
				drawOverlayInput(inputs[ 3].drawOverlay(hover, active, _x, _y, _s, _mx, _my, 1));
				break;
				
			case 1 :
				drawOverlayInput(inputs[ 4].drawOverlay(hover, active, _x, _y, _s, _mx, _my, _params));
				break;
		}
	}
	
	static processData = function(_outGrad, _data, _array_index = 0) { 
		#region data
			var _surf = _data[ 0];
			
			var _type = _data[ 1];
			var _pnt1 = _data[ 2];
			var _pnt2 = _data[ 3];
			var _path = _data[ 4];
			var _reso = _data[ 5]; _reso = max(1, _reso);
			var _remv = _data[ 7];
			
			var _intp = _data[ 6];
			
			inputs[ 2].setVisible(_type == 0);
			inputs[ 3].setVisible(_type == 0);
			inputs[ 4].setVisible(_type == 1, _type == 1);
			
			if(!is_surface(_surf)) return _outGrad;
		#endregion
		
		var keys = [];
		
		var sw = surface_get_width(_surf);
		var sh = surface_get_height(_surf);
		var oc, nc;
		
		switch(_type) {
			case 0 :
				for( var i = 0; i < _reso; i++ ) {
					var t  = i / max(0, _reso - 1);	
					var sx = lerp(_pnt1[0], _pnt2[0], t);
					var sy = lerp(_pnt1[1], _pnt2[1], t);
					
					sx = clamp(sx, 0, sw - 1);
					sy = clamp(sy, 0, sh - 1);
					nc = surface_getpixel_ext(_surf, sx, sy);
					
					if(i && _remv && nc == oc) continue;
					array_push(keys, new gradientKey(t, nc));
					oc = nc;
				}
				break;
			
			case 1 :
				if(!is_path(_path)) break;
				
				var __p = new __vec2P();
				
				for( var i = 0; i < _reso; i++ ) {
					var t  = i / max(0, _reso);	
					__p = _path.getPointRatio(t, 0, __p);
					
					var sx = __p.x;
					var sy = __p.y;
					
					sx = clamp(sx, 0, sw - 1);
					sy = clamp(sy, 0, sh - 1);
					nc = surface_getpixel_ext(_surf, sx, sy);
					
					if(i && _remv && nc == oc) continue;
					array_push(keys, new gradientKey(t, nc));
					oc = nc;
				}
				break;
				
		}
		
		_outGrad.keys = keys;
		
		switch(_intp) {
			case 0 : _outGrad.type = GRADIENT_INTER.none;	break;
			case 1 : _outGrad.type = GRADIENT_INTER.smooth; break;
			case 2 : _outGrad.type = GRADIENT_INTER.hue;	break;
			case 3 : _outGrad.type = GRADIENT_INTER.oklab;	break;
			case 4 : _outGrad.type = GRADIENT_INTER.srgb;	break;
		}
		
		
		return _outGrad; 
	}
	
	////- Draw
	
	static onDrawNode = function(xx, yy, _mx, _my, _s, _hover, _focus) {
		var bbox = draw_bbox;
		if(bbox.h < 1) return;
		
		var grad = outputs[0].getValue();
		if(!is_array(grad)) grad = [ grad ];
		
		var _y = bbox.y0;
		var gh = bbox.h / array_length(grad);
			
		for( var i = 0, n = array_length(grad); i < n; i++ ) {
			grad[i].draw(bbox.x0, _y, bbox.w, gh);
			_y += gh;
		}
	}
}
