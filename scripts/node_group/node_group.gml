function Node_Group(_x, _y, _group = noone) : Node_Collection(_x, _y, _group) constructor {
	name  = "Group";
	color = COLORS.node_blend_collection;
	icon  = THEME.group_s;
	
	////- INSTANCING
	
	static resetInstance = function() /*=>*/ { 
		icon = THEME.group_s;
		instanceBase = noone;
		return self; 
	}
		
	static setInstance = function(n, _upd = true) /*=>*/ { 
		icon = THEME.group_linked_s;
		
		if(n.instanceBase == noone)  {
			// var _c = nodeClone([n]);
			// var _newBase = _c[0];
			// _newBase.visible      = false;
			// _newBase.is_instancer = true;
			
			instanceBase   = n;
			// n.instanceBase = _newBase;
			// n.icon = THEME.group_linked_s;
			// n.updateInstance();
			
		} else instanceBase = n.instanceBase;
		
		if(_upd) {
			updateInstance();
			run_in(1, function() /*=>*/ { RENDER_ALL_REORDER });
		}
		return self; 
	}
	
	static updateInstance = function() {
		if(!is(instanceBase, Node) || !instanceBase.active) {
			resetInstance(); 
			return;
		}
		
		// nodeTopo = NodeListSort(nodes);
		
		var instTopo = instanceBase.nodeTopo;
		var currTopo = nodeTopo;
		
		var instAmo = array_length(instTopo);
		var currAmo = array_length(currTopo);
		
		var _insMap = {};
		var _curMap = {};
		
		var checkList = array_create(currAmo, 0);
		var addList   = [];
		
		for(var instInd = 0; instInd < instAmo; instInd++ ) {
			var instNod = instTopo[instInd];
			var matched = noone;
			
			if(is(instNod, Node_Group_Input))  continue;
			if(is(instNod, Node_Group_Output)) continue;
			
			for(var currInd = 0; currInd < currAmo; currInd++ ) {
				if(checkList[currInd]) continue;
				var currNod = currTopo[currInd];
				
				if(instanceof(instNod) == instanceof(currNod)) {
					matched = currNod;
					checkList[currInd] = 1;
					break;
				}
			}
			
			if(matched == noone) { array_push(addList, instNod); continue; } 
			
			matched.move(instNod.x, instNod.y);
			
			_insMap[$ instNod.node_id] = matched;
			_curMap[$ matched.node_id] = instNod;
		}
		
		for(var currInd = 0; currInd < currAmo; currInd++ ) {
			if(checkList[currInd]) continue;
			
			var currNod = currTopo[currInd];
			
			if(is(currNod, Node_Group_Input))  continue;
			if(is(currNod, Node_Group_Output)) continue;
			
			currNod.destroy(false, false);
		}
		
		for( var i = 0, n = array_length(addList); i < n; i++ ) {
			var _addNode = addList[i];
			var _newNode = _addNode.clone(self);
			
			_insMap[$ _addNode.node_id] = _newNode;
			_curMap[$ _newNode.node_id] = _addNode;
		}
		
		// io
		
		var _iamo = array_length(instanceBase.inputs);
		for( var i = 0; i < _iamo; i++ ) {
			var _ins_inp = instanceBase.inputs[i];
			var _inp_nod = _ins_inp.from;
			
			var _bas_inp = array_safe_get(inputs, i, noone);
			var _inp     = noone;
			
			if(_bas_inp == noone) 
				_inp = nodeBuild("Node_Group_Input", _inp_nod.x, _inp_nod.y, self).skipDefault();
			else 
				_inp = _bas_inp.from;
			
			_inp.instanceBase = _inp_nod;
			_insMap[$ _inp_nod.node_id] = _inp;
			_curMap[$ _inp.node_id] = _inp_nod;
			
			run_in(1, function(_inp) /*=>*/ { if(_inp.active) _inp.refreshWidget(); }, [_inp]);
		}
		
		for( var i = array_length(inputs) - 1; i >= _iamo; i--) {
			var _bas_inp = inputs[i];
			_bas_inp.destroy(false, false);
		}
		
		var _iamo = array_length(instanceBase.outputs);
		for( var i = 0; i < _iamo; i++ ) {
			var _ins_inp = instanceBase.outputs[i];
			var _inp_nod = _ins_inp.from;
			
			var _bas_inp = array_safe_get(outputs, i, noone);
			var _inp     = noone;
			
			if(_bas_inp == noone)
				_inp = nodeBuild("Node_Group_Output", _inp_nod.x, _inp_nod.y, self).skipDefault();
			else
				_inp = _bas_inp.from;
			
			_inp.instanceBase = _inp_nod;
			_insMap[$ _inp_nod.node_id] = _inp;
			_curMap[$ _inp.node_id] = _inp_nod;
		}
		
		for( var i = array_length(outputs) - 1; i >= _iamo; i--) {
			var _bas_inp = outputs[i];
			_bas_inp.destroy(false, false);
		}
		
		// connect
		
		for( var i = 0; i < instAmo; i++ ) {
			var _ins_nod = instTopo[i];
			var _cur_nod = _insMap[$ _ins_nod.node_id];
			if(_cur_nod == undefined) { print($"error: cannot find current node"); continue; }
			
			_cur_nod._from = _ins_nod;
			_cur_nod.instanceBase = _ins_nod;
			
			for( var j = 0, m = array_length(_ins_nod.inputs); j < m; j++ ) {
				var _inp = _ins_nod.inputs[j];
				var _cin = _cur_nod.inputs[j];
				
				_cin._from = _inp;
				_cin.animator  = _inp.animator;
				_cin.animators = _inp.animators;
				
				if(_inp.value_from == noone) { _cin.removeFrom(); continue; }
				var _con_nod = _insMap[$ _inp.value_from.node.node_id];
				var _con_ind = _inp.value_from.index;
				var _con_tag = _inp.value_from.tags;
				
				switch(_con_tag) {
					case VALUE_TAG.updateInTrigger  : _cin.setFrom(_con_nod.updatedInTrigger);    break;
					case VALUE_TAG.updateOutTrigger : _cin.setFrom(_con_nod.updatedOutTrigger);   break;
					case VALUE_TAG.matadata         : _cin.setFrom(_con_nod.junc_meta[_con_ind]); break;
					default : 
						if(_con_ind >= 0) {
							var _set = _cin.setFrom(_con_nod.outputs[_con_ind], false, true);
							// if(!_set) print($"Connection failed {_con_nod}");
						} 
						
						if(_con_ind >= 1000) { //connect bypass
							var _inp = array_safe_get_fast(_con_nod.inputs, _con_ind - 1000, noone);
							if(_inp != noone) {
								var _set = _cin.setFrom(_inp.bypass_junc, false, true);
								// if(!_set) print($"Connection failed {_con_nod}");
							}
						}
				}
			}
		}
		
	}
	
	////- SERIALIZATION
	
	static postLoad = function() /*=>*/ {
		var _instanceID = load_map[$ "instanceBase"] ?? "";
		if(_instanceID != "" && ds_map_exists(PROJECT.nodeMap, _instanceID)) {
			var _instance = PROJECT.nodeMap[? _instanceID];
			run_in(1, function(_i) /*=>*/ {return setInstance(_i)}, [_instance]);
		}
	}
	
}