module Admin
  class CrossDomainSessionsController < BaseController

    layout 'admin/login'

    skip_before_filter :verify_authenticity_token

    skip_before_filter :validate_site_membership

    skip_before_filter :set_locale, :only => :create

    before_filter :authenticate_admin!, :only => :new

    def new
      site = current_admin.sites.detect { |s| s._id.to_s == params[:id] }
      @target = site.domains_without_subdomain.first || site.domains_with_subdomain.first

      current_admin.reset_switch_site_token!
    end

    def create
      if account = Account.find_using_switch_site_token(params[:token])
        account.reset_switch_site_token!
        sign_in(account)
        redirect_to admin_pages_path
      else
        flash[:alert] = t('flash.admin.cross_domain_sessions.create.alert')
        redirect_to new_admin_session_path
      end
    end

  end
end
