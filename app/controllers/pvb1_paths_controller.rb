class Pvb1PathsController < ApplicationController
  # This path was followed by pvb1 users from their emails and it showed
  # information about a visit.
  # Can be removed when we stop getting traffic
  def status
    render :status, status: :not_found
  end
end
