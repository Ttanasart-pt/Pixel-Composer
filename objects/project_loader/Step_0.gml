
switch(load_process) {
    case 1 : 
        if(!struct_has(content, "nodes")) {
            log_warning("LOAD", "Cannot read node data.");
            instance_destroy();
            break;
        }
        
		var _node_list = content.nodes;
		var _t   = get_timer();
		var _skp = false;
		
    	try {
    		if(load_step == 0) {
        		load_total  = array_length(_node_list);
        		create_list = array_create(array_length(_node_list));
    		}
    		
    		for(; load_step < load_total; load_step++) {
    			
    			var _node = nodeLoad(_node_list[load_step]);
    			if(_node) create_list[node_length++] = _node;
    			
    			var _ts = get_timer() - _t;
    			if(load_step < load_total - 1 && _ts > load_delay) {
    			    _skp = true;
    			    break;
    			}
    		}
    		
    	} catch(e) {
    		log_warning("LOAD", exception_print(e));
    	}
        
        load_noti.progress = lerp(0, .75, load_step / load_total);
        if(_skp) break;
        
		array_resize(create_list, node_length);
        PROJECT.deserialize(content);
        
        printIf(log, $" > Load nodes : {(get_timer() - t1) / 1000} ms"); t1 = get_timer();
        load_process = 2;
        load_step    = 0;
    // break;
    
    // case 2 : 
        ds_queue_clear(CONNECTION_CONFLICT);
        
        try {
        	array_foreach(create_list, function(node) /*=>*/ {return node.loadGroup()} );
        	
        } catch(e) {
        	log_warning("LOAD, group", exception_print(e));
        	return false;
        }
        
        printIf(log, $" > Load group : {(get_timer() - t1) / 1000} ms"); t1 = get_timer();
        load_process = 3;
    // break;
    
    // case 3 : 
        try {
        	array_foreach(create_list, function(node) /*=>*/ {return node.postDeserialize()} );
        } catch(e) {
        	log_warning("LOAD, deserialize", exception_print(e));
        }
        
        printIf(log, $" > Deserialize: {(get_timer() - t1) / 1000} ms"); t1 = get_timer();
        load_process = 4;
    // break;
    
    // case 4 : 
    //     var _skp = false;
// 		var _t   = get_timer();
		
        try {
            for(; load_step < node_length; load_step++) {
                create_list[load_step].applyDeserialize();
                
    // 			var _ts = get_timer() - _t;
    // 			if(load_step < node_length - 1 && _ts > load_delay) {
    // 			    _skp = true;
    // 			    break;
    // 			}
            }
            
        } catch(e) {
        	log_warning("LOAD, apply deserialize", exception_print(e));
        }
        
        // load_noti.progress = lerp(.75, .9, load_step / node_length);
        // if(_skp) break;
        
        load_noti.progress = .9;
        printIf(log, $" > Apply deserialize : {(get_timer() - t1) / 1000} ms"); t1 = get_timer();
        load_process = 5;
        load_step    = 0;
    // break;
    
    // case 5 : 
        try {
        	array_foreach(create_list, function(node) /*=>*/ {return node.preConnect()}  );
        	array_foreach(create_list, function(node) /*=>*/ {return node.connect()}     );
        	array_foreach(create_list, function(node) /*=>*/ {return node.postConnect()} );
        } catch(e) {
        	log_warning("LOAD, connect", exception_print(e));
        }
        
        printIf(log, $" > Connect : {(get_timer() - t1) / 1000} ms"); t1 = get_timer();
        
        if(!ds_queue_empty(CONNECTION_CONFLICT)) {
        	var pass = 0;
        	
        	try {
        		while(++pass < 4 && !ds_queue_empty(CONNECTION_CONFLICT)) {
        			var size = ds_queue_size(CONNECTION_CONFLICT);
        			log_message("LOAD", $"[Connect] {size} Connection conflict(s) detected (pass: {pass})");
        			repeat(size) ds_queue_dequeue(CONNECTION_CONFLICT).connect();
        			repeat(size) ds_queue_dequeue(CONNECTION_CONFLICT).postConnect();
        			Render();
        		}
        		
        		if(!ds_queue_empty(CONNECTION_CONFLICT))
        			log_warning("LOAD", "Some connection(s) is unsolved. This may caused by render node not being update properly, or image path is broken.");
        	} catch(e) {
        		log_warning("LOAD, connect solver", exception_print(e));
        	}
        }
        
        load_noti.progress = 0.92;
        printIf(log, $" > Conflict : {(get_timer() - t1) / 1000} ms"); t1 = get_timer();
        load_process = 6;
    // break;
    
    // case 6 : 
        try {
        	array_foreach(create_list, function(node) { node.postLoad(); } );
        } catch(e) {
        	log_warning("LOAD, connect", exception_print(e));
        }
        
        printIf(log, $" > Post load : {(get_timer() - t1) / 1000} ms"); t1 = get_timer();
    
        try {
        	array_foreach(create_list, function(node) { node.clearInputCache(); } );
        } catch(e) {
        	log_warning("LOAD, connect", exception_print(e));
        }
        
        load_noti.progress = 0.95;
        printIf(log, $" > Clear cache : {(get_timer() - t1) / 1000} ms"); t1 = get_timer();
        load_process = 7;
    // break;
    
    // case 7 : 
        RENDER_ALL_REORDER
        
        LOADING = false;
        PROJECT.modified = false;
        
        if(!IS_CMD) PANEL_MENU.setNotiIcon(THEME.noti_icon_file_load);
        
        refreshNodeMap();
        
        printIf(log, $" > Refresh map : {(get_timer() - t1) / 1000} ms"); t1 = get_timer();
        
        if(struct_has(content, "timelines") && !array_empty(content.timelines.contents))
        	PROJECT.timelines.deserialize(content.timelines);
        
        printIf(log, $" > Timeline : {(get_timer() - t1) / 1000} ms"); t1 = get_timer();
        
        if(!IS_CMD) {
            PANEL_GRAPH.toCenterNode();
            PANEL_GRAPH.draw_refresh = true;
        }
        
        log_message("FILE", $"load {path} completed in {(get_timer() - t0) / 1000} ms", THEME.noti_icon_file_load);
        log_console("Loaded project: " + path);
        
        printIf(log, $"========== Load {array_length(PROJECT.allNodes)} nodes completed in {(get_timer() - t0) / 1000} ms ==========");
        
        if((PROJECT.load_layout || PREFERENCES.save_layout) && struct_has(content, "layout"))
        	LoadPanelStruct(content.layout.panel);
        
        array_remove(STATS_PROGRESS, load_noti);
        instance_destroy();
    
}