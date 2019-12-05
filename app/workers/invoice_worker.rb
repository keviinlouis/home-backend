class InvoiceWorker
  include Sidekiq::Worker

  def perform(data)
    bill = Bill.find data["bill_id"]
    bill.create_invoice
  end

  def self.cancel!(jid)
    scheduler = Sidekiq::ScheduledSet.new

    job = scheduler.find_job(jid)

    return if job.blank?

    job.delete
  end
end
