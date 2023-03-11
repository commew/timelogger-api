require 'swagger_helper'

RSpec.describe 'Echo API', type: :request do
  path '/api/echo' do
    get 'Simple Echo' do
      tags 'Echo'
      consumes 'application/json'

      response '200', 'echo' do
        schema type: :object,
               properties: {
                 echo: { type: :string }
               },
               required: ['echo']

        run_test!
      end
    end
  end
end
