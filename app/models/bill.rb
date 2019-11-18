class Bill < ApplicationRecord
  acts_as_paranoid

  EVENTS = [:created, :update_details, :update_users, :user_accepted, :user_rejected, :deleted]

  enum frequency_type: [:day, :week, :month, :year]

  belongs_to :user
  belongs_to :bill_category, optional: true
  has_many :bill_events
  has_many :bill_users
  has_many :invoices

  validates_presence_of :amount, :frequency, :frequency_type, :name

  validate_enum_attributes :frequency_type

  after_create :add_owner_user_to_bill
  after_create :create_invoice
  after_update :update_amount_on_bill_users
  after_update :update_or_create_invoice
  before_destroy :cancel_next_invoice

  def add_event(event, user)
    message = "O usuário #{user.name}"
    case event
    when :created
      message = "#{message} criou uma conta"
    when :update_details
      message = "#{message} atualizou a conta"
    when :update_users
      message = "#{message} atualizou os usuários da conta"
    when :user_accepted
      message = "#{message} aceitou a conta"
    when :user_rejected
      message = "#{message} rejeitou a conta"
    else
      message = "#{message} atualizou a conta"
    end

    bill_events.create(kind: :event, message: message, user: user, info: { event: event })
  end

  def add_owner_user_to_bill
    bill_users.create(user_id: user.id, percent: 100, status: :active)
  end

  def create_invoice
    status = pending_users? ? :pending : :available
    invoices.create(amount: amount, expires_at: date_to_next_invoice, number: invoices.count, status: status)
  end

  def update_or_create_invoice
    last_invoice = invoices.order(created_at: :desc).first

    return create_invoice if last_invoice.nil? || last_invoice.paid?

    last_invoice.update amount: amount, expires_at: expires_at
  end

  def cancel_next_invoice
    last_invoice = invoices.order(created_at: :desc).first

    return if last_invoice.nil? || last_invoice.paid?

    last_invoice.update status: :canceled
  end

  def last_invoice
    invoices.order(created_at: :desc).first
  end

  def date_to_next_invoice
    last_invoice = invoices.last
    last_date = last_invoice ? last_invoice.expires_at : DateTime.now
    last_date + frequency.send(frequency_type)
  end


  def update_users(users)
    total_percent = users.map { |user| user["percent"] }.sum

    return errors.add(:percent, 'As somas das porcentagens devem ser igual a 100') if total_percent != 100

    ActiveRecord::Base.transaction do

      remove_users(users)

      users.each_with_index do |user, index|
        update_user(user, index)
      end

      attribute_leftovers_to_owner

      update_or_create_invoice

      raise ActiveRecord::Rollback if errors.any?

    end
  end

  def active_all_users
    bill_users.reload.each do |bill_user|
      bill_user.update status: :active
    end

    last_invoice = self.last_invoice
    last_invoice.update_invoice_users if last_invoice && last_invoice.available?
  end

  def pending_users?
    pending_users.exists?
  end

  def pending_users
    bill_users.where(status: :pending)
  end

  def new_users
    bill_users.where('percent is null')
  end

  def old_users
    bill_users.where('percent is not null')
  end

  def remove_next_state_users
    bill_users.each do |bill_user|
      unless bill_user.percent.present?
        bill_user.delete
        next
      end

      bill_user.update status: :active, next_percent: nil
    end

    attribute_leftovers_to_owner
  end

  def attribute_leftovers_to_owner
    total_percent = bill_users.reload.map(&:percent).reject(&:nil?).sum

    puts total_percent

    leftovers_percent = 100 - total_percent

    return if leftovers_percent <= 0

    owner = owner_user_in_bill_users

    owner.update percent: owner.percent + leftovers_percent
  end

  def owner_user_in_bill_users
    bill_users.find_by(user_id: self.user_id)
  end

  private

  def update_user(user, index = 0)

    bill_user = bill_users.where(user_id: user["id"]).first || BillUser.new(bill_id: self.id, user_id: user["id"])

    bill_user.next_percent = user["percent"]

    bill_user.status = bill_user.user_id == self.user_id ? :waiting_others : :pending

    bill_user.save

    errors.add("user-#{index}", bill_user.errors) if bill_user.errors.any?
  end

  def remove_users(users)
    actual_users_ids = bill_users.pluck(:user_id)

    new_ids = users.map { |user| user["id"] }

    removed_ids = actual_users_ids.reject { |user_id| new_ids.include? user_id }

    bill_users.where(user_id: removed_ids).destroy_all if removed_ids.any?
  end

  def update_amount_on_bill_users
    bill_users.each do |bill_user|
      bill_user.update_amount_by_percent
      bill_user.save
    end
    last_invoice.update_invoice_users
  end

end
