using System.ComponentModel.DataAnnotations;
using Microsoft.EntityFrameworkCore;
namespace dotNet.Entities;

[Index(nameof(Name), IsUnique = true)]
class Category
{

    [Key]
    public int Id { get; set; }

    [Required]
    public string Name { get; set; }
}
