class Appointment < ApplicationRecord
  enum treatment: {
    manicure: "manicure",
    pedicure: "pedicure",
    massage: "massage",
    haircut: "haircut"
  }

  belongs_to :user
  has_one :family, through: :users

  def name
    "#{treatment} for #{user.email} at #{when_at}"
  end



end
