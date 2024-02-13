## intersection with crosswalk integration

### Submaps

1. intersection with crosswalk with 3m lane width
2. intersection with crosswalk with 3.5m lane width
3. intersection with crosswalk with 4m lane width

### Submap distribution
```
sub_map_1 --- sub_map_2 --- sub_map_3
```

 - The submaps aren't connected to each other.

### Procedure for creating the large map
For creating the map the following steps were taken.

1. Create the 3 submaps with the correspondent offset in a way that when merged no overlapping occurs
2. Adapt the road ids and junction ids to avoid any kind of clashing among ids.
3. Merge all OpenDRIVE descriptions into one.
4. Merge all GeoJSON descriptions into one.


#### Creation of submaps

For the creation of the submaps with the correspondent offset. The X_OFFSET and Y_OFFSET argument were used.


- sub_map_1
  ```
  X_OFFSET=0. Y_OFFSET=0. EXTENSIONS_LENGTH=300. CROSSWALK=True WIDTH=3. empy3 templates/intersection.xml.em > sub_map_1.xodr
  ```
- sub_map_2
  ```
  X_OFFSET=700. Y_OFFSET=0. EXTENSIONS_LENGTH=300. CROSSWALK=True WIDTH=3.5 empy3 templates/intersection.xml.em > sub_map_2.xodr
  ```
- sub_map_3
  ```
  X_OFFSET=1400. Y_OFFSET=0. EXTENSIONS_LENGTH=300. CROSSWALK=True WIDTH=4. empy3 templates/intersection.xml.em > sub_map_3.xodr
  ```
