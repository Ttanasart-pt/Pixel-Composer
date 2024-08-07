function __Node_3D_Extrude(_x, _y, _group = noone) : Node_Processor(_x, _y, _group) constructor {
	name = "3D Extrude";
	batch_output = false;
	
	inputs[| 0] = nodeValue_Surface("Surface in", self);
	
	inputs[| 1] = nodeValue_Dimension(self);
	
	inputs[| 2] = nodeValue("Object position", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, [ 0, 0, 0 ])
		.setDisplay(VALUE_DISPLAY.vector);
	
	inputs[| 3] = nodeValue("Object rotation", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, [ 0, 180, 0 ])
		.setDisplay(VALUE_DISPLAY.vector);
	
	inputs[| 4] = nodeValue("Object scale", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, [ 1, 1, 0.1 ])
		.setDisplay(VALUE_DISPLAY.vector);
	
	inputs[| 5] = nodeValue("Render position", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, [ 0.5, 0.5 ])
		.setDisplay(VALUE_DISPLAY.vector)
		.setUnitRef( function() { return getInputData(1); }, VALUE_UNIT.reference);
		
	inputs[| 6] = nodeValue("Render rotation", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, [ 0, 0, 0 ])
		.setDisplay(VALUE_DISPLAY.vector);
	
	inputs[| 7] = nodeValue("Render scale", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, [ 1, 1 ])
		.setDisplay(VALUE_DISPLAY.vector);
	
	inputs[| 8] = nodeValue("Manual generate", self, JUNCTION_CONNECT.input, VALUE_TYPE.trigger, false )
		.setDisplay(VALUE_DISPLAY.button, { name: "Generate", UI : true, onClick: function() { generateMesh(); doUpdate(); } });
		
	inputs[| 9] = nodeValue_Rotation("Light direction", self, 0);
		
	inputs[| 10] = nodeValue("Light height", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, 0.5)
		.setDisplay(VALUE_DISPLAY.slider, { range: [-1, 1, 0.01] });
		
	inputs[| 11] = nodeValue("Light intensity", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, 1)
		.setDisplay(VALUE_DISPLAY.slider);
	
	inputs[| 12] = nodeValue("Light color", self, JUNCTION_CONNECT.input, VALUE_TYPE.color, c_white);
	inputs[| 13] = nodeValue("Ambient color", self, JUNCTION_CONNECT.input, VALUE_TYPE.color, c_grey);
	
	inputs[| 14] = nodeValue_Surface("Height map", self);
	
	inputs[| 15] = nodeValue("Always update", self, JUNCTION_CONNECT.input, VALUE_TYPE.boolean, false);
	
	inputs[| 16] = nodeValue_Enum_Button("Projection", self,  0, [ "Orthographic", "Perspective" ])
		.rejectArray();
		
	inputs[| 17] = nodeValue("Field of view", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, 60)
		.setDisplay(VALUE_DISPLAY.slider, { range: [ 1, 90, 0.1 ] });
	
	inputs[| 18] = nodeValue("Scale view with dimension", self, JUNCTION_CONNECT.input, VALUE_TYPE.boolean, true)
	
	inputs[| 19] = nodeValue("Smooth", self, JUNCTION_CONNECT.input, VALUE_TYPE.boolean, false)
	
	input_display_list = [
		["Output",			 false], 1, 18, 
		["Geometry",		 false], 0, 8, 14, 19, 
		["Object transform", false], 2, 3, 4,
		["Camera",			 false], 16, 17, 5, 7, 15,
		["Light",			 false], 9, 10, 11, 12, 13,
	];
	
	outputs[| 0] = nodeValue("Surface out", self, JUNCTION_CONNECT.output, VALUE_TYPE.surface, noone);
	
	outputs[| 1] = nodeValue("3D scene", self, JUNCTION_CONNECT.output, VALUE_TYPE.d3object, function(index) { return submit_vertex(index); });
	
	outputs[| 2] = nodeValue("Normal pass", self, JUNCTION_CONNECT.output, VALUE_TYPE.surface, noone);
	
	outputs[| 3] = nodeValue("3D vertex", self, JUNCTION_CONNECT.output, VALUE_TYPE.d3vertex, []);
	
	output_display_list = [
		0, 2, 1, 3
	]
	
	_3d_node_init(1, /*Transform*/ 5, 7, 2, 3, 4);
	
	vertexObjects = [];
	
	mesh_generating = false;
	mesh_genetated  = false;
	mesh_generate_index  = 0;
	mesh_generate_amount = 0;
	
	static onValueUpdate = function(index) {
		if(index == 19) 
			generateMesh();
	}
	
	static onValueFromUpdate = function(index) {
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
		var _ins = getInputData(0);
		if(!is_array(_ins)) _ins = [ _ins ];
		
		for( var i = 0, n = array_length(vertexObjects); i < n; i++ ) {
			if(vertexObjects[i] == noone) continue;
			vertexObjects[i].destroy();
		}
		vertexObjects = [];
		
		mesh_generating		 = true;
		mesh_genetated		 = false;
		mesh_generate_index  = 0;
		mesh_generate_amount = array_length(_ins);
	}
		
	static generateMeshIndex = function(index) {
		var _ins = getSingleValue( 0, index);
		var _hei = getSingleValue(14, index);
		var _smt = getSingleValue(19, index);
		
		if(!is_surface(_ins)) return noone;
		var ww = surface_get_width_safe(_ins);
		var hh = surface_get_height_safe(_ins);
		
		var tw = 1 / ww;
		var th = 1 / hh;
		var sw = -ww / 2 * tw;
		var sh = -hh / 2 * th;
		var useH = is_surface(_hei);
		
		if(_smt) {
			var ts = surface_create(ww, hh);
			surface_set_shader(ts, sh_3d_extrude_filler);
				DRAW_CLEAR
				shader_set_f("dimension", ww, hh);
				draw_surface_safe(_ins);
			surface_reset_shader();
			_ins = ts;
			
			if(useH) {
				var ds = surface_create(ww, hh);
				surface_set_shader(ds, sh_3d_extrude_filler_depth);
					DRAW_CLEAR
					shader_set_f("dimension", ww, hh);
					draw_surface_safe(_hei);
				surface_reset_shader();
				_hei = ds;
			}
		}
		
		if(useH) {
			var hgw = surface_get_width_safe(_hei);
			var hgh = surface_get_height_safe(_hei);
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
		
		var v  = new VertexObject();
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
			if(!_smt && ap[i][j] == 0) continue;
			
			var i0 = sw + i * tw;
			var i1 = i0 + tw;
			var j0 = sh + j * th;
			var j1 = j0 + th;
			var tx0 = tw * i, tx1 = tx0 + tw;
			var ty0 = th * j, ty1 = ty0 + th;
			
			var dep = (useH? getHeight(hei, hgtW, hgtH, i, j) : 1) * 0.5;
			
			if(_smt) {
				var d0, d1, d2, d3;
				var d00, d10, d01, d11;
				var a, a0, a1, a2, a3;
				
				// d00 | a0 | d10
				// a1  | a  | a2
				// d01 | a3 | d11
				
				if(useH) {
					d00 = (i > 0 && j > 0)?			  getHeight(hei, hgtW, hgtH, i - 1, j - 1) * 0.5 : 0;
					d10 = (i < ww - 1 && j > 0)?	  getHeight(hei, hgtW, hgtH, i + 1, j - 1) * 0.5 : 0;
					d01 = (i > 0 && j < hh - 1)?	  getHeight(hei, hgtW, hgtH, i - 1, j + 1) * 0.5 : 0;
					d11 = (i < ww - 1 && j < hh - 1)? getHeight(hei, hgtW, hgtH, i + 1, j + 1) * 0.5 : 0;
					
					d0  = (j > 0)?		getHeight(hei, hgtW, hgtH, i, j - 1) * 0.5 : 0;
					d1  = (i > 0)?		getHeight(hei, hgtW, hgtH, i - 1, j) * 0.5 : 0;
					d2  = (i < ww - 1)?	getHeight(hei, hgtW, hgtH, i + 1, j) * 0.5 : 0;
					d3  = (j < hh - 1)?	getHeight(hei, hgtW, hgtH, i, j + 1) * 0.5 : 0;
				} else {
					d00 = (i > 0 && j > 0)?			  bool(ap[i - 1][j - 1]) * 0.5 : 0;
					d10 = (i < ww - 1 && j > 0)?	  bool(ap[i + 1][j - 1]) * 0.5 : 0;
					d01 = (i > 0 && j < hh - 1)?	  bool(ap[i - 1][j + 1]) * 0.5 : 0;
					d11 = (i < ww - 1 && j < hh - 1)? bool(ap[i + 1][j + 1]) * 0.5 : 0;
					
					d0 = (j > 0)?		bool(ap[i][j - 1]) * 0.5 : 0;
					d1 = (i > 0)?		bool(ap[i - 1][j]) * 0.5 : 0;
					d2 = (i < ww - 1)?	bool(ap[i + 1][j]) * 0.5 : 0;
					d3 = (j < hh - 1)?	bool(ap[i][j + 1]) * 0.5 : 0;
				}
				
				a  = ap[i][j];
				a0 = (j > 0)?		ap[i][j - 1] : 0;
				a1 = (i > 0)?		ap[i - 1][j] : 0;
				a2 = (i < ww - 1)?	ap[i + 1][j] : 0;
				a3 = (j < hh - 1)?	ap[i][j + 1] : 0;
				
				if(a1 && a0) d00 = (d1 + d0) / 2;
				if(a0 && a2) d10 = (d0 + d2) / 2;
				if(a2 && a3) d11 = (d2 + d3) / 2;
				if(a3 && a1) d01 = (d3 + d1) / 2;
				
				if(a) {
					v.addFace( [i1, j0, -d10], [0, 0, -1], [tx1, ty0], 
					           [i0, j0, -d00], [0, 0, -1], [tx0, ty0], 
					           [i1, j1, -d11], [0, 0, -1], [tx1, ty1], false);
						    		
					v.addFace( [i1, j1, -d11], [0, 0, -1], [tx1, ty1], 
					           [i0, j0, -d00], [0, 0, -1], [tx0, ty0], 
					           [i0, j1, -d01], [0, 0, -1], [tx0, ty1], false);
			
					v.addFace( [i1, j0,  d10], [0, 0, 1], [tx1, ty0], 
					           [i0, j0,  d00], [0, 0, 1], [tx0, ty0], 
					           [i1, j1,  d11], [0, 0, 1], [tx1, ty1], false);
						    		    
					v.addFace( [i1, j1,  d11], [0, 0, 1], [tx1, ty1], 
					           [i0, j0,  d00], [0, 0, 1], [tx0, ty0], 
					           [i0, j1,  d01], [0, 0, 1], [tx0, ty1], false);
				} else if(!a0 && !a1 && a2 && a3) {
					//var _tx0 = tw * (i + 1), _tx1 = _tx0 + tw;
					//var _ty0 = th * (j + 0), _ty1 = _ty0 + th;
					
					d00 *= d0 * d1;
					d10 *= d1 * d2;
					d01 *= d1 * d3;
					
					v.addFace( [i1, j0, -d10], [0, 0, -1], [tx1, ty0], 
					           [i0, j1, -d01], [0, 0, -1], [tx0, ty1], 
					           [i1, j1, -d11], [0, 0, -1], [tx1, ty1], false);
					
					v.addFace( [i1, j0,  d10], [0, 0,  1], [tx1, ty0], 
					           [i0, j1,  d01], [0, 0,  1], [tx0, ty1], 
					           [i1, j1,  d11], [0, 0,  1], [tx1, ty1], false);
				} else if(!a0 && a1 && !a2 && a3) {
					//var _tx0 = tw * (i - 1), _tx1 = _tx0 + tw;
					//var _ty0 = th * (j + 0), _ty1 = _ty0 + th;
					
					d00 *= d0 * d1;
					d10 *= d1 * d2;
					d11 *= d2 * d3;
					
					v.addFace( [i1, j1, -d11], [0, 0, -1], [tx1, ty1], 
					           [i0, j0, -d00], [0, 0, -1], [tx0, ty0], 
					           [i0, j1, -d01], [0, 0, -1], [tx0, ty1], false);
					
					v.addFace( [i1, j1,  d11], [0, 0,  1], [tx1, ty1], 
					           [i0, j0,  d00], [0, 0,  1], [tx0, ty0], 
					           [i0, j1,  d01], [0, 0,  1], [tx0, ty1], false);
				} else if(a0 && a1 && !a2 && !a3) {
					//var _tx0 = tw * (i - 1), _tx1 = _tx0 + tw;
					//var _ty0 = th * (j + 0), _ty1 = _ty0 + th;
					
					d10 *= d1 * d2;
					d01 *= d1 * d3;
					d11 *= d2 * d3;
					
					v.addFace( [i0, j0, -d00], [0, 0, -1], [tx0, ty0],                // d00 | a0 | d10
					           [i0, j1, -d01], [0, 0, -1], [tx0, ty1],				  // a1  | a  | a2
					           [i1, j0, -d10], [0, 0, -1], [tx1, ty0], false);		  // d01 | a3 | d11
					
					v.addFace( [i0, j0,  d00], [0, 0,  1], [tx0, ty0], 
					           [i0, j1,  d01], [0, 0,  1], [tx0, ty1], 
					           [i1, j0,  d10], [0, 0,  1], [tx1, ty0], false);
				} else if(a0 && !a1 && a2 && !a3) {
					//var _tx0 = tw * (i + 1), _tx1 = _tx0 + tw;
					//var _ty0 = th * (j + 0), _ty1 = _ty0 + th;
					
					d00 *= d0 * d1;
					d01 *= d1 * d3;
					d11 *= d2 * d3;
					
					v.addFace( [i1, j0, -d10], [0, 0, -1], [tx1, ty0], 
					           [i0, j0, -d00], [0, 0, -1], [tx0, ty0], 
					           [i1, j1, -d11], [0, 0, -1], [tx1, ty1], false);

					v.addFace( [i1, j0,  d10], [0, 0,  1], [tx1, ty0], 
					           [i0, j0,  d00], [0, 0,  1], [tx0, ty0], 
					           [i1, j1,  d11], [0, 0,  1], [tx1, ty1], false);
				} 
			} else {
				v.addFace( [i1, j0, -dep], [0, 0, -1], [tx1, ty0], 
				           [i0, j0, -dep], [0, 0, -1], [tx0, ty0], 
				           [i1, j1, -dep], [0, 0, -1], [tx1, ty1], false);
						    		
				v.addFace( [i1, j1, -dep], [0, 0, -1], [tx1, ty1], 
				           [i0, j0, -dep], [0, 0, -1], [tx0, ty0], 
				           [i0, j1, -dep], [0, 0, -1], [tx0, ty1], false);
			
				v.addFace( [i1, j0,  dep], [0, 0, 1], [tx1, ty0], 
				           [i0, j0,  dep], [0, 0, 1], [tx0, ty0], 
				           [i1, j1,  dep], [0, 0, 1], [tx1, ty1], false);
						    		    
				v.addFace( [i1, j1,  dep], [0, 0, 1], [tx1, ty1], 
				           [i0, j0,  dep], [0, 0, 1], [tx0, ty0], 
				           [i0, j1,  dep], [0, 0, 1], [tx0, ty1], false);
						   
				if((useH && dep * 2 > getHeight(hei, hgtW, hgtH, i, j - 1)) || (j == 0 || ap[i][j - 1] == 0)) { //y side 
					v.addFace( [i0, j0,  dep], [0, -1, 0], [tx1, ty0], 
					           [i0, j0, -dep], [0, -1, 0], [tx0, ty0], 
					           [i1, j0,  dep], [0, -1, 0], [tx1, ty1], false);
						    		    
					v.addFace( [i0, j0, -dep], [0, -1, 0], [tx1, ty1], 
					           [i1, j0, -dep], [0, -1, 0], [tx0, ty0], 
					           [i1, j0,  dep], [0, -1, 0], [tx0, ty1], false);
				}
			
				if((useH && dep * 2 > getHeight(hei, hgtW, hgtH, i, j + 1)) || (j == hh - 1 || ap[i][j + 1] == 0)) { //y side 
					v.addFace( [i0, j1,  dep], [0, 1, 0], [tx1, ty0], 
					           [i0, j1, -dep], [0, 1, 0], [tx0, ty0], 
					           [i1, j1,  dep], [0, 1, 0], [tx1, ty1], false);
						       
					v.addFace( [i0, j1, -dep], [0, 1, 0], [tx1, ty1], 
					           [i1, j1, -dep], [0, 1, 0], [tx0, ty0], 
					           [i1, j1,  dep], [0, 1, 0], [tx0, ty1], false);
				}
			
				if((useH && dep * 2 > getHeight(hei, hgtW, hgtH, i - 1, j)) || (i == 0 || ap[i - 1][j] == 0)) { //x side 
					v.addFace( [i0, j0,  dep], [1, 0, 0], [tx1, ty0], 
					           [i0, j0, -dep], [1, 0, 0], [tx0, ty0], 
					           [i0, j1,  dep], [1, 0, 0], [tx1, ty1], false);
						       
					v.addFace( [i0, j0, -dep], [1, 0, 0], [tx1, ty1], 
					           [i0, j1, -dep], [1, 0, 0], [tx0, ty0], 
					           [i0, j1,  dep], [1, 0, 0], [tx0, ty1], false);
				}
			
				if((useH && dep * 2 > getHeight(hei, hgtW, hgtH, i + 1, j)) || (i == ww - 1 || ap[i + 1][j] == 0)) { //x side
					v.addFace( [i1, j0,  dep], [-1, 0, 0], [tx1, ty0], 
					           [i1, j0, -dep], [-1, 0, 0], [tx0, ty0], 
					           [i1, j1,  dep], [-1, 0, 0], [tx1, ty1], false);
						       
					v.addFace( [i1, j0, -dep], [-1, 0, 0], [tx1, ty1], 
					           [i1, j1, -dep], [-1, 0, 0], [tx0, ty0], 
					           [i1, j1,  dep], [-1, 0, 0], [tx0, ty1], false);
				}
			}
		}
		
		if(_smt) {
			surface_free(_ins);
			if(useH) surface_free(_hei);
		}
		
		v.createBuffer();
		return v;
	}
	
	static step = function() {
		if(!mesh_generating) return;
		
		vertexObjects[mesh_generate_index] = generateMeshIndex(mesh_generate_index);
		
		mesh_generate_index++;
		if(mesh_generate_index >= mesh_generate_amount) {
			mesh_generating = false;
			mesh_genetated  = true;
			
			RENDER_ALL
			outputs[| 3].setValue(vertexObjects);
		}
	}
	
	static drawOverlay = function(hover, active, _x, _y, _s, _mx, _my, _snx, _sny) {
		PROCESSOR_OVERLAY_CHECK
		
		_3d_gizmo(active, _x, _y, _s, _mx, _my, _snx, _sny);
	}
	
	static submit_vertex = function(index = 0) {
		var _ins  = array_safe_get_fast(textures, index);
		if(!is_surface(_ins)) return;
		if(index >= array_length(vertexObjects)) return;
		
		var _lpos = getSingleValue( 2, index);
		var _lrot = getSingleValue( 3, index);
		var _lsca = getSingleValue( 4, index);
		var _smt  = getSingleValue(19, index);
		
		if(is_struct(vertexObjects[index])) {
			_3d_local_transform(_lpos, _lrot, _lsca);
			vertexObjects[index].submit(_ins);
			_3d_clear_local_transform();
		}
	}
	
	textures = [];
	
	static processData = function(_outSurf, _data, _output_index, _array_index) {
		if(mesh_generating) return;
		if(_output_index == 3) return vertexObjects;
		
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
		
		var _proj = _data[16];
		var _fov  = _data[17];
		var _dimS = _data[18];
		var _smt  = _data[19];
		
		inputs[| 17].setVisible(_proj);
		
		_outSurf = surface_verify(_outSurf, _dim[0], _dim[1]);
		if(!is_surface(_ins)) return _outSurf;
		
		var pass = "diff";
		switch(_output_index) {
			case 0 : pass = "diff" break;
			case 2 : pass = "norm" break;
		}
		
		if(_upda && PROJECT.animator.frame_progress)
			generateMesh();
		
		var _transform = new __3d_transform(_pos,, _sca, _lpos, _lrot, _lsca, false, _dimS );
		var _light     = new __3d_light(_ldir, _lhgt, _lint, _lclr, _aclr);
		var _cam	   = new __3d_camera(_proj, _fov);
			
		if(_smt) {
			var ww = surface_get_width_safe(_ins);
			var hh = surface_get_height_safe(_ins);
			
			var ts = surface_create(ww, hh);
			surface_set_shader(ts, sh_3d_extrude_corner);
				shader_set_f("dimension", ww, hh);
				draw_surface_safe(_ins);
			surface_reset_shader();
			textures[_array_index] = ts;
		} else 
			textures[_array_index] = _ins;
			
		_outSurf = _3d_pre_setup(_outSurf, _dim, _transform, _light, _cam, pass);
			submit_vertex(_array_index);
		_3d_post_setup();
		
		return _outSurf;
	}
	
	static onDrawNode = function(xx, yy, _mx, _my, _s, _hover, _focus) {
		if(mesh_generating) {
			var cx = xx + w * _s / 2;
			var cy = yy + h * _s / 2;
			var rr = min(w - 64, h - 64) * _s / 2;
			
			draw_set_color(COLORS._main_icon);
			draw_arc(cx, cy, rr, 90, 90 - 360 * mesh_generate_index / mesh_generate_amount, 4 * _s, max(mesh_generate_amount, 32));
		}
	}
	
	static postLoad = function() {
		generateMesh();
	}
}