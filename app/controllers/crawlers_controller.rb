class CrawlersController < ApplicationController
  include CrawlersHelper

  
  def index 
    return @result = {} if !params['query']
    # get request urls
    wellcome_request_url, amart_request_url = query_type_check(params['query'])
    wellcome = wellcome_crawler(wellcome_request_url)
    amart = amart_crawler(amart_request_url)
    @result = product_match(amart, wellcome)
  end
end


