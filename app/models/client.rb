class Client < ApplicationRecord
  validates :name, :description, :api_key, presence: true
  before_validation :client_api_key

  private

  def client_api_key
    self.api_key = Common::GenerateId.api_key.to_s
  end
end
