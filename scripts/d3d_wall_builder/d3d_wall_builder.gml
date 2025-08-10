function __3dWall_builder() : __3dObject() constructor {
	VF = global.VF_POS_NORM_TEX_COL;
	render_type = pr_trianglelist;
	
	points = [];
	offset = .1;
	height = 1;
	smooth = false;
	loop   = false;
	
	static initModel = function() {
		if(array_empty(points)) return;
		
		edges   = [];
		var eid = 0;
		
		var ofl = [];
        var ofr = [];
        var len = array_length(points);
        
        for (var i = 0; i < len - 1; i++) {
            var p1 = points[i];
            var p2 = points[i + 1];
            
            var dx = p2[0] - p1[0];
            var dy = p2[1] - p1[1];
            
            var px = -dy;
            var py =  dx;
            
            var l = sqrt(px * px + py * py);
            px /= l;
            py /= l;
            
            var olx = p1[0] + px * offset;
            var oly = p1[1] + py * offset;
            var orx = p1[0] - px * offset;
            var ory = p1[1] - py * offset;
            
            array_push(ofl, [ olx, oly ]);
            array_push(ofr, [ orx, ory ]);
        }
        
        if(loop) {
            array_push(ofl, ofl[0]);
            array_push(ofr, ofr[0]);
            
            len++;
        }
        
        ofr = array_reverse(ofr);
        len -= 2;
        
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
        
		var z   = height;
		var vbl = array_create((len) * 2 * 3);
		for( var i = 0, n = len; i < n; i++ ) {
		    var p0 = ofl[i    ];
		    var p1 = ofl[i + 1];
		    
		    var x0 = p0[0], y0 = p0[1];
		    var x1 = p1[0], y1 = p1[1];
		    
		    var u0 = i / len;
		    var u1 = (i + 1) / len;
		    
		    vbl[i * 6 + 0] = new __vertex(x0, y0, 0).setNormal(-y0, x0, 0).setUV(u0, 0);
			vbl[i * 6 + 1] = new __vertex(x1, y1, 0).setNormal(-y1, x1, 0).setUV(u1, 0);
			vbl[i * 6 + 2] = new __vertex(x1, y1, z).setNormal(-y1, x1, 0).setUV(u1, 1);
		    
			vbl[i * 6 + 3] = new __vertex(x0, y0, 0).setNormal(-y0, x0, 0).setUV(u0, 0);
			vbl[i * 6 + 4] = new __vertex(x1, y1, z).setNormal(-y1, x1, 0).setUV(u1, 1);
			vbl[i * 6 + 5] = new __vertex(x0, y0, z).setNormal(-y0, x0, 0).setUV(u0, 1);
			
			if(i == 0) edges[eid++] = new __3dObject_Edge([x0, y0, 0], [x0, y0, z]);
			edges[eid++] = new __3dObject_Edge([x1, y1, 0], [x1, y1, z]);
			
			edges[eid++] = new __3dObject_Edge([x0, y0, 0], [x1, y1, 0]);
			edges[eid++] = new __3dObject_Edge([x0, y0, z], [x1, y1, z]);
		}
		
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
        
		var vbr = array_create((len) * 2 * 3);
		for( var i = 0, n = len; i < n; i++ ) {
		    var p0 = ofr[i    ];
		    var p1 = ofr[i + 1];
		    
		    var x0 = p0[0], y0 = p0[1];
		    var x1 = p1[0], y1 = p1[1];
		    
		    var u0 = i / len;
		    var u1 = (i + 1) / len;
		    
		    vbr[i * 6 + 0] = new __vertex(x0, y0, 0).setNormal(-y0, x0, 0).setUV(u0, 0);
			vbr[i * 6 + 1] = new __vertex(x1, y1, 0).setNormal(-y1, x1, 0).setUV(u1, 0);
			vbr[i * 6 + 2] = new __vertex(x1, y1, z).setNormal(-y1, x1, 0).setUV(u1, 1);
		    
			vbr[i * 6 + 3] = new __vertex(x0, y0, 0).setNormal(-y0, x0, 0).setUV(u0, 0);
			vbr[i * 6 + 4] = new __vertex(x1, y1, z).setNormal(-y1, x1, 0).setUV(u1, 1);
			vbr[i * 6 + 5] = new __vertex(x0, y0, z).setNormal(-y0, x0, 0).setUV(u0, 1);
			
			if(i == 0) edges[eid++] = new __3dObject_Edge([x0, y0, 0], [x0, y0, z]);
			edges[eid++] = new __3dObject_Edge([x1, y1, 0], [x1, y1, z]);
			
			edges[eid++] = new __3dObject_Edge([x0, y0, 0], [x1, y1, 0]);
			edges[eid++] = new __3dObject_Edge([x0, y0, z], [x1, y1, z]);
		}
		
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
        
        if(loop) {
            vbs = [];
        } else {
    		var vbs = array_create(4 * 3);
    		
    		var p0 = ofl[0];
    	    var p1 = ofr[len];
    	    
    	    var x0 = p0[0], y0 = p0[1];
    	    var x1 = p1[0], y1 = p1[1];
    	    
    		vbs[0] = new __vertex(x0, y0, 0).setNormal(-y0, x0, 0).setUV(0, 0);
    		vbs[1] = new __vertex(x1, y1, z).setNormal(-y1, x1, 0).setUV(1, 1);
    		vbs[2] = new __vertex(x1, y1, 0).setNormal(-y1, x1, 0).setUV(1, 0);
    	    
    		vbs[3] = new __vertex(x0, y0, 0).setNormal(-y0, x0, 0).setUV(0, 0);
    		vbs[4] = new __vertex(x0, y0, z).setNormal(-y0, x0, 0).setUV(0, 1);
    		vbs[5] = new __vertex(x1, y1, z).setNormal(-y1, x1, 0).setUV(1, 1);
    		
    		edges[eid++] = new __3dObject_Edge([x0, y0, 0], [x1, y1, 0]);
    		edges[eid++] = new __3dObject_Edge([x0, y0, z], [x1, y1, z]);
    		
    		var p0 = ofl[len];
    	    var p1 = ofr[0];
    	    
    	    var x0 = p0[0], y0 = p0[1];
    	    var x1 = p1[0], y1 = p1[1];
    	    
    		vbs[6] = new __vertex(x0, y0, 0).setNormal(-y0, x0, 0).setUV(0, 0);
    		vbs[7] = new __vertex(x1, y1, 0).setNormal(-y1, x1, 0).setUV(1, 0);
    		vbs[8] = new __vertex(x1, y1, z).setNormal(-y1, x1, 0).setUV(1, 1);
    	    
    		vbs[ 9] = new __vertex(x0, y0, 0).setNormal(-y0, x0, 0).setUV(0, 0);
    		vbs[10] = new __vertex(x1, y1, z).setNormal(-y1, x1, 0).setUV(1, 1);
    		vbs[11] = new __vertex(x0, y0, z).setNormal(-y0, x0, 0).setUV(0, 1);
    		
    		edges[eid++] = new __3dObject_Edge([x0, y0, 0], [x1, y1, 0]);
    		edges[eid++] = new __3dObject_Edge([x0, y0, z], [x1, y1, z]);
    		
        }
		
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
        
		var vbt = array_create((len) * 2 * 3);
		for( var i = 0, n = len; i < n; i++ ) {
		    var p0 = ofl[i    ];
		    var p1 = ofl[i + 1];
		    var p2 = ofr[len - 1 - i    ];
		    var p3 = ofr[len - 1 - i + 1];
		    
		    var x0 = p0[0], y0 = p0[1];
		    var x1 = p1[0], y1 = p1[1];
		    var x2 = p2[0], y2 = p2[1];
		    var x3 = p3[0], y3 = p3[1];
		    
		    var u0 = i / len;
		    var u1 = (i + 1) / len;
		    
		    vbt[i * 6 + 0] = new __vertex(x0, y0, z).setNormal(0, 0, 1).setUV(u0, 0);
			vbt[i * 6 + 1] = new __vertex(x1, y1, z).setNormal(0, 0, 1).setUV(u1, 0);
			vbt[i * 6 + 2] = new __vertex(x3, y3, z).setNormal(0, 0, 1).setUV(u1, 1);
		    
			vbt[i * 6 + 3] = new __vertex(x1, y1, z).setNormal(0, 0, 1).setUV(u1, 0);
			vbt[i * 6 + 4] = new __vertex(x2, y2, z).setNormal(0, 0, 1).setUV(u0, 1);
			vbt[i * 6 + 5] = new __vertex(x3, y3, z).setNormal(0, 0, 1).setUV(u1, 1);
		}
		
		edges  = [ edges ];
		vertex = [ vbl, vbr, vbs, vbt ];
		object_counts = array_length(vertex);
		VB = build();
		
	} initModel();
	
	static onParameterUpdate = initModel;
}