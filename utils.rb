class Utils
  def self.sleep_block(&block)
    block.call
    sleep(3)
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