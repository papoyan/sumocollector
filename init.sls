{% from "sumocollector/map.jinja" import sumo with context %}

sumo.download_package:
  cmd.run:
    - name: curl -L {{ sumo.packagesource_us }} -o /tmp/sumo.sh 
    - creates: /tmp/sumo.sh
    - unless: test -f /tmp/sumo.sh
 
{% if salt['pillar.get']('sumocollector:accessid') %}
sumo.generate_credentials_file:
  file.managed:
    - name: /tmp/sumo_credentials.txt
    - user: root
    - group: root
    - source: salt://sumocollector/templates/sumo_credentials.jinja
    - template: jinja
{% endif %}

sumo.install_package:
  cmd.run:
    - name: /bin/sh /tmp/sumo.sh -q -varfile /tmp/sumo_credentials.txt
    - unless: test -f /opt/SumoCollector/collector
    - onlyif: test -f /tmp/sumo_credentials.txt

sumo.cleanup:
  cmd.run:
    - name: rm -f /tmp/sumo_credentials.txt
    - onlyif: test -f /opt/SumoCollector/collector
    - onlyif: /tmp/sumo_credentials.txt

sumo.config:
  file.managed:
    - name: /etc/sumo.conf
    - user: root
    - group: sumologic_collector
    - source: salt://sumocollector/templates/sumo.conf.jinja
    - template: jinja

