# frozen_string_literal: true

module V1
  class TaxSerializer < ModelSerializer
    def serialize
      {
        lago_id: model.id,
        name: model.name,
        code: model.code,
        rate: model.rate,
        description: model.description,
        applied_to_organization: model.applied_to_organization,
        customers_count: model.customers_count,
        created_at: model.created_at.iso8601,
      }
    end
  end
end
