module DialogHelper
  def link_to_dialog(title,url)
    "<a href=\"#\" onclick=\"link_to_dialog('#{url}');\">#{title}</a>".html_safe
  end
end
