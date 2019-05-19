class Navigation
  require 'webdrivers'
  require 'watir'
  require './utils.rb'
  require './action.rb'

  attr_accessor :page
  def initialize(brow:, page: nil)
    @page = page
    @brow = brow

    @main_accts = []
    f = open('main_accts.txt')
    f.each_line { |line| @main_accts << line }
    f.close
  end

  def login
    Utils.sleep_block { @brow.goto('https://www.instagram.com/accounts/login/') }
    password = ENV['INSTA_PASS']
    username = ENV['INSTA_USER']
    # sign in
    @brow.text_field(name: 'username').set "#{username}"
    @brow.text_field(name: 'password').set "#{password}"
    @brow.button(type: 'submit').click
    @brow.button(text: 'Not Now').click
  end

  def dream
    puts "..!...~..~....."
  end

  def goto_rnd_img
    # click on random image
    images = @brow.divs(class: 'eLAPa')
    Utils.sleep_block { Array(images).sample.click }
  end  
  
  def goto_rnd_img_with_likes_btn_and_click
    no_likes_btn = true
    while(no_likes_btn) do
      goto_rnd_img
      likes_btn = @brow.button(visible_text: /others/)
      likes_btn = @brow.button(visible_text: /likes/) unless likes_btn.present?
      no_likes_btn = false if likes_btn.present?
    end
    likes_btn.click
  end

  def goto_a_main_acct
    puts "going to a main account"
    goto_acct(@main_accts.sample)
  end

  def goto_rnd_likes_list
    goto_a_main_acct
    goto_rnd_img_with_likes_btn_and_click
  end

  def goto_acct(username)
    Utils.sleep_block { @brow.goto("https://www.instagram.com/#{username}") } 
  end
end