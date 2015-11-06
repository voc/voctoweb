module ApiErrorResponses
  extend ActiveSupport::Concern

  included do
    rescue_from ActiveRecord::RecordNotFound, with: :record_not_found
  end

  private

  def record_not_found(error)
    respond_to do |format|
      format.json { render json: { message: 'not found', error: error.message }, status: :not_found }
      format.xml { render xml: { message: 'not found', error: error.message }, status: :not_found }
    end
  end
end

