class EstateSSOMapper
  def initialize(user_sso_orgs, admin_flag = false)
    @user_sso_orgs = user_sso_orgs
    @admin_flag = admin_flag
  end

  def accessible_estates
    return [] if @user_sso_orgs.empty?

    if @admin_flag
      Estate.all
    else
      Estate.where(nomis_id: @user_sso_orgs)
    end
  end

  def admin?
    @admin_flag
  end
end
