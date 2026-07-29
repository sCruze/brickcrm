class SettingsController < ApplicationController
  def index
    @password_auth = CrmConfig.password_auth?
    @sso_enabled = CrmConfig.sso_enabled?
    @inbound_sources = CrmConfig.inbound_sources.keys
    @webhook_endpoints = WebhookEndpoint.order(:id)
    @roles = Role.order(:id)
  end
end
