describe PetitionsController do
  describe "routing" do

    it "routes to #index" do
      get("/petitions").should route_to("petitions#index")
    end

    it "routes to #new" do
      get("/petitions/new").should route_to("petitions#new")
    end

    it "routes to #show" do
      get("/petitions/1").should route_to("petitions#show", :id => "1")
    end

    it "routes to #edit" do
      get("/petitions/1/edit").should route_to("petitions#edit", :id => "1")
    end

    it "routes to #create" do
      post("/petitions").should route_to("petitions#create")
    end

    it "routes to #update" do
      put("/petitions/1").should route_to("petitions#update", :id => "1")
    end

    it "routes to #destroy" do
      delete("/petitions/1").should route_to("petitions#destroy", :id => "1")
    end

  end
end
