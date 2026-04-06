Audio window takes a sample from audioBit and convert it to array of numbers. 

Windowing mean taking a slice of 
data from larger data set by sampling a small portion of it. This is done to reduce the amount of data to be processed.


<img audio_window_sample>



## Window Properties


Properties in the window section are used to control the window position and scale. The <junc Width> 
control the size of the window.

The <junc Location> control the position on the windows.


If <junc Match timeline> is selected, then the location will be ties to the 
project animations.


## Window Output


The output of the window is an array of numbers. The size of the array is determined by the <junc Width> 
and <junc Step>. The <junc Step> control the distance between each sample. 


Thus the final array size will be <junc Width> / <junc Step>.