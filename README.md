# maliput_xodr

OpenDRIVE resources for internal testing

## Map Templates

Templatized XODR files are provided for XODR description customizing.

The files are generated using the options selected via environment variable.

This is achieved using [empy](https://github.com/dirk-thomas/empy) tool. For installing:
```
pip install empy
```


### Straight Forward
Options:
 - `WIDTH`: Width of the lanes(default 3m)

For using this template simply execute:

```sh
WIDTH=5 empy3 templates/straight_forward.xml.em > generated_file.xodr
```

Generated files are provided under the `resources` folder. 

