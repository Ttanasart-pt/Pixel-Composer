function Node_Font_Data(_x, _y, _group = noone) : Node_Processor(_x, _y, _group) constructor {
	name = "Font";
	setDrawIcon(s_node_font_data);
	setDimension(96, 48);
	
	newInput( 0, nodeValue_Font( "Font" ));
	
	newOutput(0, nodeValue_Output("Font", VALUE_TYPE.font, noone ));
	
	input_display_list = [ 0 ];
	
	////- Nodes
	
	static processData = function(_outSurf, _data, _array_index = 0) { 
		#region data
			var _font = _data[0];
		#endregion
		
		return _font; 
	}
}