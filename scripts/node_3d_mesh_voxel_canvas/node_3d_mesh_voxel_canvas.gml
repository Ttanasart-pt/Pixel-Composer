function Node_3D_Mesh_Voxel_Canvas(_x, _y, _group = noone) : Node_3D_Mesh(_x, _y, _group) constructor {
	name = "Voxel Builder";
	object_class = __3dVoxel_builder;
	var i = in_mesh;
	
	newInput(i+ 0, nodeValue_IVec3( "Voxel Size", [8,8,8] ));
	// i+1
	
	input_display_list = [
		__d3d_input_list_mesh, i+0, 
		__d3d_input_list_transform, 
	];
	
	////- Node
	
	voxelBuffer = undefined;
	
	static processData = function(_output, _data, _array_index = 0, _frame = CURRENT_FRAME) {
		#region data
			var _voxelSize = _data[in_mesh + 0];
			
		#endregion
		
		var vxSize = _voxelSize[0] * _voxelSize[1] * _voxelSize[2] * 1;
		voxelBuffer = buffer_verify(voxelBuffer, vxSize, buffer_fixed, 1);
		
		var object = getObject(_array_index);
		object.checkParameter({ 
			voxelSize: _voxelSize,
			voxelBuffer
		});
		
		setTransform(object, _data);
		return object;
	}
	
	static attributeSerialize = function() /*=>*/ { 
		var _data = {
			voxel: voxelBuffer == undefined? -1 : buffer_compress_all(voxelBuffer)
		}
		
		return _data; 
	}
	
	static attributeDeserialize = function(attr) {
		if(has(attr, "voxel")) {
			var _vox = attr.voxel;
			if(_vox != -1) voxelBuffer = buffer_decompress_all(_vox);
		}
		
	}
}