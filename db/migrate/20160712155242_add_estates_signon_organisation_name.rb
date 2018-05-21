class AddEstatesSignonOrganisationName < ActiveRecord::Migration[4.2]
  def change
    add_column :estates, :sso_organisation_name, :string
  end
end
