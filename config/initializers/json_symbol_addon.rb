##
# IMPORTANT:
# THIS FILE IS COPIED 
# IT IS ALSO AVAILABLE in architecture/lib/misc/json_symbol_addon.rb
#
# maybe candc should load it from there?
#
##
# These changes are necessary to extend json encoding & decoding
# for ruby-symbols. Tricky parts are symbols in Arrays or Hashes.

class Symbol
  # changed. encoded symbols must have : as first character, to identify them
  def as_json(options = nil) ":"+to_s end #:nodoc:
end

class Hash
  def as_json(options = nil) #:nodoc:
    # create a subset of the hash by applying :only or :except
    subset = if options
      if attrs = options[:only]
        slice(*Array.wrap(attrs))
      elsif attrs = options[:except]
        except(*Array.wrap(attrs))
      else
        self
      end
    else
      self
    end

    # use encoder as a proxy to call as_json on all values in the subset, to protect from circular references
    encoder = options && options[:encoder] || ActiveSupport::JSON::Encoding::Encoder.new(options)
    # FIDIUS changed here to from k.to_s to k.as_json to decode strings with : as symbols
    pairs = subset.map { |k, v| [k.as_json, encoder.as_json(v)] }
    result = self.is_a?(ActiveSupport::OrderedHash) ? ActiveSupport::OrderedHash.new : Hash.new
    pairs.inject(result) { |hash, pair| hash[pair.first] = pair.last; hash }
  end
end

class Array
  # [1,":aa",:asa].symbolize_keys_if_needed
  #  => [1, :aa, :asa] 
  def symbolize_keys_if_needed
    self.each_with_index do |e,i|
      e.symbolize_keys_if_needed if e.respond_to?("symbolize_keys_if_needed")
      if self[i].to_s[0] == ":"
        self[i] = e[1..-1].to_sym
      end
    end
  end
end

class Hash
  # {":a"=>1,":b"=>2}.symbolize_keys_if_needed
  # => {:a=>1, :b=>2}
  def symbolize_keys_if_needed
    self.each do |k,v|
      if v.respond_to?("symbolize_keys_if_needed")
        v.symbolize_keys_if_needed
      end
      if k[0] == ":"
        self.delete(k)
        self[k[1..-1].to_sym] = v
      end
    end
  end
end

module ActiveSupport
  module JSON
    class << self
      def decode(json)
        set_default_backend unless defined?(@backend)
        result = @backend.decode(json)
        result.symbolize_keys_if_needed
      end
    end
  end
end
