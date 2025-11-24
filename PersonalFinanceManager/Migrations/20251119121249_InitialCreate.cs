using System;
using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace PersonalFinanceManager.Migrations
{
    /// <inheritdoc />
    public partial class InitialCreate : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.CreateTable(
                name: "Budget",
                columns: table => new
                {
                    Id = table.Column<int>(type: "INTEGER", nullable: false)
                        .Annotation("Sqlite:Autoincrement", true),
                    Category = table.Column<string>(type: "TEXT", maxLength: 100, nullable: false),
                    MonthlyLimit = table.Column<decimal>(type: "DECIMAL(18,2)", nullable: false),
                    CreatedAt = table.Column<DateTime>(type: "TEXT", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_Budget", x => x.Id);
                });

            migrationBuilder.CreateTable(
                name: "Transaction",
                columns: table => new
                {
                    Id = table.Column<int>(type: "INTEGER", nullable: false)
                        .Annotation("Sqlite:Autoincrement", true),
                    Date = table.Column<DateTime>(type: "TEXT", nullable: false),
                    Amount = table.Column<decimal>(type: "DECIMAL(18,2)", nullable: false),
                    Category = table.Column<string>(type: "TEXT", maxLength: 100, nullable: false),
                    Description = table.Column<string>(type: "TEXT", maxLength: 500, nullable: false),
                    Type = table.Column<string>(type: "TEXT", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_Transaction", x => x.Id);
                });

            migrationBuilder.CreateIndex(
                name: "IX_Budget_Category",
                table: "Budget",
                column: "Category");

            migrationBuilder.CreateIndex(
                name: "IX_Transaction_Category",
                table: "Transaction",
                column: "Category");

            migrationBuilder.CreateIndex(
                name: "IX_Transaction_Date",
                table: "Transaction",
                column: "Date");

            migrationBuilder.CreateIndex(
                name: "IX_Transaction_Type",
                table: "Transaction",
                column: "Type");
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropTable(
                name: "Budget");

            migrationBuilder.DropTable(
                name: "Transaction");
        }
    }
}
