# Represents a challenge.
#
# @!attribute [r] point
#   Gets the maximum points for this challenge.
#   @return [Number]
#
# @!attribute [r] opened?
#   Gets whether the challenge is opened or not.
class Challenge < ActiveRecord::Base
  has_many :answers, dependent: :destroy, inverse_of: :challenge
  has_many :flags, dependent: :destroy, inverse_of: :challenge

  validates_associated :flags
  validates_presence_of :flags

  structure do
    name       'Parasol Star Memories', validates: :presence
    genre      'binary', validates: :presence
    opened_at  Time.new(2014, 3, 18, 9, 0, 0, '+09:00')
    timestamps
  end

  def point
    flags.pluck(:point).inject(:+)
  end

  def opened?
    opened_at.present?
  end

  # Opens the challenge.
  #
  # @return [Time] Opened time
  def open!
    unless self[:opened_at]
      self[:opened_at] ||= Time.now
      save!
    end
    self[:opened_at]
  end

  # Closes the challenge.
  #
  # @return [void]
  def close!
    self[:opened_at] = nil
    save!
  end

  # Gets all genres.
  #
  # @return [Set<String>]
  scope :genres, -> { pluck(:genre).uniq }

  # Gets all opened challenges.
  #
  # @return [Set<Challenge>]
  scope :opened, -> { where.not(opened_at: nil) }
end
