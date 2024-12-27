using System.ComponentModel.DataAnnotations;
using Microsoft.EntityFrameworkCore;

[Index(nameof(Email), IsUnique = true)]
class Author
{
    [Key]
    public int Id { get; set; }

    [Required]
    public string Email { get; set; }

    [Required]
    public string Name { get; set; }
}