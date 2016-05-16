class InterfaceController < ApplicationController
  def index
    @visit = Visit.all
  end
end
