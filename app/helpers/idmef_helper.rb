module IdmefHelper
  def idmef_bgcolor(event)
    return "#00FF00" if event.severity == "low"
    return "#888800" if event.severity == "medium"
    return "#FF0000" if event.severity == "high"
  end
end
