class InvoiceUser < ApplicationRecord
  belongs_to :user
  belongs_to :invoice
  belongs_to :bill_user

  enum status: [:available, :paid, :expired, :canceled]

  def pay
    update status: :paid
  end
end
