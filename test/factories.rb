FactoryBot.define do
  sequence :email do |n|
    "test#{n}@example.com"
  end

  sequence :conference_acronym do |n|
    "frabcon#{n}"
  end

  sequence :conference_slug do |_n|
    'conference/frabcon' + SecureRandom.hex(16)
  end
  sequence :event_guid do |_n|
    SecureRandom.hex(16)
  end

  sequence :event_slug do |_n|
    SecureRandom.hex(4)
  end

  sequence :event_title do |n|
    "some event#{n}"
  end

  sequence :tags do |n|
    "tags#{n}"
  end

  factory :api_key do
    key { '4' }
    description { 'key' }
  end

  factory :conference do
    acronym { generate(:conference_acronym) }
    title { 'FrabCon' }
    recordings_path { 'events/frabcon123' }
    images_path { 'frabcon123' }
    slug { generate(:conference_slug) }
    aspect_ratio { '16:9' }

    factory :conference_with_recordings, traits: [:conference_recordings, :has_schedule]
    factory :conference_with_audio_recordings, traits: [:conference_audio_recordings]
  end

  factory :frontend_conference, parent: :conference, class: Frontend::Conference do
  end

  trait :conference_recordings do
    after(:create) do |conference|
      conference.events << create(:event_with_recordings)
      conference.events << create(:event_with_recordings)
    end
  end

  trait :conference_audio_recordings do
    after(:create) do |conference|
      conference.events << create(:event_with_recordings)
      conference.events << create(:event_with_audio_recordings)
    end
  end

  trait :event_recordings do
    after(:create) do |event|
      event.recordings << create(:recording)
      event.recordings << create(:recording, filename: 'video.webm')
    end
  end

  trait :event_audio_recording do
    after(:create) do |event|
      event.recordings << create(:recording, mime_type: 'audio/mpeg')
    end
  end

  trait :has_schedule do
    schedule_url { 'http://localhost/schedule.xml' }
    schedule_state { 'downloaded' }
    schedule_xml { %{
    <?xml version="1.0" encoding="utf-8"?>
    <schedule>
        <version>1.3final</version>
        <conference>
            <title>SIGINT 2013</title>
            <start>2013-07-05</start>
            <end>2013-07-07</end>
            <days>1</days>
            <timeslot_duration>00:15</timeslot_duration>
        </conference>
        <day date="2013-07-05" index="1">
            <room name="Saal (MP7 OG)">
                <event guid="testGUID" id="5060">
                    <start>11:00</start>
                    <duration>01:00</duration>
                    <room>Saal (MP7 OG)</room>
                    <slug>saal_mp7_og_-_2013-07-05_11:00_-_side_effect_-_mlp_-_5060</slug>
                    <url>http://localhost/events/5060.html</url>
                    <title>Nearly Everything That Matters is a Side Effect</title>
                    <subtitle/>
                    <track>Hacking</track>
                    <type>lecture</type>
                    <language>en</language>
                    <abstract>TBD</abstract>
                    <description>TBD</description>
                    <persons>
                        <person id="1234">mlp</person>
                    </persons>
                    <links>
                    </links>
                </event>
            </room>
        </day>
    </schedule>
    } }
  end

  factory :event do
    conference
    guid { generate(:event_guid) }
    title { generate(:event_title) }
    thumb_filename { 'frabcon123.jpg' }
    poster_filename { 'frabcon123_logo.jpg' }
    timeline_filename { 'frabcon123.timeline.jpg' }
    thumbnails_filename { 'frabcon123.thumbnails.vtt' }
    subtitle { 'subtitle' }

    original_language { 'eng' }
    slug { generate(:event_slug) }
    link { 'http://localhost/ev_info' }
    description { 'description' }
    persons { ['Name'] }
    tags { ['tag'] }
    date { '2013-08-21' }
    release_date { '2013-08-21' }

    factory :event_with_recordings, traits: [:event_recordings]
    factory :event_with_audio_recordings, traits: [:event_audio_recording]
  end

  factory :recording do
    event
    filename { 'audio.mp3' }
    language { 'eng' }
    folder { '' }
    mime_type { 'video/webm' }
    height { 720 }
    width { 1024 }
    size { '12' }
    length { '5' }
    state { 'downloaded' }
    html5 { true }

    factory :audio_recording do
      mime_type { 'audio/mpeg' }
    end
  end

  factory :recording_view do
    recording
    identifier { '1234' }
    user_agent { 'browser/1.0' }
  end

  factory :admin_user do
    email { generate :email }
    password { 'admin123' }
  end

  factory :news do
    title { 'MyString' }
    body { 'MyText <b>bold</b> most html allowed.' }
    date { '2014-05-03' }
  end

  factory :import_template do
    acronym { generate(:conference_acronym) }
    title { 'FrabCon' }
    recordings_path { 'events/frabcon123' }
    images_path { 'frabcon123' }
    slug { generate(:conference_slug) }
    aspect_ratio { '16:9' }
    logo { 'logo.jpg' }
    date { '2013-08-21' }
    release_date { '2013-08-21' }
    folder { 'webm' }
    mime_type { 'video/webm' }
  end

  factory :web_feed do
    key { 'podcast_audio' }
    kind { '' }
    last_build { '2014-05-03' }
    content { '<xml/>' }

    factory :web_feed_folder do
      key { 'podcast_folder' }
      kind { 'frabcon1lqwebm' }
    end
    factory :web_feed_podcast do
      key { 'podcast' }
      kind { 'hq' }
    end
  end
end
