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

  defimpl Jason.Encoder, for: App.Blog.Category do
    @impl Jason.Encoder
    def encode(%App.Blog.Author{id: id, name: name}, opts) do
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
    @impl Jason.Encoder
    def encode_authors(authors) do
      if(is_list(authors)) do
        Enum.map(authors, fn author ->
          case Jason.encode(author) do
            {:ok, json} -> json
            # If there's an error encoding an author, return null
            {:error, _reason} -> nil
          end
        end)
      else
        nil
      end
    end

    def encode_categories(categories) do
      if(is_list(categories)) do
        Enum.map(categories, fn categories ->
          case Jason.encode(categories) do
            {:ok, json} -> json
            # If there's an error encoding an author, return null
            {:error, _reason} -> nil
          end
        end)
      else
        nil
      end
    end

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
          "authors" => encode_authors(authors),
          "categories" => encode_categories(categories)
        }
        |> Map.drop(
          ["authors", "categories"]
          |> Enum.filter(&is_nil(Map.get(%{authors: authors, categories: categories}, &1)))
        ),
        opts
      )
    end
  end
end
