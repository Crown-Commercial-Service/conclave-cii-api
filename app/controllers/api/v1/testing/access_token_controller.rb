module Api
  module V1
    module Testing
      class AccessTokenController < ActionController::API
        # Testing endpoint, to generate an AccessToken for test purposes.
        require 'json'
        before_action :validate_params

        def validate_params
          render_results(nil) unless params && params[:ccs_org_id] && params[:user_email]
        end

        def create_new_access_token
          organisation_id = org_creation(params[:ccs_org_id].to_s)

          if organisation_id
            identity_provider = identity_provider(organisation_id)
            role_id = role_id(organisation_id)
          end
          new_user = create_user(params[:user_email].to_s, organisation_id, identity_provider, role_id) if identity_provider && role_id
          bool = optional_steps if new_user

          access_token = generate_access_token(params[:user_email].to_s) if bool

          render_results(access_token)
        end

        def optional_steps
          token = post_token
          auth_id = auth_id(params[:user_email].to_s, token) if token
          disable_mfa(auth_id, token) if auth_id
        end

        def render_results(access_token)
          return render json: access_token.to_s, status: :created if access_token

          render json: { params: params, reason: @error_reason }, status: :bad_request and return
        end

        def org_creation(org_id)
          response = Faraday.post("#{ENV['ACCESS_TOKEN_SECURITY_URL']}/organisation-profiles") do |req|
            req.headers['x-api-key'] = request.headers['x-api-key']
            req.headers['Content-Type'] = 'application/json'
            req.body = org_creation_body(org_id)
          end

          return response.body.to_s if response.status == 200 && response.body.present?

          @error_reason = {
            StatusCode: response.status,
            ResponseBody: response.body,
            RequestURL: "POST #{ENV['ACCESS_TOKEN_SECURITY_URL']}/organisation-profiles",
            Note: 'Org Creation Step'
          }
          false
        end

        def org_creation_body(org_id)
          {
            identifier: {
              legalName: 'April19Org',
              uri: 'www.april19org.com'
            },
            address: {
              streetAddress: 'StreetAddress',
              locality: 'Locality',
              region: 'Region',
              postalCode: 'PostalCode',
              countryCode: 'GB'
            },
            detail: {
              isSme: true,
              isVcse: false,
              organisationId: org_id.to_s,
              rightToBuy: true,
              isActive: true
            }
          }.to_json
        end

        def identity_provider(org_id)
          response = Faraday.get("#{ENV['ACCESS_TOKEN_SECURITY_URL']}/organisations/#{org_id}/identity-providers",
                                 nil,
                                 { 'x-api-key' => request.headers['x-api-key'] })

          return JSON.parse(response.body)[0]['id'].to_s if response.status == 200 && response.body.present? && JSON.parse(response.body)[0]['connectionName'] == 'Username-Password-Authentication'

          @error_reason = {
            StatusCode: response.status,
            ResponseBody: response.body,
            RequestURL: "GET #{ENV['ACCESS_TOKEN_SECURITY_URL']}/organisations/#{org_id}/identity-providers",
            Note: 'Identity Provider Step'
          }
          false
        end

        def role_id(org_id)
          response = Faraday.get("#{ENV['ACCESS_TOKEN_SECURITY_URL']}/organisations/#{org_id}/roles",
                                 nil,
                                 { 'x-api-key' => request.headers['x-api-key'] })

          return JSON.parse(response.body)[0]['roleId'].to_s if response.status == 200 && response.body.present? && JSON.parse(response.body)[0]['roleKey'] == ENV['ACCESS_CCS_ADMIN'].to_s

          @error_reason = {
            StatusCode: response.status,
            ResponseBody: response.body,
            RequestURL: "GET #{ENV['ACCESS_TOKEN_SECURITY_URL']}/organisations/#{org_id}/roles",
            Note: 'Role ID Step'
          }
          false
        end

        def create_user(email, org_id, provider, role)
          response = Faraday.post("#{ENV['ACCESS_TOKEN_SECURITY_URL']}/user-profiles") do |req|
            req.body = create_user_body(email, org_id, provider, role)
            req.headers['Content-Type'] = 'application/json'
            req.headers['x-api-key'] = request.headers['x-api-key']
          end

          return response.body.to_s if response.status == 200 && response.body.present?

          @error_reason = {
            StatusCode: response.status,
            ResponseBody: response.body,
            RequestURL: "POST #{ENV['ACCESS_TOKEN_SECURITY_URL']}/user-profiles",
            Note: 'User Creation Step'
          }
          false
        end

        def create_user_body(email, org_id, provider, role)
          {
            userName: "#{email}@yopmail.com",
            organisationId: org_id.to_s,
            firstName: 'Test',
            lastName: 'Test',
            title: 'Mr',
            mfaEnabled: true,
            password: ENV['ACCESS_TOKEN_USER_PASSWORD'].to_s,
            accountVerified: true,
            sendUserRegistrationEmail: false,
            detail: {
              id: 0,
              roleIds: [role.to_i],
              identityProviderIds: [provider.to_i]
            }
          }.to_json
        end

        def post_token
          response = Faraday.post("#{ENV['ACCESS_TOKEN_AUTH0_URL']}/oauth/token") do |req|
            req.headers['Content-Type'] = 'application/json'
            req.body = {
              client_id: ENV['ACCESS_TOKEN_GET_TOKEN_CLIENT_ID'].to_s,
              client_secret: ENV['ACCESS_TOKEN_GET_TOKEN_CLIENT_SECRET'].to_s,
              audience: "#{ENV['ACCESS_TOKEN_AUTH0_URL']}/api/v2/",
              grant_type: 'client_credentials'
            }.to_json
          end

          return JSON.parse(response.body)['access_token'] if response.status == 200 && response.body.present? && JSON.parse(response.body)['access_token']

          @error_reason = {
            StatusCode: response.status,
            ResponseBody: response.body,
            RequestURL: "POST #{ENV['ACCESS_TOKEN_AUTH0_URL']}/oauth/token",
            Note: 'Get POST Token Step'
          }
          false
        end

        def auth_id(email, token)
          response = Faraday.get("#{ENV['ACCESS_TOKEN_AUTH0_URL']}/api/v2/users-by-email?email=#{email}@yopmail.com",
                                 nil,
                                 {
                                   'x-api-key' => request.headers['x-api-key'],
                                   'Authorization' => "Bearer #{token}"
                                 })

          return JSON.parse(response.body)[0]['user_id'].to_s if response.status == 200 && response.body.present? && JSON.parse(response.body)[0]['user_id']

          @error_reason = {
            StatusCode: response.status,
            ResponseBody: response.body,
            RequestURL: "POST #{ENV['ACCESS_TOKEN_AUTH0_URL']}/api/v2/users-by-email?email=#{email}@yopmail.com",
            Note: 'Get Auth0 ID Step'
          }
          false
        end

        def generate_access_token(email)
          response = Faraday.post("#{ENV['ACCESS_TOKEN_SECURITY_URL']}/security/test/oauth/token") do |req|
            req.headers['Content-Type'] = 'application/json'
            req.headers['X-API-KEY'] = request.headers['xapikey']
            req.body = gen_access_token_body(email)
          end

          return JSON.parse(response.body)['accessToken'] if response.status == 200 && response.body.present? && JSON.parse(response.body)['accessToken']

          @error_reason = {
            StatusCode: response.status,
            ResponseBody: response.body,
            RequestURL: "POST #{ENV['ACCESS_TOKEN_SECURITY_URL']}/security/test/oauth/token",
            Note: 'Generate Token Final Step'
          }
          false
        end

        def gen_access_token_body(email)
          {
            username: "#{email}@yopmail.com",
            password: ENV['ACCESS_TOKEN_USER_PASSWORD'].to_s,
            client_id: ENV['ACCESS_TOKEN_CREATE_TOKEN_CLIENT_ID'].to_s,
            client_secret: ENV['ACCESS_TOKEN_CREATE_TOKEN_CLIENT_SECRET'].to_s
          }.to_json
        end

        def disable_mfa(auth_id, token)
          response = Faraday.patch(URI::DEFAULT_PARSER.escape("#{ENV['ACCESS_TOKEN_AUTH0_URL']}/api/v2/users/#{auth_id}")) do |req|
            req.headers['Content-Type'] = 'application/json'
            req.headers['Authorization'] = "Bearer #{token}"
            req.body = {
              user_metadata: { use_mfa: false }
            }.to_json
          end

          return true if response.status == 200 && response.body.present?

          @error_reason = {
            StatusCode: response.status,
            ResponseBody: response.body,
            RequestURL: "PATCH #{ENV['ACCESS_TOKEN_AUTH0_URL']}/api/v2/users/#{auth_id}",
            Note: 'Disable MFA Step'
          }
          false
        end
      end
    end
  end
end
