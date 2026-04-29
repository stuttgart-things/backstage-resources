module ${{ values.goModule }}

go 1.25.5

require (
	charm.land/bubbletea/v2 v2.0.6
	charm.land/lipgloss/v2 v2.0.2
	github.com/stuttgart-things/homerun-library/v3 v3.0.4
	github.com/redis/go-redis/v9 v9.18.0
{%- if values.serviceType == "catcher" %}
	github.com/stuttgart-things/redisqueue v0.0.0-20230628084515-1d31f7874df7
{%- endif %}
)
