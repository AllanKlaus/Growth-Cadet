class Hostname < ApplicationRecord
  has_and_belongs_to_many :dns_records

  validates :hostname, presence: true, uniqueness: true
end
