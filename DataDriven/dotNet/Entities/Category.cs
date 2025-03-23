using System.ComponentModel.DataAnnotations;
using Microsoft.EntityFrameworkCore;
namespace dotNet.Entities;

[Index(nameof(Name), IsUnique = true)]
public class Category
{

    [Key]
    public int Id { get; set; }

    [Required]
    public string Name { get; set; }

    public virtual ICollection<Post> Posts { get; set; } = new HashSet<Post>();
}
