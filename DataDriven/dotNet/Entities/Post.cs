using Microsoft.EntityFrameworkCore;
using System.ComponentModel;
using System.ComponentModel.DataAnnotations;

namespace dotNet.Entities;

[Index(nameof(Slug), IsUnique = true)]
class Post
{
    [Key]
    public int Id { get; set; }

    [Required]
    public string Title { get; set; }

    [Required]
    public string Slug { get; set; }

    [Required]
    public string Content { get; set; }

    [Required]
    public DateTime LastUpdated { get; set; }

    [DefaultValue(PostStatus.Published)]
    public PostStatus PostStatus { get; set; }

    public Category[]? Categories { get; set; }

    public Author[]? Authors { get; set; }
}

public enum PostStatus
{
    Published, Draft
}
