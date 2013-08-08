require 'spec_helper'

describe AppSettings do

  let(:instance) { AppSettings.instance }

  context "as a singleton" do
    context "won't create a new instance" do
      before  { AppSettings.create }
      specify { expect { AppSettings.create }.to raise_error }
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

    context "when items are required but not available" do
      specify { expect { AppSettings.require_keys!("womp") }.to raise_error }
    end

    context "when an item is required and available" do
      before  { instance.data["foo"] = "bar"; instance.save }
      specify { expect(AppSettings.require_keys!("foo")).to eq("bar") }
    end

    context "when multiple items are required and available" do
      before  { instance.data["foo"] = "bar"; instance.data["baz"] = "qux"; instance.save }
      specify { expect(AppSettings.require_keys!("foo", "baz")).to eq(%w{bar qux}) }
    end
  end

  context "setting items in the singleton" do
    context "creates an instance if none exists, and returns the setting" do
      before  { AppSettings["foo"] = "bar" }
      specify { expect(instance.data["foo"]).to eq("bar") }
    end
  end

end
