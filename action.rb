class Action
  require './utils.rb'

  def initialize(brow:)
    @brow = brow
  end

  def check_and_follow
    follow_btn = @brow.button(visible_text: 'Follow')
    follow_btn.click if follow_btn.present?
  end

  def like_img
    @brow.span(aria_label: 'Like').click
  end

  def get_list_of_users_from_likes
    likes_modal = @brow.div(class: 'i0EQd')
    scroll_count = 0
    usernames_list = []
    while usernames_list.length < 300 && scroll_count < 20
      usernames_list = (usernames_list + read_visible_usernames(likes_modal)).uniq
      Utils.scroll_to_bottom(likes_modal.child.div)
      scroll_count += 1
      sleep(0.2)
    end
    usernames_list
  end

  def get_list_of_users_from_following
    following_modal = @brow.div(class: 'isgrP')
    scroll_count = 0
    usernames_list = []
    while scroll_count < 40
      usernames_list = (usernames_list + read_visible_usernames(following_modal)).uniq
      Utils.scroll_to_bottom(following_modal.child.div)
      scroll_count += 1
      sleep(0.2)
    end
    usernames_list
  end

  private

  def read_visible_usernames(parent)
    parent.as(title: /\w+/).map { |el| el.title.strip }
  end
end
