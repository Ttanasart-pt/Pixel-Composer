<v 1.18.0/>
Cache animation as surface array. If the output is being used in other nodes, it is recommended to play the animation at least once to capture the full range of frames.

## Properties

### <junc start frame>
The first frame to cache (set to -1 to cache from the first frame).

### <junc stop frame>
The last frame to cache (set to -1 to cache to the last frame).

### <junc step>
The frame step, 1 means every frame, 2 means every other frame, etc.