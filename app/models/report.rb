class Report < ActiveRecord::Base
  belongs_to :user

  def top_adwords_number
  	self.top_adwords_url.count
  end

  def right_adwords_number
  	self.right_adwords_url.count
  end

  def total_adwords_number
  	self.top_adwords_number + self.right_adwords_number
  end

  def non_adwords_number
  	self.non_adwords_url.count
  end

  def total_links
  	self.top_adwords_url.count + self.right_adwords_url.count + self.non_adwords_url.count
  end

  def get_page_cache
  	PGconn.unescape_bytea(self.page_cache)
  end
end
