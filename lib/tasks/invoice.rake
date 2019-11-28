namespace :invoice do
  task generate: :environment do
    Invoice.where('created_at + ')
  end
end
