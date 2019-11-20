class Utils
  def self.sleep_block(&block)
    block.call
    # pick from a random sample of sleep times
    sleep([5.1, 5.5, 5.7, 7.7, 5.2, 6.3, 9].sample)
  end

  def self.insta_acct_page?(brow)
    !brow.element(text: "Sorry, this page isn't available.").present?
  end

  def self.private_acct?(brow)
    return false unless self.insta_acct_page?(brow)
    brow.element(text: "This Account is Private").present?
  end

  def self.should_wait_a_while(brow)
    brow.element(text: "Please wait a few minutes before you try again.").present?
  end

  def self.scroll_to_bottom(container)
    container.scroll.to :bottom
  end

  def self.scroll_up(container)
    container.scroll.by(0, -100) # this isn't working,,
  end

  def self.scroll_to_top(container)
    container.scroll.to :top
  end
end
