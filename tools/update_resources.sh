#!/bin/bash

# Updates resources with the latest version of the XODR schema templates.

script_dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"

# Generates straight_road resources
LENGTH=500 WIDTH=3 CROSSWALK=True empy3 ${script_dir}/../templates/straight_road.xml.em > ${script_dir}/../resources/straight_road/straight_road_3m_width_crosswalk.xodr
${script_dir}/extract_geojson_info.sh ${script_dir}/../resources/straight_road/straight_road_3m_width_crosswalk.xodr

LENGTH=500 WIDTH=3.5 CROSSWALK=True empy3 ${script_dir}/../templates/straight_road.xml.em > ${script_dir}/../resources/straight_road/straight_road_3_5m_width_crosswalk.xodr
${script_dir}/extract_geojson_info.sh ${script_dir}/../resources/straight_road/straight_road_3_5m_width_crosswalk.xodr

LENGTH=500 WIDTH=4 CROSSWALK=True empy3 ${script_dir}/../templates/straight_road.xml.em > ${script_dir}/../resources/straight_road/straight_road_4m_width_crosswalk.xodr
${script_dir}/extract_geojson_info.sh ${script_dir}/../resources/straight_road/straight_road_4m_width_crosswalk.xodr

LENGTH=500 WIDTH=3 CROSSWALK=False empy3 ${script_dir}/../templates/straight_road.xml.em > ${script_dir}/../resources/straight_road/straight_road_3m_width.xodr
LENGTH=500 WIDTH=3.5 CROSSWALK=False empy3 ${script_dir}/../templates/straight_road.xml.em > ${script_dir}/../resources/straight_road/straight_road_3_5m_width.xodr
LENGTH=500 WIDTH=4 CROSSWALK=False empy3 ${script_dir}/../templates/straight_road.xml.em > ${script_dir}/../resources/straight_road/straight_road_4m_width.xodr

LENGTH=200 WIDTH=3 CROSSWALK=True STOPLINE=True STOPLINE_DISTANCE=7 empy3 ${script_dir}/../templates/straight_road.xml.em > ${script_dir}/../resources/straight_road/straight_road_200m_3m_width_crosswalk_stopline.xodr
${script_dir}/extract_geojson_info.sh ${script_dir}/../resources/straight_road/straight_road_200m_3m_width_crosswalk_stopline.xodr
LENGTH=200 WIDTH=3.5 CROSSWALK=True STOPLINE=True STOPLINE_DISTANCE=7 empy3 ${script_dir}/../templates/straight_road.xml.em > ${script_dir}/../resources/straight_road/straight_road_200m_3_5m_width_crosswalk_stopline.xodr
${script_dir}/extract_geojson_info.sh ${script_dir}/../resources/straight_road/straight_road_200m_3_5m_width_crosswalk_stopline.xodr
LENGTH=200 WIDTH=4. CROSSWALK=True STOPLINE=True STOPLINE_DISTANCE=7 empy3 ${script_dir}/../templates/straight_road.xml.em > ${script_dir}/../resources/straight_road/straight_road_200m_4m_width_crosswalk_stopline.xodr
${script_dir}/extract_geojson_info.sh ${script_dir}/../resources/straight_road/straight_road_200m_4m_width_crosswalk_stopline.xodr

LENGTH=600 WIDTH=3 CROSSWALK=True STOPLINE=True STOPLINE_DISTANCE=7 empy3 ${script_dir}/../templates/straight_road.xml.em > ${script_dir}/../resources/straight_road/straight_road_600m_3m_width_crosswalk_stopline.xodr
LENGTH=600 WIDTH=3.5 CROSSWALK=True STOPLINE=True STOPLINE_DISTANCE=7 empy3 ${script_dir}/../templates/straight_road.xml.em > ${script_dir}/../resources/straight_road/straight_road_600m_3_5m_width_crosswalk_stopline.xodr
LENGTH=600 WIDTH=4 CROSSWALK=True STOPLINE=True STOPLINE_DISTANCE=7 empy3 ${script_dir}/../templates/straight_road.xml.em > ${script_dir}/../resources/straight_road/straight_road_600m_4m_width_crosswalk_stopline.xodr

# Generates intersection resources
WIDTH=3 CROSSWALK=True CROSSWALK_LENGTH=2 RADIUS=8 empy3 ${script_dir}/../templates/intersection.xml.em > ${script_dir}/../resources/intersection/intersection_3m_width_crosswalk.xodr
${script_dir}/extract_geojson_info.sh ${script_dir}/../resources/intersection/intersection_3m_width_crosswalk.xodr
WIDTH=3.5 CROSSWALK=True CROSSWALK_LENGTH=2 RADIUS=8 empy3 ${script_dir}/../templates/intersection.xml.em > ${script_dir}/../resources/intersection/intersection_3_5m_width_crosswalk.xodr
${script_dir}/extract_geojson_info.sh ${script_dir}/../resources/intersection/intersection_3_5m_width_crosswalk.xodr
WIDTH=4 CROSSWALK=True CROSSWALK_LENGTH=2 RADIUS=8 empy3 ${script_dir}/../templates/intersection.xml.em > ${script_dir}/../resources/intersection/intersection_4m_width_crosswalk.xodr
${script_dir}/extract_geojson_info.sh ${script_dir}/../resources/intersection/intersection_4m_width_crosswalk.xodr

WIDTH=3 CROSSWALK=False CROSSWALK_LENGTH=2 RADIUS=8 empy3 ${script_dir}/../templates/intersection.xml.em > ${script_dir}/../resources/intersection/intersection_3m_width.xodr
${script_dir}/extract_geojson_info.sh ${script_dir}/../resources/intersection/intersection_3m_width.xodr
WIDTH=3.5 CROSSWALK=False CROSSWALK_LENGTH=2 RADIUS=8 empy3 ${script_dir}/../templates/intersection.xml.em > ${script_dir}/../resources/intersection/intersection_3_5m_width.xodr
${script_dir}/extract_geojson_info.sh ${script_dir}/../resources/intersection/intersection_3_5m_width.xodr
WIDTH=4 CROSSWALK=False CROSSWALK_LENGTH=2 RADIUS=8 empy3 ${script_dir}/../templates/intersection.xml.em > ${script_dir}/../resources/intersection/intersection_4m_width.xodr
${script_dir}/extract_geojson_info.sh ${script_dir}/../resources/intersection/intersection_4m_width.xodr

WIDTH=3.3 CROSSWALK=False STOPLINE=True RADIUS=6 empy3 ${script_dir}/../templates/intersection.xml.em > ${script_dir}/../resources/intersection/intersection_3_3m_width_6m_radius_stopline.xodr
${script_dir}/extract_geojson_info.sh ${script_dir}/../resources/intersection/intersection_3_3m_width_6m_radius_stopline.xodr
WIDTH=3.3 CROSSWALK=False STOPLINE=True RADIUS=6 EXTENSIONS_LENGTH=300 empy3 ${script_dir}/../templates/intersection.xml.em > ${script_dir}/../resources/intersection/intersection_3_3m_width_6m_radius_300m_approach_stopline.xodr
${script_dir}/extract_geojson_info.sh ${script_dir}/../resources/intersection/intersection_3_3m_width_6m_radius_300m_approach_stopline.xodr

# Generates t_intersection resources
empy3 ${script_dir}/../templates/t_intersection.xml.em > ${script_dir}/../resources/t_intersection/t_intersection_default.xodr
EXTENSIONS_LENGTH=300 empy3 ${script_dir}/../templates/t_intersection.xml.em > ${script_dir}/../resources/t_intersection/t_intersection_300m_approach.xodr

# Generates curved_road resources
empy3 ${script_dir}/../templates/curved_road.xml.em > ${script_dir}/../resources/curved_road/curved_road_default.xodr

# Generates dedicated_southbound_right_turn_lane
EXTENSIONS_LENGTH=300 WIDTH=3.3 STOPLINE=True RADIUS=6.0 empy3 ${script_dir}/../templates/dedicated_southbound_right_turn_lane.xml.em > ${script_dir}/../resources/dedicated_southbound_right_turn_lane/dedicated_southbound_right_turn_lane.xodr
${script_dir}/extract_geojson_info.sh ${script_dir}/../resources/dedicated_southbound_right_turn_lane/dedicated_southbound_right_turn_lane.xodr
EXTENSIONS_LENGTH=100 WIDTH=3.3 STOPLINE=True RADIUS=6.0 empy3 ${script_dir}/../templates/dedicated_southbound_right_turn_lane.xml.em > ${script_dir}/../resources/dedicated_southbound_right_turn_lane/dedicated_southbound_right_turn_lane_100m_extension.xodr
${script_dir}/extract_geojson_info.sh ${script_dir}/../resources/dedicated_southbound_right_turn_lane/dedicated_southbound_right_turn_lane_100m_extension.xodr

# Generates curved_connected_roads resources
empy3 ${script_dir}/../templates/curved_connected_roads.xml.em > ${script_dir}/../resources/curved_connected_roads/curved_connected_roads_default.xodr

# Generates bus stop resources
empy3 ${script_dir}/../templates/bus_stop.xml.em > ${script_dir}/../resources/bus_stop/bus_stop_default.xodr
