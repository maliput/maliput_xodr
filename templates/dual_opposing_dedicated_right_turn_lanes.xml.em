<?xml version="1.0" encoding="UTF-8"?>
<!--
 BSD 3-Clause License

 Copyright (c) 2023, Woven by Toyota. All rights reserved.

 Redistribution and use in source and binary forms, with or without
 modification, are permitted provided that the following conditions are met:

 * Redistributions of source code must retain the above copyright notice, this
   list of conditions and the following disclaimer.

 * Redistributions in binary form must reproduce the above copyright notice,
   this list of conditions and the following disclaimer in the documentation
   and/or other materials provided with the distribution.

 * Neither the name of the copyright holder nor the names of its
   contributors may be used to endorse or promote products derived from
   this software without specific prior written permission.

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
-->
@{
import em
import os
import math as m
import pyproj

# Georeference information
LAT_0 = 37.4168716
LON_0 = -122.1030492

def str2bool(string):
  return string.lower() in ("yes", "true", "t", "1")

def str2float(string):
  return float(string)

def arc_length(r: float, angle: float):
  return r * angle


def cartesian_to_geodetic(x, y, z, origin_lon, origin_lat):
  # Define the projection systems
  geodetic_crs = pyproj.CRS.from_string("EPSG:4326")  # Geodetic (lon, lat) system (WGS84)
  projection_crs = pyproj.CRS.from_string(f"+proj=tmerc +lat_0={origin_lat} +lon_0={origin_lon} +k=1 +x_0=0 +y_0=0 +datum=WGS84 +units=m +no_defs")  # Cartesian (x, y, z) system with tmerc projection (WGS84)

  # Create the transformer
  transformer = pyproj.Transformer.from_crs(projection_crs, geodetic_crs, always_xy=True)

  # Convert Cartesian coordinates to geodetic
  target_lon, target_lat, target_z = transformer.transform(x, y, z)

  return target_lon, target_lat, target_z

def to_lon_lat_points(points):
  lon_lat_points = []
  for point in points:
    lon, lat, h = cartesian_to_geodetic(point[0], point[1], 0, LON_0, LAT_0)
    lon_lat_points.append([lon, lat, h])
  return lon_lat_points

# This is the road this file represents.
#
#
#                 *
#                 |
#                 ^
#                 3
#                 |
#                 *
#                 |
# x----4>----x----5>----x----6>----x
#                 |   /
#                 ^  /
#                 2 7
#                 *
#                 |
#                 ^
#                 1
#                 |
#                 *

# Origin offset
x_offset = str2float(os.environ['X_OFFSET']) if 'X_OFFSET' in os.environ  else 0.0
y_offset = str2float(os.environ['Y_OFFSET']) if 'Y_OFFSET' in os.environ  else 0.0
# Width of the lanes
width = str2float(os.environ['WIDTH']) if 'WIDTH' in os.environ  else 4.0
# Radius of the junction
radius = str2float(os.environ['RADIUS']) if 'RADIUS' in os.environ else 6.0
# stopline
stopline = str2bool(os.environ['STOPLINE']) if 'STOPLINE' in os.environ else True

road_1_start = [0. + x_offset, 0. + y_offset, m.pi / 2.]
road_1_length = 100.

road_2_start = [road_1_start[0], road_1_start[1] + road_1_length, m.pi / 2.]
road_2_length = 2. * width + 2. * radius

road_5_start = [road_2_start[0], road_2_start[1] + road_2_length, m.pi / 2.]
road_5_length = 100.

road_6_length = 100.
road_6_start = [road_1_start[0] - 2 * width - road_6_length, road_1_start[1] + road_1_length + radius + width, 0.]

road_7_start = [road_6_start[0] + road_6_length, road_6_start[1], 0.]
road_7_length = 3. * width + radius

road_8_start = [road_7_start[0] + road_7_length, road_7_start[1], 0.]
road_8_length = 100.

road_9_start = [road_1_start[0], road_1_start[1] + road_1_length, m.pi / 2.]
road_9_curvature = -1. / (radius + width)
road_9_length = arc_length(radius + width, m.pi / 2.)

if stopline:
  stopline_west_points = [
    [road_6_start[0] + road_6_length, road_6_start[1] + width],
    [road_6_start[0] + road_6_length, road_6_start[1]],
  ]
  stopline_east_points = [
    [road_8_start[0], road_8_start[1] - width],
    [road_8_start[0], road_8_start[1]],
  ]
  stopline_west_points_lon_lat = to_lon_lat_points(stopline_west_points)
  stopline_east_points_lon_lat = to_lon_lat_points(stopline_east_points)
}@
<!--
 Map generated using https://github.com/maliput/maliput_xodr.
 Generated using the following parameters:
  - WIDTH: @(width)@ 
    - Indicates the width of the lane
  - RADIUS: @(radius)@ 
    - Indicates the radius of the intersection
  - STOPLINE: @(stopline)@ 
    - Indicates if stoplines are generated(for east west directions only)(it only affects geoJSON info)
  - OFFSET_X: @(x_offset)@ 
    - Indicates the offset in the x axis of the openDRIVE map
  - OFFSET_Y: @(y_offset)@ 
    - Indicates the offset in the y axis of the openDRIVE map
-->
<OpenDRIVE>
    <header revMajor="1" revMinor="1" name="DualOpposingDedicatedRightTurnLanes" version="1.00" date="Tue Aug 29 12:00:00 2023" north="0.0e+00" south="0.0e+00" east="0.0e+00" west="0.0e+00" maxRoad="2" maxJunc="0" maxPrg="0">
        <geoReference><![CDATA[+proj=tmerc +lat_0=@(LAT_0)@  +lon_0=@(LON_0)@  +k=1 +x_0=0 +y_0=0 +datum=WGS84 +units=m +vunits=m +no_defs ]]></geoReference>
    </header>
    <road name="Road 1" length="@(road_1_length)@\" id="1" junction="-1">
        <link>
            <successor elementType="junction" elementId="10"/>
        </link>
        <planView>
            <geometry s="0.0e+00" x="@(road_1_start[0])@\" y="@(road_1_start[1])@\" hdg="@(road_1_start[2])@\" length="@(road_1_length)@\">
                <line/>
            </geometry>
        </planView>
        <elevationProfile>
        </elevationProfile>
        <lateralProfile>
        </lateralProfile>
        <lanes>
            <laneSection s="0.0e+00">
                <left>
                    <lane id="2" type="driving" level= "0">
                        <link>
                        </link>
                        <width sOffset="0.0e+00" a="@(width)@\" b="0.0e+00" c="0.0e+00" d="0.0e+00"/>
                        <roadMark sOffset="0.0e+00" type="solid" weight="standard" color="standard" width="1.0e-01"/>
                        <userData>
                            <vectorLane travelDir="forward"/>
                        </userData>
                    </lane>
                    <lane id="1" type="driving" level= "0">
                        <link>
                        </link>
                        <width sOffset="0.0e+00" a="@(width)@\" b="0.0e+00" c="0.0e+00" d="0.0e+00"/>
                        <roadMark sOffset="0.0e+00" type="solid" weight="standard" color="standard" width="1.0e-01"/>
                        <userData>
                            <vectorLane travelDir="forward"/>
                        </userData>
                    </lane>
                </left>
                <center>
                    <lane id="0" type="none" level= "0">
                        <link>
                        </link>
                        <roadMark sOffset="0.0e+00" type="broken" weight="standard" color="standard" width="1.0e-01"/>
                    </lane>
                </center>
                <right>
                    <lane id="-1" type="driving" level= "0">
                        <link>
                        </link>
                        <width sOffset="0.0e+00" a="@(width)@\" b="0.0e+00" c="0.0e+00" d="0.0e+00"/>
                        <roadMark sOffset="0.0e+00" type="solid" weight="standard" color="standard" width="1.0e-01"/>
                        <userData>
                            <vectorLane travelDir="backward"/>
                        </userData>
                    </lane>
                </right>
            </laneSection>
        </lanes>
    </road>
    <road name="Road 2" length="@(road_2_length)@\" id="2" junction="10">
        <link>
            <predecessor elementType="road" elementId="1" contactPoint="end"/>
            <successor elementType="road" elementId="5" contactPoint="start"/>
        </link>
        <planView>
            <geometry s="0.0e+00" x="@(road_2_start[0])@\" y="@(road_2_start[1])@\" hdg="@(road_2_start[2])@\" length="@(road_2_length)@\">
                <line/>
            </geometry>
        </planView>
        <elevationProfile>
        </elevationProfile>
        <lateralProfile>
        </lateralProfile>
        <lanes>
            <laneSection s="0.0e+00">
                <left>
                    <lane id="2" type="driving" level= "0">
                        <link>
                            <successor id="2"/>
                        </link>
                        <width sOffset="0.0e+00" a="@(width)@\" b="0.0e+00" c="0.0e+00" d="0.0e+00"/>
                        <roadMark sOffset="0.0e+00" type="solid" weight="standard" color="standard" width="1.0e-01"/>
                        <userData>
                            <vectorLane travelDir="forward"/>
                        </userData>
                    </lane>
                    <lane id="1" type="driving" level= "0">
                        <link>
                            <successor id="1"/>
                        </link>
                        <width sOffset="0.0e+00" a="@(width)@\" b="0.0e+00" c="0.0e+00" d="0.0e+00"/>
                        <roadMark sOffset="0.0e+00" type="solid" weight="standard" color="standard" width="1.0e-01"/>
                        <userData>
                            <vectorLane travelDir="forward"/>
                        </userData>
                    </lane>
                </left>
                <center>
                    <lane id="0" type="none" level= "0">
                        <link>
                        </link>
                        <roadMark sOffset="0.0e+00" type="broken" weight="standard" color="standard" width="1.0e-01"/>
                    </lane>
                </center>
                <right>
                    <lane id="-1" type="driving" level= "0">
                        <link>
                            <successor id="-1"/>
                        </link>
                        <width sOffset="0.0e+00" a="@(width)@\" b="0.0e+00" c="0.0e+00" d="0.0e+00"/>
                        <roadMark sOffset="0.0e+00" type="solid" weight="standard" color="standard" width="1.0e-01"/>
                        <userData>
                            <vectorLane travelDir="backward"/>
                        </userData>
                    </lane>
                </right>
            </laneSection>
        </lanes>
    </road>
    <road name="Road 5" length="@(road_5_length)@\" id="5" junction="-1">
        <link>
            <predecessor elementType="junction" elementId="10"/>
        </link>
        <planView>
            <geometry s="0.0e+00" x="@(road_5_start[0])@\" y="@(road_5_start[1])@\" hdg="@(road_5_start[2])@\" length="@(road_5_length)@\">
                <line/>
            </geometry>
        </planView>
        <elevationProfile>
        </elevationProfile>
        <lateralProfile>
        </lateralProfile>
        <lanes>
            <laneSection s="0.0e+00">
                <left>
                    <lane id="2" type="driving" level= "0">
                        <link>
                        </link>
                        <width sOffset="0.0e+00" a="@(width)@\" b="0.0e+00" c="0.0e+00" d="0.0e+00"/>
                        <roadMark sOffset="0.0e+00" type="solid" weight="standard" color="standard" width="1.0e-01"/>
                        <userData>
                            <vectorLane travelDir="forward"/>
                        </userData>
                    </lane>
                    <lane id="1" type="driving" level= "0">
                        <link>
                        </link>
                        <width sOffset="0.0e+00" a="@(width)@\" b="0.0e+00" c="0.0e+00" d="0.0e+00"/>
                        <roadMark sOffset="0.0e+00" type="solid" weight="standard" color="standard" width="1.0e-01"/>
                        <userData>
                            <vectorLane travelDir="forward"/>
                        </userData>
                    </lane>
                </left>
                <center>
                    <lane id="0" type="none" level= "0">
                        <link>
                        </link>
                        <roadMark sOffset="0.0e+00" type="broken" weight="standard" color="standard" width="1.0e-01"/>
                    </lane>
                </center>
                <right>
                    <lane id="-1" type="driving" level= "0">
                        <link>
                        </link>
                        <width sOffset="0.0e+00" a="@(width)@\" b="0.0e+00" c="0.0e+00" d="0.0e+00"/>
                        <roadMark sOffset="0.0e+00" type="solid" weight="standard" color="standard" width="1.0e-01"/>
                        <userData>
                            <vectorLane travelDir="backward"/>
                        </userData>
                    </lane>
                </right>
            </laneSection>
        </lanes>
    </road>
    <road name="Road 6" length="@(road_6_length)@\" id="6" junction="-1">
        <link>
            <successor elementType="junction" elementId="10"/>
        </link>
        <planView>
            <geometry s="0.0e+00" x="@(road_6_start[0])@\" y="@(road_6_start[1])@\" hdg="@(road_6_start[2])@\" length="@(road_6_length)@\">
                <line/>
            </geometry>
        </planView>
        <elevationProfile>
        </elevationProfile>
        <lateralProfile>
        </lateralProfile>
        <lanes>
            <laneSection s="0.0e+00">
                <left>
                    <lane id="1" type="driving" level= "0">
                        <link>
                        </link>
                        <width sOffset="0.0e+00" a="@(width)@\" b="0.0e+00" c="0.0e+00" d="0.0e+00"/>
                        <roadMark sOffset="0.0e+00" type="solid" weight="standard" color="standard" width="1.0e-01"/>
                        <userData>
                            <vectorLane travelDir="forward"/>
                        </userData>
                    </lane>
                </left>
                <center>
                    <lane id="0" type="none" level= "0">
                        <link>
                        </link>
                        <roadMark sOffset="0.0e+00" type="broken" weight="standard" color="standard" width="1.0e-01"/>
                    </lane>
                </center>
                <right>
                    <lane id="-1" type="driving" level= "0">
                        <link>
                        </link>
                        <width sOffset="0.0e+00" a="@(width)@\" b="0.0e+00" c="0.0e+00" d="0.0e+00"/>
                        <roadMark sOffset="0.0e+00" type="solid" weight="standard" color="standard" width="1.0e-01"/>
                        <userData>
                            <vectorLane travelDir="backward"/>
                        </userData>
                    </lane>
                </right>
            </laneSection>
        </lanes>
    </road>
    <road name="Road 7" length="@(road_7_length)@\" id="7" junction="10">
        <link>
            <predecessor elementType="road" elementId="6" contactPoint="end"/>
            <successor elementType="road" elementId="8" contactPoint="start"/>
        </link>
        <planView>
            <geometry s="0.0e+00" x="@(road_7_start[0])@\" y="@(road_7_start[1])@\" hdg="@(road_7_start[2])@\" length="@(road_7_length)@\">
                <line/>
            </geometry>
        </planView>
        <elevationProfile>
        </elevationProfile>
        <lateralProfile>
        </lateralProfile>
        <lanes>
            <laneSection s="0.0e+00">
                <left>
                    <lane id="1" type="driving" level= "0">
                        <link>
                            <successor id="1"/>
                        </link>
                        <width sOffset="0.0e+00" a="@(width)@\" b="0.0e+00" c="0.0e+00" d="0.0e+00"/>
                        <roadMark sOffset="0.0e+00" type="solid" weight="standard" color="standard" width="1.0e-01"/>
                        <userData>
                            <vectorLane travelDir="forward"/>
                        </userData>
                    </lane>
                </left>
                <center>
                    <lane id="0" type="none" level= "0">
                        <link>
                        </link>
                        <roadMark sOffset="0.0e+00" type="broken" weight="standard" color="standard" width="1.0e-01"/>
                    </lane>
                </center>
                <right>
                    <lane id="-1" type="driving" level= "0">
                        <link>
                            <successor id="-1"/>
                        </link>
                        <width sOffset="0.0e+00" a="@(width)@\" b="0.0e+00" c="0.0e+00" d="0.0e+00"/>
                        <roadMark sOffset="0.0e+00" type="solid" weight="standard" color="standard" width="1.0e-01"/>
                        <userData>
                            <vectorLane travelDir="backward"/>
                        </userData>
                    </lane>
                </right>
            </laneSection>
        </lanes>
    </road>
    <road name="Road 8" length="@(road_8_length)@\" id="8" junction="-1">
        <link>
            <predecessor elementType="junction" elementId="10"/>
        </link>
        <planView>
            <geometry s="0.0e+00" x="@(road_8_start[0])@\" y="@(road_8_start[1])@\" hdg="@(road_8_start[2])@\" length="@(road_8_length)@\">
                <line/>
            </geometry>
        </planView>
        <elevationProfile>
        </elevationProfile>
        <lateralProfile>
        </lateralProfile>
        <lanes>
            <laneSection s="0.0e+00">
                <left>
                    <lane id="1" type="driving" level= "0">
                        <link>
                        </link>
                        <width sOffset="0.0e+00" a="@(width)@\" b="0.0e+00" c="0.0e+00" d="0.0e+00"/>
                        <roadMark sOffset="0.0e+00" type="solid" weight="standard" color="standard" width="1.0e-01"/>
                        <userData>
                            <vectorLane travelDir="forward"/>
                        </userData>
                    </lane>
                </left>
                <center>
                    <lane id="0" type="none" level= "0">
                        <link>
                        </link>
                        <roadMark sOffset="0.0e+00" type="broken" weight="standard" color="standard" width="1.0e-01"/>
                    </lane>
                </center>
                <right>
                    <lane id="-1" type="driving" level= "0">
                        <link>
                        </link>
                        <width sOffset="0.0e+00" a="@(width)@\" b="0.0e+00" c="0.0e+00" d="0.0e+00"/>
                        <roadMark sOffset="0.0e+00" type="solid" weight="standard" color="standard" width="1.0e-01"/>
                        <userData>
                            <vectorLane travelDir="backward"/>
                        </userData>
                    </lane>
                </right>
            </laneSection>
        </lanes>
    </road>
    <road name="Road 9" length="@(road_9_length)@\" id="9" junction="10">
        <link>
            <predecessor elementType="road" elementId="1" contactPoint="end"/>
            <successor elementType="road" elementId="8" contactPoint="start"/>
        </link>
        <planView>
            <geometry s="0.0e+00" x="@(road_9_start[0])@\" y="@(road_9_start[1])@\" hdg="@(road_9_start[2])@\" length="@(road_9_length)@\">
                <arc curvature="@(road_9_curvature)@\"/>
            </geometry>
        </planView>
        <elevationProfile>
        </elevationProfile>
        <lateralProfile>
        </lateralProfile>
        <lanes>
            <laneSection s="0.0e+00">
                <left>
                    <lane id="1" type="driving" level= "0">
                        <link>
                            <predecessor id="1"/>
                            <successor id="1"/>
                        </link>
                        <width sOffset="0.0e+00" a="@(width)@\" b="0.0e+00" c="0.0e+00" d="0.0e+00"/>
                        <roadMark sOffset="0.0e+00" type="solid" weight="standard" color="standard" width="1.0e-01"/>
                        <userData>
                            <vectorLane travelDir="forward"/>
                        </userData>
                    </lane>
                </left>
                <center>
                    <lane id="0" type="none" level= "0">
                        <link>
                        </link>
                        <roadMark sOffset="0.0e+00" type="broken" weight="standard" color="standard" width="1.0e-01"/>
                    </lane>
                </center>
            </laneSection>
        </lanes>
    </road>
    <junction id="10" name="Junction 10">
        <connection id="0" incomingRoad="1" connectingRoad="2" contactPoint="start">
            <laneLink from="2" to="2"/>
            <laneLink from="1" to="1"/>
            <laneLink from="-1" to="-1"/>
        </connection>
        <connection id="3" incomingRoad="6" connectingRoad="7" contactPoint="start">
            <laneLink from="1" to="1"/>
            <laneLink from="-1" to="-1"/>
        </connection>
        <connection id="5" incomingRoad="1" connectingRoad="9" contactPoint="start">
            <laneLink from="1" to="1"/>
        </connection>
    </junction>
</OpenDRIVE>
@[if stopline]
<!-- GeoJSON information for the stoplines
Generated GeoJSON can be verified using: https://geojson.io
@{
}@

{
  "features": [
@[if stopline]
    {
      "geometry": {
        "coordinates": [
  @[for idx, lon_lat_z in enumerate(stopline_west_points_lon_lat)]@
          [
            @(lon_lat_z[0]),
            @(lon_lat_z[1]),
            @(lon_lat_z[2])
          ]@[if (idx != len(stopline_west_points_lon_lat)-1)],@[end if]
  @[end for ]@
        ],
        "type": "LineString"
      },
      "properties": {
        "Id": "{ba11d4ae-3784-11ee-be56-0242ac120002}",
        "Type": "Stopline"
      },
      "type": "Feature"
    },
    {
      "geometry": {
        "coordinates": [
  @[for idx, lon_lat_z in enumerate(stopline_east_points_lon_lat)]@
          [
            @(lon_lat_z[0]),
            @(lon_lat_z[1]),
            @(lon_lat_z[2])
          ]@[if (idx != len(stopline_east_points_lon_lat)-1)],@[end if]
  @[end for ]@
        ],
        "type": "LineString"
      },
      "properties": {
        "Id": "{ba11d7ce-3784-11ee-be56-0242ac120002}",
        "Type": "Stopline"
      },
      "type": "Feature"
    }
@[end if]
  ],
  "type": "FeatureCollection"
}

-->
@[end if]
