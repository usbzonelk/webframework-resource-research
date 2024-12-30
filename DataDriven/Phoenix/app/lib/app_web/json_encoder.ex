defmodule AppWeb.Jason.Encoder do
  defimpl(Jason.Encoder) do
    @impl Jason.Encoder
    def encode(%App.Blog.Author{id: id, name: name, email: email}, opts) do
      Jason.Encode.map(
        %{
          "id" => id,
          "name" => name,
          "email" => email
        },
        opts
      )
    end
  end

  defimpl(Jason.Encoder) do
    @impl Jason.Encoder
    def encode(
          %App.Blog.Post{
            id: id,
            title: title,
            slug: slug,
            content: content,
            postStatus: postStatus,
            lastUpdated: lastUpdated,
          },
          opts
        ) do
      Jason.Encode.map(
        %{
          "id" => id,
          "title" => title,
          "slug" => slug,
          "content" => content,
          "postStatus" => postStatus,
          "lastUpdated" => lastUpdated,
        },
        opts
      )
    end
  end
end
