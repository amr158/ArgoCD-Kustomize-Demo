var builder = WebApplication.CreateBuilder(args);
builder.Services.AddCors();
builder.Services.AddControllers();
var app = builder.Build();

app.UseCors(x => x.AllowAnyMethod()
.AllowAnyHeader()
.SetIsOriginAllowed(origin => true) // allow any origin
.AllowCredentials()); // allow credentials



app.MapGet("/", () => "Hello From Integrant Version: 0.0.0");
// app.MapGet("/", () => "Hello From Integrant Version: 0.0.1");

app.Run();
