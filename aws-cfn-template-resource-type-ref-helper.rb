require 'kconv'
require 'open-uri'
require 'nokogiri'
require 'csv'

charset = 'UTF-8'
#    Local html file name
# url = 'AWS-EC2-EIP-AWS-CloudFormation.html'
# Web html file name
# url = 'http://docs.aws.amazon.com/ja_jp/AWSCloudFormation/latest/UserGuide/aws-properties-ec2-eip.html'
url = ARGV[0]
# For local html file
# html = File.read(url).force_encoding(charset)
# For web
html = open(url) do |f|
  charset = f.charset
  f.read
end

doc = Nokogiri::HTML.parse(html, nil, charset)

# filename = url.match(/[^\/]+$/)[0]
# csvfile = filename.gsub(/\.html/, '').concat('.csv')
csvfile = doc.xpath('//h1[@class="topictitle"]').text.gsub(/::/, '_').concat('.csv')

CSV.open(csvfile, 'w') do |row|
  # Add header to fisrt row of csv file
  row << %w(Property Description Required DataType Condition)
  doc.xpath('id("main-col-body")/div[@class="section"]/div[@class="section"]').each do |node|
    next unless node.xpath('div[@class="titlepage"]/div/div/h2[@class="title"]').text == "\u30D7\u30ED\u30D1\u30C6\u30A3"
    node.xpath('div[@class="variablelist"]/dl/dt').each do |dt|
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
        elsif data.text =~ /(^\u5fc5\u9808:|^Required:)/
          datalist.push(data.text.tosjis)
        # Push datatype to datalist
        elsif data.text =~ /(^\u30bf\u30a4\u30d7:|^Type:)/
          datalist.push(data.text.tosjis)
        # Push condition to datalist
        elsif data.text =~ /(^\u66f4\u65b0\u306b\u4f34\u3046|^Condition:)/
          datalist.push(data.text.tosjis)
         end
      end
      row << datalist
    end
  end
end
