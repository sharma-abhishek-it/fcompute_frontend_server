require 'rails_helper'

RSpec.describe FDataFetcher, type: :worker do
  describe "worker execution and impact on db" do
    include_context "fdata_setup"

    before :each do
      create_fdata_files
      ENV['FDATA_DIR'] = test_dir
    end
    after :each do
      destroy_fdata_files
    end

    it "adds correct no of sectors to db" do
      expect{FDataFetcher.new.perform}.to change{Sector.count}.from(0).to(2)
    end

    it "adds correct no of products to db" do
      expect{FDataFetcher.new.perform}.to change{Product.count}.from(0).to(3)
    end

    it "makes the right associations between sector and products to db" do
      FDataFetcher.new.perform

      s1 = Sector.find_by_name("Sector1")
      s2 = Sector.find_by_name("Sector2")

      p1 = Product.find_by_name("Product1")
      p2 = Product.find_by_name("Product2")
      p3 = Product.find_by_name("Product3")

      expect(p1.sector).to eql s1
      expect(p2.sector).to eql s1
      expect(p3.sector).to eql s2
    end

    it "gets the right data for products to db" do
      FDataFetcher.new.perform
      p2 = Product.find_by_name("Product2")
      expect(p2.data).to eql("[390.0, 370.0, 370.0, 370.0, 370.0, 380.0, 400.0]")
    end

    it "does not add sectors to db for same sectors and products" do
      FDataFetcher.new.perform
      create_fdata_files

      expect{FDataFetcher.new.perform}.to_not change{Sector.count}
    end

    it "does not add products to db for same sectors and products" do
      FDataFetcher.new.perform
      create_fdata_files

      expect{FDataFetcher.new.perform}.to_not change{Product.count}
    end
  end

  describe "worker execution and impact on cache" do
    include_context "fdata_setup"

    before :each do
      create_fdata_files
      ENV['FDATA_DIR'] = test_dir
      @redis = Redis.new(:url => "redis://#{ENV['REDIS_HOST']}:#{ENV['REDIS_PORT']}/#{ENV['REDIS_DB']}")
      @redis.flushdb
    end
    after :each do
      destroy_fdata_files
    end

    it "adds correct no of sectors to cache" do
      expect{FDataFetcher.new.perform}.to change{@redis.scard("all_sectors")}.from(0).to(2)
    end

    it "adds correct no of products for Sector1 to cache" do
      expect{FDataFetcher.new.perform}.to change{@redis.scard("Sector1:Products")}.from(0).to(2)
    end

    it "adds correct no of products for Sector1 to cache" do
      expect{FDataFetcher.new.perform}.to change{@redis.scard("Sector2:Products")}.from(0).to(1)
    end

    it "sets correct value for particular product key" do
      FDataFetcher.new.perform
      value = @redis.hmget("Sector1:Product2", "name", "data")
      expected = ["Product2", "[390.0, 370.0, 370.0, 370.0, 370.0, 380.0, 400.0]"]

      expect(value).to eql expected
    end

    it "does not add sectors to cache for same sectors and products" do
      FDataFetcher.new.perform
      create_fdata_files

      expect{FDataFetcher.new.perform}.to_not change{@redis.scard("all_sectors")}
    end

    it "does not add products to cache for same sectors and products" do
      FDataFetcher.new.perform
      create_fdata_files

      expect{FDataFetcher.new.perform}.to_not change{@redis.scard("Sector1:Products")}
    end

  end
end
