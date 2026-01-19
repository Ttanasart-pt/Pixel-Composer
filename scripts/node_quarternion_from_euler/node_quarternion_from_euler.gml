function Node_Quarternion_From_Euler(_x, _y, _group = noone) : Node_Processor(_x, _y, _group) constructor {
	name = "Quaternion From Euler";
	setDrawIcon(s_node_quarternion_from_euler);
	setDimension(96, 48);
	
	newInput(0, nodeValue_Vec3("Euler Rotation", [0,0,0] )).setVisible(true, true);
	
	newOutput(0, nodeValue_Output("Rotation", VALUE_TYPE.float, [0,0,0,1])).setDisplay(VALUE_DISPLAY.d3quarternion);
	
	input_display_list = [ 0 ];
	
	////- Nodes
	
	static processData = function(_outSurf, _data, _array_index = 0) { 
		#region data
			var _eul = _data[0];
		#endregion
		
		var _quar = quarternionFromEuler(_eul[0], _eul[1], _eul[2]);
		
		return _quar; 
	}
}