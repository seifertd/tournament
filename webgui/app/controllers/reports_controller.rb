class ReportsController < ApplicationController
  layout 'report'
  def show
    @pool = Pool.find(params[:id])
  end

end
