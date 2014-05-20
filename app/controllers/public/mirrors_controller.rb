class Public::MirrorsController < ApplicationController
  def index
    # connect to other db
    # build array
    # render
    @mirrors = Mirror.all
  end
end
