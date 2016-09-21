require "rails_helper"

RSpec.describe ApplicationController, type: :controller do
  controller do
    def index
      head :ok
    end
  end

  describe '#set_locale' do
    context 'with an invalid locale' do
      it 'defaults to en' do
        expect {
          get :index, locale: 'ent'
        }.to_not raise_error
      end
    end
  end
end
