module Settings
  class OverviewController < BaseController
    def index
      @roles_count = Role.count
      @endpoints_count = WebhookEndpoint.count
      @branches_count = Branch.count
      @password_auth = CrmConfig.password_auth?
      @sso_enabled = CrmConfig.sso_enabled?
      @inbound_sources = CrmConfig.inbound_sources.keys
    end
  end
end
