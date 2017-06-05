module PrisonRestrictionController
  extend ActiveSupport::Concern

  included do
    before_action :authorize_prison_request
    skip_before_action :store_current_location
  end
end
