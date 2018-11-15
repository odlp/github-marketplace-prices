require_relative "capybara_config"
require "capybara/dsl"
require "pry"
require "csv"

include Capybara::DSL

visit("https://github.com/marketplace")

category_links = page.all(".filter-item").map do |link|
  if link["href"].include? "category"
    link["href"]
  end
end.compact

product_links = category_links.flat_map do |category_link|
  puts "Crawling #{category_link}"
  visit(category_link)
  all(".container-lg .col-md-9 a").map do |link|
    if link["href"].include? "marketplace"
      link["href"]
    end
  end.compact
end.uniq

plans = product_links.flat_map do |product_link|
  puts "Crawling #{product_link}"
  visit(product_link)

  product_name = find("h1").text

  find("#marketplace-plans-container .filter-list").all("li").map do |plan_node|
    name = plan_node.find("h4").text
    desc = plan_node.find("p.text-small").text

    price = (
      plan_node.all("span.float-right")[0] ||
      plan_node.all("div.text-right")[0]
    ).text

    {
      product_name: product_name,
      product_url: product_link,
      name: name,
      desc: desc,
      price: price,
    }
  end
end

CSV.open("prices.csv", "wb") do |csv|
  csv << ["product name", "price", "period", "plan name", "plan desc", "product URL"]

  plans.each do |plan|
    price, period = plan[:price].split("\n/ ")

    csv << [
      plan[:product_name],
      price,
      period,
      plan[:name],
      plan[:desc],
      plan[:product_url],
    ]
  end
end
