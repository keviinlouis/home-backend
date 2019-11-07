class Invoice < ApplicationRecord
  belongs_to :bill, -> { with_deleted }
  has_many :invoice_users, dependent: :destroy

  after_update :update_invoice_users, if: :available?

  enum status: [:pending, :available, :paid, :expired, :canceled]

  def create_invoice_users
    bill.bill_users.each do |bill_user|
      create_invoice_user_by_bill_user bill_user
    end
  end

  def update_invoice_users
    bill.bill_users.where('percent is not null').each do |bill_user|
      invoice_user = invoice_users.where(user_id: bill_user.user_id).first

      return create_invoice_user_by_bill_user(bill_user) if invoice_user.nil?

      update_invoice_user(invoice_user, bill_user)
    end
  end

  def create_invoice_user_by_bill_user(bill_user)
    invoice_users.create(
      amount: bill_user.amount,
      expires_at: expires_at,
      user: bill_user.user,
      bill_user: bill_user,
      status: :available
    )
  end

  def update_invoice_user(invoice_user, bill_user)
    invoice_user.update(
      amount: bill_user.amount,
      expires_at: expires_at,
      status: status
    )
  end

  def update_status_if_everyone_paid
    update status: :paid unless invoice_users.where.not(status: :paid).exists?
  end
end

