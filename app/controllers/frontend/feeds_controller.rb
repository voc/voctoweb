module Frontend
  class FeedsController < FrontendController
    before_action :set_conference, only: %i(podcast_folder)
    before_action :set_quality, only: %i(podcast podcast_archive podcast_folder)

    def podcast
      xml = WebFeed.find_by!(key: :podcast, kind: @quality).content

      respond_to do |format|
        format.xml { render xml: xml }
      end
    end

    def podcast_legacy
      xml = WebFeed.find_by!(key: :podcast_legacy).content

      respond_to do |format|
        format.xml { render xml: xml }
      end
    end

    def podcast_archive
      xml = WebFeed.find_by!(key: :podcast_archive, kind: @quality).content

      respond_to do |format|
        format.xml { render xml: xml }
      end
    end

    def podcast_archive_legacy
      xml = WebFeed.find_by!(key: :podcast_archive_legacy).content

      respond_to do |format|
        format.xml { render xml: xml }
      end
    end

    def podcast_folder
      kind = WebFeed.folder_key(@conference, @quality, @mime_type)
      xml = WebFeed.find_by!(key: :podcast_folder, kind: kind).content

      respond_to do |format|
        format.xml { render xml: xml }
      end
    end

    def podcast_audio
      xml = WebFeed.find_by!(key: :podcast_audio).content

      respond_to do |format|
        format.xml { render xml: xml }
      end
    end

    # rss 1.0 last 100 feed
    def updates
      xml = WebFeed.find_by!(key: :rdftop100).content

      respond_to do |format|
        format.xml { render xml: xml }
      end
    end

    private

    def set_conference
      @conference = if params[:acronym]
                      Frontend::Conference.find_by!(acronym: params[:acronym])
                    elsif params[:slug]
                      Frontend::Conference.find_by!(slug: params[:slug])
                    end
      fail ActiveRecord::RecordNotFound unless @conference

      _, @mime_type = @conference.mime_type_names.find { |_,n| n == params[:mime_type] }
      fail ActiveRecord::RecordNotFound unless @mime_type
    end

    def set_quality
      @quality = params[:quality] || ''
    end
  end
end
