using System.ComponentModel.DataAnnotations;

namespace dotNet.Entities;

class Comment
{
    [Key]
    public int Id { get; set; }

    [Required]
    public string AuthorName { get; set; }

    [Required]
    public string Content { get; set; }

    [Required]
    public DateTime LastUpdated { get; set; }

    [Required]
    public Post Post { get; set; }

}
