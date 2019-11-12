class Device < ApplicationRecord
  belongs_to :user

  enum device_type: [:android, :ios, :web]
end
