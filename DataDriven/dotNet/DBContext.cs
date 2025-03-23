using Microsoft.EntityFrameworkCore;
using dotNet.Entities;

namespace dotNet;

public class AppDbContext : DbContext
{
    public AppDbContext(DbContextOptions<AppDbContext> options) : base(options)
    {
    }

    public DbSet<Category> Categories { get; set; }
    public DbSet<Comment> Comments { get; set; }
    public DbSet<Post> Posts { get; set; }
    public DbSet<Author> Authors { get; set; }


    protected override void OnModelCreating(ModelBuilder modelBuilder)
    {
        base.OnModelCreating(modelBuilder);

        modelBuilder.Entity<Category>()
            .HasMany(c => c.Posts)
            .WithMany(p => p.Categories)
            .UsingEntity(j => j.ToTable("CategoryPosts"));

        modelBuilder.Entity<Author>()
            .HasMany(a => a.Posts)
            .WithMany(p => p.Authors)
            .UsingEntity(j => j.ToTable("AuthorPosts"));

        modelBuilder.Entity<Comment>()
            .HasOne(c => c.Post)
            .WithMany(p => p.Comments)
            .HasForeignKey("PostId");
    }

}