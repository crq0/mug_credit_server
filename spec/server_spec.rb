# spec/app_spec.rb
require File.expand_path '../spec_helper.rb', __FILE__

def login
  user = build(:user)
  post "/register?username=#{user.username}&password=password"
  post "/login?username=#{user.username}&password=password"
  JSON.parse(last_response.body)["token"]
end

describe "The Mug Credit Server" do
  it "should not allow accessing the home page" do
    get '/'
    last_response.status.should eq(404)
  end

  it "Should not get balance" do
    get '/balance'
    last_response.body.should eq("{\"error\":\"Token needed\"}")
    last_response.status.should eq(500)
  end

  it "should regsiter a user" do
    user = build(:user)

    post "/register?username=#{user.username}&password=password"
    last_response.should be_ok
    User.all.last.username.should eq(user.username)
  end

  it "should complain about a taken username" do
    user = build(:user)

    2.times { post "/register?#{user.username}&password=password" }
    expect(last_response.status).to eq(500)
  end


  it "should login a user" do
    post "/register?username=shouldlogin&password=abc123"
    post "/login?username=shouldlogin&password=abc123"
    last_response.should be_ok
    JSON.parse(last_response.body)["token"].should_not eq(nil)
  end

  it "should get a balance" do
    get "/balance?token=#{login}"
    expect(last_response.status).to eq(200)
  end
end


# Unit tests
describe "The Crypto functions" do
  it "should encrypt a password" do
    User.hash_password("abc123", "salt").should eq("7668ddf038bd73f6fd03dbf070f07e23addd1d95")
  end

  it "should generate and save a token" do
    u = create(:user)
    t = Time.now
    User.generate_token(u, t)
    User.all.last.token.should eq((Digest::SHA2.new << (u.username + t.to_s)).to_s)
  end

  it "should generate random data" do
    first = get_rand
    second = get_rand
    first.should_not eq(second)
    expect(first.length).to be > 0
    expect(second.length).to be > 0
  end
end

# Model tests
describe "The User model" do
  it "should not save a blank user" do
    User.new.save.should eq(false)
  end

  it "should save a valid user" do
    User.create()
  end
end
