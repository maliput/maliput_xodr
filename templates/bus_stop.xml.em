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
import math as m
import os
import uuid

import pyproj

# Georeference information
LAT_0 = 37.4168716
LON_0 = -122.1030492

def str2bool(string):
  return string.lower() in ("yes", "true", "t", "1")

def str2float(string):
  return float(string)

def calculate_lane_offset(off_a, off_b, s_end):
  # Calculate the lane offset poliynomial: a + b * s + c * s^2 + d * s^3
  # Args:
  #  - off_a: lane offset at the start of the lane
  #  - off_b: lane offset at the end of the lane
  #  - s_end: length of the lane
  # Returns:
  #  - [a, b, c, d]: lane offset polynomial coefficients
  #
  # Considerations:
  # - The lane offset is a polynomial of degree 3
  # - The lane offset is defined in the s-coordinate system
  # - The derivative of the lane offset is 0 at the start and end of the lane
  a = off_a
  b = 0
  c = 3 * (off_b - off_a) / s_end ** 2
  d = -2 * (off_b - off_a) / s_end ** 3
  return [a, b, c, d]

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

width = str2float(os.environ['WIDTH']) if 'WIDTH' in os.environ  else 4.0
bus_stop_length = str2float(os.environ['BUS_STOP_LENGTH']) if 'BUS_STOP_LENGTH' in os.environ  else 15.
merge_length = str2float(os.environ['MERGE_LENGTH']) if 'MERGE_LENGTH' in os.environ  else 10.
extensions_length = str2float(os.environ['EXTENSIONS_LENGTH']) if 'EXTENSIONS_LENGTH' in os.environ  else 300.
x_offset = str2float(os.environ['X_OFFSET']) if 'X_OFFSET' in os.environ  else 0.0
y_offset = str2float(os.environ['Y_OFFSET']) if 'Y_OFFSET' in os.environ  else 0.0

#     ┌───┬───┐
#     │   │   │
#     │   │   │
#     │   │   │
#     │   │   │  Road 3 (driving | driving )
#     │   │   │
#     │   │   │
#     │   │   │
#     ├───┼───┤
#     │   │   │
#    /│  /│   │
#   / │ / │   │  Junction 2 (Road 7 | Road 8 | Road 9 )
#  /  │/  │   │
# ┌───┼───┼───┤
# │   │   │   │
# │   │   │   │
# │   │   │   │  Road 2 (special1 | driving | driving )
# │   │   │   │
# │   │   │   │
# └───┼───┼───┤
#  \  │\  │   │
#   \ │ \ │   │
#    \│  \│   │  Junction 1 (Road 4 | Road 5 | Road 6 )
#     │   │   │
#     ├───┼───┤
#     │   │   │
#     │   │   │
#     │   │   │
#     │   │   │  Road 1 (driving | driving )
#     │   │   │
#     │   │   │
#     │   │   │
#     │   │   │
#     └───┴───┘

# Road 1 - Two lanes - One left - One right
road_1_length = extensions_length
road_1_hdg = m.pi/2.
road_1_start = [0. + x_offset, 0. + y_offset]
road_1_end = [road_1_start[0], road_1_start[1] + road_1_length]

# Road 4 - One left lane - Variable lane offset
road_4_length = merge_length
road_4_hdg = road_1_hdg
road_4_start = road_1_end #
road_4_end = [road_4_start[0], road_4_start[1] + merge_length]

road_4_lane_offset = calculate_lane_offset(0., width, merge_length)

# Road 5 - One left lane
road_5_length = merge_length
road_5_hdg = road_1_hdg
road_5_start = road_1_end
road_5_end = [road_5_start[0], road_5_start[1] + merge_length]

# Road 6 - One right lane
road_6_length = merge_length
road_6_hdg = road_1_hdg
road_6_start = road_1_end
road_6_end = [road_6_start[0], road_6_start[1] + merge_length]

# Road 2 - Three lanes - Two left - One right - Leftest is special1
road_2_length = bus_stop_length
road_2_hdg = road_1_hdg
road_2_start = road_5_end
road_2_end = [road_2_start[0], road_2_start[1] + road_2_length]

# Road 7 - One left lane - Variable lane offset
road_7_length = merge_length
road_7_hdg = road_1_hdg
road_7_start = road_2_end
road_7_end = [road_7_start[0], road_7_start[1] + merge_length]
road_7_lane_offset = calculate_lane_offset(width, 0., merge_length)

# Road 8 - One left lane
road_8_length = merge_length
road_8_hdg = road_1_hdg
road_8_start = road_2_end
road_8_end = [road_8_start[0], road_8_start[1] + merge_length]

# Road 9 - One right lane
road_9_length = merge_length
road_9_hdg = road_1_hdg
road_9_start = road_2_end
road_9_end = [road_9_start[0], road_9_start[1] + merge_length]

# Road 3 - Two lanes - One left - One right
road_3_length = extensions_length
road_3_hdg = road_1_hdg
road_3_start = road_9_end
road_3_end = [road_3_start[0], road_3_start[1] + road_3_length]


# For geojson generation
bus_lane_boundary_left_start = [road_2_start[0] - 2 * width, road_2_start[1]]
bus_lane_boundary_left_end = [road_2_end[0] - 2 * width, road_2_end[1]]
bus_lane_boundary_left_points = [bus_lane_boundary_left_start, bus_lane_boundary_left_end]
bus_lane_boundary_left_points_lon_lat = to_lon_lat_points(bus_lane_boundary_left_points)

bus_lane_boundary_right_start = [road_2_start[0] - width, road_2_start[1]]
bus_lane_boundary_right_end = [road_2_end[0] - width, road_2_end[1]]
bus_lane_boundary_right_points = [bus_lane_boundary_right_start, bus_lane_boundary_right_end]
bus_lane_boundary_right_points_lon_lat = to_lon_lat_points(bus_lane_boundary_right_points)

bus_lane_center_start = [bus_lane_boundary_left_start[0] + width / 2., bus_lane_boundary_left_start[1]]
bus_lane_center_end = [bus_lane_boundary_left_end[0] + width / 2., bus_lane_boundary_left_end[1]]
bus_lane_center_points = [bus_lane_center_start, bus_lane_center_end]
bus_lane_center_points_lon_lat = to_lon_lat_points(bus_lane_center_points)

bus_lane_id = str(uuid.uuid4())
bus_lane_boundary_left_id = str(uuid.uuid4())
bus_lane_boundary_right_id = str(uuid.uuid4())


}@
<!--
 Map generated using:
  - WIDTH: @(width)@ 
    - Indicates the width of the lane.
  - EXTENSIONS_LENGTH: @(extensions_length)@ 
    - Indicates the extension length of the lane to North and South.
  - BUS_STOP_LENGTH: @(bus_stop_length)@ 
    - Indicates the length of the bus stop lane.
  - MERGE_LENGTH: @(merge_length)@ 
    - Indicates the length of the merge lane.
  - OFFSET_X: @(x_offset)@ 
    - Indicates the offset in the x axis of the OpenDRIVE map.
  - OFFSET_Y: @(y_offset)@ 
    - Indicates the offset in the y axis of the OpenDRIVE map.
-->
<OpenDRIVE>
    <header revMajor="1" revMinor="1" name="BusStopLane" version="1.00" date="Thu Aug 24 12:00:00 2023" north="0.0000000000000000e+00" south="0.0000000000000000e+00" east="0.0000000000000000e+00" west="0.0000000000000000e+00" maxRoad="2" maxJunc="0" maxPrg="0">
        <geoReference><![CDATA[+proj=tmerc +lat_0=@(LAT_0)@  +lon_0=@(LON_0)@  +k=1 +x_0=0 +y_0=0 +datum=WGS84 +units=m +vunits=m +no_defs ]]></geoReference>
    </header>
    <road name="Road 1" length="@(road_1_length)@\" id="1" junction="-1">
        <link>
          <successor elementType="junction" elementId="1"/>
        </link>
        <planView>
            <geometry s="0.0" x="@(road_1_start[0])@\" y="@(road_1_start[1])@\" hdg="@(road_1_hdg)@\" length="@(road_1_length)@\">
                <line/>
            </geometry>
        </planView>
        <elevationProfile>
        </elevationProfile>
        <lateralProfile>
        </lateralProfile>
        <lanes>
            <laneSection s="0.0">
                <left>
                    <lane id="1" type="driving" level= "0">
                        <link>
                            <successor id="1"/>
                        </link>
                        <width sOffset="0.0000000000000000e+00" a="@(width)@\" b="0.0000000000000000e+00" c="0.0000000000000000e+00" d="0.0000000000000000e+00"/>
                        <roadMark sOffset="0.0000000000000000e+00" type="solid" weight="standard" color="standard" width="1.0000000000000000e-01"/>
                        <userData>
                            <vectorLane travelDir="forward"/>
                        </userData>
                    </lane>
                </left>
                <center>
                    <lane id="0" type="none" level= "0">
                        <link>
                        </link>
                        <roadMark sOffset="0.0000000000000000e+00" type="broken" weight="standard" color="standard" width="1.3000000000000000e-01"/>
                    </lane>
                </center>
                <right>
                    <lane id="-1" type="driving" level= "0">
                        <link>
                            <successor id="-1"/>
                        </link>
                        <width sOffset="0.0000000000000000e+00" a="@(width)@\" b="0.0000000000000000e+00" c="0.0000000000000000e+00" d="0.0000000000000000e+00"/>
                        <roadMark sOffset="0.0000000000000000e+00" type="solid" weight="standard" color="standard" width="1.0000000000000000e-01"/>
                        <userData>
                            <vectorLane travelDir="backward"/>
                        </userData>
                    </lane>
                </right>
            </laneSection>
        </lanes>
    </road>
    <road name="Road 2" length="@(road_2_length)@\" id="2" junction="-1">
        <link>
          <predecessor elementType="junction" elementId="1"/>
          <successor elementType="junction" elementId="2"/>
        </link>
        <planView>
            <geometry s="0.0" x="@(road_2_start[0])@\" y="@(road_2_start[1])@\" hdg="@(road_2_hdg)@\" length="@(road_2_length)@\">
                <line/>
            </geometry>
        </planView>
        <elevationProfile>
        </elevationProfile>
        <lateralProfile>
        </lateralProfile>
        <lanes>
            <laneSection s="0.0">
                <left>
                    <lane id="2" type="special1" level= "0">
                        <link>
                            <successor id="1"/>
                        </link>
                        <width sOffset="0.0000000000000000e+00" a="@(width)@\" b="0.0000000000000000e+00" c="0.0000000000000000e+00" d="0.0000000000000000e+00"/>
                        <roadMark sOffset="0.0000000000000000e+00" type="solid" weight="standard" color="standard" width="1.0000000000000000e-01"/>
                        <userData>
                            <vectorLane travelDir="forward"/>
                        </userData>
                    </lane>
                    <lane id="1" type="driving" level= "0">
                        <link>
                            <successor id="1"/>
                        </link>
                        <width sOffset="0.0000000000000000e+00" a="@(width)@\" b="0.0000000000000000e+00" c="0.0000000000000000e+00" d="0.0000000000000000e+00"/>
                        <roadMark sOffset="0.0000000000000000e+00" type="solid" weight="standard" color="standard" width="1.0000000000000000e-01"/>
                        <userData>
                            <vectorLane travelDir="forward"/>
                        </userData>
                    </lane>
                </left>
                <center>
                    <lane id="0" type="none" level= "0">
                        <link>
                        </link>
                        <roadMark sOffset="0.0000000000000000e+00" type="broken" weight="standard" color="standard" width="1.3000000000000000e-01"/>
                    </lane>
                </center>
                <right>
                    <lane id="-1" type="driving" level= "0">
                        <link>
                            <successor id="-1"/>
                        </link>
                        <width sOffset="0.0000000000000000e+00" a="@(width)@\" b="0.0000000000000000e+00" c="0.0000000000000000e+00" d="0.0000000000000000e+00"/>
                        <roadMark sOffset="0.0000000000000000e+00" type="solid" weight="standard" color="standard" width="1.0000000000000000e-01"/>
                        <userData>
                            <vectorLane travelDir="backward"/>
                        </userData>
                    </lane>
                </right>
            </laneSection>
        </lanes>
    </road>
    <road name="Road 3" length="@(road_3_length)@\" id="3" junction="-1">
        <link>
          <predecessor elementType="junction" elementId="2"/>
        </link>
        <planView>
            <geometry s="0.0" x="@(road_3_start[0])@\" y="@(road_3_start[1])@\" hdg="@(road_3_hdg)@\" length="@(road_3_length)@\">
                <line/>
            </geometry>
        </planView>
        <elevationProfile>
        </elevationProfile>
        <lateralProfile>
        </lateralProfile>
        <lanes>
            <laneSection s="0.0">
                <left>
                    <lane id="1" type="driving" level= "0">
                        <link>
                            <successor id="1"/>
                        </link>
                        <width sOffset="0.0000000000000000e+00" a="@(width)@\" b="0.0000000000000000e+00" c="0.0000000000000000e+00" d="0.0000000000000000e+00"/>
                        <roadMark sOffset="0.0000000000000000e+00" type="solid" weight="standard" color="standard" width="1.0000000000000000e-01"/>
                        <userData>
                            <vectorLane travelDir="forward"/>
                        </userData>
                    </lane>
                </left>
                <center>
                    <lane id="0" type="none" level= "0">
                        <link>
                        </link>
                        <roadMark sOffset="0.0000000000000000e+00" type="broken" weight="standard" color="standard" width="1.3000000000000000e-01"/>
                    </lane>
                </center>
                <right>
                    <lane id="-1" type="driving" level= "0">
                        <link>
                            <successor id="-1"/>
                        </link>
                        <width sOffset="0.0000000000000000e+00" a="@(width)@\" b="0.0000000000000000e+00" c="0.0000000000000000e+00" d="0.0000000000000000e+00"/>
                        <roadMark sOffset="0.0000000000000000e+00" type="solid" weight="standard" color="standard" width="1.0000000000000000e-01"/>
                        <userData>
                            <vectorLane travelDir="backward"/>
                        </userData>
                    </lane>
                </right>
            </laneSection>
        </lanes>
    </road>
    <road name="Road 4" length="@(road_4_length)@\" id="4" junction="1">
        <link>
          <predecessor elementType="road" elementId="1" contactPoint="end"/>
          <successor elementType="road" elementId="2" contactPoint="start"/>
        </link>
        <planView>
            <geometry s="0.0" x="@(road_4_start[0])@\" y="@(road_4_start[1])@\" hdg="@(road_4_hdg)@\" length="@(road_4_length)@\">
                <line/>
            </geometry>
        </planView>
        <elevationProfile>
        </elevationProfile>
        <lateralProfile>
        </lateralProfile>
        <lanes>
            <laneOffset s="0.00000000000000e+0" a="@(road_4_lane_offset[0])@\" b="@(road_4_lane_offset[1])@\" c="@(road_4_lane_offset[2])@\" d="@(road_4_lane_offset[3])@\"/>
            <laneSection s="0.0">
                <left>
                    <lane id="1" type="special1" level= "0">
                        <link>
                            <predecessor id="1"/>
                            <successor id="2"/>
                        </link>
                        <width sOffset="0.0000000000000000e+00" a="@(width)@\" b="0.0000000000000000e+00" c="0.0000000000000000e+00" d="0.0000000000000000e+00"/>
                        <roadMark sOffset="0.0000000000000000e+00" type="solid" weight="standard" color="standard" width="1.0000000000000000e-01"/>
                        <userData>
                            <vectorLane travelDir="forward"/>
                        </userData>
                    </lane>
                </left>
                <center>
                    <lane id="0" type="none" level= "0">
                        <link>
                        </link>
                        <roadMark sOffset="0.0000000000000000e+00" type="broken" weight="standard" color="standard" width="1.3000000000000000e-01"/>
                    </lane>
                </center>
            </laneSection>
        </lanes>
    </road>
    <road name="Road 5" length="@(road_5_length)@\" id="5" junction="1">
        <link>
          <predecessor elementType="road" elementId="1" contactPoint="end"/>
          <successor elementType="road" elementId="2" contactPoint="start"/>
        </link>
        <planView>
            <geometry s="0.0" x="@(road_5_start[0])@\" y="@(road_5_start[1])@\" hdg="@(road_5_hdg)@\" length="@(road_5_length)@\">
                <line/>
            </geometry>
        </planView>
        <elevationProfile>
        </elevationProfile>
        <lateralProfile>
        </lateralProfile>
        <lanes>
            <laneSection s="0.0">
                <left>
                    <lane id="1" type="driving" level= "0">
                        <link>
                            <predecessor id="1"/>
                            <successor id="1"/>
                        </link>
                        <width sOffset="0.0000000000000000e+00" a="@(width)@\" b="0.0000000000000000e+00" c="0.0000000000000000e+00" d="0.0000000000000000e+00"/>
                        <roadMark sOffset="0.0000000000000000e+00" type="solid" weight="standard" color="standard" width="1.0000000000000000e-01"/>
                        <userData>
                            <vectorLane travelDir="forward"/>
                        </userData>
                    </lane>
                </left>
                <center>
                    <lane id="0" type="none" level= "0">
                        <link>
                        </link>
                        <roadMark sOffset="0.0000000000000000e+00" type="broken" weight="standard" color="standard" width="1.3000000000000000e-01"/>
                    </lane>
                </center>
            </laneSection>
        </lanes>
    </road>
    <road name="Road 6" length="@(road_6_length)@\" id="6" junction="1">
        <link>
          <predecessor elementType="road" elementId="1" contactPoint="end"/>
          <successor elementType="road" elementId="2" contactPoint="start"/>
        </link>
        <planView>
            <geometry s="0.0" x="@(road_6_start[0])@\" y="@(road_6_start[1])@\" hdg="@(road_6_hdg)@\" length="@(road_6_length)@\">
                <line/>
            </geometry>
        </planView>
        <elevationProfile>
        </elevationProfile>
        <lateralProfile>
        </lateralProfile>
        <lanes>
            <laneSection s="0.0">
                <center>
                    <lane id="0" type="none" level= "0">
                        <link>
                        </link>
                        <roadMark sOffset="0.0000000000000000e+00" type="broken" weight="standard" color="standard" width="1.3000000000000000e-01"/>
                    </lane>
                </center>
                <right>
                    <lane id="-1" type="driving" level= "0">
                        <link>
                            <predecessor id="-1"/>
                            <successor id="-1"/>
                        </link>
                        <width sOffset="0.0000000000000000e+00" a="@(width)@\" b="0.0000000000000000e+00" c="0.0000000000000000e+00" d="0.0000000000000000e+00"/>
                        <roadMark sOffset="0.0000000000000000e+00" type="solid" weight="standard" color="standard" width="1.0000000000000000e-01"/>
                        <userData>
                            <vectorLane travelDir="forward"/>
                        </userData>
                    </lane>
                </right>
            </laneSection>
        </lanes>
    </road>
    <road name="Road 7" length="@(road_7_length)@\" id="7" junction="2">
        <link>
          <predecessor elementType="road" elementId="2" contactPoint="end"/>
          <successor elementType="road" elementId="3" contactPoint="start"/>
        </link>
        <planView>
            <geometry s="0.0" x="@(road_7_start[0])@\" y="@(road_7_start[1])@\" hdg="@(road_7_hdg)@\" length="@(road_7_length)@\">
                <line/>
            </geometry>
        </planView>
        <elevationProfile>
        </elevationProfile>
        <lateralProfile>
        </lateralProfile>
        <lanes>
            <laneOffset s="0.00000000000000e+0" a="@(road_7_lane_offset[0])@\" b="@(road_7_lane_offset[1])@\" c="@(road_7_lane_offset[2])@\" d="@(road_7_lane_offset[3])@\"/>
            <laneSection s="0.0">
                <left>
                    <lane id="1" type="special1" level= "0">
                        <link>
                            <predecessor id="2"/>
                            <successor id="1"/>
                        </link>
                        <width sOffset="0.0000000000000000e+00" a="@(width)@\" b="0.0000000000000000e+00" c="0.0000000000000000e+00" d="0.0000000000000000e+00"/>
                        <roadMark sOffset="0.0000000000000000e+00" type="solid" weight="standard" color="standard" width="1.0000000000000000e-01"/>
                        <userData>
                            <vectorLane travelDir="forward"/>
                        </userData>
                    </lane>
                </left>
                <center>
                    <lane id="0" type="none" level= "0">
                        <link>
                        </link>
                        <roadMark sOffset="0.0000000000000000e+00" type="broken" weight="standard" color="standard" width="1.3000000000000000e-01"/>
                    </lane>
                </center>
            </laneSection>
        </lanes>
    </road>
    <road name="Road 8" length="@(road_8_length)@\" id="8" junction="2">
        <link>
          <predecessor elementType="road" elementId="2" contactPoint="end"/>
          <successor elementType="road" elementId="3" contactPoint="start"/>
        </link>
        <planView>
            <geometry s="0.0" x="@(road_8_start[0])@\" y="@(road_8_start[1])@\" hdg="@(road_8_hdg)@\" length="@(road_8_length)@\">
                <line/>
            </geometry>
        </planView>
        <elevationProfile>
        </elevationProfile>
        <lateralProfile>
        </lateralProfile>
        <lanes>
            <laneSection s="0.0">
                <left>
                    <lane id="1" type="driving" level= "0">
                        <link>
                            <predecessor id="1"/>
                            <successor id="1"/>
                        </link>
                        <width sOffset="0.0000000000000000e+00" a="@(width)@\" b="0.0000000000000000e+00" c="0.0000000000000000e+00" d="0.0000000000000000e+00"/>
                        <roadMark sOffset="0.0000000000000000e+00" type="solid" weight="standard" color="standard" width="1.0000000000000000e-01"/>
                        <userData>
                            <vectorLane travelDir="forward"/>
                        </userData>
                    </lane>
                </left>
                <center>
                    <lane id="0" type="none" level= "0">
                        <link>
                        </link>
                        <roadMark sOffset="0.0000000000000000e+00" type="broken" weight="standard" color="standard" width="1.3000000000000000e-01"/>
                    </lane>
                </center>
            </laneSection>
        </lanes>
    </road>
    <road name="Road 9" length="@(road_9_length)@\" id="9" junction="2">
        <link>
          <predecessor elementType="road" elementId="2" contactPoint="end"/>
          <successor elementType="road" elementId="3" contactPoint="start"/>
        </link>
        <planView>
            <geometry s="0.0" x="@(road_9_start[0])@\" y="@(road_9_start[1])@\" hdg="@(road_9_hdg)@\" length="@(road_9_length)@\">
                <line/>
            </geometry>
        </planView>
        <elevationProfile>
        </elevationProfile>
        <lateralProfile>
        </lateralProfile>
        <lanes>
            <laneSection s="0.0">
                <center>
                    <lane id="0" type="none" level= "0">
                        <link>
                        </link>
                        <roadMark sOffset="0.0000000000000000e+00" type="broken" weight="standard" color="standard" width="1.3000000000000000e-01"/>
                    </lane>
                </center>
                <right>
                    <lane id="-1" type="driving" level= "0">
                        <link>
                            <predecessor id="-1"/>
                            <successor id="-1"/>
                        </link>
                        <width sOffset="0.0000000000000000e+00" a="@(width)@\" b="0.0000000000000000e+00" c="0.0000000000000000e+00" d="0.0000000000000000e+00"/>
                        <roadMark sOffset="0.0000000000000000e+00" type="solid" weight="standard" color="standard" width="1.0000000000000000e-01"/>
                        <userData>
                            <vectorLane travelDir="forward"/>
                        </userData>
                    </lane>
                </right>
            </laneSection>
        </lanes>
    </road>
    <junction id="1" name="SouthJunction">
        <connection id="0" incomingRoad="1" connectingRoad="4" contactPoint="start">
            <laneLink from="1" to="1"/>
        </connection>
        <connection id="1" incomingRoad="1" connectingRoad="5" contactPoint="start">
            <laneLink from="1" to="1"/>
        </connection>
        <connection id="2" incomingRoad="1" connectingRoad="6" contactPoint="start">
            <laneLink from="-1" to="-1"/>
        </connection>
    </junction>
    <junction id="2" name="NorthJunction">
        <connection id="0" incomingRoad="2" connectingRoad="7" contactPoint="start">
            <laneLink from="2" to="1"/>
        </connection>
        <connection id="1" incomingRoad="2" connectingRoad="8" contactPoint="start">
            <laneLink from="1" to="1"/>
        </connection>
        <connection id="2" incomingRoad="2" connectingRoad="9" contactPoint="start">
            <laneLink from="-1" to="-1"/>
        </connection>
    </junction>
</OpenDRIVE>
<!-- GeoJSON information for the crosswalks
Generated GeoJSON can be verified using: https://geojson.io
@{
}@

{
  "features": [
    {
      "geometry": {
        "coordinates": [
@[for idx, lon_lat_z in enumerate(bus_lane_center_points_lon_lat)]@
          [
            @(lon_lat_z[0]),
            @(lon_lat_z[1]),
            @(lon_lat_z[2])
          ]@[if (idx != len(bus_lane_center_points_lon_lat)-1)],@[end if]
@[end for ]@
        ],
        "type": "LineString"
      },
      "properties": {
        "Id": "{@(bus_lane_id)}",
        "LaneType": "Special 1",
        "LeftBoundary": {
          "Dir": "Forward",
          "Id": "{@(bus_lane_boundary_left_id)}"
        },
        "RightBoundary": {
          "Dir": "Forward",
          "Id": "{@(bus_lane_boundary_right_id)}"
        },
        "Predecessors": [],
        "Successors": [],
        "TravelDir": "Undirected",
        "Type": "Lane"
      },
      "type": "Feature"
    },
    {
      "geometry": {
        "coordinates": [
@[for idx, lon_lat_z in enumerate(bus_lane_boundary_right_points_lon_lat)]@
          [
            @(lon_lat_z[0]),
            @(lon_lat_z[1]),
            @(lon_lat_z[2])
          ]@[if (idx != len(bus_lane_boundary_right_points_lon_lat)-1)],@[end if]
@[end for ]@
        ],
        "type": "LineString"
      },
      "properties": {
        "Id": "{@(bus_lane_boundary_right_id)}",
        "RightLane": {
          "Dir": "Forward",
          "Id": "{bus_lane_id}"
        },
        "Type": "LaneBoundary"
      },
      "type": "Feature"
    },
    {
      "geometry": {
        "coordinates": [
@[for idx, lon_lat_z in enumerate(bus_lane_boundary_left_points_lon_lat)]@
          [
            @(lon_lat_z[0]),
            @(lon_lat_z[1]),
            @(lon_lat_z[2])
          ]@[if (idx != len(bus_lane_boundary_left_points_lon_lat)-1)],@[end if]
@[end for ]@
        ],
        "type": "LineString"
      },
      "properties": {
        "Id": "{@(bus_lane_boundary_left_id)}",
        "LeftLane": {
          "Dir": "Forward",
          "Id": "{bus_lane_id}"
        },
        "Type": "LaneBoundary"
      },
      "type": "Feature"
    }
  ],
  "type": "FeatureCollection"
}
-->
