class DnsRecord < ApplicationRecord
  has_and_belongs_to_many :hostnames
  accepts_nested_attributes_for :hostnames

  validates :ip, presence: true, uniqueness: true
end
