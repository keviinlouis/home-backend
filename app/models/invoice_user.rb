class InvoiceUser < ApplicationRecord
  alias_attribute :payment, :invoice_user_payment

  belongs_to :user
  belongs_to :invoice
  belongs_to :bill_user
  has_many :invoice_user_payment, dependent: :destroy

  enum status: [:available, :paid, :pending, :expired, :canceled]

  after_update :update_status, if: :amount_has_been_changed?

  def pay(payment_data)
    payment = invoice_user_payment.create(payment_data)

    return payment unless payment.valid?

    update status: can_be_marked_as_payed? ? :paid : :pending
    invoice.update_status_if_everyone_paid
    payment
  end

  def total_payed
    invoice_user_payment.sum(:amount)
  end

  def can_be_marked_as_payed?
    amount <= total_payed
  end

  def update_status
    pending! unless can_be_marked_as_payed?
  end
end
