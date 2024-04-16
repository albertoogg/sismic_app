class Api::FeaturesController < ApplicationController
  def index
    @features = Feature.all
    render json: @features, include: :comments
  end
end
