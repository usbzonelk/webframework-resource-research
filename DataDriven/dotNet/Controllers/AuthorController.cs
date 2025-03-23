using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using dotNet;
using dotNet.Entities;

namespace dotNet.Controllers
{
    [ApiController]
    [Route("authors")]

    public class AuthSend
    {
        public string Name;
        public string Email;
    }
    public class AuthorController : ControllerBase
    {
        private readonly AppDbContext _context;

        public AuthorController(AppDbContext context)
        {
            _context = context;
        }

        [HttpPost("get-posts")]
        public async Task<IActionResult> GetPosts([FromBody] RequestModel request)
        {
            if (request == null || request.Emails == null || request.Emails.Count == 0)
            {
                return BadRequest(new { error = "Invalid request payload." });
            }

            var authors = await _context.Authors
                .Where(a => request.Emails.Contains(a.Email))
                .ToListAsync();

            if (authors.Count == 0)
            {
                return Ok(new { result = "No authors found." });
            }

            var authorIDs = authors.Select(a => a.Id).ToList();

            var posts = await _context.Posts
                .Include(p => p.Authors)
                .Where(p => p.Authors.Any(ap => authorIDs.Contains(ap.Id)))
                .ToListAsync();

            if (posts.Count == 0)
            {
                return Ok(new { result = "No posts found." });
            }

            return Ok(new { result = posts });
        }

        public class RequestModel
        {
            public List<string> Emails { get; set; }
        }

        [HttpPost("save-authors")]
        public async Task<IActionResult> SaveAuthors([FromBody] List<AuthSend> authors)
        {
            if (authors == null || authors.Count == 0)
            {
                return BadRequest(new { error = "Invalid request payload." });
            }
            List<Author> authLists = new();
            foreach (var author in authors)
            {
                if (string.IsNullOrWhiteSpace(author.Email) || string.IsNullOrWhiteSpace(author.Name))
                {
                    return BadRequest(new { error = "Each author must have a valid Email and Name." });
                }

                if (await _context.Authors.AnyAsync(a => a.Email == author.Email))
                {
                    return Conflict(new { error = $"Author with email {author.Email} already exists." });
                }
                authLists.Add(new Author { Name = author.Name, Email = author.Email });
            }

            await _context.Authors.AddRangeAsync(authLists);
            await _context.SaveChangesAsync();

            return Ok(new { result = "Authors saved successfully." });
        }
    }
}