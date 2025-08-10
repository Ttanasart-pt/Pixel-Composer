function Node_3D_Mesh_Cube(_x, _y, _group = noone) : Node_3D_Mesh(_x, _y, _group) constructor {
	name = "3D Cube";
	object_class = __3dCube;
	
	var i = in_mesh;
	
	////- Mesh
	
	newInput(i+9, nodeValue_IVec3(       "Subdivision", [1,1,1] ));
	newInput(i+7, nodeValue_Slider(      "Taper",        0, [-1,1,0.01] ));
	newInput(i+8, nodeValue_Enum_Button( "Taper Axis",   0, [ "X", "Y", "Z" ]));
	
	////- Materials
	
	newInput(i+0, nodeValue_Enum_Button( "Material Mode", 0, [ "Uniform", "Per Face", "Top and Side" ] ));
	newInput(i+1, nodeValue_D3Material(  "Material"        )).setVisible(true, true);
	newInput(i+2, nodeValue_D3Material(  "Material Bottom" )).setVisible(true, true);
	newInput(i+3, nodeValue_D3Material(  "Material Left"   )).setVisible(true, true);
	newInput(i+4, nodeValue_D3Material(  "Material Right"  )).setVisible(true, true);
	newInput(i+5, nodeValue_D3Material(  "Material Back"   )).setVisible(true, true);
	newInput(i+6, nodeValue_D3Material(  "Material Front"  )).setVisible(true, true);
	
	input_display_list = [
		__d3d_input_list_mesh,      i+9, i+7, i+8, 
		__d3d_input_list_transform, 
		["Material", false],        i+0, i+1, i+2, i+3, i+4, i+5, i+6, 
	]
	
	static onDrawOverlay3D = function(active, params, _mx, _my, _snx, _sny, _panel) {}
	
	static processData = function(_output, _data, _array_index = 0) { 
		var i = in_mesh;
		
		var _mat_side = _data[i+0];
		var _mat_1    = _data[i+1];
		var _mat_2    = _data[i+2];
		var _mat_3    = _data[i+3];
		var _mat_4    = _data[i+4];
		var _mat_5    = _data[i+5];
		var _mat_6    = _data[i+6];
		
		var _tap_amo  = _data[i+7];
		var _tap_axs  = _data[i+8];
		var _subd     = _data[i+9];
		
		_subd[0] = max(1, _subd[0]);
		_subd[1] = max(1, _subd[1]);
		_subd[2] = max(1, _subd[2]);
		
		var _mat = [ _mat_1, _mat_2, _mat_3, _mat_4, _mat_5, _mat_6 ];
		
		switch(_mat_side) {
			case 0 :
				inputs[i+1].name = "Material";
				
				inputs[i+1].setVisible( true,  true);
				inputs[i+2].setVisible(false, false);
				inputs[i+3].setVisible(false, false);
				inputs[i+4].setVisible(false, false);
				inputs[i+5].setVisible(false, false);
				inputs[i+6].setVisible(false, false);
				break;
			
			case 1 :
				inputs[i+1].name = "Material Top";
				
				inputs[i+1].setVisible(true, true);
				inputs[i+2].setVisible(true, true);
				inputs[i+3].setVisible(true, true);
				inputs[i+4].setVisible(true, true);
				inputs[i+5].setVisible(true, true);
				inputs[i+6].setVisible(true, true);
				break;
			
			case 2 :
				inputs[i+1].name = "Material Top";
				inputs[i+2].name = "Material Side";
				
				inputs[i+1].setVisible(true, true);
				inputs[i+2].setVisible(true, true);
				inputs[i+3].setVisible(false, false);
				inputs[i+4].setVisible(false, false);
				inputs[i+5].setVisible(false, false);
				inputs[i+6].setVisible(false, false);
				
				_mat = [ _mat_1, _mat_1, _mat_2, _mat_2, _mat_2, _mat_2 ];
				break;
			
		}
		
		var object = getObject(_array_index);
		object.checkParameter({ 
			separate_faces: _mat_side,
			taper_amount:   _tap_amo, 
			taper_axis:     _tap_axs, 
			subdivision:    _subd, 
		});
		object.materials = _mat;
		setTransform(object, _data);
		
		return object;
	}
	
	static getPreviewValues = function() { return getSingleValue(in_mesh + 1); }
}