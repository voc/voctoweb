module ApiErrorResponses
  extend ActiveSupport::Concern

  included do
    include ActionController::MimeResponds
    rescue_from ActiveRecord::RecordNotFound, with: :record_not_found
    rescue_from ActionController::RoutingError, with: :record_not_found

    before_action { |controller| set_header(controller) }

  end

  private

  def record_not_found(error)
    respond_to do |format|
      format.json { render json: { message: 'not found', error: error.message }, status: :not_found }
      format.xml { render xml: { message: 'not found', error: error.message }, status: :not_found }
    end
  end

  def error(error)
    if error.respond_to?(:status)
      status = error.status
    else
      status = Rails.configuration.action_dispatch.rescue_responses.fetch(error.to_s, :unprocessable_entity)
    end
    respond_to do |format|
      format.json { render json: { message: error.message, error: error.full_message }, status: status }
      format.xml { render xml: { message: error.message, error: error.full_message}, status: status }
    end
  end

  def set_header(controller)
    unless controller.response.headers.key?('Content-Type')
      controller.response['Content-Type'] = 'application/json'
    end
  end
end

