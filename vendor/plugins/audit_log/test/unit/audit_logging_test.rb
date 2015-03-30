require File.join(File.dirname(__FILE__), '..', 'test_helper')

require 'song'
#require 'album'
#require 'artist'

class AuditLoggingTest < ActiveSupport::TestCase
  fixtures :artists, :albums

  test 'audit_logging' do
    artist = Artist.find_by_name 'The Smashing Pumpkins'
    assert artist
    artist.name = 'Smashing Pumpkins'
    assert_equal 'Smashing Pumpkins', artist.name
    artist.name = 'TSP'
    assert_equal 'TSP', artist.name
    assert_equal 'TSP', artist.audit_logger.new_value_for('name')
    assert_equal 'The Smashing Pumpkins', artist.audit_logger.previous_value_for('name')
  end

  test 'setting_loggable_actions_works' do
    song = Song.new(:name => "whatever")
    assert song.save
    assert_equal 0, song.audit_log_records.size
    song.name = 'blah'
    song.save
    song.audit_log_records.reload
    assert_equal 1, song.audit_log_records.size
    song.destroy
    song.audit_log_records.reload
    assert_equal 1, song.audit_log_records.size
  end

  test 'audit_log_except_certain_attributes_works' do
    artist = SomeKindaArtist.new(:name => 'blah', :home_town => 'blah blah', :year_formed => '1995')
    assert artist.save
    assert_equal 2, artist.audit_log_records.size # yep, looks like if you audit_logged in a parent and child class, they both audit log. seems like a bug, but probably no one is encountering.
    artist.name = 'word'
    artist.home_town = 'word word word'
    artist.year_formed = '3000'
    assert artist.save
    assert_equal 4, artist.audit_log_records.reload.size
  end

  test 'typecasted_log_accessors' do
    artist = Artist.new(:name => 'hey boy', :home_town => 'hey girl', :year_formed => '1995')
    assert artist.save
    artist.year_formed = '3000'
    assert artist.save
    artist.audit_log_records.reload
    assert_equal 2, artist.audit_log_records.size
    assert_kind_of Integer, artist.year_formed
    assert log_record = artist.audit_log_records.find_by_attribute_name('year_formed')
    assert_kind_of String, log_record.new_value
    assert_kind_of Integer, log_record.new_value_after_typecast
  end

  test 'audit_log_for_only_certain_attributes_works' do
    artist = AnotherKindaArtist.new(:name => 'hey boy', :home_town => 'hey girl', :year_formed => '1995')
    assert artist.save
    assert_equal 2, artist.audit_log_records.size # yep, looks like if you audit_logged in a parent and child class, they both audit log. seems like a bug, but probably no one is encountering.
    artist.name = 'superstar djs'
    artist.home_town = 'here we go'
    artist.year_formed = '3000'
    assert artist.save
    assert_equal 3, artist.audit_log_records.reload.size
  end

  test 'audit_logging_on_non_ar_attributes_defined_after_the_audit_log_statement' do
    assert album = Album.find_by_title('Adore')
    album.non_ar_method = 'word'
    album.save
    album.non_ar_method = 'word word word'
    assert_equal 'word', album.audit_logger.previous_value_for('non_ar_method')
    assert_equal 'word word word', album.audit_logger.new_value_for('non_ar_method')
    album.save
    album.audit_log_records.reload
    assert_equal 2, album.audit_log_records.size
  end

  test 'test_audit_logging_on_non_ar_attributes_defined_before_the_audit_log_statement' do
    assert album = Album.find_by_title('Adore')
    album.predefined_non_ar_method = 'word'
    album.save
    album.predefined_non_ar_method = 'word word word'
    assert_equal 'word', album.audit_logger.previous_value_for('predefined_non_ar_method')
    assert_equal 'word word word', album.audit_logger.new_value_for('predefined_non_ar_method')
    album.save
    album.audit_log_records.reload
    assert_equal 2, album.audit_log_records.size
  end

  test 'this_works_with_inheritance' do
    album = PlatinumAlbum.find_by_title 'Adore'
    assert album
    assert album.kind_of?(PlatinumAlbum)
    assert_equal 'Billy Corgan & Brad Wood', album.producers
    album.producers = 'Some guys with some computers'
    assert_equal 'Billy Corgan & Brad Wood', album.audit_logger.previous_value_for('producers')
  end

  test 'model_trackability' do
    assert Album.audit_log_enabled
    assert PlatinumAlbum.audit_log_enabled
    assert !NonTrackableAlbum.audit_log_enabled
  end

  test 'change_record_saving' do
    album = Album.find_by_title 'Adore'
    assert album
    mess_with_adore_producers(album)
    mess_with_adore_title(album)
    album.save
    assert title_change = album.audit_log_records.find_by_attribute_name('title')
    assert producer_change = album.audit_log_records.find_by_attribute_name('producers')
    assert_equal 'Adore', title_change.previous_value
    assert_equal album.title, title_change.new_value
    assert_equal 'Billy Corgan & Brad Wood', producer_change.previous_value
    assert_equal album.producers, producer_change.new_value
  end

  test 'new_record_logging' do
    album = Album.create(:title => 'test')
    assert_equal 1, album.audit_log_records.size
    assert_equal 'create', album.audit_log_records.first.action
  end

  test 'record_destroy_logging' do
    album = Album.find_by_title 'Adore'
    album_id = album.id
    album.destroy
    assert destroy_record = AuditLogRecord.find_by_action('destroy')
    assert_equal album_id, destroy_record.loggable_id
    assert_equal 'Album', destroy_record.loggable_type
  end

  test 'temporary_callback_disabling' do
    Album.without_audit_logging do
      album = Album.find_by_title 'Adore'
      assert album
      mess_with_adore_producers(album)
      mess_with_adore_title(album)
      album.save
      assert album.audit_log_records.empty?
    end
  end

private

  def mess_with_adore_producers(album)
    album.producers = 'Billy Corgan and Brad Wood'
    album.producers = 'Billy Corgan the egomaniac'
    album.producers = 'William H. Corgan'
    assert_equal 'William H. Corgan', album.producers
  end

  def mess_with_adore_title(album)
    album.title = "ADORE"
    album.title = "adore"
    assert_equal 'adore', album.title
  end

end
