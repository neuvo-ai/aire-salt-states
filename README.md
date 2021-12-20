## Salt-Master config /etc/salt/master

```yaml
# Salt formulas added under file roots
file_roots:
  base:
    - /srv/salt
    - /srv/formulas/oh-my-zsh-formula
    - /srv/formulas/salt-formula-aide

pillar_roots:
   base:
     - /srv/pillar

# Default database is salt, can override with:
# mongo.db: "salt"
mongo.host: "localhost"
ext_pillar:
  - mongo: {}

pillar_source_merging_strategy: recurse
```

## Install to Salt-Master

**To read Pillar data from a mongodb collection depends pymongo (for salt-master)**
To use Salt-Master ext_pillar install:

`apt install python3-pip`
`pip install pymongo`

## Salt master common command line commands

Test connection from salt-master to salt-minion
`salt minion4 test.ping`

Get minion pillar data for pillar key mongodb
`salt minion4 pillar.item mongodb`

Get minion all pillar data
`salt minion4 pillar.items`

Refresh minion pillar data
`salt minion4 saltutil.refresh_pillar`

Add grain value to key
`salt minion4 grains.append roles botfront`

Remove grain value from key
`salt minion4 grains.remove roles botfront`

Run specific state for minion
`salt minion4 state.apply mongodb`

To target more than one specific minion
`salt -L 'minion4,minion5' test.ping`

Restart Salt-Master service
`systemctl restart salt-master.service`