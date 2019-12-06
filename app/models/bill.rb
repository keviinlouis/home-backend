class Bill < ApplicationRecord
  acts_as_paranoid

  EVENTS = [:created, :update_details, :update_users, :user_accepted, :user_refused, :deleted]

  enum frequency_type: [:day, :week, :month, :year]

  belongs_to :user
  belongs_to :bill_category, optional: true
  has_many :bill_events
  has_many :bill_users
  has_many :invoices

  validates_presence_of :amount, :name
  validates_presence_of :frequency_type, if: :frequency?
  validates_presence_of :frequency, if: :frequency_type?
  validates :expires_at, in_future: true

  validate_enum_attributes :frequency_type

  after_create :add_owner_user_to_bill
  after_create :create_invoice

  after_update :update_amount_on_bill_users
  after_update :update_or_create_invoice
  after_update :update_invoice_worker, if: :timestamps_changed?

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
    when :user_refused
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
    invoices.create(amount: amount, number: invoices.count, status: status)
    schedule_next_invoice
  end

  def update_or_create_invoice
    last_invoice = invoices.order(created_at: :desc).first

    return create_invoice if last_invoice.nil? || last_invoice.paid?

    last_invoice.update amount: amount, expires_at: expires_at
  end

  def schedule_next_invoice
    return unless repeats?
    update_column :next_invoice_jid, InvoiceWorker.perform_at(created_at + (frequency.send(frequency_type) * invoices.size), bill_id: id)
  end

  def cancel_invoice_worker
    return if next_invoice_jid.blank?
    InvoiceWorker.cancel!(next_invoice_jid)
    update_column :next_invoice_jid, nil
  end

  def update_invoice_worker
    cancel_invoice_worker
    schedule_next_invoice
  end

  def cancel_next_invoice
    return if last_invoice.nil? || last_invoice.paid?

    last_invoice.update status: :canceled
    cancel_invoice_worker
  end

  def last_invoice
    @last_invoice ||= invoices.order(created_at: :desc).first
  end

  def update_users(users)
    users = users.map { |t| t.transform_keys(&:to_sym) }

    total_percent = users.map { |user| user[:percent].to_f }.sum

    return errors.add(:percent, 'As somas das porcentagens devem ser igual a 100') if total_percent != 100

    ActiveRecord::Base.transaction do

      remove_users(users)

      users.each_with_index do |user, index|
        update_user(user, index)
      end

      raise ActiveRecord::Rollback if errors.any?

      attribute_leftovers_to_owner(in_next_percent: true)

      active_all_users if bill_users.count == 1
    end
  end

  def active_all_users
    bill_users.reload.each { |bill_user| bill_user.update status: :active }

    last_invoice.update_invoice_users if last_invoice&.available?
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

  def pending_users?
    pending_users.exists?
  end

  def pending_users
    bill_users.where(status: :pending)
  end

  def new_users
    bill_users.without_percent
  end

  def old_users
    bill_users.with_percent
  end

  def repeats?
    frequency? && frequency_type?
  end

  def attribute_leftovers_to_owner(options = {})
    percents = if options[:in_next_percent]
                 bill_users.reload.map(&:next_percent).reject(&:nil?)
               else
                 bill_users.reload.map(&:percent).reject(&:nil?)
               end
    total_percent = percents.sum

    leftovers_percent = 100 - total_percent

    return if leftovers_percent <= 0

    owner = owner_user_in_bill_users

    owner.update percent: owner.percent + leftovers_percent if options[:in_next_percent]
    owner.update next_percent: owner.next_percent + leftovers_percent if options[:in_next_percent]
  end

  def owner_user_in_bill_users
    bill_users.find_by(user_id: self.user_id)
  end

  private

  def update_user(user, index = 0)
    bill_user = bill_users.where(user_id: user[:id]).first || BillUser.new(bill_id: self.id, user_id: user[:id])

    bill_user.next_percent = user[:percent].to_f

    bill_user.status = bill_user.user_id == self.user_id ? :waiting_others : :pending

    bill_user.save

    errors.add("user-#{index}", bill_user.errors) if bill_user.errors.any?
  end

  def remove_users(users)
    actual_users_ids = bill_users.pluck(:user_id)

    new_ids = users.map { |user| user[:id] }

    removed_ids = actual_users_ids.reject { |user_id| new_ids.include? user_id }

    bill_users.where(user_id: removed_ids).destroy_all if removed_ids.any?
  end

  def update_amount_on_bill_users
    bill_users.each do |bill_user|
      bill_user.update_amount
      bill_user.save
    end
    last_invoice.update_invoice_users
  end

  def timestamps_changed?
    timestamps = %w(frequency frequency_type expires_at)

    timestamps.any? { |attribute| saved_changes[attribute].present? }
  end

end
