class Api::EchoController < ApplicationController
  def index
    render json: {
      echo: 'ok',
    }
  end
end
