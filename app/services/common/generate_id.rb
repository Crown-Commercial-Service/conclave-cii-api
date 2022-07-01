module Common
  class GenerateId
    def self.ccs_org_id
      "#{rand(10000..99999)}#{(Time.now.to_f.round(3) * 1000).to_i}"
    end

    def self.api_key
      SecureRandom.hex(40)
    end
  end
end
