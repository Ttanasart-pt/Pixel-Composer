function Node_Mesh_To_Path(_x, _y, _group = noone) : Node(_x, _y, _group) constructor {
	name = "Mesh to Path";
	setDrawIcon();
	setDimension(96, 48);
	
	////- =Mesh
	newInput( 0, nodeValue_Mesh( "Mesh" )).setVisible(true, true);
	newInput( 1, nodeValue_Bool( "Faces", false )).setTooltip("Export each face edges as path segment.");
	
	////- =Path
	// 1
	
	newOutput(0, nodeValue_Output("Path", VALUE_TYPE.pathnode, noone));
	
	input_display_list = [
		[ "Mesh", false ], 0, 1, 
		[ "Path", false ], 
	]
	
	////- Node
	
	static update = function() {  
		#region data
			var _mesh = getInputData( 0);
			var _face = getInputData( 1);
			
		#endregion
		
		if(!is(_mesh, Mesh)) return;
		
		var _outPath = outputs[0].getValue();
		if(!is(_outPath, PathSegment))
			_outPath = new PathSegment(self);
		outputs[0].setValue(_outPath);
		
		if(_face && _mesh.faces != undefined) {
			var _edges = _mesh.getFaceData();
			_outPath.setSegment(_edges);
			
		} else {
			var _segs = _mesh.mergePath();
			_outPath.setSegment(_segs);
		}
	}
}