# frozen_string_literal: true

class EventsService < BaseService
  def create(organization:, params:)
    event = organization.events.find_by(id: params[:transaction_id])

    if event
      result.event = event
      return result
    end

    unless current_customer(organization.id, params[:customer_id])
      return result.fail!('missing_argument', 'customer does not exists')
    end

    event = organization.events.new
    event.code = params[:code]
    event.transaction_id = params[:transaction_id]
    event.customer = current_customer
    event.properties = params[:properties]

    event.timestamp = Time.zone.at(params[:timestamp]) if params[:timestamp]

    event.save!

    result.event = event
    result
  rescue ActiveRecord::RecordInvalid => e
    result.fail_with_validations!(e.record)
  end

  private

  def current_customer(organization_id = nil, customer_id = nil)
    @current_customer ||= Customer.find_by(
      customer_id: customer_id,
      organization_id: organization_id,
    )
  end
end