function check_directory_redirector(path) {
    var _dir = filename_dir(path) + "\\";
    var _rep = 0;
    
    // print($"Checkin rediect for {array_length(PROJECT.pathInputs)} inputs to {_dir}");
    
    for( var i = 0, n = array_length(PROJECT.pathInputs); i < n; i++ ) {
        var _j = PROJECT.pathInputs[i];
        if(!is(_j, NodeValue)) continue;
        if(!_j.node.active)    continue;
        
        var _p = _j.getValue();
        if(file_exists(_p))    continue;
        
        var _fname = filename_name(_p);
        var _npath = _dir + _fname;
        
        if(file_exists(_npath)) {
            _j.setValue(_npath);
            _rep++;
        }
    }
    
    if(_rep) noti_warning($"Redirect {_rep} file input(s) to use the new directory.");
}