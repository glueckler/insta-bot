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
      sleep(1)
    end
    usernames_list
  end

  def get_list_of_users_from_following
    following_modal = @brow.div(class: 'isgrP')
    scroll_without_loading_anymore_users = 0
    usernames_list = []
    while scroll_without_loading_anymore_users < 4 && usernames_list.length < HiBot::REL_USR_COUNT
      Utils.scroll_to_top(following_modal.child.div)
      sleep(0.3)
      Utils.scroll_to_bottom(following_modal.child.div)

      sleep(1)

      previous_username_list_len = usernames_list.length
      usernames_list = (usernames_list + read_visible_usernames(following_modal)).uniq

      if previous_username_list_len == usernames_list.length
        scroll_without_loading_anymore_users += 1
        puts "scroll without loading more x " + scroll_without_loading_anymore_users.to_s if scroll_without_loading_anymore_users % 2 == 0
      else
        scroll_without_loading_anymore_users = 0
        puts usernames_list.length.to_s + " usernames scrolled" if usernames_list.length % 50 > 38
      end
    end
    usernames_list.uniq
  end

  private

  def read_visible_usernames(parent)
    parent.as(title: /\w+/).map { |el| el.title.strip }
  end
end
