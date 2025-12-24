function Node_3D_Mesh_Wall_Builder(_x, _y, _group = noone) : Node_3D_Mesh(_x, _y, _group) constructor {
	name = "3D Wall";
	object_class = __3dWall_builder;
	var i = in_mesh;
	
	newInput(i+0, nodeValue_PathNode( "Path" ));
	newInput(i+6, nodeValue_Float(    "Path Scale", .01    ));
	newInput(i+9, nodeValue_Bool(     "Loop",        false ));
	newInput(i+1, nodeValue_Int(      "Segments",    16    ));
	newInput(i+2, nodeValue_Float(    "Height",      1     ));
	newInput(i+3, nodeValue_Slider(   "Thickness",  .1     ));
	
	////- =Material
	newInput(i+4, nodeValue_Bool(       "Material per side", false ));
	newInput(i+5, nodeValue_D3Material( "Side Material",     new __d3dMaterial() )).setVisible(true, true);
	newInput(i+7, nodeValue_D3Material( "Side Material 2",   new __d3dMaterial() )).setVisible(true, true);
	newInput(i+8, nodeValue_D3Material( "Cap Material",      new __d3dMaterial() )).setVisible(true, true);
	// i+10
	
	input_display_list = [
		__d3d_input_list_mesh, i+0, i+6, i+9, i+1, i+2, i+3,  
		__d3d_input_list_transform,
		["Material",	false], i+4, i+5, i+7, i+8, 
	];
	
	////- Node
	
	static processData = function(_output, _data, _array_index = 0, _frame = CURRENT_FRAME) {
		var _paths   = _data[in_mesh + 0];
		var _segment = _data[in_mesh + 1];
		var _loop    = _data[in_mesh + 9];
		var _height  = _data[in_mesh + 2];
		var _thick   = _data[in_mesh + 3];
		var _pscale  = _data[in_mesh + 6];
		
		var _side2    = _data[in_mesh + 4];
		var _mat_sid  = _data[in_mesh + 5];
		var _mat_sid2 = _data[in_mesh + 7];
		var _mat_cap  = _data[in_mesh + 8];
		
		inputs[in_mesh + 7].setVisible(_side2, _side2);
		
		if(_paths == noone) return noone;
		
		var points = array_create(_segment + 1);
		var p = new __vec2P();
		
		for( var i = 0; i <= _segment; i++ ) {
			p = _paths.getPointRatio(i / _segment, 0, p);
			
			points[i] = [ p.x * _pscale, -p.y * _pscale ];
		}
		
		var object = getObject(_array_index);
		object.checkParameter({
			points :  points,
			offset : _thick,
			height : _height,
			loop   : _loop,
		});
		object.materials = _side2? [ _mat_sid, _mat_sid2, _mat_cap, _mat_cap ] : [ _mat_sid, _mat_sid, _mat_cap, _mat_cap ];
		
		setTransform(object, _data);
		
		return object;
	}
	
	static getPreviewValues = function() { return getInputSingle(in_mesh + 5); }
}