module FIDIUS::RpcModelActions
  class FIDIUS::XmlRpcModel < ActiveRecord::Base
    # this finder is called via association_proxy to find associated model
    # use own relation to use self.find
    def self.construct_finder_arel(options = {}, scope = nil)
      # ar calls this method multiple times so we have to collect all options
      # and store them in a single relation
      if @rel
        @rel.add_options(options)
      else
        @rel = FIDIUS::XMLRpcRelation.new(self,Arel::Table.new("DOES NOT MATTER"),options)
      end
      @rel
    end

    def self.find_by_sql(sql)
      raise "NOT AVAILABLE"
    end

    def self.first
      find(:first)
    end

    def self.last
      find(:last)
    end

    def self.find(*args)
      if self.respond_to?("query_name")
        model_name = self.query_name
      else
        model_name = self.name
      end
      parse_xml call_rpc "model.find",model_name,args.to_json
    end
    
    def self.all(*args)
      res = find(:all, *args)
      return [res] if !res.respond_to?("size")
      res
    end

    def self.available_models
      # find all models in app/models 
      res = []
      p = ["#{Rails.root}/app/models/", "#{Rails.root}/app/models/evasion_db"]
      p.each do |path|
        res << Dir.foreach(path).select do |file|
          !File.directory?(path+file)
        end.map do |filename|
          filename.gsub(".rb","")
        end
      end
      res = res.flatten
      res.delete(".")
      res.delete("..")
      return res
    end

    def save(*args)
      raise "Not Implemented"
    end

    def update(*args)
      raise "Not Implemented"
    end

    def create(*args)
      raise "Not Implemented"
    end

    def delete(*args)
      raise "Not Implemented"
    end

    def destroy(*args)
      raise "Not Implemented"
    end

    # overwrite to trick AssociationCollection.load_target 
    def new_record?
      false
    end
  end
end
