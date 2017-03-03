{%- set accessid =  salt['pillar.get']('sumocollector:accessid') %}
{%- set accesskey =  salt['pillar.get']('sumocollector:accesskey') %}
{%- set collector_name =  salt['pillar.get']('sumocollector:collector_name') %}
{%- set collector_region =  salt['pillar.get']('sumocollector:collector_region') %}
{%- set sources_file_path =  salt['pillar.get']('sumocollector:sources_file_path') %}
{% from "sumocollector/map.jinja" import sumo with context %}


{% if collector_region == 'eu' %}
    {%- set sumo_package_url =  sumo.packagesource_eu %}
{% else %}
    {%- set sumo_package_url =  sumo.packagesource_us %}
{% endif %}


sumo.source_directory:
  file.directory:
    - name: {{ sources_file_path }}
    - mode: 755
    - user: root
    - group: sumologic_collector
    - recurse:
      - user
      - group


{% for src in salt['pillar.get']('sumocollector:sources') -%}
{{ src.file_name }}:
  file.serialize:
    - name: {{ sources_file_path }}/{{ src.file_name }}.json
    - dataset: {{ src.data }}
    - user: root
    - group: sumologic_collector
    - mode: 644
    - formatter: json
    - require:
        - file: sumo.source_directory
{% endfor %}


sumo.download_package:
  cmd.run:
    - name: curl -L {{ sumo_package_url }} -o /tmp/sumo.sh 
    - creates: /tmp/sumo.sh
    - unless: test -f /tmp/sumo.sh
 

sumo.install_package:
  cmd.run:
    - name: /bin/sh /tmp/sumo.sh -q -Vsumo.accessid={{ accessid }} -Vsumo.accesskey={{ accesskey }} -VsyncSources={{ sources_file_path }} -Vcollector.name={{ collector_name }}
    - unless: test -d {{ sumo.install_dir }}
    - onlyif: test -d {{ sources_file_path }}
