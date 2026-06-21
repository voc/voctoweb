ActiveAdmin.register Conference do
  menu priority: 2
  filter :acronym
  filter :title
  filter :slug, label: 'UI Path'
  filter :recordings_path
  filter :images_path
  filter :updated_at

  index do
    selectable_column
    column :acronym
    column 'UI Path', :slug
    column :recordings_path
    column :images_path
    column :schedule_url
    column :created_at do |conference|
      l(conference.created_at, format: :pretty_datetime)
    end
    actions
  end

  show do |c|
    attributes_table do
      row :acronym
      row :title
      row :recordings_path do
        div show_folder label: c.recordings_path, path: c.get_recordings_url
      end
      row :images_path do
        div show_folder label: c.images_path, path: c.get_images_url
      end
      row('UI Path') { |conference| conference.slug }
      row :logo
      row :description
      row :link
      row :global_event_notes
      row :aspect_ratio
      row :schedule_url
      row 'Schedule (last fetch)' do
        div c.schedule_xml.try(:truncate, 200)
      end
      row :schedule_state do |conference|
        state = conference.schedule_state
        colors = { 'not_present' => '#999', 'new' => '#b07800', 'downloading' => '#38678b', 'downloaded' => '#1a7a1a' }
        color  = colors[state] || '#666'
        active = %w[downloading new].include?(state)

        badge_html = <<~HTML
          <span id="sched-state-badge" style="display:inline-flex;align-items:center;gap:6px;padding:4px 10px;border:1px solid #{color};border-radius:4px;color:#{color};font-size:12px;font-weight:600;background:#{color}18">
            #{'<span class="sched-spinner"></span>' if active}
            #{state}
          </span>
        HTML
        text_node badge_html.html_safe

        if active
          text_node <<~HTML.html_safe
            <script>
              (function() {
                var pollUrl = #{schedule_status_admin_conference_path(conference).to_json};
                var badge   = document.getElementById('sched-state-badge');
                var labels  = { not_present: 'not present', new: 'queued', downloading: 'downloading…', downloaded: 'downloaded ✓' };
                var colors  = { not_present: '#999', new: '#b07800', downloading: '#38678b', downloaded: '#1a7a1a' };

                var timer = setInterval(function() {
                  fetch(pollUrl, { headers: { Accept: 'application/json', 'X-Requested-With': 'XMLHttpRequest' } })
                    .then(function(r) { return r.json(); })
                    .then(function(data) {
                      var s = data.state;
                      var c = colors[s] || '#666';
                      badge.style.borderColor = c;
                      badge.style.color       = c;
                      badge.style.background  = c + '18';
                      var spinner = badge.querySelector('.sched-spinner');
                      if (s !== 'downloading' && s !== 'new') {
                        if (spinner) spinner.remove();
                        badge.lastChild.textContent = ' ' + (labels[s] || s);
                        clearInterval(timer);
                        if (s === 'downloaded') setTimeout(function() { window.location.reload(); }, 800);
                      } else {
                        badge.lastChild.textContent = ' ' + (labels[s] || s);
                      }
                    })
                    .catch(function() {});
                }, 2000);
              })();
            </script>
          HTML
        end
      end
      row :created_at
      row :updated_at
      row :metadata do
        div c.metadata.try(:truncate, 200)
      end
      row :custom_css do
        div c.custom_css.try(:truncate, 200)
      end
    end
    table_for c.events.order('slug ASC') do
      column "Events" do |event|
        link_to "#{event.slug} (#{event.title})", [ :admin, event ]
      end
    end
  end

  form do |f|
    f.inputs "Conference Details" do
      f.input :acronym
      f.input :title
      f.input :schedule_url
      f.input :aspect_ratio, collection: Conference::ASPECT_RATIO
      f.input :slug, label: 'UI Path'
      f.input :description #, input_html: { class: 'tinymce' }
      f.input :link
      f.input :global_event_notes, hint: 'Notes to be shown as a notice on the page of every lecture in this conference'
    end
    f.inputs "Paths" do
      f.input :recordings_path, hint: conference.get_recordings_url
      f.input :images_path, hint: conference.get_images_url
    end
    f.inputs "Files" do
      f.input :logo, hint: 'filename in images path'
      f.input :logo_does_not_contain_title, :as => :boolean, hint: 'displays title below conference logo in player view'
    end
    f.inputs "Meta" do
      f.input :subtitles, :as => :boolean, label: 'Conference has subtitles', hint: 'displays subtitle appeal below player'
      f.input :custom_css
    end
    f.actions
  end

  member_action :schedule_import_preview, method: :get do
    @conference = Conference.find(params[:id])
    @preview    = ScheduleImportPreview.new(@conference).run
    render 'schedule_import_preview', layout: 'active_admin'
  end

  member_action :schedule_import_apply, method: :post do
    conference  = Conference.find(params[:id])
    event_ids   = conference.event_ids
    PersonImportWorker.perform_async(conference.id)
    EventUpdateWorker.perform_async(event_ids) if event_ids.any?
    redirect_to admin_conference_path(conference),
                notice: "Import queued — persons, participations and event metadata will be updated in the background."
  end

  member_action :schedule_status, method: :get do
    conference = Conference.find(params[:id])
    render json: { state: conference.schedule_state }
  end

  member_action :schedule_probe, method: :get do
    conference = Conference.find(params[:id])
    if conference.schedule_url.blank?
      render json: { error: 'No schedule URL configured.', formats: [] }
    else
      render json: ScheduleProbe.new(conference.schedule_url).probe
    end
  end

  member_action :download_schedule, method: :post do
    conference = Conference.find(params[:id])
    url = params[:schedule_url].presence || conference.schedule_url
    if url.present?
      conference.update!(schedule_url: url) if url != conference.schedule_url
      conference.url_changed!
    end
    redirect_to action: :show
  end

  member_action :duplicate, method: :post do
    original = Conference.find(params[:id])
    copy = original.dup

    current_year = Time.current.year.to_s
    previous_year = (Time.current.year - 1).to_s

    if original.acronym&.include?(previous_year) or original.recordings_path&.include?(previous_year)

      %i[slug title link recordings_path images_path schedule_url acronym].each do |field|
        value = original.public_send(field)
        next if value.blank?

        copy.public_send("#{field}=", value.gsub(previous_year, current_year))
      end

      if not original.acronym&.include?(previous_year) and original.acronym&.match?(/\d+/)
        num = original.acronym[/\d+/].to_i
        copy.acronym = original.acronym.gsub(num.to_s, (num + 1).to_s)

        if not original.title&.include?(previous_year) and original.title&.include?(num.to_s)
          copy.title = original.title.gsub(num.to_s, (num + 1).to_s)
        end
      end

    else
      copy.acronym = "duplicate-of-#{original.slug}"
      copy.title = "Duplicate of #{original.title}"
      copy.slug = "#{original.slug}+1"
    end
    if copy.save
      redirect_to edit_admin_conference_path(copy), notice: 'Conference duplicated successfully.'
    else
      redirect_to admin_conference_path(original), alert: "Failed to duplicate conference as #{copy.acronym}."
    end
  end

  action_item(:add_event, only: [:show, :edit]) do
    link_to 'View', conference_path(acronym: conference.acronym), method: :get
  end

  action_item(:schedule_import_preview, only: :show) do
    link_to 'Preview Import', schedule_import_preview_admin_conference_path(conference) if conference.downloaded?
  end

  action_item(:download_schedule, only: :show) do
    link_to 'Download Schedule', '#',
            data: {
              schedule_dialog: true,
              probe_url:  schedule_probe_admin_conference_path(conference),
              action_url: download_schedule_admin_conference_path(conference),
              acronym:    conference.acronym
            }
  end

  action_item(:duplicate, only: [:show, :edit]) do
    link_to 'Duplicate', duplicate_admin_conference_path(conference), method: :post, data: { confirm: 'Are you sure you want to duplicate this conference?' }
  end

  action_item(:add_event, only: [:show, :edit]) do
    link_to 'Add Event', new_admin_event_path(event: {conference_id: conference.id}), method: :get
  end

  controller do
    def permitted_params
      params.permit conference: [ :acronym,
                                  :title,
                                  :description,
                                  :link,
                                  :global_event_notes,
                                  :schedule_url,
                                  :recordings_path,
                                  :images_path,
                                  :logo,
                                  :logo_does_not_contain_title,
                                  :slug,
                                  :aspect_ratio,
                                  :subtitles,
                                  :custom_css,
                                ]
    end
  end
end
