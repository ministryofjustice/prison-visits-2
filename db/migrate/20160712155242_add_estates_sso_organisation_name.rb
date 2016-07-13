class AddEstatesSsoOrganisationName < ActiveRecord::Migration
  def change
    add_column :estates, :sso_organisation_name, :string
  end
end
