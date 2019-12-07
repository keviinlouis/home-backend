class InvoiceUserPayment < ApplicationRecord
  include Rails.application.routes.url_helpers

  has_one_attached :image

  belongs_to :invoice_user

  validates :amount, numericality: { greater_than: 0 }

  before_destroy :invoice_valid?

  after_destroy :update_invoice_user

  def image_url
    return unless image.attached?
    url_for(image)
  end

  def update_invoice_user
    status = if InvoiceUserPayment.find_by_invoice_user_id(id).blank?
               :available
             else
               :pending
             end
    invoice_user.update status: status
  end

  def invoice_valid?
    if invoice_user.invoice.paid?
      errors.add(:base, 'Esse pagamento já está finalizado')
      throw :abort
    end
  end
end
