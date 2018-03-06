class CrawlersController < ApplicationController
  include CrawlersHelper

  def index 
    return @result = {} if !params['query']
    # get request urls
    wellcome_request_url, amart_request_url = query_type_check(params['query'])
    # crawl wellcome page
    wellcome = wellcome_crawler(wellcome_request_url)
    # crawl amart page
    amart = amart_crawler(amart_request_url)
    # render the product both side have sell
    @result = product_match(amart, wellcome)
  end
end


