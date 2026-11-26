module ${{ values.goModule }}

go 1.26.6

require (
	charm.land/bubbletea/v2 v2.2.0
	charm.land/lipgloss/v2 v2.1.1
	github.com/stuttgart-things/homerun-library/v4 v4.6.0
	github.com/redis/go-redis/v9 v9.24.0
{%- if values.serviceType == "catcher" %}
	github.com/stuttgart-things/redisqueue v0.0.0-20230628084515-1d31f7874df7
{%- endif %}
)
