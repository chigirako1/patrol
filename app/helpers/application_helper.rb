module ApplicationHelper

  BASE_TITLE = "巡回app".freeze

  def full_title(page_title)
    if page_title.blank?
      BASE_TITLE
    else
      "#{page_title} - #{BASE_TITLE}"
    end
  end

  def get_twt_user_url(twtid)
    %!https://twitter.com/#{twtid}!
  end

end
