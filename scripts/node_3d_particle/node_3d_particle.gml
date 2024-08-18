function Node_3D_Particle(_x, _y, _group = noone) : Node_3D_Modifier(_x, _y, _group) constructor {
	name = "3D Particle";
	update_on_frame = true;
	
	newInput(in_mesh + 0, nodeValue_Int("Amounts", self, 1));
	
	part_pool_size = 128;
	parts = array_create(part_pool_size);
	for( var i = 0; i < part_pool_size; i++ ) 
		parts[i] = new __3DVFX();
	
	part_pos = array_create(part_pool_size);
	part_rot = array_create(part_pool_size);
	part_sca = array_create(part_pool_size);
	
	seed = irandom_range(100000, 999999);
	
	static processData_prebatch  = function() {
		if(IS_FIRST_FRAME) {
			var _sed = seed;
			
			for( var i = 0; i < part_pool_size; i++ ) 
				parts[i].reset(_sed++);
				
			return;
		} 
		
		for( var i = 0; i < part_pool_size; i++ ) 
			parts[i].step();
	}
	
	static processData = function(_output, _data, _output_index, _array_index = 0) {
		var _obj = _data[0];
		if(!is_instanceof(_obj, __3dObject))		return noone;
		if(_obj.VF != global.VF_POS_NORM_TEX_COL)	return noone;
		
		var _amo = _data[in_mesh + 0];
		
		if(_amo <= 0) return noone;
		var _res = new __3dObjectInstancer();
		var _scaleZero = [ 0, 0, 0 ];
		
		_res.object_counts  = max(1, _amo);
		
		for( var i = 0; i < part_pool_size; i++ ) {
			var _part = parts[i];
			
			part_pos[i] = _part.position;
			part_rot[i] = _part.rotation;
			part_sca[i] = _part.active? _part.scale : _scaleZero;
		}
		
		_res.positions     = part_pos;
		_res.rotations     = part_rot;
		_res.scales        = part_sca;
		_res.object_counts = part_pool_size;
		
		_res.vertex = _obj.vertex;
		_res.VB     = _obj.VB;
		_res.render_type    = _obj.render_type;
		_res.custom_shader  = _obj.custom_shader;
		_res.transform      = _obj.transform.clone();
		_res.size           = _obj.size.clone();
		_res.materials      = _obj.materials;
		_res.material_index = _obj.material_index;
		_res.texture_flip   = _obj.texture_flip;
		
		_res.setData();
		
		return _res;
	}
}