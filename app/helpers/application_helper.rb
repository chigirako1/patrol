module ApplicationHelper

  BASE_TITLE = "巡回app".freeze

  def full_title(page_title)
    if page_title.blank?
      BASE_TITLE
    else
      "#{page_title} - #{BASE_TITLE}"
    end
  end

  def link_to_ex(txt, link)
    link_to(txt, link, target: :_blank, rel: "noopener noreferrer")
  end
end
