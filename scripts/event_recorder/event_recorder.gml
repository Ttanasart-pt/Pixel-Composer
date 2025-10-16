globalvar UNDO_STACK, REDO_STACK;
globalvar IS_UNDOING, UNDO_HOLDING;

IS_UNDOING   = false;
UNDO_HOLDING = false;
UNDO_STACK   = ds_stack_create();
REDO_STACK   = ds_stack_create();

enum ACTION_TYPE {
	var_modify,
	array_modify,
	array_insert,
	array_delete,
	
	node_added,
	node_delete,
	junction_connect,
	junction_disconnect,
	
	group_added,
	group_removed,
	
	group,
	ungroup,
	
	collection_loaded,
	
	struct_modify,
	custom,
}

enum DS_TYPE {
	array,
	list,
}

function Action(_type, _object, _data, _trigger = 0) constructor {
	name    = "";
	ref     = undefined;
	type    = _type;
	obj     = _object;
	data    = _data;
	trigger = _trigger;
	
	extra_data   = 0;
	clear_action = noone;
	
	prev_action  = noone;
	next_actions = [];
	
	static setName  = function(n) /*=>*/ { name = n; return self; }
	static setRef   = function(r) /*=>*/ { if(type == undefined) return self; 
		ref = r; 
		if(is(ref, Node)) ref.logNode(toString(), false);
		
		return self; 
	}
	
	static undo = function() {
		var _n;
		
		switch(type) {
			case ACTION_TYPE.var_modify : 
				if(is_struct(obj)) {
					_n = variable_struct_get(obj, data[1]);
					variable_struct_set(obj, data[1], data[0]);
					
				} else if(object_exists(obj)) {
					_n = variable_instance_get(obj, data[1]);
					variable_instance_set(obj, data[1], data[0]);
				}
				
				data[0] = _n;
				break;
				
			case ACTION_TYPE.array_insert :
				if(!is_array(obj)) return;
				array_delete(obj, data[1], 1);
				break;
				
			case ACTION_TYPE.array_modify :
				if(!is_array(obj)) return;
				_n = data[0];
				obj[data[1]] = data[0];
				data[0] = _n;
				break;
				
			case ACTION_TYPE.array_delete :
				if(!is_array(obj)) return;
				array_insert(obj, data[1], data[0]);
				break;
				
			case ACTION_TYPE.node_added :
				obj.destroy();
				break;
				
			case ACTION_TYPE.node_delete :
				obj.restore();
				break;
				
			case ACTION_TYPE.junction_connect :
				if(obj.is_dummy) {
					data[0].setFrom(noone);
					if(obj.dummy_undo != -1) obj.dummy_undo(data[0]);
				} else {
					var _d = obj.value_from;
					obj.setFrom(data);
					data = _d;
				}
				break;
				
			case ACTION_TYPE.junction_disconnect :
				obj.setFrom(data);
				break;
				
			case ACTION_TYPE.group_added :
				obj.remove(data);
				break;
				
			case ACTION_TYPE.group_removed :
				obj.add(data);
				break;
				
			case ACTION_TYPE.group :
				upgroupNode(obj, false);
				break;
				
			case ACTION_TYPE.ungroup :
				obj.restore();
				groupNodes(data.content, obj, false, false);
				
				for (var i = 0, n = array_length(data.deleted); i < n; i++) {
					var _dl = data.deleted[i];
					var _nd = _dl.node;
					var _vt = _dl.value_to;
					_nd.enable();
					
					for (var j = 0, m = array_length(_nd.outputs); j < m; j++) {
						var _out = _nd.outputs[j];
						var _too = _vt[j];
						
						for (var k = 0, p = array_length(_too); k < p; k++)
							_too[k].setFrom(_out);
					}
				}
				
				var _connectTo = data.connectTo;
				
				for (var i = 0, n = array_length(_connectTo);    i < n; i++)
				for (var j = 0, m = array_length(_connectTo[i]); j < m; j++)
					_connectTo[i][j].setFrom(obj.outputs[i]);
				
				break;
				
			case ACTION_TYPE.collection_loaded :
				for( var i = 0, n = array_length(obj); i < n; i++ ) 
					obj[i].destroy();
				break;
				
			case ACTION_TYPE.struct_modify : 
				var _data = obj.serialize();
				obj.deserialize(data);
				data = _data;
				break;
				
			case ACTION_TYPE.custom : 
				obj(data, true);
				break;
		}
		
		if(trigger) trigger();
	}
	
	static redo = function() {
		var _n;
		switch(type) {
			case ACTION_TYPE.var_modify :
				if(is_struct(obj)) {
					_n = variable_struct_get(obj, data[1]);
					variable_struct_set(obj, data[1], data[0]);
					
				} else if(object_exists(obj)) {
					_n = variable_instance_get(obj, data[1]);
					variable_instance_set(obj, data[1], data[0]);	
				}
				
				data[0] = _n;
				break;
				
			case ACTION_TYPE.array_insert :
				if(!is_array(obj)) return;
				array_insert(obj, data[1], data[0]);
				break;
				
			case ACTION_TYPE.array_modify :
				if(!is_array(obj)) return;
				_n = data[0];
				obj[data[1]] = data[0];
				data[0] = _n;
				break;
				
			case ACTION_TYPE.array_delete :
				if(!is_array(obj)) return;
				array_delete(obj, data[1], 1);
				break;
				
			case ACTION_TYPE.node_added :
				obj.restore();
				break;
				
			case ACTION_TYPE.node_delete :
				obj.destroy();
				break;
				
			case ACTION_TYPE.junction_connect :
				if(obj.is_dummy) {
					obj.setFrom(data[1]);
					data[0] = obj.dummy_target;
					if(obj.dummy_redo != -1) obj.dummy_redo(data[0]);
				} else {
					var _d = obj.value_from;
					obj.setFrom(data);
					data = _d;
				}
				break;
				
			case ACTION_TYPE.junction_disconnect :
				obj.removeFrom();
				break;
				
			case ACTION_TYPE.group_added :	
				obj.add(data);
				break;
				
			case ACTION_TYPE.group_removed :
				obj.remove(data);
				break;
				
			case ACTION_TYPE.group :
				obj.restore();
				groupNodes(data.content, obj, false, true);
				break;
				
			case ACTION_TYPE.ungroup :
				upgroupNode(obj, false);
				break;
				
			case ACTION_TYPE.collection_loaded :
				for( var i = 0, n = array_length(obj); i < n; i++ )
					obj[i].restore();
				break;
				
			case ACTION_TYPE.struct_modify : 
				var _data = obj.serialize();
				obj.deserialize(data);
				data = _data;
				break;
				
			case ACTION_TYPE.custom : 
				obj(data, false);
				break;
		}
		
		if(trigger) trigger();
	}
	
	static toString = function() {
		if(name != "") return name;
		
		switch(type) {
			case ACTION_TYPE.var_modify :          return $"Modify '{array_length(data) > 2? data[2] : data[1]}'";
			case ACTION_TYPE.array_insert :        return array_length(data) > 2? data[2] : $"Insert {data[1]} to array {obj}";
			case ACTION_TYPE.array_modify :        return $"Modify '{data[1]}' of array '{obj}'";
			case ACTION_TYPE.array_delete :        return $"Delete '{data[1]}' from array '{obj}'";
			case ACTION_TYPE.node_added :          return $"Add '{obj.name}' node";
			case ACTION_TYPE.node_delete :         return $"Deleted '{obj.name}' node";
			case ACTION_TYPE.junction_connect :    return $"Connect '{obj.name}'";
			case ACTION_TYPE.junction_disconnect : return $"Disconnect '{obj.name}'";
			case ACTION_TYPE.group_added :         return $"Add '{obj.name}' to group";
			case ACTION_TYPE.group_removed :       return $"Remove '{obj.name}' from group";
			case ACTION_TYPE.group :               return $"Group {array_length(data.content)} nodes";
			case ACTION_TYPE.ungroup :             return $"Ungroup '{obj.name}' node";
			case ACTION_TYPE.collection_loaded :   return $"Load '{filename_name(data)}'";
			case ACTION_TYPE.struct_modify :       return $"Modify struct value '{struct_try_get(obj, "name", "value")}'";
			case ACTION_TYPE.custom :              return struct_try_get(data, "tooltip", "action");
		}
		
		return "";
	}
	
	static destroy = function() {
		if(clear_action == noone) return;
		clear_action(data);
	}
}

function recordAction(_type, _object, _data = -1, _trigger = 0) {
	var _action = __recordAction(_type, _object, _data, _trigger);
	if(_action == noone) _action = new Action(undefined, undefined, undefined);
	
	return _action;
}

function __recordAction(_type, _object, _data = -1, _trigger = 0) {
	if(IS_UNDOING || LOADING || UNDO_HOLDING) return noone;
	
	if(_type == ACTION_TYPE.struct_modify && _data == -1 && struct_has(_object, "serialize"))
		_data = _object.serialize();
	
	var act = new Action(_type, _object, _data, _trigger);
	array_push(o_main.action_last_frame, act);
	
	while(!ds_stack_empty(REDO_STACK)) {
		var actions = ds_stack_pop(REDO_STACK);
		array_foreach(actions, function(a) /*=>*/ {return a.destroy()});
	}
	
	PANEL_MENU.undoUpdate();
	return act;
}

function recordAction_variable_change(object, variable_name, variable_old_value, undo_label = "", _trigger = 0) {
	return recordAction(ACTION_TYPE.var_modify, object, undo_label == ""? [ variable_old_value, variable_name ] : 
	                                                                      [ variable_old_value, variable_name, undo_label ], _trigger);
}

/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

function mergeAction(act) {
	if(ds_stack_empty(UNDO_STACK)) {
		ds_stack_push(UNDO_STACK, [ act ]);
		PANEL_MENU.undoUpdate();
		return;
	}
	
	var _top = ds_stack_pop(UNDO_STACK);
	array_push(_top, act);
	ds_stack_push(UNDO_STACK, _top);
}

function UNDO() {
	CALL("undo");
	if(ds_stack_empty(UNDO_STACK))				return;
	if(instance_exists(_p_dialog_undo_block))	return;
	
	IS_UNDOING = true;
	var actions = ds_stack_pop(UNDO_STACK);
	for(var i = array_length(actions) - 1; i >= 0; i--)
		actions[i].undo();
	IS_UNDOING = false;
	RenderSync(PROJECT);
	
	ds_stack_push(REDO_STACK, actions);
	PANEL_MENU.undoUpdate();
}

function REDO() {
	CALL("redo");
	if(ds_stack_empty(REDO_STACK))				return;
	if(instance_exists(_p_dialog_undo_block))	return;
	
	IS_UNDOING = true;
	var actions = ds_stack_pop(REDO_STACK);
	for(var i = 0; i < array_length(actions); i++)
		actions[i].redo();
	IS_UNDOING = false;
	RenderSync(PROJECT);
	
	ds_stack_push(UNDO_STACK, actions);	
	PANEL_MENU.undoUpdate();
}