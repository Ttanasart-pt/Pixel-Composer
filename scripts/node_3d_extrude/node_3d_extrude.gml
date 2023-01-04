function Node_3D_Extrude(_x, _y, _group = -1) : Node_Processor(_x, _y, _group) constructor {
	name = "3D Extrude";
	
	inputs[| 0] = nodeValue(0, "Surface in", self, JUNCTION_CONNECT.input, VALUE_TYPE.surface, noone);
	
	inputs[| 1] = nodeValue(1, "Dimension", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, def_surf_size2)
		.setDisplay(VALUE_DISPLAY.vector);
	
	inputs[| 2] = nodeValue(2, "Object position", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, [ 0, 0, 0 ])
		.setDisplay(VALUE_DISPLAY.vector);
	
	inputs[| 3] = nodeValue(3, "Object rotation", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, [ 0, 0, 0 ])
		.setDisplay(VALUE_DISPLAY.vector);
	
	inputs[| 4] = nodeValue(4, "Object scale", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, [ 1, 1, 0.1 ])
		.setDisplay(VALUE_DISPLAY.vector);
	
	inputs[| 5] = nodeValue(5, "Render position", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, [ def_surf_size / 2, def_surf_size / 2 ])
		.setDisplay(VALUE_DISPLAY.vector)
		.setUnitRef( function() { return inputs[| 1].getValue(); });
		
	inputs[| 6] = nodeValue(6, "Render rotation", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, [ 0, 0, 0 ])
		.setDisplay(VALUE_DISPLAY.vector);
	
	inputs[| 7] = nodeValue(7, "Render scale", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, [ 1, 1 ])
		.setDisplay(VALUE_DISPLAY.vector);
	
	inputs[| 8] = nodeValue(8, "Manual generate", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, 0)
		.setDisplay(VALUE_DISPLAY.button, [ function() {
			generateMesh();
			update();
		}, "Generate"] );
		
	inputs[| 9] = nodeValue(9, "Light direction", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, 0)
		.setDisplay(VALUE_DISPLAY.rotation);
		
	inputs[| 10] = nodeValue(10, "Light height", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, 0.5)
		.setDisplay(VALUE_DISPLAY.slider, [-1, 1, 0.01]);
		
	inputs[| 11] = nodeValue(11, "Light intensity", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, 1)
		.setDisplay(VALUE_DISPLAY.slider, [0, 1, 0.01]);
	
	inputs[| 12] = nodeValue(12, "Light color", self, JUNCTION_CONNECT.input, VALUE_TYPE.color, c_white);
	inputs[| 13] = nodeValue(13, "Ambient color", self, JUNCTION_CONNECT.input, VALUE_TYPE.color, c_grey);
	
	inputs[| 14] = nodeValue(14, "Height map", self, JUNCTION_CONNECT.input, VALUE_TYPE.surface, noone);
	
	inputs[| 15] = nodeValue(15, "Always update", self, JUNCTION_CONNECT.input, VALUE_TYPE.boolean, false);
	
	input_display_list = [1, 
		["Geometry",		 false], 0, 12, 8, 14,
		["Object transform", false], 2, 3, 4,
		["Render",			 false], 5, 7, 15,
		["Light",			 false], 9, 10, 11, 12, 13,
	];
	
	outputs[| 0] = nodeValue(0, "Surface out", self, JUNCTION_CONNECT.output, VALUE_TYPE.surface, PIXEL_SURFACE);
	
	outputs[| 1] = nodeValue(1, "3D object", self, JUNCTION_CONNECT.output, VALUE_TYPE.d3object, function(index) { return submit_vertex(index); });
	
	_3d_node_init(1, /*Transform*/ 5, 3, 7);
	
	VB = [];
	VB[0] = vertex_create_buffer();
	vertex_begin(VB[0], FORMAT_PT);
	vertex_end(VB[0]);
	
	static onValueUpdateFrom = function(index) {
		if(index == 0 || index == 14) 
			generateMesh();
	}
	
	static getHeight = function(h, gw, gh, i, j) {
		var _i = round(i * gw);
		var _j = round(j * gh);
		
		_i = clamp(_i, 0, array_length(h) - 1);
		_j = clamp(_j, 0, array_length(h[_i]) - 1);
		
		return h[_i][_j];
	}
	
	static generateMesh = function() {
		var _ins = inputs[| 0].getValue();
		if(!is_array(_ins)) _ins = [ _ins ];
		
		for( var i = 0; i < array_length(_ins); i++ ) {
			VB[i] = generateMeshIndex(i);
		}
	}
		
	static generateMeshIndex = function(index) {
		var _ins = getSingleValue( 0, index);
		var _hei = getSingleValue(12, index);
		if(!is_surface(_ins)) return;
		
		var ww = surface_get_width(_ins);
		var hh = surface_get_height(_ins);
		var tw = 1 / ww;
		var th = 1 / hh;
		var sw = -ww / 2 * tw;
		var sh = -hh / 2 * th;
		var useH = is_surface(_hei);
		
		if(useH) {
			var hgw = surface_get_width(_hei);
			var hgh = surface_get_height(_hei);
			var hgtW = hgw / ww;
			var hgtH = hgh / hh;
			
			var height_buffer = buffer_create(hgw * hgh * 4, buffer_fixed, 2);
			buffer_get_surface(height_buffer, _hei, 0);
			buffer_seek(height_buffer, buffer_seek_start, 0);
			
			var hei = array_create(hgw, hgh);
			
			for( var j = 0; j < hgh; j++ )
			for( var i = 0; i < hgw; i++ ) {
				var cc = buffer_read(height_buffer, buffer_u32);
				var _b = colorBrightness(cc & ~0b11111111);
				hei[i][j] = _b;
			}
			
			buffer_delete(height_buffer);
		}
		
		var surface_buffer = buffer_create(ww * hh * 4, buffer_fixed, 2);
		buffer_get_surface(surface_buffer, _ins, 0);
		buffer_seek(surface_buffer, buffer_seek_start, 0);
		
		var VB = vertex_create_buffer();
		vertex_begin(VB, FORMAT_PNT);
		var ap = array_create(ww, hh);
		
		for( var j = 0; j < hh; j++ )
		for( var i = 0; i < ww; i++ ) {
			var cc = buffer_read(surface_buffer, buffer_u32);
			var _a = (cc & (0b11111111 << 24)) >> 24;
			ap[i][j] = _a;
		}
		
		buffer_delete(surface_buffer);
		
		for( var i = 0; i < ww; i++ )
		for( var j = 0; j < hh; j++ ) {
			if(ap[i][j] == 0) continue;
			
			var i0 = sw + i * tw, i1 = i0 + tw;
			var j0 = sh + j * th, j1 = j0 + th;
			var tx0 = tw * i, tx1 = tx0 + tw;
			var ty0 = th * j, ty1 = ty0 + th;
			
			var dep = (useH? getHeight(hei, hgtW, hgtH, i, j) : 1) * 0.5;
			
			vertex_add_pnt(VB, [i1, j0, -dep], [0, 0, -1], [tx1, ty0]);
			vertex_add_pnt(VB, [i0, j0, -dep], [0, 0, -1], [tx0, ty0]);
			vertex_add_pnt(VB, [i1, j1, -dep], [0, 0, -1], [tx1, ty1]);
						    		
			vertex_add_pnt(VB, [i1, j1, -dep], [0, 0, -1], [tx1, ty1]);
			vertex_add_pnt(VB, [i0, j0, -dep], [0, 0, -1], [tx0, ty0]);
			vertex_add_pnt(VB, [i0, j1, -dep], [0, 0, -1], [tx0, ty1]);
			
			vertex_add_pnt(VB, [i1, j0,  dep], [0, 0, 1], [tx1, ty0]);
			vertex_add_pnt(VB, [i0, j0,  dep], [0, 0, 1], [tx0, ty0]);
			vertex_add_pnt(VB, [i1, j1,  dep], [0, 0, 1], [tx1, ty1]);
						    		    
			vertex_add_pnt(VB, [i1, j1,  dep], [0, 0, 1], [tx1, ty1]);
			vertex_add_pnt(VB, [i0, j0,  dep], [0, 0, 1], [tx0, ty0]);
			vertex_add_pnt(VB, [i0, j1,  dep], [0, 0, 1], [tx0, ty1]);
			
			if((useH && dep * 2 > getHeight(hei, hgtW, hgtH, i, j - 1)) || (j == 0 || ap[i][j - 1] == 0)) {
				vertex_add_pnt(VB, [i0, j0,  dep], [0, -1, 0], [tx1, ty0]);
				vertex_add_pnt(VB, [i0, j0, -dep], [0, -1, 0], [tx0, ty0]);
				vertex_add_pnt(VB, [i1, j0,  dep], [0, -1, 0], [tx1, ty1]);
						    		    
				vertex_add_pnt(VB, [i0, j0, -dep], [0, -1, 0], [tx1, ty1]);
				vertex_add_pnt(VB, [i1, j0, -dep], [0, -1, 0], [tx0, ty0]);
				vertex_add_pnt(VB, [i1, j0,  dep], [0, -1, 0], [tx0, ty1]);
			}
			
			if((useH && dep * 2 > getHeight(hei, hgtW, hgtH, i, j + 1)) || (j == hh - 1 || ap[i][j + 1] == 0)) {
				vertex_add_pnt(VB, [i0, j1,  dep], [0, 1, 0], [tx1, ty0]);
				vertex_add_pnt(VB, [i0, j1, -dep], [0, 1, 0], [tx0, ty0]);
				vertex_add_pnt(VB, [i1, j1,  dep], [0, 1, 0], [tx1, ty1]);
						    		    
				vertex_add_pnt(VB, [i0, j1, -dep], [0, 1, 0], [tx1, ty1]);
				vertex_add_pnt(VB, [i1, j1, -dep], [0, 1, 0], [tx0, ty0]);
				vertex_add_pnt(VB, [i1, j1,  dep], [0, 1, 0], [tx0, ty1]);
			}
			
			if((useH && dep * 2 > getHeight(hei, hgtW, hgtH, i - 1, j)) || (i == 0 || ap[i - 1][j] == 0)) {
				vertex_add_pnt(VB, [i0, j0,  dep], [1, 0, 0], [tx1, ty0]);
				vertex_add_pnt(VB, [i0, j0, -dep], [1, 0, 0], [tx0, ty0]);
				vertex_add_pnt(VB, [i0, j1,  dep], [1, 0, 0], [tx1, ty1]);
						    		    
				vertex_add_pnt(VB, [i0, j0, -dep], [1, 0, 0], [tx1, ty1]);
				vertex_add_pnt(VB, [i0, j1, -dep], [1, 0, 0], [tx0, ty0]);
				vertex_add_pnt(VB, [i0, j1,  dep], [1, 0, 0], [tx0, ty1]);
			}
			
			if((useH && dep * 2 > getHeight(hei, hgtW, hgtH, i + 1, j)) || (i == ww - 1 || ap[i + 1][j] == 0)) {
				vertex_add_pnt(VB, [i1, j0,  dep], [-1, 0, 0], [tx1, ty0]);
				vertex_add_pnt(VB, [i1, j0, -dep], [-1, 0, 0], [tx0, ty0]);
				vertex_add_pnt(VB, [i1, j1,  dep], [-1, 0, 0], [tx1, ty1]);
						    		    
				vertex_add_pnt(VB, [i1, j0, -dep], [-1, 0, 0], [tx1, ty1]);
				vertex_add_pnt(VB, [i1, j1, -dep], [-1, 0, 0], [tx0, ty0]);
				vertex_add_pnt(VB, [i1, j1,  dep], [-1, 0, 0], [tx0, ty1]);
			}
		}
		vertex_end(VB);
		return VB;
	}
	
	static drawOverlay = function(active, _x, _y, _s, _mx, _my, _snx, _sny) {
		_3d_gizmo(active, _x, _y, _s, _mx, _my, _snx, _sny);
	}
	
	static submit_vertex = function(index) {
		var _ins  = getSingleValue(0, index);
		if(!is_surface(_ins)) return;
		
		var _lpos = getSingleValue(2, index);
		var _lrot = getSingleValue(3, index);
		var _lsca = getSingleValue(4, index);
		
		_3d_local_transform(_lpos, _lrot, _lsca);
		vertex_submit(VB[index], pr_trianglelist, surface_get_texture(_ins));
		_3d_clear_local_transform();
	}
	
	static process_data = function(_outSurf, _data, _output_index, _array_index) {
		var _ins  = _data[ 0];
		var _dim  = _data[ 1];
		var _lpos = _data[ 2];
		var _lrot = _data[ 3];
		var _lsca = _data[ 4];
		
		var _pos  = _data[ 5];
		var _sca  = _data[ 7];
		
		var _ldir = _data[ 9];
		var _lhgt = _data[10];
		var _lint = _data[11];
		var _lclr = _data[12];
		var _aclr = _data[13];
		
		var _upda = _data[15];
		
		surface_verify(_outSurf, _dim[0], _dim[1]);
		if(!is_surface(_ins)) return _outSurf;
		
		if(_upda && ANIMATOR.frame_progress)
			generateMesh();
		
		_3d_pre_setup(_outSurf, _dim, _pos, _sca, _ldir, _lhgt, _lint, _lclr, _aclr, _lpos, _lrot, _lsca, false);
			submit_vertex(_array_index);
		_3d_post_setup();
		
		return _outSurf;
	}
}