function Node_Differential(_x, _y, _group = noone) : Node_Processor(_x, _y, _group) constructor {
    name		= "Differential";
    color		= COLORS.node_blend_number;
    
    setDimension(96, 48);
    
    newInput(0, nodeValue_Float("Value", 0))
        .setVisible(true, true);
    
    newOutput(0, nodeValue_Output("Result", VALUE_TYPE.float, 0));
    
    prev_values = [];
    
    static processData = function(_output, _data, _array_index = 0) {
        var _v = _data[0];
        
        var _p = array_safe_get_fast(prev_values, _array_index, 0);
        if(!is_array(_p)) _p = [ 0, 0 ];
        
        var _dx = _v - _p[0];
        var _dt = CURRENT_FRAME - _p[1];
        
        _p[0] = _v;
        _p[1] = CURRENT_FRAME;
        prev_values[_array_index] = _p;
        
        return _dt == 0? 0 : _dx / _dt;
    }
    
    static onDrawNode = function(xx, yy, _mx, _my, _s, _hover, _focus) {
        var bbox = drawGetBbox(xx, yy, _s);
        draw_sprite_bbox_uniform(s_node_differential, 0, bbox);
    }
}
