{%- if values.serviceType == "catcher" %}
package catcher

import (
	"log/slog"

	"${{ values.goModule }}/internal/models"
)

// LogHandler returns a MessageHandler that logs messages with severity-aware levels.
func LogHandler() MessageHandler {
	return func(msg models.CaughtMessage) {
		level := severityToLevel(msg.Severity)

		slog.Log(nil, level, "message caught",
			"objectId", msg.ObjectID,
			"streamId", msg.StreamID,
			"title", msg.Title,
			"message", msg.Message.Message,
			"severity", msg.Severity,
			"author", msg.Author,
			"system", msg.System,
			"timestamp", msg.Timestamp,
			"tags", msg.Tags,
		)
	}
}

func severityToLevel(severity string) slog.Level {
	switch severity {
	case "error":
		return slog.LevelError
	case "warning":
		return slog.LevelWarn
	case "debug":
		return slog.LevelDebug
	default:
		return slog.LevelInfo
	}
}
{%- else %}
package catcher
{%- endif %}
