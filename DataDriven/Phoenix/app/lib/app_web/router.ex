defmodule AppWeb.Router do
  use AppWeb, :router

  pipeline :api do
    plug :accepts, ["json"]
    get "/posts", AppWeb.PostController, :get
    get "/posts/popular", AppWeb.PostController, :popular_posts
    get "/posts/search", AppWeb.PostController, :search
    get "/posts/sort-by-date", AppWeb.PostController, :sort_by_date
    post "/posts/create", AppWeb.PostController, :create
    put "/posts/status-update", AppWeb.PostController, :bulk_status_update
    put "/posts/edit", AppWeb.PostController, :edit

    post "/authors/get-posts", AppWeb.AuthorController, :get_posts

    post "/comments/create-bulk", AppWeb.CommentController, :create_bulk
    post "/comments/delete-bulk", AppWeb.CommentController, :delete_bulk
  end

  scope "/api", AppWeb do
    pipe_through :api
  end

  # Enable LiveDashboard and Swoosh mailbox preview in development
  if Application.compile_env(:app, :dev_routes) do
    import Phoenix.LiveDashboard.Router

    scope "/dev" do
      pipe_through [:fetch_session, :protect_from_forgery]
      live_dashboard "/dashboard", metrics: AppWeb.Telemetry
      forward "/mailbox", Plug.Swoosh.MailboxPreview
    end
  end
end
