{% for instance in pillar['instances'] %}
hetzner-instance-{{ instance.name }}:
  cloud.profile:
    - name: {{ instance.name }}
    - profile: hetzner_cx11
    #- kwargs: {{ instance.kwargs | yaml }}
    #- kwargs:
    #    size: cpx11
{% endfor %}