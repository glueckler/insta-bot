class Utils
  def self.sleep_block(&block)
    block.call
    # pick from a random sample of sleep times
    sleep([5.1, 5.5, 5.7, 7.7, 5.2, 6.3, 9].sample)
  end

  def self.insta_acct_page?(brow)
    brow.div(class: "nZSzR").present?
  end

  def self.private_acct?(brow)
    return false unless self.insta_acct_page?(brow)
    brow.element(text: "This Account is Private").present?
  end

  def self.scroll_to_bottom(container)
    container.scroll.to :bottom
  end
end
