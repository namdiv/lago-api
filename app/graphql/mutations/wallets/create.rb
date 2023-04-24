# frozen_string_literal: true

module Mutations
  module Wallets
    class Create < BaseMutation
      include AuthenticableApiUser
      include RequiredOrganization

      graphql_name 'CreateCustomerWallet'
      description 'Creates a new Customer Wallet'

      argument :currency, Types::CurrencyEnum, required: true
      argument :customer_id, ID, required: true
      argument :expiration_at, GraphQL::Types::ISO8601DateTime, required: false
      argument :granted_credits, String, required: true
      argument :name, String, required: false
      argument :paid_credits, String, required: true
      argument :rate_amount, String, required: true

      type Types::Wallets::Object

      def resolve(**args)
        validate_organization!

        result = ::Wallets::CreateService
          .new(context[:current_user])
          .create(
            args
              .merge(organization_id: current_organization.id)
              .merge(customer: current_customer(args[:customer_id]))
              .except(:customer_id),
          )

        result.success? ? result.wallet : result_error(result)
      end

      def current_customer(id)
        Customer.find_by(id:, organization_id: current_organization.id)
      end
    end
  end
end
