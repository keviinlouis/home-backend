class ApplicationRecord < ActiveRecord::Base
  self.abstract_class = true

  def amount_has_been_changed?
    saved_changes["amount"].present?
  end
end
