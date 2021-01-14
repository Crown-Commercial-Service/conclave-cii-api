module Common
  class GenerateId
    def self.ccs_org_id
      "#{SecureRandom.random_number(1000000000000)}#{rand(Time.now.to_i)}".slice(0..8)
    end
  end
end

