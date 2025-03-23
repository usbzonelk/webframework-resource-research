using Microsoft.AspNetCore.Mvc;
using dotNet.Entities;
using Microsoft.EntityFrameworkCore;

namespace dotNet.Controllers
{
    [ApiController]
    [Route("api/[controller]")]

    public class CatSend
    {
        public string Name;
    }
    public class CategoryController : ControllerBase
    {
        private readonly DbContext _context;

        public CategoryController(DbContext context)
        {
            _context = context;
        }

        [HttpPost("bulk")]
        public async Task<IActionResult> SaveCategories([FromBody] List<CatSend> categories)
        {
            if (categories == null || !categories.Any())
            {
                return BadRequest("No categories provided.");
            }
            List<Category> categoryList = new List<Category>();
            foreach (var category in categories)
            {
                if (string.IsNullOrWhiteSpace(category.Name))
                {
                    return BadRequest("Category name cannot be empty.");
                }

                if (await _context.Set<Category>().AnyAsync(c => c.Name == category.Name))
                {
                    return Conflict($"Category with name '{category.Name}' already exists.");
                }
                categoryList.Add(new Category { Name = category.Name });
            }

            _context.Set<Category>().AddRange(categoryList);
            await _context.SaveChangesAsync();

            return Ok("Categories saved successfully.");
        }
    }
}