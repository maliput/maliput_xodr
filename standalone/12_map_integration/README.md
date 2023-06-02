## 12_map_integration map


The 12_map_integration map is composed of 12 submaps.

<img src="../../docs/12_map_integration.jpg" width=500>

### Submaps


 - sub_map_1 : [straight_forward_3m_width.xodr](../../resources/straight_forward/straight_forward_3m_width.xodr)
 - sub_map_2 : [straight_forward_3_5m_width.xodr](../../resources/straight_forward/straight_forward_3_5m_width.xodr)
 - sub_map_3 : [straight_forward_4m_width.xodr](../../resources/straight_forward/straight_forward_4m_width.xodr)
 - sub_map_4 : [straight_forward_3m_width_crosswalk.xodr](../../resources/straight_forward/straight_forward_3m_width_crosswalk.xodr)
 - sub_map_5 : [straight_forward_3_5m_width_crosswalk.xodr](../../resources/straight_forward/straight_forward_3_5m_width_crosswalk.xodr)
 - sub_map_6 : [straight_forward_4m_width_crosswalk.xodr](../../resources/straight_forward/straight_forward_4m_width_crosswalk.xodr)
 - sub_map_7 : [intersection_3m_width.xodr](../../resources/intersection/intersection_3m_width.xodr)
 - sub_map_8 : [intersection_3_5m_width.xodr](../../resources/intersection/intersection_3_5m_width.xodr)
 - sub_map_9 : [intersection_4m_width.xodr](../../resources/intersection/intersection_4m_width.xodr)
 - sub_map_10 : [intersection_3m_width_crosswalk.xodr](../../resources/intersection/intersection_3m_width_crosswalk.xodr)
 - sub_map_11 : [intersection_3_5m_width_crosswalk.xodr](../../resources/intersection/intersection_3_5m_width_crosswalk.xodr)
 - sub_map_12 : [intersection_4m_width_crosswalk.xodr](../../resources/intersection/intersection_4m_width_crosswalk.xodr)

### Submap distribution


 - The submaps are composed into one large map with the following distribution.

```

sub_map_1 ----- sub_map_2 ----- sub_map_3 ----- sub_map_4 ----- sub_map_5 ----- sub_map_6
    |
    |
    |
sub_map_7 ----- sub_map_8 ----- sub_map_9 ----- sub_map_10 ----- sub_map_11 ----- sub_map_12
```

 - The submaps aren't connected to each other.

### Procedure for creating the large map

For creating the map the following steps were taken.

1. Create the 12 submaps with the correspondent offset in a way that when merged no overlapping occurs
2. Adapt the road ids and junction ids to avoid any kind of clashing among ids.
3. Merge all OpenDRIVE descriptions into one.
4. Merge all GeoJSON descriptions into one.

#### Creation of submaps

For the creation of the submaps with the correspondent offset. The X_OFFSET and Y_OFFSET argument were used.


- sub_map_1
  ```
  X_OFFSET=0. Y_OFFSET=0. CROSSWALK=False WIDTH=3. empy3 templates/straight_forward.xml.em
  ```
- sub_map_2
  ```
  X_OFFSET=210. Y_OFFSET=0. CROSSWALK=False WIDTH=3.5 empy3 templates/straight_forward.xml.em
  ```
- sub_map_3
  ```
  X_OFFSET=420. Y_OFFSET=0. CROSSWALK=False WIDTH=4. empy3 templates/straight_forward.xml.em
  ```
- sub_map_4
  ```
  X_OFFSET=630. Y_OFFSET=0. CROSSWALK=True WIDTH=3. empy3 templates/straight_forward.xml.em
  ```
- sub_map_5
  ```
  X_OFFSET=840. Y_OFFSET=0. CROSSWALK=True WIDTH=3.5 empy3 templates/straight_forward.xml.em
  ```
- sub_map_6
  ```
  X_OFFSET=1050. Y_OFFSET=0. CROSSWALK=True WIDTH=4. empy3 templates/straight_forward.xml.em
  ```
- sub_map_7
  ```
  X_OFFSET=0. Y_OFFSET=-150. CROSSWALK=False WIDTH=3. empy3 templates/intersection.xml.em
  ```
- sub_map_8
  ```
  X_OFFSET=250. Y_OFFSET=-150. CROSSWALK=False WIDTH=3.5 empy3 templates/intersection.xml.em
  ```
- sub_map_9
  ```
  X_OFFSET=500. Y_OFFSET=-150. CROSSWALK=False WIDTH=4. empy3 templates/intersection.xml.em
  ```
- sub_map_10
  ```
  X_OFFSET=750. Y_OFFSET=-150. CROSSWALK=True WIDTH=3. empy3 templates/intersection.xml.em
  ```
- sub_map_11
  ```
  X_OFFSET=1000. Y_OFFSET=-150. CROSSWALK=True WIDTH=3.5 empy3 templates/intersection.xml.em
  ```
- sub_map_12
  ```
  X_OFFSET=1250. Y_OFFSET=-150. CROSSWALK=True WIDTH=4. empy3 templates/intersection.xml.em
  ```
