function Node_3D_Mirror(_x, _y, _group = noone) : Node_3D_Object(_x, _y, _group) constructor {
	name  = "Mirror 3D";
	
	gizmo_object = [ new __3dGizmoPlane() ];
	
	var i = in_d3d;
	newInput(i+0, nodeValue_D3Mesh(      "Mesh" ));
	newInput(i+1, nodeValue_Enum_Button( "Axis", 0, [ "X", "Y", "Z" ] ));
	// i+2
	
	newOutput(0, nodeValue_Output("Mesh", VALUE_TYPE.d3Mesh, noone));
	
	input_display_list = [ i+0, 
		[ "Mirror Plane", false ], i+1, 0, 
	];
	
	static processData = function(_output, _data, _array_index = 0, _frame = CURRENT_FRAME) {
		var _mesh = _data[in_d3d + 0];
		if(!is(_mesh, __3dInstance)) return noone;
		
		var _axis = _data[in_d3d + 1];
		var _pos  = _data[0];
		
		var _mrot;
		switch(_axis) {
			case 0 : _mrot = new BBMOD_Quaternion().FromEuler(0, 90, 0).ToArray(); break;
			case 1 : _mrot = new BBMOD_Quaternion().FromEuler(90, 0, 0).ToArray(); break;
			case 2 : _mrot = new BBMOD_Quaternion().FromEuler(0, 0, 90).ToArray(); break;
		}
			
		#region gizmo
			gizmo.transform.position.set(_pos[0], _pos[1], _pos[2]);
			gizmo.transform.applyMatrix();
			
			gizmo_object[0].transform.position.set(_pos[0], _pos[1], _pos[2]);
			gizmo_object[0].transform.rotation.set(_mrot[0], _mrot[1], _mrot[2], _mrot[3]);
			gizmo_object[0].transform.applyMatrix();
		#endregion
		
		var _scene = new __3dMirrored(_mesh);
		
		switch(_axis) {
			case 0 : _scene.transform.position.set(_pos[0] * 2, 0, 0);
				     _scene.transform.scale.set(-1, 1, 1); break;
				
			case 1 : _scene.transform.position.set(0, _pos[1] * 2, 0);
				     _scene.transform.scale.set(1, -1, 1); break;
				
			case 2 : _scene.transform.position.set(0, 0, _pos[2] * 2);
				     _scene.transform.scale.set(1, 1, -1); break;
		}
		
		_scene.transform.applyMatrix();
		
		return _scene;
	}
	
	static getPreviewObjects		= function() /*=>*/ {return array_append([getPreviewObject()], gizmo_object)};
	static getPreviewObjectOutline  = function() /*=>*/ {return gizmo_object};
}

function __3dMirrored(_object = noone) : __3dInstance() constructor {
	object = _object;
	
	static getCenter = function() { return object.getCenter().add(transform.position); }
	
	static getBBOX   = function() {
		var _b = object.getBBOX().clone();
		
		_b.first.multiplyVec(transform.scale);
		_b.first.add(transform.position);
		
		_b.second.multiplyVec(transform.scale);
		_b.second.add(transform.position);
		
		return _b;
	}
	
	static submitTran = function() /*=>*/ {
		transform.submitMatrix();
		var _c = gpu_get_cullmode();
		switch(_c) {
			case cull_clockwise : gpu_set_cullmode(cull_counterclockwise); break;
			case cull_counterclockwise : gpu_set_cullmode(cull_clockwise); break;
		}
	}
	
	static clearTran = function() /*=>*/ {
		transform.clearMatrix();
		var _c = gpu_get_cullmode();
		switch(_c) {
			case cull_clockwise : gpu_set_cullmode(cull_counterclockwise); break;
			case cull_counterclockwise : gpu_set_cullmode(cull_clockwise); break;
		}
	}
	
	static submit       = function(_sc = {}, _sh = noone) /*=>*/ { submitTran(); object.submit(_sc, _sh);       clearTran(); }
	static submitSel    = function(_sc = {}, _sh = noone) /*=>*/ { submitTran(); object.submitSel(_sc, _sh);    clearTran(); }
	static submitShader = function(_sc = {}, _sh = noone) /*=>*/ { submitTran(); object.submitShader(_sc, _sh); clearTran(); }
	static submitShadow = function(_sc = {}, _ob = noone) /*=>*/ { object.submitShadow(_sc, _ob); }
	
	static clone = function(vertex = true, cloneBuffer = false) {
		var _new = new __3dTransformed();
		
		_new.transform = transform.clone();
		_new.object    = object.clone(vertex, cloneBuffer);
		
		return _new;
	}
}