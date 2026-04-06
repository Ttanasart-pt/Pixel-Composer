# Pixel Composer Doc

A documentation page for [Pixel Composer](https://github.com/Ttanasart-pt/Pixel-Composer).

Github page: https://docs.pixel-composer.com

## Editing

Edit files in `content/` then call `py ./gen/main.py` to generate all pages.

- Page name can begins with number to force ordering. Number needs to ends with underscore `_` before the actual name ("2_interfaces").

## Media

All media are stored in `src`. Every image should use different name (even in different directory.) to allow for tag shortcuts.

## Tag shortcuts

There are multiple tag shortcuts that can be use to simplify writing. There tag will be replaced when call `gen/main.py`.

`<img [image name]>`

Add image with default style (image name without extension).

`<img-deco [image name]>`

Add image with corner + frame decoration.

`<node [node name]>`

Add link to specific node page.

`<junc [junction]>`

(Only works in `content/__nodes`) Add decorated junction with type data.

`<attr [attribute name]>`

(Only works in `content/__nodes`) Add decorated attrubute.