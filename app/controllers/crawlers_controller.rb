class CrawlersController < ApplicationController
  include CrawlersHelper

  
  def index 
    return @result = {} if !params['query']
    # get request urls
    wellcome_request_url, friday_request_url = query_type_check(params['query'])
    wellcome = wellcome_crawler(wellcome_request_url)
    friday = friday_crawler(friday_request_url)
    @result = product_match(friday, wellcome)
  end
end


