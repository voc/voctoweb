class FrontendController < ActionController::Base
  before_action :init_item_crutch
  def init_item_crutch
    @item = OpenStruct.new identifier: ''
  end
end
