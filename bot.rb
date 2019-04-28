require 'pry'
require 'slop'
require './hi_bot.rb'

class Global
  OPTS = Slop.parse do |o|
    o.bool '-q', '--quiet', 'suppress output (quiet mode)'
  end

  attr_accessor :errors, :bot
  def initialize
    @errors = []
    @bot = HiBot.new
    @bot.login
    bot_do
  end

  def nap
    puts "\nGOING TO TAKE A NAP...\n..\n."
    sleep(10000)
  end

  def the_loop
    while true
      puts "oh man, we have: #{errors.length} errors.." unless errors.empty?
      status = bot.go_like_something
      nap unless status[:continue]
    end
  end

  def bot_do
    begin
      the_loop
    rescue => e
      puts "\n\n! ! !\n\n"
      puts e.message
      puts "\n\n\n"
      errors << e
      the_loop
    end
  end
end

Global.new
