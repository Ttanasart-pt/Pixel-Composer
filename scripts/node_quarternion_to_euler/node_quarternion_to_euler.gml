function Node_Quarternion_To_Euler(_x, _y, _group = noone) : Node_Processor(_x, _y, _group) constructor {
	name = "Quaternion To Euler";
	setDrawIcon(s_node_quarternion_to_euler);
	setDimension(96, 48);
	
	newInput(0, nodeValue_Quaternion("Rotation", [0,0,0,1] )).setVisible(true, true);
	
	newOutput(0, nodeValue_Output("Euler Angles", VALUE_TYPE.float, [0,0,0])).setDisplay(VALUE_DISPLAY.vector);
	
	input_display_list = [ 0 ];
	
	////- Nodes
	
	static processData = function(_outSurf, _data, _array_index = 0) { 
		#region data
			var _qur = _data[0];
		#endregion
		
		var _eul = quarternionToEuler(_qur[0], _qur[1], _qur[2], _qur[3]);
		
		return _eul; 
	}
}