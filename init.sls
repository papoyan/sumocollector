{%- set sources =  salt['pillar.get']('sumocollector:sources') %}
{%- set accessid =  salt['pillar.get']('sumocollector:accessid') %}
{%- set accesskey =  salt['pillar.get']('sumocollector:accesskey') %}
{%- set collector_name =  salt['pillar.get']('sumocollector:collector_name') %}
{%- set sources_file_path =  salt['pillar.get']('sumocollector:sources_file_path') %}
{% from "sumocollector/map.jinja" import sumo with context %}

sumo.sources:
  file.serialize:
    - name: {{ sources_file_path }}
    - dataset: {{ sources }}
    - user: root
    - group: sumologic_collector
    - mode: 644
    - formatter: json

sumo.download_package:
  cmd.run:
    - name: curl -L {{ sumo.packagesource_us }} -o /tmp/sumo.sh 
    - creates: /tmp/sumo.sh
    - unless: test -f /tmp/sumo.sh
 
sumo.install_package:
  cmd.run:
    - name: /bin/sh /tmp/sumo.sh -q -Vsumo.accessid={{ accessid }} -Vsumo.accesskey={{ accesskey }} -VsyncSources={{ sources_file_path }} -Vcollector.name={{ collector_name }}
    - unless: test -d {{ sumo.install_dir }}
    - onlyif: test -f {{ sources_file_path }}
