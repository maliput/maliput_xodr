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

# Georeference information
LAT_0 = 37.4168716
LON_0 = -122.1030492

def str2bool(string):
  return string.lower() in ("yes", "true", "t", "1")

def str2float(string):
  return float(string)

length = str2float(os.environ['LENGTH']) if 'LENGTH' in os.environ  else 500.0
x_offset = str2float(os.environ['X_OFFSET']) if 'X_OFFSET' in os.environ  else 0.0
y_offset = str2float(os.environ['Y_OFFSET']) if 'Y_OFFSET' in os.environ  else 0.0
width = str2float(os.environ['WIDTH']) if 'WIDTH' in os.environ  else 3.0
crosswalk = str2bool(os.environ['CROSSWALK']) if 'CROSSWALK' in os.environ else False
crosswalk_length = 2.0

# With crosswalk:
#         Road 3
# ------> ------> ------->
# <------ <------ <-------
# Road 1  Road 4  Road 2

# Without crosswalk:
# Road 1
# ----------------->
# <-----------------
#


if crosswalk:
  import pyproj
  def cartesian_to_geodetic(x, y, z, origin_lon, origin_lat):
    # Define the projection systems
    geodetic_crs = pyproj.CRS.from_string("EPSG:4326")  # Geodetic (lon, lat) system (WGS84)
    projection_crs = pyproj.CRS.from_string(f"+proj=tmerc +lat_0={origin_lat} +lon_0={origin_lon} +k=1 +x_0=0 +y_0=0 +datum=WGS84 +units=m +no_defs")  # Cartesian (x, y, z) system with tmerc projection (WGS84)

    # Create the transformer
    transformer = pyproj.Transformer.from_crs(projection_crs, geodetic_crs, always_xy=True)

    # Convert Cartesian coordinates to geodetic
    target_lon, target_lat, target_z = transformer.transform(x, y, z)

    return target_lon, target_lat, target_z


  ## Roads coordinates
  # Road 1
  road_1_length = length/2.0 - 2.0
  road_1_start = [x_offset, y_offset]
  road_1_end = [road_1_length + road_1_start[0], road_1_start[1]]

  # Road 3
  road_3_length = 4.0
  road_3_start = road_1_end
  road_3_end = [road_3_start[0] + road_3_length, road_3_start[1]]

  # Road 4
  road_4_length = 4.0
  road_4_start = road_3_start
  road_4_end = road_3_end

  # Road 2
  road_2_length = road_1_length
  road_2_start = road_3_end
  road_2_end = [road_2_start[0] + road_2_length, road_2_start[1]]

  ## Calculate corners of the crosswalk
  crosswalk_points = [[road_3_start[0] + crosswalk_length/2. , road_3_start[1] + width],
                      [road_3_start[0] + crosswalk_length/2. , road_3_start[1] - width],
                      [road_3_end[0] - crosswalk_length/2. , road_3_end[1] - width],
                      [road_3_end[0] - crosswalk_length/2. , road_3_end[1] + width]]

  crosswalk_points_lon_lat = []
  for point in crosswalk_points:
    lon, lat, h = cartesian_to_geodetic(point[0], point[1], 0, LON_0, LAT_0)
    crosswalk_points_lon_lat.append([lon, lat, h])
  crosswalk_points_lon_lat.append(crosswalk_points_lon_lat[0]) # GeoJSON format needs closure

}@
<!--
 Map generated using:
  - LENGTH: @(length)@ 
  - WIDTH: @(width)@ 
  - CROSSWALK: @(crosswalk)@ 
  - OFFSET_X: @(x_offset)@ 
  - OFFSET_Y: @(y_offset)@ 
-->
<OpenDRIVE>
    <header revMajor="1" revMinor="1" name="StraightRoad" version="1.00" date="Fri Apr 28 12:00:00 2023" north="0.0000000000000000e+00" south="0.0000000000000000e+00" east="0.0000000000000000e+00" west="0.0000000000000000e+00" maxRoad="2" maxJunc="0" maxPrg="0">
        <geoReference><![CDATA[+proj=tmerc +lat_0=@(LAT_0)@  +lon_0=@(LON_0)@  +k=1 +x_0=0 +y_0=0 +datum=WGS84 +units=m +vunits=m +no_defs ]]></geoReference>
    </header>
    @[if not crosswalk]<road name="Road 1" length="@(length)@\" id="1" junction="-1">
        <link>
        </link>
        <planView>
            <geometry s="0.0000000000000000e+00" x="@(x_offset)@\" y="@(y_offset)@\" hdg="0.0" length="@(length)@\">
                <line/>
            </geometry>
        </planView>
        <elevationProfile>
        </elevationProfile>
        <lateralProfile>
        </lateralProfile>
        <lanes>
            <laneSection s="0.0000000000000000e+00">
                <left>
                    <lane id="1" type="driving" level= "0">
                        <link>
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
    </road>@[else]<road name="Road 1" length="@(road_1_length)@\" id="1" junction="-1">
        <link>
          <successor elementType="junction" elementId="2"/>
        </link>
        <planView>
            <geometry s="0.0000000000000000e+00" x="@(road_1_start[0])@\" y="@(road_1_start[1])@\" hdg="0.0" length="@(road_1_length)@\">
                <line/>
            </geometry>
        </planView>
        <elevationProfile>
        </elevationProfile>
        <lateralProfile>
        </lateralProfile>
        <lanes>
            <laneSection s="0.0000000000000000e+00">
                <left>
                    <lane id="1" type="driving" level= "0">
                        <link>
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
    <road name="Road 3" length="@(road_3_length)@\" id="3" junction="2">
        <link>
            <predecessor elementType="road" elementId="1" contactPoint="end"/>
            <successor elementType="road" elementId="2" contactPoint="start"/>
        </link>
        <planView>
            <geometry s="0.0000000000000000e+00" x="@(road_3_start[0])@\" y="@(road_3_start[1])@\" hdg="0.0" length="@(road_3_length)@\">
                <line/>
            </geometry>
        </planView>
        <elevationProfile>
        </elevationProfile>
        <lateralProfile>
        </lateralProfile>
        <lanes>
            <laneSection s="0.0000000000000000e+00">
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
        <objects>
            <object type="crosswalk" id="0" s="2.0" t="0.0" zOffset="0.0" orientation="none" length="2.0" width="@(width)@\" hdg="0.0" pitch="0.0" roll="0.0">
                <outlines>
                    <outline id="0">
                        <cornerRoad s="1.0" t="@(width)@\" dz="0.0" height="4.0" id="0"/>
                        <cornerRoad s="1.0" t="0.0" dz="0.0" height="4.0" id="1"/>
                        <cornerRoad s="3.0" t="0.0" dz="0.0" height="4.0" id="2"/>
                        <cornerRoad s="3.0" t="@(width)@\" dz="0.0" height="4.0" id="3"/>
                    </outline>
                </outlines>
                <markings>
                    <marking width="0.1" color="white" zOffset="0.005" spaceLength ="0.05" lineLength ="0.2" startOffset="0.0" stopOffset="0.0" outlineId="0">
                        <cornerReference id="0"/>
                        <cornerReference id="1"/>
                    </marking>
                    <marking width="0.1" color="white" zOffset="0.005" spaceLength ="0.05" lineLength ="0.2" startOffset="0.0" stopOffset="0.0" outlineId="0">
                        <cornerReference id="2"/>
                        <cornerReference id="3"/>
                    </marking>
                </markings>
            </object>
        </objects>
        <signals>
        </signals>
    </road>
    <road name="Road 4" length="@(road_4_length)@\" id="4" junction="2">
        <link>
            <predecessor elementType="road" elementId="1" contactPoint="end"/>
            <successor elementType="road" elementId="2" contactPoint="start"/>
        </link>
        <planView>
            <geometry s="0.0000000000000000e+00" x="@(road_4_start[0])@\" y="@(road_4_start[1])@\" hdg="0.0" length="@(road_4_length)@\">
                <line/>
            </geometry>
        </planView>
        <elevationProfile>
        </elevationProfile>
        <lateralProfile>
        </lateralProfile>
        <lanes>
            <laneSection s="0.0000000000000000e+00">
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
                            <vectorLane travelDir="backward"/>
                        </userData>
                    </lane>
                </right>
            </laneSection>
        </lanes>
        <objects>
            <object type="crosswalk" id="0" s="2.0" t="0.0" zOffset="0.0" orientation="none" length="2.0" width="@(width)@\" hdg="0.0" pitch="0.0" roll="0.0">
                <outlines>
                    <outline id="0">
                        <cornerRoad s="1.0" t="0.0" dz="0.0" height="4.0" id="0"/>
                        <cornerRoad s="1.0" t="-@(width)@\" dz="0.0" height="4.0" id="1"/>
                        <cornerRoad s="3.0" t="-@(width)@\" dz="0.0" height="4.0" id="2"/>
                        <cornerRoad s="3.0" t="0.0" dz="0.0" height="4.0" id="3"/>
                    </outline>
                </outlines>
                <markings>
                    <marking width="0.1" color="white" zOffset="0.005" spaceLength ="0.05" lineLength ="0.2" startOffset="0.0" stopOffset="0.0" outlineId="0">
                        <cornerReference id="0"/>
                        <cornerReference id="1"/>
                    </marking>
                    <marking width="0.1" color="white" zOffset="0.005" spaceLength ="0.05" lineLength ="0.2" startOffset="0.0" stopOffset="0.0" outlineId="0">
                        <cornerReference id="2"/>
                        <cornerReference id="3"/>
                    </marking>
                </markings>
            </object>
        </objects>
        <signals>
        </signals>
    </road>
    <road name="Road 2" length="@(road_2_length)@\" id="2" junction="-1">
        <link>
          <predecessor elementType="junction" elementId="2"/>
        </link>
        <planView>
            <geometry s="0.0000000000000000e+00" x="@(road_2_start[0])@\" y="@(road_2_start[1])@\" hdg="0.0" length="@(road_2_length)@\">
                <line/>
            </geometry>
        </planView>
        <elevationProfile>
        </elevationProfile>
        <lateralProfile>
        </lateralProfile>
        <lanes>
            <laneSection s="0.0000000000000000e+00">
                <left>
                    <lane id="1" type="driving" level= "0">
                        <link>
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
    <junction id="2" name="CrosswalkJunction">
        <connection id="0" incomingRoad="1" connectingRoad="3" contactPoint="start">
            <laneLink from="1" to="1"/>
        </connection>
        <connection id="1" incomingRoad="1" connectingRoad="4" contactPoint="start">
            <laneLink from="-1" to="-1"/>
        </connection>
    </junction>@[end if]
</OpenDRIVE>
@[if crosswalk]
<!-- GeoJSON information for the crosswalks
Generated GeoJSON can be verified using: https://geojson.io
@{
}@

{
  "features": [
    {
      "geometry": {
        "coordinates": [
          [
@[for idx, lon_lat_z in enumerate(crosswalk_points_lon_lat)]@
            [
              @(lon_lat_z[0]),
              @(lon_lat_z[1]),
              @(lon_lat_z[2])
            ]@[if (idx != len(crosswalk_points_lon_lat)-1)],@[end if]
@[end for ]@
          ]
        ],
        "type": "Polygon"
      },
      "properties": {
          "Id": "{46c1b716-c704-427b-b57d-afe4fab608df}",
          "Type": "Crosswalk"
      },
      "type": "Feature"
    }
  ],
  "type": "FeatureCollection"
}

-->@[end if]
