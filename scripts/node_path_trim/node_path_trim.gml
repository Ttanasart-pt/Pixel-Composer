function Node_Path_Trim(_x, _y, _group = noone) : Node_Processor(_x, _y, _group) constructor {
	name = "Trim Path";
	setDimension(96, 48);

	newInput(0, nodeValue_PathNode(     "Path"));
	newInput(3, nodeValue_Enum_Scroll(  "Trim Mode", 0, { data: ["Progress", "Anchor"], update_hover: false }));
	newInput(1, nodeValue_Slider_Range( "Range", [ 0, 1 ]));
	newInput(2, nodeValue_Float(        "Shift", 0));

	newOutput(0, nodeValue_Output("Path", VALUE_TYPE.pathnode, noone));

	input_display_list = [ 0, 3, 1, 2 ];
	disp_type = 0;

	function _trimmedPath(_node) : Path(_node) constructor {
		curr_path  = noone;
		curr_range = noone;
		
		static drawOverlay = function(hover, active, _x, _y, _s, _mx, _my, _snx, _sny, _params) { 
			var hovering = false;
			if(has(curr_path, "drawOverlay")) {
				var hv = curr_path.drawOverlay(hover, active, _x, _y, _s, _mx, _my, _snx, _sny, _params);
				hovering = hovering || hv;
			}
			
			PathDrawOverlay(self, _x, _y, _s);
			
			return hovering;
		}
		
		static getLineCount    = function(   ) /*=>*/ {return is_path(curr_path)? curr_path.getLineCount()     : 1};
		static getSegmentCount = function(i=0) /*=>*/ {return is_path(curr_path)? curr_path.getSegmentCount(i) : 0};
		static getLength       = function(i=0) /*=>*/ {return is_path(curr_path)? curr_path.getLength(i)       : 0};
		static getAccuLength   = function(i=0) /*=>*/ {return is_path(curr_path)? curr_path.getAccuLength(i)   : []};
		static getBoundary     = function(i=0) /*=>*/ {return is_path(curr_path)? curr_path.getBoundary(i)     : new BoundingBox( 0, 0, 1, 1 )};
			
		static getPointRatio = function(_rat, ind = 0, out = undefined) {
			if(!is_path(curr_path)) return out;
			
			_rat = lerp(curr_range[0], curr_range[1], _rat);
			return curr_path.getPointRatio(_rat, ind, out);
		}
		
		static getPointDistance = function(_dist, ind = 0, out = undefined) { return getPointRatio(_dist / getLength(), ind, out); }
	}

	function _trimmedPathAnchors(_anchors, _weights, _sample) : Path() constructor {
		anchors = _anchors;
		weights = _weights;
		sample = _sample;  
		segments = [];     
		sampleWeights = [];
		lengthTotal = 0;   
		lengths = [];      
		lengthAccs = [];   
		boundary = new BoundingBox();
		curr_range = noone;
		curr_path  = noone;

		static drawOverlay = function(hover, active, _x, _y, _s, _mx, _my, _snx, _sny, _params) { 
			var hovering = false;
			if(has(curr_path, "drawOverlay")) {
				var hv = curr_path.drawOverlay(hover, active, _x, _y, _s, _mx, _my, _snx, _sny, _params);
				hovering = hovering || hv;
			}
			
			PathDrawOverlay(self, _x, _y, _s);
			
			return hovering;
		}

		// Crop outgoing handle of last anchor to prevent bezier overextension
		var anchor_count = array_length(anchors);
		if (anchor_count > 0) {
			anchors[anchor_count - 1][4] = 0;
			anchors[anchor_count - 1][5] = 0;
		}

		// Sample segments and weights
		if (anchor_count == 1) {
			var anchor = anchors[0];
			array_push(segments, new __vec2(anchor[0], anchor[1]));
			array_push(sampleWeights, is_array(_weights[0]) ? _weights[0][1] : _weights[0]);
		} else {
			for (var seg_idx = 0; seg_idx < anchor_count - 1; seg_idx++) {
				var a0 = anchors[seg_idx];
				var a1 = anchors[seg_idx + 1];
				var segDist = point_distance(a0[0], a0[1], a1[0], a1[1]);
				var h0x = a0[4], h0y = a0[5];
				var h1x = a1[2], h1y = a1[3];
				var h0len = point_distance(0, 0, h0x, h0y);
				var h1len = point_distance(0, 0, h1x, h1y);
				var maxHandle = max(0.0001, segDist);
				var h0scale = h0len > maxHandle ? (maxHandle / h0len) : 1;
				var h1scale = h1len > maxHandle ? (maxHandle / h1len) : 1;
				var weightA = is_array(_weights[seg_idx]) ? _weights[seg_idx][1] : _weights[seg_idx];
				var weightB = is_array(_weights[seg_idx + 1]) ? _weights[seg_idx + 1][1] : _weights[seg_idx + 1];
				for (var sample_idx = 0; sample_idx <= sample; sample_idx++) {
					var u = sample_idx / sample;
					var nx, ny;
					if (h0x == 0 && h0y == 0 && h1x == 0 && h1y == 0) {
						nx = lerp(a0[0], a1[0], u);
						ny = lerp(a0[1], a1[1], u);
					} else {
						var c0x = a0[0] + h0x * h0scale;
						var c0y = a0[1] + h0y * h0scale;
						var c1x = a1[0] + h1x * h1scale;
						var c1y = a1[1] + h1y * h1scale;
						nx = eval_bezier_x(u, a0[0], a0[1], a1[0], a1[1], c0x, c0y, c1x, c1y);
						ny = eval_bezier_y(u, a0[0], a0[1], a1[0], a1[1], c0x, c0y, c1x, c1y);
					}
					array_push(segments, new __vec2(nx, ny));
					array_push(sampleWeights, lerp(weightA, weightB, u));
				}
			}
		}

		// Compute segment lengths and update bounding box
		var prev_x, prev_y;
		for (var seg_i = 0; seg_i < array_length(segments); seg_i++) {
			var pt = segments[seg_i];
			boundary.addPoint(pt.x, pt.y);
			if (seg_i > 0) {
				var seg_length = point_distance(prev_x, prev_y, pt.x, pt.y);
				lengthTotal += seg_length;
				lengths[seg_i - 1] = seg_length;
				lengthAccs[seg_i - 1] = lengthTotal;
			}
			prev_x = pt.x;
			prev_y = pt.y;
		}

		static getLineCount    = function() { return 1; };
		static getSegmentCount = function() { return array_length(lengths); };
		static getBoundary     = function() { return boundary; };
		static getLength       = function() { return lengthTotal; };
		static getAccuLength   = function() { return lengthAccs; };
		static getPointDistance = function(_dist, _ind = 0, out = undefined) {
			if (out == undefined) out = new __vec2P();
			else { out.x = 0; out.y = 0; }
			if (lengthTotal <= 0) { out.weight = 1; return out; }
			var l = _dist;
			for (var seg_i = 0; seg_i < array_length(lengths); seg_i++) {
				var seg_len = lengths[seg_i];
				if (l <= seg_len) {
					var rat = seg_len == 0 ? 0 : l / seg_len;
					var p0 = segments[seg_i];
					var p1 = segments[seg_i + 1];
					out.x = lerp(p0.x, p1.x, rat);
					out.y = lerp(p0.y, p1.y, rat);
					// Interpolate weight between samples
					var idx0 = clamp(seg_i * (sample + 1) + floor(rat * sample), 0, array_length(sampleWeights) - 1);
					var idx1 = clamp(idx0 + 1, 0, array_length(sampleWeights) - 1);
					var t = rat * sample - floor(rat * sample);
					out.weight = lerp(sampleWeights[idx0], sampleWeights[idx1], t);
					return out;
				}
				l -= seg_len;
			}
			// Fallback: return last point and weight
			var last_idx = array_length(segments) - 1;
			if (last_idx >= 0) {
				out.x = segments[last_idx].x;
				out.y = segments[last_idx].y;
			}
			out.weight = sampleWeights[array_length(sampleWeights) - 1];
			return out;
		};
	}
	static drawOverlay = function(hover, active, _x, _y, _s, _mx, _my, _snx, _sny, _params) { 
		InputDrawOverlay(outputs[0].drawOverlay(hover, active, _x, _y, _s, _mx, _my, _snx, _sny, _params));
		return w_hovering;
	}
	
	static processData = function(_outData, _data, _array_index = 0) { 
		var _path = _data[0];
		var _rang = [ _data[1][0], _data[1][1] ];
		var _shft = _data[2];
		var _disp = _data[3];
		
		var _updated_disp_type = disp_type != _disp;
		disp_type = _disp;
		
		switch (disp_type) {
			case 0:
				if (_updated_disp_type)
					inputs[1].setDefValue([0, 1]);

				if(!is(_outData, _trimmedPath)) 
					_outData = new _trimmedPath(self);
		
				_rang[0] += _shft;
				_rang[1] += _shft;
				
				_outData.cached_pos = {};
				_outData.curr_path  = _path;
				_outData.curr_range = _rang;

			case 1:
				var _path_len = is_path(_path) ? array_length(_path.anchors) : 0;
				if (_updated_disp_type)
					inputs[1].setDefValue([0, _path_len]);
				_shft = floor(_shft);
				var start_idx = clamp(round(_rang[0] + _shft), 0, _path_len);
				var end_idx   = clamp(round(_rang[1] + _shft), 0, _path_len);
				if (end_idx <= start_idx || _path_len == 0) {
					_outData.curr_range = _rang;
					return _outData;
				}
				var _new_anchors = [];
				for (var i = start_idx; i < end_idx; i++) {
					var _a = array_safe_get(is_path(_path)? _path.anchors : [], i, undefined);
					if (!is_array(_a)) {
						_a = [0,0,0,0,0,0];
					} else if (array_length(_a) < 6) {
						_a = array_clone(_a, 1);
						array_resize(_a, 6);
						for (var _ai = 0; _ai < 6; _ai++) if (is_undefined(_a[_ai])) _a[_ai] = 0;
					} else {
						_a = array_clone(_a, 1);
					}
					array_push(_new_anchors, _a);
				}
				var _new_weights = [];
				if (is_path(_path) && has(_path, "weights")) {
					for (var i = start_idx; i < end_idx; i++)
						array_push(_new_weights, array_safe_get(_path.weights, i, 1));
				} else {
					var anchor_count = array_length(_new_anchors);
					for (var i = 0; i < anchor_count; i++) array_push(_new_weights, 1);
				}
				var sample = PREFERENCES.path_resolution;
				var trimmed = new _trimmedPathAnchors(_new_anchors, _new_weights, sample);
				_outData = trimmed;
				_outData.curr_range = _rang;
				_outData.curr_path  = _path;
				return _outData;
				break;
		}

	}
	
	static onDrawNode = function(xx, yy, _mx, _my, _s, _hover, _focus) {
		var bbox = draw_bbox;
		draw_sprite_fit(s_node_path_trim, 0, bbox.xc, bbox.yc, bbox.w, bbox.h);
	}
}
