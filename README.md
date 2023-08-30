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
Description:
 - 200m road.
 - Two lanes with opposite direction.

<img src="docs/straight_forward.png" width=500>


Options:
 - `LENGTH`: Length of the road(default 500m).
 - `WIDTH`: Width of the lanes(default 3m).
 - `CROSSWALK`: Adds a 2m-width crosswalk in the middle(s=100m).(default=`False`)
 - `X_OFFSET`: X offset with respect to the origin.
 - `Y_OFFSET`: Y offset with respect to the origin.

For generating a XODR file by using this template simply execute:

```sh
CROSSWALK=True WIDTH=4 empy3 templates/straight_forward.xml.em > generated_file.xodr
```

### Intersection
Description:
 - 4 road intersection.

<img src="docs/intersection.png" width=500>

Options:
 - `WIDTH`: Width of the lanes(default 3m).
 - `RADIUS`: Radius of the junction's border(default 8m).
 - `CROSSWALK`: Adds a crosswalk in each of the four sides of the intersection.(default=`False`)
 - `CROSSWALK_LENGTH`: Length of the crosswalk to be added if enabled.(default 2m)
 - `X_OFFSET`: X offset with respect to the origin.
 - `Y_OFFSET`: Y offset with respect to the origin.

For generating a XODR file by using this template simply execute:

```sh
WIDTH=4 RADIUS=8 CROSSWALK=True CROSSWALK_LENGTH=2 empy3 templates/intersection.xml.em > generated_file.xodr
```

### Bus Stop
Description:
 - A two-way road with a bus stop
   - Modelled as an extra lane of lane type: `special1`
 - geoJSON information is added for the bus stop lane only.

<img src="docs/bus_stop_lane.png" width=300>

Options:
 - `WIDTH`: Width of the lanes(default 4m).
 - `EXTENSIONS_LENGTH`: Length of the outer lane sections(default 30m).
 - `BUS_STOP_LENGTH`: Length of the bus stop lane(default 15m).
 - `MERGE_LENGTH`: Length of the merge lane connecting to the bust stop lane (10m).
 - `X_OFFSET`: X offset with respect to the origin.
 - `Y_OFFSET`: Y offset with respect to the origin.

For generating a XODR file by using this template simply execute:

```sh
WIDTH=4 EXTENSIONS_LENGTH=30 BUS_STOP_LENGTH=15 MERGE_LENGTH=10 empy3 templates/bus_stop.xml.em > generated_file.xodr
```

## Resources

Example files with different values are provided under the `resources` folder.

## Standalone maps

Standalone maps that do not correspond to a particular template are added in the `standalone` folder.

 - [12_map_integration](standalone/12_map_integration/) map:
    A large-combined map was created out of the available `resources`.
    See [12_map_integration/README](standalone/12_map_integration/README.md) for more information about the map creation process.

    <img src="docs/12_map_integration.png" width=500>

