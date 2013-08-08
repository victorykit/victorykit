require 'spec_helper'

describe AppSettings do

  let(:instance) { AppSettings.instance }

  context "as a singleton" do
    context "won't create a new instance" do
      before  { AppSettings.create }
      specify { expect { AppSettings.create }.to raise_error }
    end

    it "creates an instance as necessary" do
      expect(AppSettings.count).to eq(0)
      AppSettings.instance
      expect(AppSettings.count).to eq(1)
    end
  end

  context "retrieving items from the singleton" do
    context "creates an instance if none exists, and returns nil" do
      specify { expect(AppSettings["foo"]).to be_nil }
    end

    context "retrieves the underlying value if it exists" do
      before  { instance.data["foo"] = "bar"; instance.save }
      specify { expect(AppSettings["foo"]).to eq("bar") }
    end
  end

  context "setting items in the singleton" do
    context "creates an instance if none exists, and returns the setting" do
      before  { AppSettings["foo"] = "bar" }
      specify { expect(instance.data["foo"]).to eq("bar") }
    end
  end

end
