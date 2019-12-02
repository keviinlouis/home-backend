class InvoiceUserPayment < ApplicationRecord
  include Rails.application.routes.url_helpers

  has_one_attached :image

  belongs_to :invoice_user

  def image_url
    return unless image.attached?
    url_for(image)
  end
end
