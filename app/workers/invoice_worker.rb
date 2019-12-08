class InvoiceWorker
  include Sidekiq::Worker

  def perform(data)
    data = data.transform_keys(&:to_sym)
    bill = Bill.find_by_id data[:bill_id]
    return if bill.blank?

    bill.create_invoice
  end

  def self.cancel!(jid)
    scheduler = Sidekiq::ScheduledSet.new

    job = scheduler.find_job(jid)

    return if job.blank?

    job.delete
  end
end
