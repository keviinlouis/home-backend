class BillCategorySerializer < ActiveModel::Serializer
  attributes :id, :name
  belongs_to :user
end
