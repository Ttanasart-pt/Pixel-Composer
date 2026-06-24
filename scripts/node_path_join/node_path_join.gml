function Node_Path_Join(_x, _y, _group = noone) : Node(_x, _y, _group) constructor {
	name = "Path Join";
	setDrawIcon();
	setDimension(96, 48);
	
	newOutput(0, nodeValue_Output("Joined Path", VALUE_TYPE.pathnode, self));
	
	input_display_list = [
		[ "Paths", false ], 
	];
	
	function createNewInput(i = array_length(inputs)) {
		newInput(i+0, nodeValue_Path( "Path"           ));
		newInput(i+1, nodeValue_Bool( "Reverse", false ));
		
		if(i > input_fix_len)
			array_push(input_display_list, new Inspector_Spacer(ui(6), true));
		array_push(input_display_list, i+0, i+1);
		return inputs[i];
	} 
	
	setDynamicInput( 2, true, VALUE_TYPE.pathnode);
	
	////- Path
	
	cached_pos    = ds_map_create();
	curr_path_amo = 0;
	path_data     = [];
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
		
		var _path = path_data[_ind][0];
		var _revr = path_data[_ind][1];
		
		if(_revr) _dist = path_lengths[_ind] - _dist;
		out = _path.getPointDistance(_dist, ind, out);
		
		var _ptran = path_trans[_ind];
		out.x += _ptran[0];
		out.y += _ptran[1];
		
		return out;
	}
	
	////- Nodes
	
	static drawOverlay = function(hover, active, _x, _y, _s, _mx, _my, _params) { 
		for( var i = 0; i < curr_path_amo; i++ ) {
			var _path = path_data[i][0];
			if(!has(_path, "drawOverlay")) continue;
			
			var _ptran = path_trans[i];
			var _px = _x + _ptran[0] * _s; 
			var _py = _y + _ptran[1] * _s; 
			
			drawOverlayInput(_path.drawOverlay(hover, active, _px, _py, _s, _mx, _my, _params));
		}
		
		return w_hovering;
	}
	
	static update = function(frame = CURRENT_FRAME) {
		ds_map_clear(cached_pos);
		outputs[0].setValue(self);
		
		path_data = [];
		
		for( var i = input_fix_len; i < array_length(inputs); i += data_length ) {
			var _pth = getInputData(i+0);
			var _rev = getInputData(i+1);
			
			if(is_path(_pth)) {
				array_push(path_data, [_pth, _rev]);
				
			} else if(is_array(_pth)) {
				for( var j = 0, m = array_length(_pth); j < m; j++ )
					array_push(path_data, [_pth[j], _rev]);
			}
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
		
		curr_path_amo = array_length(path_data);
		for( var i = 0, n = array_length(path_data); i < n; i++ ) {
			var _path = path_data[i][0];
			var _revr = path_data[i][1];
			
			if(i) {
				var _stap = _path.getPointRatio(_revr? .999 : 0);
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
			
			var _endp = _path.getPointRatio(_revr? 0 : .999);
			_oriX += _endp.x;
			_oriY += _endp.y;
			
		}
	}
	
}