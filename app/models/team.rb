require 'bcrypt'

class Team < ActiveRecord::Base
  include ::BCrypt

  has_many :players

  structure do
    name            validates: [:presence, :uniqueness]
    password_digest validates: :presence
    suspended_until Time.now.tomorrow
    timestamps
  end

  def password
    @password ||= Password.new(password_digest)
  end

  def password=(new_password)
    if new_password.present?
      @password = Password.create(new_password)
      self.password_digest = @password
    else
      @password = nil
      self.password_digest = nil
    end
  end

  def authenticate(password)
    if self.password == password
      self
    else
      nil
    end
  end

  def forget_password
    new_password = [*('a'..'z'), *('A'..'Z'), *('0'..'9')].sample(8).join
    self.password = new_password
    self.save!
    new_password
  end

  # Gets whether the team is suspended or not.
  #
  # @return [Boolean] `true` if the team is suspended; otherwise, `false`.
  def is_suspended?
    if self.suspended_until
      if self.suspended_until < Time.now
        resume!
        false
      else
        true
      end
    else
      false
    end
  end

  # Suspend the team.
  #
  # @param period [Integer, Time] the period to suspend.
  #   if Integer is given, the team is suspended until `Time.now + +period+`.
  #   if Time is given, the team suspended until +period+.
  # @return [void]
  def suspend!(period = 900)
    raise ArgumentError, "`period' must not be nil." unless period
    case period
    when Integer, Float
      self.suspended_until = Time.now + period
    when Time
      self.suspended_until = period
    else
      raise TypeError, "`period' should be Integer or Time."
    end
    save!
  end

  # Resume the team.
  #
  # @return [void]
  def resume!
    self.suspended_until = nil
    save!
  end
end
