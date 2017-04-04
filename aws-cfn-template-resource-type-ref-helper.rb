require 'kconv'
require 'open-uri'
require 'nokogiri'
require 'csv'

charset = 'UTF-8'

url = ARGV[0]
html = open(url).read
doc = Nokogiri::HTML.parse(html.toutf8, nil, charset)

csvfile = doc.xpath('//h1[@class="topictitle"]').text.gsub(/::/, '_').concat('.csv')

CSV.open(csvfile, 'w') do |row|
  # Add header to fisrt row of csv file
  row << %w(Property Description Required DataType Condition)
    doc.xpath('//div[@class="variablelist"]/dl/dt').each do |dt|
      datalist = []
      # Push property to datalist
      datalist.push(dt.text.tosjis)
      # Get dd element
      dd = dt.xpath('following-sibling::*').chunk(&:name).first.last[0]
      dd.xpath('p').each_with_index do |data, count|
        # Push description to datalist
        if count.zero?
          datalist.push(data.text.tosjis)
        # Push required to datalist
        elsif data.text =~ /(^\u5fc5\u9808|^Required)/
          datalist.push(data.text.tosjis)
        # Push datatype to datalist
        elsif data.text =~ /(^\u30bf\u30a4\u30d7|^Type)/
          datalist.push(data.text.tosjis)
        # Push condition to datalist
        elsif data.text =~ /(^\u66f4\u65b0\u306b\u4f34\u3046|^\u578b|^Condition)/
          datalist.push(data.text.tosjis)
         end
      end
      row << datalist
    end
end
