require 'test_helper'

class EventTest < ActiveSupport::TestCase
  setup do
    @event = create(:event)
  end

  test "should return first slide by order of mime types" do
    @event.recordings << create(:recording, mime_type: 'video/mp4', filename: 'audio.ogg', event: @event)
    @event.recordings << create(:recording, mime_type: 'video/mp4', folder: 'slides', filename: 'slides.mp4', event: @event)
    @event.recordings << create(:recording, mime_type: 'application/pdf', folder: 'slides', filename: 'slides.pdf', event: @event)
    @event = Frontend::Event.find(@event.id)
    assert_equal 'slides.pdf', @event.slide.filename
  end

  test "should find preferred recordings" do
    @event.recordings << create(:recording, mime_type: 'audio/mpeg', filename: 'audio.mp3', event: @event)
    @event.recordings << create(:recording, mime_type: 'audio/ogg', filename: 'audio.ogg', event: @event)
    @event.recordings << create(:recording, mime_type: 'video/mp4', filename: 'video.mp4', event: @event)
    @event = Frontend::Event.find(@event.id)
    assert_equal 'audio.ogg', @event.audio_recording.filename
    assert_equal 'video.mp4', @event.preferred_recording.filename
  end

  test "should not find preferred recordings" do
    @event.recordings << create(:recording, mime_type: 'video/mp4', filename: 'video.mp4', event: @event)
    @event = Frontend::Event.find(@event.id)
    assert_nil @event.audio_recording
  end

  test 'should list related events' do
    events = create_list(:event, 3)
    @event.metadata[:related] = events.pluck(:id).each_with_object({}) { |v,h| h[v] = 1 }
    @event.save
    assert_equal 3, @event.metadata['related'].count
  end

  test 'should shorten titles using ellipsis character' do
    @event = Frontend::Event.new
    @event.title = "regular title"
    assert_equal "regular title", @event.short_title

    @event.title = "too long title.....20...25...30...35...40....45"
    assert_equal "too long title.....20...25...30...35...…", @event.short_title
  end

  test 'filetypes returns humanized and display names for recordings' do
    @event.recordings << create(:recording, mime_type: 'video/mp4', filename: 'video.mp4', event: @event)
    @event.recordings << create(:recording, mime_type: 'video/webm', filename: 'video.webm', event: @event)
    @event.recordings << create(:recording, mime_type: 'audio/mpeg', filename: 'audio.mp3', event: @event)
    @event = Frontend::Event.find(@event.id)

    filetypes = @event.filetypes(['video/mp4', 'video/webm', 'audio/mpeg'])
    assert_equal 3, filetypes.length

    filetypes = filetypes.to_h
    assert_equal 'MP4', filetypes['mp4']
    assert_equal 'WebM', filetypes['webm']
    assert_equal 'MP3', filetypes['mp3']
  end

  test 'filetypes supports AV1 mime type' do
    @event.recordings << create(:recording, mime_type: 'video/webm;codecs=av01', filename: 'video-av1.webm', event: @event)
    @event = Frontend::Event.find(@event.id)

    filetypes = @event.filetypes(['video/webm;codecs=av01'])
    assert_equal 1, filetypes.length

    filetypes = filetypes.to_h
    assert_equal 'AV1', filetypes['av1']
  end

  test 'video_for_download returns high quality video by filetype' do
    @event.recordings << create(:recording, mime_type: 'video/mp4', filename: 'hd.mp4', height: 1080, high_quality: true, event: @event)
    @event.recordings << create(:recording, mime_type: 'video/mp4', filename: 'sd.mp4', height: 720, high_quality: false, event: @event)
    @event = Frontend::Event.find(@event.id)

    video = @event.video_for_download('mp4', high_quality: true)
    assert_equal 'hd.mp4', video.filename
  end

  test 'video_for_download returns low quality video by filetype' do
    @event.recordings << create(:recording, mime_type: 'video/mp4', filename: 'hd.mp4', height: 1080, high_quality: true, event: @event)
    @event.recordings << create(:recording, mime_type: 'video/mp4', filename: 'sd.mp4', height: 720, high_quality: false, event: @event)
    @event = Frontend::Event.find(@event.id)

    video = @event.video_for_download('mp4', high_quality: false)
    assert_equal 'sd.mp4', video.filename
  end

  test 'video_for_download returns AV1 video by filetype' do
    @event.recordings << create(:recording, mime_type: 'video/webm;codecs=av01', filename: 'av1.webm', height: 1080, event: @event)
    @event = Frontend::Event.find(@event.id)

    video = @event.video_for_download('av1', high_quality: true)
    assert_equal 'av1.webm', video.filename
  end

  test 'videos_for_download returns videos grouped by height' do
    @event.recordings << create(:recording, mime_type: 'video/mp4', filename: 'hd.mp4', height: 1080, event: @event)
    @event.recordings << create(:recording, mime_type: 'video/mp4', filename: 'sd.mp4', height: 720, event: @event)
    @event.recordings << create(:recording, mime_type: 'video/mp4', filename: 'hd2.mp4', height: 1080, html5: false, event: @event)
    @event = Frontend::Event.find(@event.id)

    videos = @event.videos_for_download('mp4')
    assert_equal 2, videos.length
    assert_equal 1080, videos[0].height
    assert_equal 720, videos[1].height
    assert_equal 'hd2.mp4', videos[0].filename
  end

  test 'videos_for_download returns AV1 videos' do
    @event.recordings << create(:recording, mime_type: 'video/webm;codecs=av01', filename: 'av1-hd.webm', height: 1080, event: @event)
    @event.recordings << create(:recording, mime_type: 'video/webm;codecs=av01', filename: 'av1-sd.webm', height: 720, event: @event)
    @event = Frontend::Event.find(@event.id)

    videos = @event.videos_for_download('av1')
    assert_equal 2, videos.length
    assert_equal 1080, videos[0].height
    assert_equal 720, videos[1].height
  end

  test 'audio_recordings_for_download returns audio by filetype' do
    @event.recordings << create(:recording, mime_type: 'audio/mpeg', filename: 'audio-eng.mp3', language: 'eng', event: @event)
    @event.recordings << create(:recording, mime_type: 'audio/mpeg', filename: 'audio-deu.mp3', language: 'deu', event: @event)
    @event = Frontend::Event.find(@event.id)

    audio = @event.audio_recordings_for_download('mp3')
    assert_equal 2, audio.length
    assert_equal 'audio-eng.mp3', audio['eng'].filename
    assert_equal 'audio-deu.mp3', audio['deu'].filename
  end

  test 'audio_recordings_for_download sorts by original language first' do
    @event.original_language = 'deu'
    @event.recordings << create(:recording, mime_type: 'audio/mpeg', filename: 'audio-eng.mp3', language: 'eng', event: @event)
    @event.recordings << create(:recording, mime_type: 'audio/mpeg', filename: 'audio-deu.mp3', language: 'deu', event: @event)
    @event = Frontend::Event.find(@event.id)

    audio = @event.audio_recordings_for_download('mp3')
    assert_equal 'audio-deu.mp3', audio.values.first.filename
  end

  test 'audio_recordings_for_download returns opus audio' do
    @event.recordings << create(:recording, mime_type: 'audio/opus', filename: 'audio.opus', event: @event)
    @event = Frontend::Event.find(@event.id)

    audio = @event.audio_recordings_for_download('opus')
    assert_equal 1, audio.length
    assert_equal 'audio.opus', audio.values.first.filename
  end

  test 'slides_for_download returns slides by filetype' do
    @event.recordings << create(:recording, mime_type: 'application/pdf', filename: 'slides.pdf', folder: 'slides', event: @event)
    @event = Frontend::Event.find(@event.id)

    slides = @event.slides_for_download('pdf')
    assert_equal 1, slides.length
    assert_equal 'slides.pdf', slides.values.first.filename
  end

  test 'clappr_sources returns mpd first if available' do
    @event.recordings << create(:recording, mime_type: 'application/dash+xml', filename: 'stream.mpd', event: @event)
    @event.recordings << create(:recording, mime_type: 'video/mp4', filename: 'video.mp4', html5: true, event: @event)
    @event = Frontend::Event.find(@event.id)

    sources = @event.clappr_sources
    assert sources.first.is_a?(Frontend::Recording)
    assert_equal 'stream.mpd', sources.first.filename
  end

  test 'clappr_sources returns only videos when mpd not available' do
    @event.recordings << create(:recording, mime_type: 'video/mp4', filename: 'video.mp4', html5: true, event: @event)
    @event = Frontend::Event.find(@event.id)

    sources = @event.clappr_sources
    assert sources.all? { |s| s.is_a?(String) }
  end
end
