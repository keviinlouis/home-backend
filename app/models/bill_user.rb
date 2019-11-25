class BillUser < ApplicationRecord
  belongs_to :user
  belongs_to :bill
  has_many :invoice_users
  has_one :last_invoice, -> { order(created_at: :desc) }, class_name: 'InvoiceUser'

  enum status: [:pending, :waiting_others, :active]

  validates :percent, presence: true, unless: :next_percent?

  before_save :check_next_percent, if: :status_changed?
  before_save :update_amount, if: :percent_changed?
  before_save :update_next_amount, if: :next_percent_changed?

  before_destroy :handle_invoice_users

  scope :without_percent, -> { where('percent is null') }
  scope :with_percent, -> { where('percent is not null') }

  def update_amount
    return if percent.nil? || status == :pending

    self.amount = bill.amount * (percent / 100)
  end

  def update_next_amount
    return if next_percent.nil?

    self.next_amount = bill.amount * (next_percent / 100)
  end

  def check_next_percent
    return unless self.next_percent.present? && active?

    self.percent = self.next_percent
    self.next_percent = nil
    self.next_amount = nil
  end

  def handle_invoice_users
    invoice_users.where(status: [:available, :pending]).destroy_all
    invoice_users.update_all bill_user_id: nil
  end
end
