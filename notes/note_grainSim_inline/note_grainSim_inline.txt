[banner][color=#ffe478]
This node is part of the <a href="https://docs.pixel-composer.com/nodes/grainSim">GrainSim</a> category.
[/banner]

GrainSim simulates pixel-level material simulation. It use Material point method (MPM), which is an extension to FLIP. Hence, the node can be seen as 
a combination between <node Node_FLIP_Group_Inline> and <node Node_Rigid_Group_Inline> but leans closer to <node Node_FLIP_Group_Inline>.

In this system. Each pixel represent material point (also called grain). Each grain can moves freely which allow the object to break and bend in 
soft-body manner. Grain proerty is defined globally in <node Node_GrainSim_Domain>.

[link]https://github.com/yuanming-hu/taichi_mpm[/link]