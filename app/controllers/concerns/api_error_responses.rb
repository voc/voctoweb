module ApiErrorResponses
  extend ActiveSupport::Concern

  included do
    include ActionController::MimeResponds
    rescue_from ActiveRecord::RecordNotFound, with: :record_not_found
    after_action { |controller| set_header(controller) }

  end

  private

  def record_not_found(error)
    respond_to do |format|
      format.json { render json: { message: 'not found', error: error.message }, status: :not_found }
      format.xml { render xml: { message: 'not found', error: error.message }, status: :not_found }
    end
  end

  def set_header(controller)
    unless controller.response.headers.key?('Content-Type')
      controller.response['Content-Type'] = 'application/json'
    end
  end
end

