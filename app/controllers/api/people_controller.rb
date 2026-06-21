class Api::PeopleController < ApiController
  protect_from_forgery except: %i(create)
  before_action :set_person, only: [:show, :edit, :update, :destroy]

  # GET /api/people.json
  def index
    @people = Person.all
  end

  # GET /api/people/1.json
  def show
  end

  # GET /api/people/new
  def new
    @person = Person.new
  end

  # GET /api/people/1/edit
  def edit
  end

  # POST /api/people.json
  def create
    @person = Person.new(person_params)

    respond_to do |format|
      if @person.save
        format.json { render :show, status: :created }
      else
        format.json { render json: @person.errors.messages, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /api/people/1.json
  def update
    fail ActiveRecord::RecordNotFound unless @person

    respond_to do |format|
      if @person.update(person_params)
        format.json { render :show, status: :ok }
      else
        format.json { render json: @person.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /api/people/1.json
  def destroy
    @person.destroy
    respond_to do |format|
      format.json { head :no_content }
    end
  end

  private

  def set_person
    @person = Person.find(params[:id])
  end

  def person_params
    params.require(:person).permit(
      :name, :public_name, :email, :avatar_url, :description,
      links_attributes: [:id, :url, :name, :link_type, :service, :_destroy]
    )
  end
end
