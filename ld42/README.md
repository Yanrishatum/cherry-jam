# Edgy Fantasy Battle Deluxe - a Ludum Dare 42 game

This is our third game on Ludum Dare as well as first our 3D game and first game made on Heaps.

Source code is distributed to showcase what can be done on Heaps in just 3 days. As well as example of html5 3D game on this engine.
I literally started learning Heaps around a month before doing this, however I do have expansive knowledge of HaxePunk (old one) and based lots of my code on it.

## Compilation
* I use git Heaps, but it (probably) should work on 1.6.1
* [Gasm-heaps](https://github.com/lbergman/GASM-heaps) and [msignal](https://github.com/massiveinteractive/msignal) are patched for Heaps/haxe4 compatibility and stored in `vendor` folder.
* Haxe4-rc1 should be compatible.
* Other libraries that can be downloaded from `haxelib`: 
```
format: latest
structural: latest?
gasm: 1.4.1
  actuate: 1.8.7 (I think I fixed it for Haxe4)
  buddy: 2.8.5
    promhx: 1.1.0
    asynctools: 0.1.0
```
* Compile `build.hxml` for hl output, `build_c.hxml` for HLC output and `build_js.hxml` for HTML5.