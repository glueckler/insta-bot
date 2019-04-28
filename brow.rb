require 'webdrivers'
require 'watir'

class Brow
  attr_reader :brow
  def initialize
    @brow = Watir::Browser.new
  end
end