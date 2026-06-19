function Node_Path_Join(_x, _y, _group = noone) : Node(_x, _y, _group) constructor {
	name = "Path Join";
	setDrawIcon();
	setDimension(96, 48);
	
	newOutput(0, nodeValue_Output("Joined Path", VALUE_TYPE.pathnode, self));
	
	input_display_list = [
		[ "Paths", false ], 
	];
	
	function createNewInput(index = array_length(inputs)) {
		var inAmo = array_length(inputs);
		newInput(index, nodeValue_Path( "Path" ));
		array_push(input_display_list, index);
		return inputs[index];
	} setDynamicInput(1, true, VALUE_TYPE.pathnode);
	
	////- Path
	
	cached_pos    = ds_map_create();
	curr_path_amo = 0;
	curr_path     = [];
	path_trans    = [];
	path_lengths  = [];
	
	line_count    = 0;
	segment_count = 0;
	length_total  = 0;
	length_accu   = [];
	boundary      = new BoundingBox();
	
	__p = [0,1];
	
	static getLineCount    = function() /*=>*/ {return line_count};
	static getSegmentCount = function() /*=>*/ {return segment_count};
	static getLength       = function() /*=>*/ {return length_total};
	static getAccuLength   = function() /*=>*/ {return length_accu};
	static getBoundary     = function() /*=>*/ {return boundary};
	
	static getPointRatio = function(_rat, ind = 0, out = undefined) {
		return getPointDistance(_rat * length_total, ind, out);
	}
	
	static getPointDistance = function(_dist, ind = 0, out = undefined) {
		out ??= new __vec2P();
		if(curr_path_amo == 0) return out;
		
		var _ind = 0;
		while(_dist > path_lengths[_ind]) {
			_dist -= path_lengths[_ind];
			_ind++;
			if(_ind >= curr_path_amo) break;
		}
		
		if(_ind >= curr_path_amo) return out;
		
		out = curr_path[_ind].getPointDistance(_dist, ind, out);
		
		var _ptran = path_trans[_ind];
		out.x += _ptran[0];
		out.y += _ptran[1];
		
		return out;
	}
	
	static pathSpread = function(arr, p) {
		if(is_path(p))  { array_push(arr, p); return; }
		if(is_array(p)) {
			for( var i = 0, n = array_length(p); i < n; i++ ) 
				pathSpread(arr, p[i]);
		}
	}
	
	////- Nodes
	
	static drawOverlay = function(hover, active, _x, _y, _s, _mx, _my, _params) { 
		for( var i = 0; i < curr_path_amo; i++ ) {
			if(!has(curr_path[i], "drawOverlay")) continue;
			
			var _ptran = path_trans[i];
			var _px = _x + _ptran[0] * _s; 
			var _py = _y + _ptran[1] * _s; 
			
			InputDrawOverlay(curr_path[i].drawOverlay(hover, active, _px, _py, _s, _mx, _my, _params));
		}
		
		return w_hovering;
	}
	
	static update = function(frame = CURRENT_FRAME) {
		ds_map_clear(cached_pos);
		outputs[0].setValue(self);
		
		curr_path  = [];
		
		for( var i = input_fix_len; i < array_length(inputs); i += data_length ) {
			var _path = getInputData(i);
			pathSpread(curr_path, _path);
		}
		
		path_trans    = [];
		path_lengths  = [];
		length_accu   = [];
		line_count    = 0;
		segment_count = 0;
		length_total  = 0;
		boundary      = new BoundingBox();
		
		var _oriX = 0;
		var _oriY = 0;
		
		curr_path_amo = array_length(curr_path);
		for( var i = 0, n = array_length(curr_path); i < n; i++ ) {
			var _path = curr_path[i];
			
			if(i) {
				var _stap = _path.getPointRatio(.000);
				_oriX -= _stap.x;
				_oriY -= _stap.y;
			}
				
			path_trans[i] = [_oriX, _oriY];
			boundary.addBBOX(_path.getBoundary());
			
			var _len = _path.getLength();
			array_push(path_lengths, _len);
			
			line_count    += _path.getLineCount();
			segment_count += _path.getSegmentCount();
			length_total  += _len;
			array_append(length_accu, _path.getAccuLength());
			
			var _endp = _path.getPointRatio(.999);
			_oriX += _endp.x;
			_oriY += _endp.y;
			
		}
	}
	
}