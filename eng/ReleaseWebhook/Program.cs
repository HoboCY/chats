using Amazon.S3;
using Microsoft.Extensions.Options;
using Octokit;
using ProductHeaderValue = Octokit.ProductHeaderValue;

WebApplicationBuilder builder = WebApplication.CreateBuilder(args);

// 1. �������ļ��а����ǵ����ý�
builder.Services.Configure<GitHubSettings>(builder.Configuration.GetSection("GitHub"));
builder.Services.Configure<MinioSettings>(builder.Configuration.GetSection("Minio"));

// 2. ��� MVC Controller ֧��
builder.Services.AddControllers();

// 3. ע�� Octokit GitHubClient��ʹ�����õ�Token��
builder.Services.AddSingleton(provider =>
{
    GitHubSettings gh = provider.GetRequiredService<IOptions<GitHubSettings>>().Value;
    GitHubClient client = new(new ProductHeaderValue("Sdcb-Chats-Sync"))
    {
        Credentials = new Credentials(gh.Token)
    };
    return client;
});

// 4. ע�� AWS S3 / MinIO Client
builder.Services.AddSingleton(provider =>
{
    MinioSettings minio = provider.GetRequiredService<IOptions<MinioSettings>>().Value;
    AmazonS3Config s3Config = new()
    {
        ServiceURL = minio.Endpoint,
        ForcePathStyle = true, // MinIO ͨ����Ҫʹ�� PathStyle
        RequestChecksumCalculation = Amazon.Runtime.RequestChecksumCalculation.WHEN_REQUIRED,
    };
    return (IAmazonS3)new AmazonS3Client(minio.AccessKey, minio.SecretKey, s3Config);
});

// 5. ע�� HttpClient ����
builder.Services.AddHttpClient();

WebApplication app = builder.Build();

// ʹ��·������Ȩ�м����ע�⣬������Ҫ��� HTTPS����̬�ļ����м���ȣ�
app.UseRouting();
app.UseAuthorization();
app.MapControllers();

app.Run();