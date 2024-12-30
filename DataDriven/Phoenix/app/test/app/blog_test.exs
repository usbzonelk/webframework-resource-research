defmodule App.BlogTest do
  use App.DataCase

  alias App.Blog

  describe "authors" do
    alias App.Blog.Author

    import App.BlogFixtures

    @invalid_attrs %{id: nil, name: nil, email: nil}

    test "list_authors/0 returns all authors" do
      author = author_fixture()
      assert Blog.list_authors() == [author]
    end

    test "get_author!/1 returns the author with given id" do
      author = author_fixture()
      assert Blog.get_author!(author.id) == author
    end

    test "create_author/1 with valid data creates a author" do
      valid_attrs = %{id: 42, name: "some name", email: "some email"}

      assert {:ok, %Author{} = author} = Blog.create_author(valid_attrs)
      assert author.id == 42
      assert author.name == "some name"
      assert author.email == "some email"
    end

    test "create_author/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Blog.create_author(@invalid_attrs)
    end

    test "update_author/2 with valid data updates the author" do
      author = author_fixture()
      update_attrs = %{id: 43, name: "some updated name", email: "some updated email"}

      assert {:ok, %Author{} = author} = Blog.update_author(author, update_attrs)
      assert author.id == 43
      assert author.name == "some updated name"
      assert author.email == "some updated email"
    end

    test "update_author/2 with invalid data returns error changeset" do
      author = author_fixture()
      assert {:error, %Ecto.Changeset{}} = Blog.update_author(author, @invalid_attrs)
      assert author == Blog.get_author!(author.id)
    end

    test "delete_author/1 deletes the author" do
      author = author_fixture()
      assert {:ok, %Author{}} = Blog.delete_author(author)
      assert_raise Ecto.NoResultsError, fn -> Blog.get_author!(author.id) end
    end

    test "change_author/1 returns a author changeset" do
      author = author_fixture()
      assert %Ecto.Changeset{} = Blog.change_author(author)
    end
  end

  describe "categories" do
    alias App.Blog.Category

    import App.BlogFixtures

    @invalid_attrs %{id: nil, name: nil}

    test "list_categories/0 returns all categories" do
      category = category_fixture()
      assert Blog.list_categories() == [category]
    end

    test "get_category!/1 returns the category with given id" do
      category = category_fixture()
      assert Blog.get_category!(category.id) == category
    end

    test "create_category/1 with valid data creates a category" do
      valid_attrs = %{id: 42, name: "some name"}

      assert {:ok, %Category{} = category} = Blog.create_category(valid_attrs)
      assert category.id == 42
      assert category.name == "some name"
    end

    test "create_category/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Blog.create_category(@invalid_attrs)
    end

    test "update_category/2 with valid data updates the category" do
      category = category_fixture()
      update_attrs = %{id: 43, name: "some updated name"}

      assert {:ok, %Category{} = category} = Blog.update_category(category, update_attrs)
      assert category.id == 43
      assert category.name == "some updated name"
    end

    test "update_category/2 with invalid data returns error changeset" do
      category = category_fixture()
      assert {:error, %Ecto.Changeset{}} = Blog.update_category(category, @invalid_attrs)
      assert category == Blog.get_category!(category.id)
    end

    test "delete_category/1 deletes the category" do
      category = category_fixture()
      assert {:ok, %Category{}} = Blog.delete_category(category)
      assert_raise Ecto.NoResultsError, fn -> Blog.get_category!(category.id) end
    end

    test "change_category/1 returns a category changeset" do
      category = category_fixture()
      assert %Ecto.Changeset{} = Blog.change_category(category)
    end
  end

  describe "posts" do
    alias App.Blog.Post

    import App.BlogFixtures

    @invalid_attrs %{id: nil, title: nil, slug: nil, content: nil, post_status: nil, last_updated: nil}

    test "list_posts/0 returns all posts" do
      post = post_fixture()
      assert Blog.list_posts() == [post]
    end

    test "get_post!/1 returns the post with given id" do
      post = post_fixture()
      assert Blog.get_post!(post.id) == post
    end

    test "create_post/1 with valid data creates a post" do
      valid_attrs = %{id: 42, title: "some title", slug: "some slug", content: "some content", post_status: "some post_status", last_updated: ~N[2024-12-29 06:38:00]}

      assert {:ok, %Post{} = post} = Blog.create_post(valid_attrs)
      assert post.id == 42
      assert post.title == "some title"
      assert post.slug == "some slug"
      assert post.content == "some content"
      assert post.post_status == "some post_status"
      assert post.last_updated == ~N[2024-12-29 06:38:00]
    end

    test "create_post/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Blog.create_post(@invalid_attrs)
    end

    test "update_post/2 with valid data updates the post" do
      post = post_fixture()
      update_attrs = %{id: 43, title: "some updated title", slug: "some updated slug", content: "some updated content", post_status: "some updated post_status", last_updated: ~N[2024-12-30 06:38:00]}

      assert {:ok, %Post{} = post} = Blog.update_post(post, update_attrs)
      assert post.id == 43
      assert post.title == "some updated title"
      assert post.slug == "some updated slug"
      assert post.content == "some updated content"
      assert post.post_status == "some updated post_status"
      assert post.last_updated == ~N[2024-12-30 06:38:00]
    end

    test "update_post/2 with invalid data returns error changeset" do
      post = post_fixture()
      assert {:error, %Ecto.Changeset{}} = Blog.update_post(post, @invalid_attrs)
      assert post == Blog.get_post!(post.id)
    end

    test "delete_post/1 deletes the post" do
      post = post_fixture()
      assert {:ok, %Post{}} = Blog.delete_post(post)
      assert_raise Ecto.NoResultsError, fn -> Blog.get_post!(post.id) end
    end

    test "change_post/1 returns a post changeset" do
      post = post_fixture()
      assert %Ecto.Changeset{} = Blog.change_post(post)
    end
  end

  describe "comments" do
    alias App.Blog.Comment

    import App.BlogFixtures

    @invalid_attrs %{author_name: nil, content: nil, post_id: nil, last_updated: nil}

    test "list_comments/0 returns all comments" do
      comment = comment_fixture()
      assert Blog.list_comments() == [comment]
    end

    test "get_comment!/1 returns the comment with given id" do
      comment = comment_fixture()
      assert Blog.get_comment!(comment.id) == comment
    end

    test "create_comment/1 with valid data creates a comment" do
      valid_attrs = %{author_name: "some author_name", content: "some content", post_id: 42, last_updated: ~N[2024-12-29 06:39:00]}

      assert {:ok, %Comment{} = comment} = Blog.create_comment(valid_attrs)
      assert comment.author_name == "some author_name"
      assert comment.content == "some content"
      assert comment.post_id == 42
      assert comment.last_updated == ~N[2024-12-29 06:39:00]
    end

    test "create_comment/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Blog.create_comment(@invalid_attrs)
    end

    test "update_comment/2 with valid data updates the comment" do
      comment = comment_fixture()
      update_attrs = %{author_name: "some updated author_name", content: "some updated content", post_id: 43, last_updated: ~N[2024-12-30 06:39:00]}

      assert {:ok, %Comment{} = comment} = Blog.update_comment(comment, update_attrs)
      assert comment.author_name == "some updated author_name"
      assert comment.content == "some updated content"
      assert comment.post_id == 43
      assert comment.last_updated == ~N[2024-12-30 06:39:00]
    end

    test "update_comment/2 with invalid data returns error changeset" do
      comment = comment_fixture()
      assert {:error, %Ecto.Changeset{}} = Blog.update_comment(comment, @invalid_attrs)
      assert comment == Blog.get_comment!(comment.id)
    end

    test "delete_comment/1 deletes the comment" do
      comment = comment_fixture()
      assert {:ok, %Comment{}} = Blog.delete_comment(comment)
      assert_raise Ecto.NoResultsError, fn -> Blog.get_comment!(comment.id) end
    end

    test "change_comment/1 returns a comment changeset" do
      comment = comment_fixture()
      assert %Ecto.Changeset{} = Blog.change_comment(comment)
    end
  end
end
