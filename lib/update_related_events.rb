class UpdateRelatedEvents
  def initialize
    @graph = {}
    @recording_cache = {}
    @event_cache = {}
  end

  def update
    related = related_by_views

    build_graph(related)

    update_related
  end

  def clean
    Event.where('metadata ? :value', value: 'related').each do |event|
      weights = event.metadata['related'].values
      if weights.count > 10
        limit = percentile(weights, 0.25)
        event.metadata['related'].delete_if { |_k, v| v < limit.to_i }
      end
      #r = event.metadata['related'].count
      #puts "#{event.id}: removing weak #{weights.count - r} of #{weights.count}" if weights.count != r

      event.metadata['related'].delete_if { |k, _v| !event_exists?(k) }
      #d = event.metadata['related'].count
      #puts "#{event.id}: removing deleted #{r - d} of #{weights.count - r}" if d != r

      event.update_columns(metadata: event.metadata)
    end
  end

  private

  def event_exists?(id)
    @event_cache[id] ||= Event.exists?(id)
  end

  def related_by_views
    views = RecordingView.connection.execute(%{
        SELECT array_agg(DISTINCT recording_id) as recording_group
          FROM recording_views
         GROUP BY identifier, user_agent
    })
    views.values.map { |group| group.first[1..-2].split(/,/) }
  end

  def build_graph(related)
    related.each do |recording_ids|
      # identifier is valid for 12 hours only, how many presentations can one human watch?
      next if recording_ids.size == 1 || recording_ids.size > 50

      event_ids = Recording.where(id: recording_ids).pluck(:event_id).uniq
      event_ids.each do |event_id|
        node = if @graph.key?(event_id)
                 @graph[event_id]
               else
                 @graph[event_id] = Hash.new { |h, v| h[v] = 0 }
               end

        (event_ids-[event_id]).each { |id| node[id] +=1 }
      end
    end

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
      event = Event.find(id)
      next unless event

      event.metadata['related'] ||= {}
      event.metadata['related'].merge!(edges)
      # skip callbacks
      event.update_columns(metadata: event.metadata)
    end
  end
end
