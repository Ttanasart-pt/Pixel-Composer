function __transform() constructor {
	parent = noone;
	
	position = new __vec3(0);
	anchor   = new __vec3(0);
	rotation = new BBMOD_Quaternion();
	scale    = new __vec3(1);
	
	matTran = noone;
	matPos  = noone;
	matRot  = noone;
	matSca  = noone;
	matAnc  = noone;
	
	////- Matrix
	
	static submitMatrix = function() {
		if(parent) parent.submitMatrix();
		if(matTran != noone) matrix_stack_push(matTran);
	}
	
	static clearMatrix = function() {
		if(matTran != noone) matrix_stack_pop();
	}
	
	////- Apply
	
	static applyMatrix = function() {
		if(parent) parent.applyMatrix();
		
		matPos = matrix_build(position.x, position.y, position.z, 
							  0, 0, 0, 
							  1, 1, 1);
		matRot = rotation.ToMatrix();
		
		matSca = matrix_build(0, 0, 0, 
					  		  0, 0, 0, 
					  		  scale.x,    scale.y,    scale.z);
					  		  
		matAnc = matrix_build(-anchor.x, -anchor.y, -anchor.z, 
							   0, 0, 0, 
							   1, 1, 1);
		
		matAnp = matrix_build( anchor.x,  anchor.y,  anchor.z, 
							   0, 0, 0, 
							   1, 1, 1);
		
		matTran = matAnc;
		matTran = matrix_multiply(matTran, matSca);
		matTran = matrix_multiply(matTran, matRot);
		matTran = matrix_multiply(matTran, matPos);
		matTran = matrix_multiply(matTran, matAnp);
	}
	
	static applyTransform = function(_transform) {
		var t2 = new __transform();

		t2.parent   = parent;
		t2.position = position.add(_transform.position);
		t2.rotation = rotation.Mul(_transform.rotation);
		t2.scale    = scale.multiplyVec(_transform.scale);
		t2.anchor   = anchor.add(_transform.anchor);

		return t2;
	}
	
	static applyPoint = function(px, py, pz) {
		var _res = [
			matTran[ 0] * px + matTran[ 4] * py + matTran[ 8] * pz + matTran[12] * 1,
			matTran[ 1] * px + matTran[ 5] * py + matTran[ 9] * pz + matTran[13] * 1,
			matTran[ 2] * px + matTran[ 6] * py + matTran[10] * pz + matTran[14] * 1,
			1
		];
		
		return _res;
	}
	
	static applyNormal = function(nx, ny, nz) {
		var _res = rotation.Rotate(new __vec3(nx, ny, nz));
		return _res;
	}
	
	////- Actions
	
	static setPolar = function(ha, va, dist = 4) {
		var pos = d3d_PolarToCart(0, 0, 0, ha, va, dist)
		position.set(pos.x, pos.y, pos.z);
		
		var _rot = new __rot3().lookAt(position, new __vec3());
		rotation.FromEuler(_rot.x, _rot.y, _rot.z);
		
		applyMatrix();
		
		return self;
	}
	
	static clone = function() {
		var _res = new __transform();
		
		_res.parent   = parent;
		_res.position = position.clone();
		_res.anchor   = anchor.clone();
		_res.rotation = rotation.Clone();
		_res.scale    = scale.clone();
		_res.applyMatrix();
		
		return _res;
	}
	
	
}