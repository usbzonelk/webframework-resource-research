defmodule AppWeb.Jason.Encoder do
  defimpl Jason.Encoder, for: App.Blog.Author do
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

  defimpl Jason.Encoder, for: App.Blog.Comment do
    def encode_component(entity) do
      if(is_list(entity)) do
        Enum.map(entity, fn entity ->
          case Jason.encode(entity) do
            {:ok, json} -> json
            {:error, _reason} -> nil
          end
        end)
      else
        nil
      end
    end

    @impl Jason.Encoder
    def encode(
          %App.Blog.Comment{
            id: id,
            authorName: authorName,
            content: content,
            post: post,
            lastUpdated: lastUpdated
          },
          opts
        ) do
      Jason.Encode.map(
        %{
          "id" => id,
          "authorName" => authorName,
          "content" => content,
          "post" => encode_component(post),
          "lastUpdated" => lastUpdated
        },
        opts
      )
    end
  end

  defimpl Jason.Encoder, for: App.Blog.Category do
    @impl Jason.Encoder

    def encode(%App.Blog.Category{id: id, name: name}, opts) do
      Jason.Encode.map(
        %{
          "id" => id,
          "name" => name
        },
        opts
      )
    end
  end

  defimpl Jason.Encoder, for: App.Blog.Post do
    def encode_component(entity) do
      if(is_list(entity)) do
        Enum.map(entity, fn entity ->
          IO.inspect(entity)

          case Jason.encode(entity) do
            {:ok, json} -> json
            {:error, _reason} -> nil
          end
        end)
      else
        nil
      end
    end

    @impl Jason.Encoder
    def encode(
          %App.Blog.Post{
            id: id,
            title: title,
            slug: slug,
            content: content,
            postStatus: postStatus,
            lastUpdated: lastUpdated,
            authors: authors,
            categories: categories
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
          "authors" => authors
        }
        |> IO.inspect(),
        opts
      )
    end
  end
end
