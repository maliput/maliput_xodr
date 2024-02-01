<?xml version="1.0" encoding="UTF-8"?>
<!--
 BSD 3-Clause License

 Copyright (c) 2024, Woven by Toyota. All rights reserved.

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

def str2bool(string):
  return string.lower() in ("yes", "true", "t", "1")

def str2float(string):
  return float(string)

def sqrtdistance(p1:list, p2:list):
  return m.sqrt((p1[0] - p2[0])**2 + (p1[1] - p2[1])**2)

# Georeference information
LAT_0 = 37.4168716
LON_0 = -122.1030492

# Origin offset
x_offset = str2float(os.environ['X_OFFSET']) if 'X_OFFSET' in os.environ  else 0.0
y_offset = str2float(os.environ['Y_OFFSET']) if 'Y_OFFSET' in os.environ  else 0.0
# Width of the lanes
inner_lane_width = str2float(os.environ['INNER_LANE_WIDTH']) if 'INNER_LANE_WIDTH' in os.environ  else 4.3
outer_lane_width = str2float(os.environ['OUTER_LANE_WIDTH']) if 'OUTER_LANE_WIDTH' in os.environ  else 5.3
# Radius of circle map
radius = str2float(os.environ['RADIUS']) if 'RADIUS' in os.environ else 6.5

# Map
#
#                     Start of Road 2_____ End of Road 1
#                                      |            
#                                      v
#                             xxxxxxxxx xxxxxxxxx
#                           xxxx               xxxx
#                         xxx                     xxx
#                        xx                         xx
# End of Road 2__       xx                           xx
#                \     xx                             xx
#                /     xx <----------> X radius       xx <-- End of Road 0 | Start of Road 1
# Start of Road 3       xx                           xx
#                        xx                         xx
#                         xxx                      xxx
#                           xxxx                xxxx
#                             xxxxxxxxx xxxxxxxxx
#                                      ^
#                      End of Road 3 __|__ Start of Road 0
#
# Road 0 - Half circle
# Road 1 - Half circle

# Common road data:
road_radius = radius + inner_lane_width
road_curvature = 1. / road_radius
road_length = road_radius * m.pi / 2.

road_data = {}
road_data[0] = {
    'start': [x_offset, y_offset],
    'heading': 0.,
}
road_data[1] = {
    'start': [x_offset + road_radius, y_offset  + road_radius],
    'heading': m.pi / 2.,
}
road_data[2] = {
    'start': [x_offset, y_offset  + 2. * road_radius],
    'heading': m.pi,
}
road_data[3] = {
    'start': [x_offset - road_radius, y_offset  + road_radius],
    'heading': -m.pi / 2.,
}

}@
<!--
 Map generated using https://github.com/maliput/maliput_xodr.
 Generated using the following parameters:
  - INNER_LANE_WIDTH: @(inner_lane_width)@ 
    - Indicates the width of the inner lane
  - OUTER_LANE_WIDTH: @(outer_lane_width)@ 
    - Indicates the width of the outer lane
  - RADIUS: @(radius)@ 
    - Indicates the radius of the circle
  - OFFSET_X: @(x_offset)@ 
    - Indicates the offset in the x axis of the openDRIVE map
  - OFFSET_Y: @(y_offset)@ 
    - Indicates the offset in the y axis of the openDRIVE map
-->
<OpenDRIVE>
    <header revMajor="1" revMinor="1" name="Circle" version="1.00" date="Tue Jan 09 12:00:00 2024" north="0.0e+00" south="0.0e+00" east="0.0e+00" west="0.0e+00" maxRoad="2" maxJunc="0" maxPrg="0">
        <geoReference><![CDATA[+proj=tmerc +lat_0=@(LAT_0)@  +lon_0=@(LON_0)@  +k=1 +x_0=0 +y_0=0 +datum=WGS84 +units=m +vunits=m +no_defs ]]></geoReference>
    </header>
    <road name="Road 0" length="@(road_length)@\" id="0" junction="-1">
        <link>
            <predecessor elementType="road" elementId="3" contactPoint="end"/>
            <successor elementType="road" elementId="1" contactPoint="start"/>
        </link>
        <planView>
            <geometry s="0" x="@(road_data[0]['start'][0])@\" y="@(road_data[0]['start'][1])@\" hdg="@(road_data[0]['heading'])@\" length="@(road_length)@\">
                <arc curvature="@(road_curvature)@\"/>
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
                        <width sOffset="0.0e+00" a="@(inner_lane_width)@\" b="0.0e+00" c="0.0e+00" d="0.0e+00"/>
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
                        <roadMark sOffset="0.0e+00" type="broken" weight="standard" color="standard" width="1.3e-01"/>
                    </lane>
                </center>
                <right>
                    <lane id="-1" type="driving" level= "0">
                        <link>
                            <predecessor id="-1"/>
                            <successor id="-1"/>
                        </link>
                        <width sOffset="0.0e+00" a="@(outer_lane_width)@\" b="0.0e+00" c="0.0e+00" d="0.0e+00"/>
                        <roadMark sOffset="0.0e+00" type="solid" weight="standard" color="standard" width="1.0e-01"/>
                        <userData>
                            <vectorLane travelDir="backward"/>
                        </userData>
                    </lane>
                </right>
            </laneSection>
        </lanes>
    </road>
    <road name="Road 1" length="@(road_length)@\" id="1" junction="-1">
        <link>
            <predecessor elementType="road" elementId="0" contactPoint="end"/>
            <successor elementType="road" elementId="2" contactPoint="start"/>
        </link>
        <planView>
            <geometry s="0" x="@(road_data[1]['start'][0])@\" y="@(road_data[1]['start'][1])@\" hdg="@(road_data[1]['heading'])@\" length="@(road_length)@\">
                <arc curvature="@(road_curvature)@\"/>
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
                        <width sOffset="0.0e+00" a="@(inner_lane_width)@\" b="0.0e+00" c="0.0e+00" d="0.0e+00"/>
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
                        <roadMark sOffset="0.0e+00" type="broken" weight="standard" color="standard" width="1.3e-01"/>
                    </lane>
                </center>
                <right>
                    <lane id="-1" type="driving" level= "0">
                        <link>
                            <predecessor id="-1"/>
                            <successor id="-1"/>
                        </link>
                        <width sOffset="0.0e+00" a="@(outer_lane_width)@\" b="0.0e+00" c="0.0e+00" d="0.0e+00"/>
                        <roadMark sOffset="0.0e+00" type="solid" weight="standard" color="standard" width="1.0e-01"/>
                        <userData>
                            <vectorLane travelDir="backward"/>
                        </userData>
                    </lane>
                </right>
            </laneSection>
        </lanes>
    </road>
    <road name="Road 2" length="@(road_length)@\" id="2" junction="-1">
        <link>
            <predecessor elementType="road" elementId="1" contactPoint="end"/>
            <successor elementType="road" elementId="3" contactPoint="start"/>
        </link>
        <planView>
            <geometry s="0" x="@(road_data[2]['start'][0])@\" y="@(road_data[2]['start'][1])@\" hdg="@(road_data[2]['heading'])@\" length="@(road_length)@\">
                <arc curvature="@(road_curvature)@\"/>
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
                        <width sOffset="0.0e+00" a="@(inner_lane_width)@\" b="0.0e+00" c="0.0e+00" d="0.0e+00"/>
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
                        <roadMark sOffset="0.0e+00" type="broken" weight="standard" color="standard" width="1.3e-01"/>
                    </lane>
                </center>
                <right>
                    <lane id="-1" type="driving" level= "0">
                        <link>
                            <predecessor id="-1"/>
                            <successor id="-1"/>
                        </link>
                        <width sOffset="0.0e+00" a="@(outer_lane_width)@\" b="0.0e+00" c="0.0e+00" d="0.0e+00"/>
                        <roadMark sOffset="0.0e+00" type="solid" weight="standard" color="standard" width="1.0e-01"/>
                        <userData>
                            <vectorLane travelDir="backward"/>
                        </userData>
                    </lane>
                </right>
            </laneSection>
        </lanes>
    </road>
    <road name="Road 3" length="@(road_length)@\" id="3" junction="-1">
        <link>
            <predecessor elementType="road" elementId="2" contactPoint="end"/>
            <successor elementType="road" elementId="0" contactPoint="start"/>
        </link>
        <planView>
            <geometry s="0" x="@(road_data[3]['start'][0])@\" y="@(road_data[3]['start'][1])@\" hdg="@(road_data[3]['heading'])@\" length="@(road_length)@\">
                <arc curvature="@(road_curvature)@\"/>
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
                        <width sOffset="0.0e+00" a="@(inner_lane_width)@\" b="0.0e+00" c="0.0e+00" d="0.0e+00"/>
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
                        <roadMark sOffset="0.0e+00" type="broken" weight="standard" color="standard" width="1.3e-01"/>
                    </lane>
                </center>
                <right>
                    <lane id="-1" type="driving" level= "0">
                        <link>
                            <predecessor id="-1"/>
                            <successor id="-1"/>
                        </link>
                        <width sOffset="0.0e+00" a="@(outer_lane_width)@\" b="0.0e+00" c="0.0e+00" d="0.0e+00"/>
                        <roadMark sOffset="0.0e+00" type="solid" weight="standard" color="standard" width="1.0e-01"/>
                        <userData>
                            <vectorLane travelDir="backward"/>
                        </userData>
                    </lane>
                </right>
            </laneSection>
        </lanes>
    </road>
</OpenDRIVE>
