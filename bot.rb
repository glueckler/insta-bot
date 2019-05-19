require 'pry'
require 'slop'
require './hi_bot.rb'

class Global
  OPTS = Slop.parse do |o|
    o.bool '-q', '--quiet', 'suppress output (quiet mode)'
  end

  attr_accessor :errors, :bot
  def initialize
    @bot_on = true
    @errors = []
    @bot = HiBot.new
    @bot.login
    bot_do
  end

  def nap
    puts "\nGOING TO TAKE A NAP...\n..\n."
    sleep(10000)
  end

  def dream
    puts "~--`~-~~~____`~~~~"
  end

  def the_loop
    while @bot_on
      dream
      puts "oh man, we have: #{errors.length} errors.." unless errors.empty?

      status = bot.bot_checks
      nap if status[:error] == HiBot::ERR_MAX_LIKES
      next unless status[:continue]

      status = bot.find_user_to_interact
      if status[:error] == HiBot::ERR_NO_USER_FOUND
        puts status[:error]
        bot.comb_usernames_from_rnd_main
        next
      end

      status = bot.go_like_something(status[:user])
      if status[:error]
        puts "! ! !"
        puts status[:error]
        puts "! ! !"
      end
    end
  end

  def bot_do
    begin
      the_loop
    rescue => e
      puts "! ! ~ - ~ ! !"
      puts e.message
      puts "! ! ~ - ~ ! !"
      errors << e
      sleep(5)
      bot_do
    end
  end
end

Global.new
