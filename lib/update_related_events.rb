class UpdateRelatedEvents
  def initialize
    @graph = {}
    @recording_cache = {}
  end

  def update
    related = related_by_views

    build_graph(related)

    update_related
  end

  private

  def related_by_views
    views = RecordingView.connection.execute(%{
        SELECT array_agg(DISTINCT recording_id) as recording_group
          FROM recording_views
         GROUP BY identifier, user_agent
    })
    views.values.map { |group| group.first[1..-2].split(/,/) }
  end

  def build_graph(related)
    related.each { |events|
      # identifier is valid for 12 hours only, how many presentations can one human watch?
      next if events.size == 1 || events.size > 50

      events.each { |event|
        node = if @graph.key?(event)
                 @graph[event]
               else
                 @graph[event] = Hash.new { |h, v| h[v] = 0 }
               end

        (events-[event]).each { |v| node[v] +=1 }
      }
    }

    @graph.each do |_id, edges|
      weights = edges.values
      next if weights.count < 2
      limit = percentile(weights, 0.95)
      edges.delete_if { |_k, v| v < limit.to_i }
    end
  end

  def percentile(values, percentile)
    values_sorted = values.sort
    k = (percentile * (values_sorted.length - 1) + 1).floor - 1
    f = (percentile * (values_sorted.length - 1) + 1).modulo(1)

    values_sorted[k] + (f * (values_sorted[k + 1] - values_sorted[k]))
  end

  def update_related
    @graph.each do |id, edges|
      event = find_recording(id).event
      next unless event
      related_events = {}
      edges.map do |recording_id, weight|
        event_id = find_recording(recording_id).event_id
        next unless event_id
        related_events[event_id] = weight
      end

      event.metadata['related'] ||= {}
      event.metadata['related'].merge!(related_events)
      # skip callbacks
      event.update_columns(metadata: event.metadata)
    end
  end

  def find_recording(recording_id)
    @recording_cache[recording_id] ||= Recording.find(recording_id)
  end
end
