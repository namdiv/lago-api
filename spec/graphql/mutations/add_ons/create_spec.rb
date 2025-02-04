# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Mutations::AddOns::Create, type: :graphql do
  let(:membership) { create(:membership) }
  let(:mutation) do
    <<-GQL
      mutation($input: CreateAddOnInput!) {
        createAddOn(input: $input) {
          id,
          name,
          code,
          description,
          amountCents,
          amountCurrency
        }
      }
    GQL
  end

  it 'creates an add-on' do
    result = execute_graphql(
      current_user: membership.user,
      current_organization: membership.organization,
      query: mutation,
      variables: {
        input: {
          name: 'Test Add-on',
          code: 'free-beer-for-us',
          description: 'some text',
          amountCents: 5000,
          amountCurrency: 'EUR',
        },
      },
    )

    result_data = result['data']['createAddOn']

    aggregate_failures do
      expect(result_data['id']).to be_present
      expect(result_data['name']).to eq('Test Add-on')
      expect(result_data['code']).to eq('free-beer-for-us')
      expect(result_data['description']).to eq('some text')
      expect(result_data['amountCents']).to eq('5000')
      expect(result_data['amountCurrency']).to eq('EUR')
    end
  end

  context 'without current user' do
    it 'returns an error' do
      result = execute_graphql(
        current_organization: membership.organization,
        query: mutation,
        variables: {
          input: {
            name: 'Test Add-on',
            code: 'free-beer-for-us',
            amountCents: 5000,
            amountCurrency: 'EUR',
          },
        },
      )

      expect_unauthorized_error(result)
    end
  end

  context 'without current organization' do
    it 'returns an error' do
      result = execute_graphql(
        current_user: membership.user,
        query: mutation,
        variables: {
          input: {
            name: 'Test Add-on',
            code: 'free-beer-for-us',
            amountCents: 5000,
            amountCurrency: 'EUR',
          },
        },
      )

      expect_forbidden_error(result)
    end
  end
end
