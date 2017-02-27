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
    - unless: test -d {{ sumo.install_dir }}
    - onlyif: test -f /tmp/sumo_credentials.txt

sumo.cleanup:
  cmd.run:
    - name: rm -f /tmp/sumo_credentials.txt
    - onlyif: test -d {{ sumo.install_dir }}
    - onlyif: /tmp/sumo_credentials.txt

sumo.restart:
  cmd.run:
    - name: {{ sumo.install_dir }}/collector restart

user.properties:
  file.managed:
    - name: {{ sumo.install_dir }}/config/user.properties
    - user: root
    - group: sumologic_collector
    - mode: 644
    - source: salt://sumocollector/templates/user.properties.jinja
    - template: jinja
    - onlyif: test -f {{ sumo.install_dir }}/config/user.properties
    - watch_in:
      - module: sumo.restart

sumo.sources:
  file.managed:
    - name: {{ sumo.install_dir }}/config/sources.json
    - user: root
    - group: sumologic_collector
    - mode: 644
    - source: salt://sumocollector/templates/sources.json.jinja
    - template: jinja
    - onlyif: test -d {{ sumo.install_dir }}
    - watch_in:
      - module: sumo.restart
