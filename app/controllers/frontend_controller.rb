class FrontendController < ActionController::Base
  layout 'frontend/conference'

  before_action :init_item_crutch

  private

  def init_item_crutch
    @item = OpenStruct.new identifier: ''
  end
end
