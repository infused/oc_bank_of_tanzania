# -*- coding: utf-8 -*-

require 'json'
require 'mechanize'
require 'turbotlib'

url = 'http://www.bot-tz.org/BankingSupervision/RegisteredBanks.asp'

agent = Mechanize.new
page = agent.get(url)
page.search('table.MsoNormalTable table tr').each do |co|
  if co.search('td')[0].text.to_i > 0
    officer_title, officer_name = co.search('td')[2].text.split("\r\n")
    contact_parts = co.search('td')[3].text.split("\r\n")
    telephone_line = contact_parts.detect {|s| s.match(/Tel:/i)}
    telephone = telephone_line && telephone_line.gsub('Tel:', '').strip.squeeze(' ')
    fax_line = contact_parts.detect {|s| s.match(/Fax:/i)}
    fax = fax_line && fax_line.gsub('Fax:', '').strip.squeeze(' ')
    address_parts = contact_parts.reject {|s| s.match(/(fax|tel|www)/i)}
    address = address_parts.join(', ').strip.squeeze(' ,').gsub(/(,|;)\Z/, '')

    data = {
      company_name: co.search('td')[1].text.squeeze(' '),
      officer_title: officer_title.squeeze(' '),
      officer_name: officer_name.squeeze(' '),
      hq_address: co.search('td')[4].text.split("\r\n").join(',').squeeze(' ,').gsub(' ,', ''),
      telephone: telephone,
      fax: fax,
      address: address,
      category: 'Bank',
      source_url: url,
      sample_date: Time.now,
    }

    puts JSON.dump(data)
  end
end
