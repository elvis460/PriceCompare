module CrawlersHelper
  @@wellcome_domain = 'https://sbd-ec.wellcome.com.tw/'
  @@friday_domain = 'http://shopping.friday.tw/'

  def wellcome_crawler(url)
    # 頂好
    request = RestClient.get(@@wellcome_domain + url).body

    w_title = Nokogiri::HTML(request).css('.item-name').map(&:text)
    w_link = Nokogiri::HTML(request).css('.item-name a').map{|tag| tag['href']}
    w_price = Nokogiri::HTML(request).css('.item-price-container').map(&:text)

    wellcome = {}

    w_title.each_with_index do |item, index|
      type = item.scan(/\[([^\)]+)\]/).last.first
      wellcome[type] = [] if !wellcome[type]
      wellcome[type] << ({title: item, link: w_link[index], price: w_price[index]})
    end

    return wellcome
  end

  def friday_crawler(url)
    # 愛買
    request = RestClient.get(@@friday_domain + url).body
    friday = {}

    f_title = Nokogiri::HTML(request).css('h5 a').map(&:text)
    f_image = Nokogiri::HTML(request).css('p a img').map{|tag| tag['src']}
    f_link = Nokogiri::HTML(request).css('h5 a').map{|tag| tag['href']}
    f_price = Nokogiri::HTML(request).css('span.price').map(&:text)
    links = Nokogiri::HTML(request).css('.page_number a').map{|tag| tag['href']}.uniq

    friday[:title] = f_title
    friday[:image] = f_image
    friday[:link] = f_link
    friday[:price] = f_price

    if links.present?
      links.each do |url|
        request = RestClient.get(@@friday_domain + url).body
        friday[:title] << Nokogiri::HTML(request).css('h5 a').map(&:text)
        friday[:image] << Nokogiri::HTML(request).css('p a img').map{|tag| tag['src']}
        friday[:link] << Nokogiri::HTML(request).css('h5 a').map{|tag| tag['href']}
        friday[:price] << Nokogiri::HTML(request).css('span.price').map(&:text)
      end
    end

    return friday
  end

  def product_match(friday, wellcome)
    result = {}

    friday[:title].each_with_index do |title, friday_index|
      wellcome.keys.each do |type|
        next if !title.include?(type)

        wellcome[type].each_with_index do |item, wellcome_index|
          if item[:title].include?(title.gsub(type, "").split('-').last.split(/(\d+)/)[0])
            if !result[item[:title]]
              result[item[:title]] = [] 
            else
              break
            end

            result[item[:title]] << {from: 'wellcome', title: item[:title], link: item[:link], price: item[:price]}
            result[item[:title]] << {from: 'friday', title: friday[:title][friday_index], link: friday[:link][friday_index], price: friday[:price][friday_index], image: friday[:image][friday_index]}
            next
          end
        end
      end
    end

    return result
  end

  def show_product_price_and_link(item)
    if item[:from] == 'wellcome'
      link_url = @@wellcome_domain + item[:link]
      market = "頂好"
      price = item[:price]
    else
      link_url = @@friday_domain + item[:link]
      market = "愛買"
      price = " "+item[:price]
    end
    
    ("<a class='price' href='#{link_url}'> #{market}: NT$#{price} </a>").html_safe
  end

  def query_type_check(type)
    case type
      when 'wash_powder'
        wellcome_request_url = "product/listByCategory/126?query=128&"
        friday_request_url = "shopping/Browse.do?op=vc&sid=12&cid=169362&cp=1"
      when 'wash_oil'
        wellcome_request_url = "product/listByCategory/126?query=127&sortValue=1&offset=0&max=200&sort=viewCount&order=desc"
        friday_request_url = "shopping/Browse.do?op=vc&sid=12&cid=33230&cp=1"
      when 'dumpling'
        wellcome_request_url = "product/listByCategory/87?query=88&sortValue=1&offset=0&max=100&sort=viewCount&order=desc"
        friday_request_url = "shopping/Browse.do?op=vc&cid=162218&sid=12"
      when 'oats' 
        wellcome_request_url = "product/listByCategory/44?query=47&sortValue=1&offset=0&max=100&sort=viewCount&order=desc"
        friday_request_url = "shopping/Browse.do?op=vc&cid=46059&sid=12"
      when 'coffee'
        wellcome_request_url = "product/listByKeyword?skeyword=%E5%92%96%E5%95%A1&query=50&sortValue=1&offset=0&max=200&sort=viewCount&order=desc"
        friday_request_url = "shopping/Browse.do?op=vc&cid=190&sid=12"  
      when 'sauce'
        wellcome_request_url = "product/listByCategory/31?query=32&sortValue=1&offset=0&max=100&sort=viewCount&order=desc"
        friday_request_url = "shopping/Browse.do?op=vc&sid=12&cid=84255&cp=1"
    end
    return wellcome_request_url, friday_request_url
  end
end
