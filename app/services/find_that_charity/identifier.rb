module FindThatCharity
  class Identifier
    def initialize(scheme_id, result)
      super()
      @scheme_id = scheme_id
      @result = result
    end

    def build_response
      {
        scheme: @scheme_id,
        id: id,
        legalName: legal_name,
        uri: uri
      }
    end

    def id
      exists_or_null(@result['charityNumber'])
    end

    def legal_name
      exists_or_null(@result['name'])
    end

    #def uri

      #exists_or_null(@result['links'][2]['url'])

      #@result['links'].each do |link|
        #@matchedLink = exists_or_null(link['url']) if link['url'].include? "https://register-of-charities.charitycommission.gov.uk/"
        #@matchedLink = exists_or_null(link['url']) if link['url'].include? "https://www.oscr.org.uk/"
        #@matchedLink = exists_or_null(link['url']) if link['url'].include? "https://www.charitycommissionni.org.uk/"

        #if @result['id'].include? 'CHC'
          #puts "a"
          #@matchedLink = exists_or_null(link['url']) if link['url'].include? "https://register-of-charities.charitycommission.gov.uk/"
        #elsif @result['id'].include? 'SC'
          #puts "b"
          #@matchedLink = exists_or_null(link['url']) if link['url'].include? "https://www.oscr.org.uk/"
        #elsif @result['id'].include? 'NIC'
          #puts "c"
          #@matchedLink = exists_or_null(link['url']) if link['url'].include? "https://www.charitycommissionni.org.uk/"
        #end
        
        #case @result['id']
        #when @result['id'].include? "CHC"
        #  puts "a"
        #when @result['id'].include? "SC"
        #  puts "b"
        #when @result['id'].include? "NIC"
        #  puts "c"
        #else
        #  "I have no idea what to do with that."
        #end
        
      #end
      #exists_or_null(@matchedLink)
    #end

    def uri
      #puts "[hereee]-- #{exists_or_null(@result['links'][2]['url'])}"
      #exists_or_null(@result['links'][2]['url'])
      @result['links'].each do |link|
        @matchedLink = link['url'] if link['url'].include? "https://register-of-charities.charitycommission.gov.uk"
        @matchedLink = link['url'] if link['url'].include? "https://www.oscr.org.uk"
        @matchedLink = link['url'] if link['url'].include? "https://www.charitycommissionni.org.uk"
      end
      puts "66667-- #{@matchedLink}"
      exists_or_null(@matchedLink)
    end

    private

    def exists_or_null(api_param)
      api_param.present? ? api_param : ''
    end
  end
end
