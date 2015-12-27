module Frontend
  class RecentChangesController < FrontendController
    def index
      @offset = 0
      @buckets = Hash.new { |h,k| h[k] = Hash.new { |h2, k2| h2[k2] = 0 } }
      while recent_events = fetch_events
        recent_events.each do |event|
          date = event.release_date.to_date
          @buckets[date][event.conference] += 1
          return if @buckets.keys.size > 10
        end
      end

      respond_to { |format| format.html }
    end

    private

    def fetch_events
      recent_events = Frontend::Event.downloaded.order(release_date: :desc).limit(1000).offset(@offset).includes(:conference)
      @offset += 1000
      return nil if recent_events.empty?
      recent_events
    end
  end
end
