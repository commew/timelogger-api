module Api
  class EchoController < ApplicationController
    def index
      render json: {
        echo: 'ok'
      }
    end
  end
end
