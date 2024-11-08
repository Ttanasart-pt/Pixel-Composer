function RiggedMeshedSurface() constructor {
	mesh   = noone;
	rigMap = {};
	
	static getSurface = function() { return mesh == noone? noone : mesh.surface; }
}

function Node_Armature_Mesh_Rig(_x, _y, _group = noone) : Node(_x, _y, _group) constructor {
	name = "Armature Mesh Rig";
	setDimension(96, 72);
	
	newInput(0, nodeValue_Armature("Armature", self, noone))
		.setVisible(true, true);
	
	newInput(1, nodeValue_Mesh("Mesh", self, noone))
		.setVisible(true, true);
	
	newInput(2, nodeValue_Trigger("Autoweight", self, false ))
		.setDisplay(VALUE_DISPLAY.button, { name: "Auto weight", UI : true, onClick: function() /*=>*/ {return AutoWeightPaint()} });
		
	//////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	
	newOutput(0, nodeValue_Output("Rigged mesh", self, VALUE_TYPE.mesh, noone));
	
	rigdata = {};
	
	static AutoWeightPaint = function() {
	    var _bones = inputs[0].getValue();
        var _mesh  = inputs[1].getValue();
        
        if(!is(_bones, __Bone))        return;
        if(!is(_mesh,  MeshedSurface)) return;
        
        rigdata = {};
        
        var _boneArr = _bones.toArray();
        var _boneDat = array_create(array_length(_boneArr));
        
        for( var i = 0, n = array_length(_boneArr); i < n; i++ ) {
            var _b  = _boneArr[i];
            
            _boneDat[i] = {
                b  : _b,
                ID : _b.ID,
                p0 : _b.getPoint(0),
                p1 : _b.getPoint(1),
            };
        }
        
        var _pnts = _mesh.points;
        
        for( var i = 0, n = array_length(_pnts); i < n; i++ ) {
            var _p  = _pnts[i];
            var _px = _p.x;
            var _py = _p.y;
            
            var _minDist = 9999;
            var _minBone = noone;
            
            for( var j = 0, m = array_length(_boneDat); j < m; j++ ) {
                var _b = _boneDat[j];
                
                var _dist = distance_to_line(_px, _py, _b.p0.x, _b.p0.y, _b.p1.x, _b.p1.y);
                if(_dist < _minDist) {
                    _minDist = _dist;
                    _minBone = _b;
                }
            }
            
        }
	}
	
    static update = function() {
        var _bones = inputs[0].getValue();
        var _mesh  = inputs[1].getValue();
        
        if(!is(_bones, __Bone))        return;
        if(!is(_mesh,  MeshedSurface)) return;
        
        var _meshRigged    = new RiggedMeshedSurface();
        _meshRigged.mesh   = _mesh;
        _meshRigged.rigMap = rigdata;
        
        outputs[0].setValue(_meshRigged);
    }
}