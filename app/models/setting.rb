#require 'lib/config_manager'
# Setting is the setting of one webapplication
# Maybe in futur, there are several webapp. I don't know
# the settings is save in a hash serializable in Database
class Setting < ActiveRecord::Base
  include ConfigManager
  serialize :settings, Hash

  setting :webapp_name,               :string, 'My own personal WebGallery'
  setting :webapp_subtitle,           :string, ''
  setting :thumbnail_max_width,       :string, '200'
  setting :thumbnail_max_height,      :string, '200'
  setting :picture_max_width,         :string, '600'
  setting :picture_max_height,        :string, '450'
  setting :pictures_pagination,       :string, '9'
  setting :galleries_pagination,      :string, '9'
  setting :nb_upload_mass_by_request, :string, '5'
  setting :comment,                   :boolean, true

  validate_on_update :validate_settings

  after_save :change_thumbnail_size
  after_save :change_picture_size
  after_save :empty_setting_changed

  def initialize
    super
    self.settings = {}
  end

  # Return the fist webapp by Id.
  # But if there are no Setting save in first
  # A setting is create
  def self.default
    s = Setting.find :first, :order => 'id'
    if s.nil?
      Setting.new
    else
      s
    end
  end

  def change_size_thumbnails?
    setting_changed?('thumbnail_max_width') || setting_changed?('thumbnail_max_height')
  end
  
  def change_size_view?
    setting_changed?('picture_max_width') || setting_changed?('picture_max_height')
  end

  def settings_changed
    @settings_changed ||= []
  end

  def empty_setting_changed
    @settings_changed = []
  end

  def setting_changed?(field)
    settings_changed.include? field
  end

private

  def validate_settings
    errors.add webapp_name, "Galleries names can't be blank" if webapp_name.empty?
    errors.add thumbnail_max_width, "The with max of a thumbnail can't be zero or negative" if thumbnail_max_width.to_i < 1
    errors.add thumbnail_max_height, "The height max of a thumbnail can't be zero or negative" if thumbnail_max_height.to_i < 1
    errors.add picture_max_width, "The with max of a picture can't be zero or negative" if picture_max_width.to_i < 1
    errors.add picture_max_height, "The height max of a picture can't be zero or negative" if picture_max_height.to_i < 1
  end

  # Change the thumbnails size of a Picture
  # with size define in setting
  def change_thumbnail_size
    if change_size_thumbnails?
      Picture.attachment_options[:thumbnails] = { 
        :thumb => "#{Setting.default.thumbnail_max_width}x#{Setting.default.thumbnail_max_height}>"
      }
      Picture.all.each { |pic| 
        Import.create!(:picture_id => pic.id, 
                        :type_pic => Import::THUMB, 
                        :total => Picture.count)
      }
    end
  end
  
  # Change the picture origin size
  # with size define in setting
  def change_picture_size
    if change_size_view?
      Picture.attachment_options[:thumbnails] = { 
        :view => "#{Setting.default.picture_max_width}x#{Setting.default.picture_max_height}>"
      }
      Picture.all.each { |pic| 
        Import.create!(:picture_id => pic.id, 
                       :type_pic => Import::VIEW,
                       :total => Picture.count)
      }
    end
  end

end
