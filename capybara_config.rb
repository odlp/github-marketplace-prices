require "capybara"
require "selenium-webdriver"

chrome_args = [
  "window-size=1200,800",
]

chrome_args << "auto-open-devtools-for-tabs" if ENV.key?("CHROME_OPEN_DEVTOOLS")
chrome_args << "headless" if ENV.key?("CHROME_HEADLESS")

Capybara.register_driver :selenium_chrome do |app|
  Capybara::Selenium::Driver.new(
    app,
    browser: :chrome,
    desired_capabilities: Selenium::WebDriver::Remote::Capabilities.chrome(
      chromeOptions: { args: chrome_args }
    )
  )
end

Capybara.default_driver = :selenium_chrome
