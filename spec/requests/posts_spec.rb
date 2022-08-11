require 'rails_helper'

RSpec.describe "Posts", type: :request do
  describe "GET /posts" do
    it "return an array of posts" do
      user = User.create!(name: "kat", email: "kat@example.com", password: "password")
      Post.create(title: "post", body: "here's the post", user_id: user.id)
      Post.create(title: "post2", body: "here's the post", user_id: user.id)
      Post.create(title: "post3", body: "here's the post", user_id: user.id)
      Post.first.update(title: "post1")
      Post.second.destroy

      get "/posts.json"
      posts = JSON.parse(response.body)
      post1 = posts[0]
      post2 = posts[1]

      expect(response).to have_http_status(200)
      expect(posts.length).to eq(2)
      expect(post1["title"]).to eq("post1")
      # expect(post1["body"]).to eq("here's the second post")
    end
  end

  describe "GET /recipes/:id" do
    it "return a hash with the appropriate attributes" do
      user = User.create!(name: "Test", email: "test@test.com", password: "password")
      post = Post.create!(user_id: user.id, title: "Test of a Title", body: "This is a test of entering a body")

      post_id = post.id
      get "/posts/#{post_id}"
      post_response = JSON.parse(response.body)

      expect(response).to have_http_status(200)
      expect(post_response["title"]).to eq("Test of a Title")
      expect(post_response["body"]).to eq("This is a test of entering a body")
    end
  end

  describe "POST /posts" do
    it "should create a post" do
      user = User.create!(name: "Test", email: "test@test.com", password: "password")
      jwt = JWT.encode(
        {
          user_id: user.id,
        },
        Rails.application.credentials.fetch(:secret_key_base),
        "HS256"
      )
      post "/posts", params: {
                        title: "New Test of New Title",
                        body: "This is a new test of the body of the post (thanks Chris)",
                      },
                      headers: { "Authorization" => "Bearer #{jwt}"}

      post = JSON.parse(response.body)
      expect(response).to have_http_status(200)
      expect(post["title"]).to include("Test")
    end
  end

  describe "PATCH /posts" do
    it "should update a post" do
      user = User.create!(name: "Test", email: "test@test.com", password: "password")
      jwt = JWT.encode(
        {
          user_id: user.id,
        },
        Rails.application.credentials.fetch(:secret_key_base),
        "HS256"
      )
      post "/posts", params: {
                        title: "New Test of New Title",
                        body: "This is a new test of the body of the post (thanks Chris)",
                      },
                      headers: { "Authorization" => "Bearer #{jwt}"}

      post = Post.find_by(title: "New Test of New Title")

      patch "/posts/#{post.id}", params: { title: "Test Title" },
                        headers: { "Authorization" => "Bearer #{jwt}"}

      post = JSON.parse(response.body)
      expect(response).to have_http_status(200)
      expect(post["title"]).to eq("Test Title")
    end
  end

  describe "PATCH /posts" do
    it "should update a post" do
      user = User.create!(name: "Test", email: "test@test.com", password: "password")
      jwt = JWT.encode(
        {
          user_id: user.id,
        },
        Rails.application.credentials.fetch(:secret_key_base),
        "HS256"
      )
      post "/posts", params: {
                        title: "New Test of New Title",
                        body: "This is a new test of the body of the post (thanks Chris)",
                      },
                      headers: { "Authorization" => "Bearer #{jwt}"}

      post = Post.find_by(title: "New Test of New Title")

      delete "/posts/#{post.id}", headers: { "Authorization" => "Bearer #{jwt}"}

      post = JSON.parse(response.body)
      expect(response).to have_http_status(200)
      expect(post["message"]).to include("destroyed")
    end
  end

  describe "GET /recipes/:id" do
    it "return a hash with the appropriate attributes" do
      user = User.create!(name: "Test", email: "test@test.com", password: "password")
      post = Post.create!(user_id: user.id, title: "Test of a Title", body: "This is a test of entering a body")
      post.update(title: "No Longer is this a Test of a Title")

      post_id = post.id
      get "/posts/#{post_id}"
      post_response = JSON.parse(response.body)

      expect(response).to have_http_status(200)
      expect(post_response["title"]).to eq("No Longer is this a Test of a Title")
      expect(post_response["title"]).to include("Test")
      expect(post_response["body"]).to eq("This is a test of entering a body")
    end
  end

  describe "GET /recipes/:id" do
    it "return an array with 1 post" do
      user = User.create!(name: "Test", email: "test@test.com", password: "password")
      post = Post.create!(user_id: user.id, title: "Test of a Title", body: "This is a test of entering a body")
      post.destroy

      get "/posts.json"
      posts = JSON.parse(response.body)

      expect(response).to have_http_status(200)
      expect(posts.length).to eq(0)
    end
  end
end
