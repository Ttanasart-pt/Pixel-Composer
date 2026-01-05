/*

BSD 2-Clause License

Copyright © 2021, Samuel Venable
All rights reserved.

Redistribution and use in source and binary forms, with or without
modification, are permitted provided that the following conditions are met:

1. Redistributions of source code must retain the above copyright notice, this
   list of conditions and the following disclaimer.

2. Redistributions in binary form must reproduce the above copyright notice,
   this list of conditions and the following disclaimer in the documentation
   and/or other materials provided with the distribution.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE
FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

*/

#define sprite_create_from_file
image_load(argument0);
width = image_get_width(argument0);
height = image_get_height(argument0);
channel = buffer_sizeof(buffer_u64);
buffer = buffer_create(channel * width * height, buffer_fixed, channel);
if (!buffer_exists(buffer)) return -1;
buffer_poke(buffer, buffer_get_size(buffer) - 1, buffer_u8, 0);
surface = surface_create(width, height);
surface_set_target(surface);
draw_clear_alpha(c_black, 0);
image_set_buffer(argument0, buffer_get_address(buffer));
buffer_set_surface(buffer, surface, 0);
if (!surface_exists(surface)) return -1;
sprite = sprite_create_from_surface(surface, 0, 0, width, height, argument1, argument2, argument3, argument4);
surface_reset_target();
surface_free(surface);
buffer_delete(buffer);
return sprite;

#define sprite_add_from_file
image_load(argument1);
width = image_get_width(argument1);
height = image_get_height(argument1);
channel = buffer_sizeof(buffer_u64);
buffer = buffer_create(channel * width * height, buffer_fixed, channel);
if (!buffer_exists(buffer)) return;
buffer_poke(buffer, buffer_get_size(buffer) - 1, buffer_u8, 0);
surface = surface_create(width, height);
surface_set_target(surface);
draw_clear_alpha(c_black, 0);
image_set_buffer(argument1, buffer_get_address(buffer));
buffer_set_surface(buffer, surface, 0);
if (!surface_exists(surface)) return;
sprite_add_from_surface(argument0, surface, 0, 0, width, height, argument2, argument3);
surface_reset_target();
surface_free(surface);
buffer_delete(buffer);
