function __transform() constructor {
	parent = noone;
	
	position = new __vec3(0);
	anchor   = new __vec3(0);
	rotation = new BBMOD_Quaternion();
	scale    = new __vec3(1);
	
	static submitMatrix = function() {
		if(parent) parent.submitMatrix();
		
		var pos = matrix_build(position.x, position.y, position.z, 
							   0, 0, 0, 
							   1, 1, 1);
		var rot = rotation.ToMatrix();
		var sca = matrix_build(0, 0, 0, 
					  		   0, 0, 0, 
					  		   scale.x,    scale.y,    scale.z);
		var anc = matrix_build(-anchor.x, -anchor.y, -anchor.z, 
							   0, 0, 0, 
							   1, 1, 1);
							   
		matrix_stack_push(pos);
		matrix_stack_push(rot);
		matrix_stack_push(sca);
		matrix_stack_push(anc);
	}
	
	static clearMatrix = function() {
		matrix_stack_pop();
		matrix_stack_pop();
		matrix_stack_pop();
		matrix_stack_pop();
	}
	
	static clone = function() {
		var _res = new __transform();
		
		_res.parent   = parent;
		_res.position = position.clone();
		_res.anchor   = anchor.clone();
		_res.rotation = rotation.Clone();
		_res.scale    = scale.clone();
		
		return _res;
	}
}