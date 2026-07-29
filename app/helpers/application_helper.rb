module ApplicationHelper
  def nav_link(title, path)
    css = "sidebar__link"
    css += " sidebar__link--active" if current_page?(path)
    link_to title, path, class: css
  end
end
