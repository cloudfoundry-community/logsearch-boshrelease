# $LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
require 'helpers/filters_helper'

RSpec.configure do |config|
  config.extend FiltersHelper
  config.include FiltersHelper
end
